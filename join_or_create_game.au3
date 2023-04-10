#include <AutoItConstants.au3>
#include "libs\AutoIT_ImageSearchUDF\_ImageSearch_UDF.au3"

Global $IMAGE_SEARCH_TIMEOUT = 60000

;~ Wait for game to fully boot and set its window size to the one set in game options
Sleep(2500)

$CREATE_ACTION = "create"
$JOIN_ACTION = "join"

$D2R_WINDOW_NAME = $CmdLine[1]
$ACTION = $CmdLine[2]
$GAME_NAME = $CmdLine[3]
$GAME_PASSWORD = $CmdLine[4]

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

Func WaitForImage($ImageFileName, $MoveToImage = True, $ClickMouse = True, $CenterPosition = True, $Timeout = $IMAGE_SEARCH_TIMEOUT, $Tolerance = 0)
	$result = _ImageSearch_Wait(@ScriptDir & "\" & "d2r_game_images" & "\" & $ImageFileName, $TimeOut, $Tolerance, $CenterPosition)
	
	If ($MoveToImage) Then
		MouseMove($result[1], $result[2], 5)
	EndIf
	If ($ClickMouse) Then
		MouseClick($MOUSE_CLICK_LEFT)
	EndIf
EndFunc

Func GetToLobby()
	; Skip Blizzard Logo video
	Send("{SPACE}")
	Sleep(3500)

	;~ Skip D2R logo video
	Send("{SPACE}")

	;~ Skip title screen
	WaitForImage("title_screen_prod.bmp", False)

	;~ move to the lobby button and click it
	WaitForImage("lobby_button.bmp")
	Sleep(1000)
EndFunc


Func FillGameDetails($GameName, $GamePassword)
	Send($GameName)
	Send("{TAB}")
	Send($GamePassword)
	Send("{ENTER}")

	;~ Wait for game to open
	WaitForImage("game_menu_button.bmp", False, False)

	;~ move the character
	MoveInsideGameWindow(0.7, 0.7)
	MouseClick($MOUSE_CLICK_LEFT)
	Sleep(1000)

	;~ minimise current game window to reduce load on cpu/ram/gpu
	WinSetState($d2r_window, "",  @SW_MINIMIZE)
EndFunc


Func CreateGame($GameName, $GamePassword)
	;~ Click on create game tab
	WaitForImage("create_game_button_dim.bmp")

	;~ Click on game name field
	WaitForImage("create_game_name_field.bmp")

	;~ Enter game name and password and enter
	FillGameDetails($GameName, $GamePassword)
EndFunc


Func JoinGame($GameName, $GamePassword)
	;~ Click on join game tab
	WaitForImage("join_game_button.bmp")

	;~ Click on game name field
	WaitForImage("join_game_name_field.bmp")

	;~ Enter game name and password and enter
	FillGameDetails($GameName, $GamePassword)
EndFunc

;~ =============================
;~ ========== MAIN =============
;~ =============================

GetToLobby()

If $ACTION = $CREATE_ACTION Then
	CreateGame($GAME_NAME, $GAME_PASSWORD)
ElseIf $ACTION = $JOIN_ACTION Then
	JoinGame($GAME_NAME, $GAME_PASSWORD)
EndIf
