if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

$configuration = Get-Content -Raw -Path "$PSScriptRoot/.config.json" | ConvertFrom-Json
$d2r_instances_settings = $configuration.d2r_instances_settings
$default_game_name = $configuration.game_session_settings.default_game_name
$default_game_password = $configuration.game_session_settings.default_game_password

$game_name = if ($value = Read-Host -Prompt "Please enter game name [default: $default_game_name]") {$value} else {$default_game_name}
$game_password = if ($value = Read-Host -Prompt "Please enter game password [default: $default_game_password]") {$value} else {$default_game_password}


function GetCpuAffinity {
    param (
        [int[]] $CpuAllocation
    )
    Write-Host "the CpuAllocation is: $CpuAllocation"

    [Int64] $Mask = 0
    $CpuAllocation | ForEach-Object {$Mask += [System.Math]::Pow(2, $_)}
    return [Int64] $Mask
}


$bnet_user_number = 1
ForEach ($d2r_instance_settings in $d2r_instances_settings) {
    $d2r_window_name = "D2R_BN_$($bnet_user_number)"
    $bnet_user_number += 1
    
    # Start instance of D2R
    Start-Process -NoNewWindow -FilePath "$($d2r_instance_settings.d2r_path)" `
    -ArgumentList "-username $($d2r_instance_settings.username) -password $($d2r_instance_settings.password) -address eu.actual.battle.net -nosound" 
    
    if ($d2r_instance_settings.cpu_affinity_enabled) {
        Write-Host "Setting cpu affinity for d2r instance with process ID: $($d2r_process.Id)"
        $cpu_affinity = GetCpuAffinity -CpuAllocation $d2r_instance_settings.cpu_allocation
        $d2r_process.ProcessorAffinity = $cpu_affinity
        Write-Host "Cpu affinity set to: $([System.Convert]::ToString($cpu_affinity, 2))"

        if ($separate_cpu_cores_per_instance) {
            $first_cpu_number += $cpu_cores_per_d2r_instance
        }
    }

    # Kill handle retricting to 1 copy of D2R
    & Start-Process -NoNewWindow powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\D2Rhandle.ps1`""
    
    # Create or join game
    # & Start-Process -NoNewWindow -Wait -FilePath "${env:ProgramFiles(x86)}\AutoIt3\AutoIt3.exe" `
    # -ArgumentList "/AutoIt3ExecuteScript $PSScriptRoot\join_or_create_game.au3 $($d2r_window_name) $($d2r_instance_settings.action) $($game_name) $($game_password)"
}

# debug
Pause