#include <AutoItConstants.au3>

;~ Wait for game to fully boot and set its window size to the one set in game options
Sleep(2500)

$CREATE_ACTION = "create"
$JOIN_ACTION = "join"
$DEFAULT_GAME_PASSWORD = "tomkilt"

$D2R_WINDOW_NAME = $CmdLine[1]
$ACTION = $CmdLine[2]
$GAME_NAME = $CmdLine[3]

;~ Change title of the window for easier identification and focus it
WinWaitActive("Diablo II: Resurrected", "", 1)
$d2r_window = WinActivate("Diablo II: Resurrected", "")
WinSetTitle($d2r_window,  "", $D2R_WINDOW_NAME)

;~ Get game window data
$GameWindowData = WinGetPos($d2r_window, "")
$WinXPos = $GameWindowData[0]
$WinYPos = $GameWindowData[1]
$WinWidth=$GameWindowData[2]
$WinHeight=$GameWindowData[3]

Func MoveInsideGameWindow($RelativeXMove, $RelativeYMove)
	MouseMove($WinXPos + $RelativeXMove * $WinWidth, $WinYPos + $RelativeYMove * $WinHeight, 5)
EndFunc

Func GetToLobby()
	; Skip Blizzard Logo video
	Send("{SPACE}")
	Sleep(1500)

	;~ Skip D2R logo video
	Send("{SPACE}")
	Sleep(7000)

	;~ Skip title screen
	Send("{SPACE}")

	;~ Wait for battle net connection
	Sleep(11000)

	;~ move to the lobby button and click it
	MoveInsideGameWindow(0.56, 0.9)
	MouseClick($MOUSE_CLICK_LEFT)
	Sleep(1000)
EndFunc


Func FillGameDetails($GameName, $GamePassword)
	Send($GameName)
	Send("{TAB}")
	Send($GamePassword)
	Send("{ENTER}")
	;~ Wait for game to open and minimise window
	Sleep(8000)
	WinSetState($d2r_window, "",  @SW_MINIMIZE)
EndFunc


Func CreateGame($GameName, $GamePassword)
	;~ Click on create game tab
	MoveInsideGameWindow(0.67, 0.08)
	MouseClick($MOUSE_CLICK_LEFT)

	;~ Click on game name field
	MoveInsideGameWindow(0.7, 0.16)
	MouseClick($MOUSE_CLICK_LEFT)

	;~ Enter game name and password and enter
	FillGameDetails($GameName, $GamePassword)
EndFunc


Func JoinGame($GameName, $GamePassword)
	;~ Click on join game tab
	MoveInsideGameWindow(0.75, 0.08)
	MouseClick($MOUSE_CLICK_LEFT)

	;~ Click on game name field
	MoveInsideGameWindow(0.65, 0.13)
	MouseClick($MOUSE_CLICK_LEFT)

	;~ Enter game name and password and enter
	FillGameDetails($GameName, $GamePassword)
EndFunc

;~ =============================
;~ ========== MAIN =============
;~ =============================

GetToLobby()

If $ACTION = $CREATE_ACTION Then
	CreateGame($GAME_NAME, $DEFAULT_GAME_PASSWORD)
ElseIf $ACTION = $JOIN_ACTION Then
	JoinGame($GAME_NAME, $DEFAULT_GAME_PASSWORD)
EndIf
