if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

$DEFAULT_GAME_NAME = "tomski001"

$game_name = if ($value = Read-Host -Prompt "Please enter game name [$DEFAULT_GAME_NAME]") {$value} else {$DEFAULT_GAME_NAME}

$json_data = Get-Content -Raw -Path "$PSScriptRoot/.bnet_accounts.json" | ConvertFrom-Json
$bnet_accounts = $json_data.bnet_accounts


$bnet_user_number = 1
ForEach ($bnet_account in $bnet_accounts) {
    $d2r_window_name = "D2R_BN_$($bnet_user_number)"
    $bnet_user_number += 1
    
    # Start instance of D2R
    Start-Process -NoNewWindow -FilePath "$($bnet_account.d2r_path)" -ArgumentList "-username $($bnet_account.username) -password $($bnet_account.password) -address eu.actual.battle.net -nosound"
    
    # Kill handle retricting to 1 copy of D2R
    & Start-Process -NoNewWindow powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\D2Rhandle.ps1`""
    
    # Create or join game
    & Start-Process -NoNewWindow -Wait -FilePath "${env:ProgramFiles(x86)}\AutoIt3\AutoIt3.exe" `
    -ArgumentList "/AutoIt3ExecuteScript C:\Users\tomas\GAME_UTILS\d2R_handle\join_or_create_game.au3 $($d2r_window_name) $($bnet_account.action) $($game_name)"
}
