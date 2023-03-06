# Uncomment the line below if you are using this script independently from
# parent script which starts all your D2R instances.
# This is because handle64.exe requires to be run in elevated mode.
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

$DETECTION_TIMEOUT_SECONDS = 5
$DETECTION_PERIOD_SECONDS = 1
$D2R_EXE = "D2R.exe"
$HANDLES_NOT_FOUND_MSG = "No matching handles found."
$CHECK_FOR_OTHER_INSTANCES_HANDLE_MSG = "Check For Other Instances"
$HANDLE64_EXE = "$PSScriptRoot\handle64.exe"

# Detect running instances of D2R.exe and store their handles details.

# To avoid race condition where detection is done too early we loop here until we timeout.
# We need to detect both D2R.exe and the handle responsible for preventing 
# running of multiple instances.
$timeout = New-TimeSpan -Seconds $DETECTION_TIMEOUT_SECONDS
$stopwatch = [System.Diagnostics.StopWatch]::StartNew()
[bool] $check_for_other_instances_handle_detected = $false
do {
    $d2r_handles = & $HANDLE64_EXE -accepteula -a -p $D2R_EXE

    if ($d2r_handles.Contains($HANDLES_NOT_FOUND_MSG) -Or !($d2r_handles -match $CHECK_FOR_OTHER_INSTANCES_HANDLE_MSG)) {
        Write-Host "Handle64.exe did not detect '$($CHECK_FOR_OTHER_INSTANCES_HANDLE_MSG)' D2R handle. Trying again in a bit..."
        Start-Sleep $DETECTION_PERIOD_SECONDS
        continue
    }

    $check_for_other_instances_handle_detected = $true
    Write-Host "Handle64.exe detected '$($CHECK_FOR_OTHER_INSTANCES_HANDLE_MSG)' D2R handle."
    break
} while ($stopwatch.elapsed -lt $timeout)

if (!$check_for_other_instances_handle_detected) {
    Write-Host "No '$($CHECK_FOR_OTHER_INSTANCES_HANDLE_MSG)' D2R handle detected in allocated time. Exiting..."
    exit
}

$current_d2r_process_id = ""
foreach($handle in $d2r_handles) {
    $d2r_process_id = $handle | Select-String -Pattern '^D2R.exe pid\: (?<g1>.+) ' | %{$_.Matches.Groups[1].value}
    if ($d2r_process_id) {
        $current_d2r_process_id = $d2r_process_id
    }

    $d2r_check_for_other_instances_handle_id = $handle | Select-String -Pattern '^(?<g2>.+): Event.*DiabloII Check For Other Instances' | %{$_.Matches.Groups[1].value}

    if ($current_d2r_process_id -And $d2r_check_for_other_instances_handle_id) {
        Write-Host "Handle to close is: $($handle)"
        Write-Host "Closing '$($CHECK_FOR_OTHER_INSTANCES_HANDLE_MSG)' D2R handle id: $($d2r_check_for_other_instances_handle_id) for $($D2R_EXE) process id: $($current_d2r_process_id)"
        & $HANDLE64_EXE -p $current_d2r_process_id -c $d2r_check_for_other_instances_handle_id -y
    }
}
