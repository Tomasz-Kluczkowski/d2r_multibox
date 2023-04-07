if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

$configuration = Get-Content -Raw -Path "$PSScriptRoot/.config.json" | ConvertFrom-Json
$bnet_accounts = $configuration.bnet_accounts
$default_game_name = $configuration.session_details.default_game_name
$default_game_password = $configuration.session_details.default_game_password

$game_name = if ($value = Read-Host -Prompt "Please enter game name [default: $default_game_name]") {$value} else {$default_game_name}
$game_password = if ($value = Read-Host -Prompt "Please enter game password [default: $default_game_password]") {$value} else {$default_game_password}



$bnet_user_number = 1
ForEach ($bnet_account in $bnet_accounts) {
    $d2r_window_name = "D2R_BN_$($bnet_user_number)"
    $bnet_user_number += 1
    
    # Start instance of D2R
    Start-Process -NoNewWindow -FilePath "$($bnet_account.d2r_path)" `
    -ArgumentList "-username $($bnet_account.username) -password $($bnet_account.password) -address eu.actual.battle.net -nosound"
    
    # Kill handle retricting to 1 copy of D2R
    & Start-Process -NoNewWindow powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\D2Rhandle.ps1`""
    
    # Create or join game
    & Start-Process -NoNewWindow -Wait -FilePath "${env:ProgramFiles(x86)}\AutoIt3\AutoIt3.exe" `
    -ArgumentList "/AutoIt3ExecuteScript C:\Users\tomas\GAME_UTILS\d2R_handle\join_or_create_game.au3 $($d2r_window_name) $($bnet_account.action) $($game_name) $($game_password)"
}
