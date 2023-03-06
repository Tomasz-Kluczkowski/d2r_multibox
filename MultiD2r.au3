#include <AutoItConstants.au3>

$D2R_WINDOW_NAME = $CmdLine[1]

;~ Change title of the window for easier identification and focus it
WinWaitActive("Diablo II: Resurrected", "", 3)
$d2r_window = WinActivate("Diablo II: Resurrected", "")
WinSetTitle($d2r_window,  "", $D2R_WINDOW_NAME)
;~ WinActivate($D2R_WINDOW_NAME, "")

; Get through all the menus - see if holding space is better
Sleep(2500)
Send("{SPACE}")
Sleep(3000)
Send("{SPACE}")
Sleep(25000)
Send("{SPACE}")

;~ Wait for battle net connection
Sleep(14000)

;~ Get game window data
$WinLoc = WinGetPos($d2r_window, "")
$WinXPos = $WinLoc[0]
$WinYPos = $WinLoc[1]
$WinXMid = $WinLoc[2]/2
$WinYMid = $WinLoc[3]/2

$WinXMidPos = $WinXPos + $WinXMid
$WinYMidPos = $WinYPos + $WinYMid

;~ move to the lobby button and click it
MouseMove($WinXMidPos + 100, $WinYMidPos + 200, 5)
MouseClick($MOUSE_CLICK_LEFT)
Sleep(1000)

;~ move to the join game name field and click it
MouseMove($WinXMidPos + 150, $WinYMidPos - 165, 5)
Sleep(1000)
MouseClick($MOUSE_CLICK_LEFT)

;~ Enter game name and password and enter
Send("tomski001")
Send("{TAB}")
Send("tom")
Send("{ENTER}")

;~ ; Minimise window - we should move it to another screen?
WinSetState($d2r_window, "",  @SW_MINIMIZE)

