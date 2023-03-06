#include <AutoItConstants.au3>

$D2R_WINDOW_NAME = "D2R_MAIN"

;~ Change title of the window for easier identification and focus it
WinWaitActive("Diablo II: Resurrected", "", 3)
$d2r_window = WinActivate("Diablo II: Resurrected", "")
WinSetTitle($d2r_window,  "", $D2R_WINDOW_NAME)
;~ WinActivate($D2R_WINDOW_NAME, "")


;~ ; Minimise window - we should move it to another screen?
WinSetState($d2r_window, "",  @SW_MINIMIZE)
Sleep(2500)
 