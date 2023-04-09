if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

$configuration = Get-Content -Raw -Path "$PSScriptRoot/.config.json" | ConvertFrom-Json
$bnet_accounts = $configuration.bnet_accounts
$default_game_name = $configuration.session_details.default_game_name
$default_game_password = $configuration.session_details.default_game_password

$game_name = if ($value = Read-Host -Prompt "Please enter game name [default: $default_game_name]") {$value} else {$default_game_name}
$game_password = if ($value = Read-Host -Prompt "Please enter game password [default: $default_game_password]") {$value} else {$default_game_password}
$cpu_affinity_enabled = $configuration.d2r_instance_settings.cpu_affinity_enabled -eq "true"
$separate_cpu_cores_per_instance = $configuration.d2r_instance_settings.separate_cpu_cores_per_instance -eq "true"
$cpu_cores_per_d2r_instance = $configuration.d2r_instance_settings.cpu_cores_per_d2r_instance

Write-Host "Cpu affinity enabled: $($cpu_affinity_enabled)"
Write-Host "Cpu cores per d2r instance: $($cpu_cores_per_d2r_instance)"

function GetCpuAffinity {
    param (
        [int]$FirstCpuNumber,
        [int]$CpuCoresPerD2rInstance
    )
    [Int64]$Mask = 0
    $CPUList = @($FirstCpuNumber..($FirstCpuNumber + $CpuCoresPerD2rInstance - 1))
    $CPUList | ForEach-Object {$Mask += [System.Math]::Pow(2, $_)}
    return $Mask
}


$first_cpu_number = 0
$bnet_user_number = 1
ForEach ($bnet_account in $bnet_accounts) {
    $d2r_window_name = "D2R_BN_$($bnet_user_number)"
    $bnet_user_number += 1
    
    # Start instance of D2R
    $d2r_process = Start-Process -NoNewWindow -FilePath "$($bnet_account.d2r_path)" -PassThru `
    -ArgumentList "-username $($bnet_account.username) -password $($bnet_account.password) -address eu.actual.battle.net -nosound"

    if ($cpu_affinity_enabled) {
        Write-Host "Setting cpu affinity for d2r instance with process ID: $($d2r_process.Id)"
        $cpu_affinity = GetCpuAffinity -FirstCpuNumber $first_cpu_number -CpuCoresPerD2rInstance $cpu_cores_per_d2r_instance
        $d2r_process.ProcessorAffinity = $cpu_affinity
        Write-Host "Cpu affinity set to: $([System.Convert]::ToString($cpu_affinity, 2))"

        if ($separate_cpu_cores_per_instance) {
            $first_cpu_number += $cpu_cores_per_d2r_instance
        }
    }
    # Kill handle retricting to 1 copy of D2R
    & Start-Process -NoNewWindow powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\D2Rhandle.ps1`""
    
    # Create or join game
    & Start-Process -NoNewWindow -Wait -FilePath "${env:ProgramFiles(x86)}\AutoIt3\AutoIt3.exe" `
    -ArgumentList "/AutoIt3ExecuteScript $PSScriptRoot\join_or_create_game.au3 $($d2r_window_name) $($bnet_account.action) $($game_name) $($game_password)"
}
