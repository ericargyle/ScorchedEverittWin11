; ______________________________________________________________________________
; |										|
; | ECE 291 Fall 2001 Final Project						|
; | -- SCORCHED EVERITT --							|
; |										|
; | Team Leader:								|
; |	Suneil Hosmane (hosmane@uiuc.edu)					|
; |										|
; | Team Members:								|
; |	Terrence B. Janas (tjanas@uiuc.edu)					|
; |     Yajur Parikh	  (yparikh@uiuc.edu)					|
; |										|
; | University of Illinois at Urbana-Champaign					|
; | Department of Electrical & Computer Engineering				|
; |										|
; | Dated Started: Nov 20, 2001							|
; | Dated Completed: Dec 6, 2001						|
; ------------------------------------------------------------------------------

%include "lib291.inc"

BITS 32

GLOBAL _main
; _______________________________________________________________________________
; Define Contants								|

; Keyboard Constants:
LSHIFT	EQU	6
RSHIFT	EQU	7
BKSP	EQU	8
ENTR	EQU	13
ESC	EQU	27
DEL	EQU	10
HOME	EQU	11
UP	EQU	24
PGUP	EQU	12
LEFT	EQU	27
RIGHT	EQU	26
END	EQU	14
DOWN	EQU	25
PGDN	EQU	15
INS	EQU	16
SPACE	EQU	17


; Various Screen Coordinates
; __________________________
; 
; All coordinates below
; are in terms of the 
; upper-left hand corner

CANVAS_X	EQU	25			; starting coordinates of the boxes in the main menu
CANVAS_Y	EQU	90

GameScreenX	EQU	0			; (0,14) is the beginning of where the "game" is played
GameScreenY	EQU	14			; the game screen size is 640x397

BoxWidth	EQU	25			; width of gun-size box
BoxHeight	EQU	15			; height of gun-size box

P1_Gun_X	EQU	82			; location of player 1's gun size boxes
P1_Gun_Y	EQU	454

P2_Gun_X	EQU	505			; location of player 2's gun size boxes
P2_Gun_Y	EQU	454

P1_Name_X	EQU	75			; location of player 1's name:
P1_Name_Y	EQU	414

P2_Name_X	EQU	499			; location of player 2's name:
P2_Name_Y	EQU	414

P1_Score_X	EQU	81			; location of player 1's score:
P1_Score_Y	EQU	434

P2_Score_X	EQU	505			; location of player 2's score:
P2_Score_Y	EQU	434

PosPower_X	EQU	300			; location of the POWER:
PosPower_Y	EQU	422

PosAngle_X	EQU	300			; location of the ANGLE:
PosAngle_Y	EQU	444

MaxChars	EQU	10			; maximum number of characters			
CharHeight	EQU	16			; 16x16 character
CharWidth	EQU	16

MaxDigits	EQU	3			; in the power & angle, there is a max of 3 digits

LandWidth	EQU	640			; 640x297 piece of land
LandHeight	EQU	397

TankSize	EQU	60			; 60x60 Tank Image

TankMenuX	EQU	80			; location of the tank select menu
TankMenuY	EQU	60			

TEXT_X		EQU	125
TEXT_Y		EQU	104			; Used in player 1/2 setup

; Coordinates of the tank positions for player 1 & 2 for lands 1 --> 10
P1_L1_X		EQU	GameScreenX+105
P1_L1_Y		EQU	GameScreenY+210
P2_L1_X		EQU	GameScreenX+541
P2_L1_Y		EQU	GameScreenY+259

P1_L2_X		EQU	GameScreenX+82
P1_L2_Y		EQU	GameScreenY+159
P2_L2_X		EQU	GameScreenX+509
P2_L2_Y		EQU	GameScreenY+186

P1_L3_X		EQU	GameScreenX+3
P1_L3_Y		EQU	GameScreenY+148
P2_L3_X		EQU	GameScreenX+504
P2_L3_Y		EQU	GameScreenY+158

P1_L4_X		EQU	GameScreenX+73
P1_L4_Y		EQU	GameScreenY+345
P2_L4_X		EQU	GameScreenX+495
P2_L4_Y		EQU	GameScreenY+292

P1_L5_X		EQU	GameScreenX+72
P1_L5_Y		EQU	GameScreenY+165
P2_L5_X		EQU	GameScreenX+469
P2_L5_Y		EQU	GameScreenY+335
		
P1_L6_X		EQU	GameScreenX+119
P1_L6_Y		EQU	GameScreenY+203
P2_L6_X		EQU	GameScreenX+479
P2_L6_Y		EQU	GameScreenY+153
		
P1_L7_X		EQU	GameScreenX+96
P1_L7_Y		EQU	GameScreenY+222
P2_L7_X		EQU	GameScreenX+458
P2_L7_Y		EQU	GameScreenY+194

P1_L8_X		EQU	GameScreenX+86
P1_L8_Y		EQU	GameScreenY+211
P2_L8_X		EQU	GameScreenX+445
P2_L8_Y		EQU	GameScreenY+186

P1_L9_X		EQU	GameScreenX+100
P1_L9_Y		EQU	GameScreenY+203
P2_L9_X		EQU	GameScreenX+520
P2_L9_Y		EQU	GameScreenY+278
		
P1_L10_X	EQU	GameScreenX+109
P1_L10_Y	EQU	GameScreenY+207
P2_L10_X	EQU	GameScreenX+447
P2_L10_Y	EQU	GameScreenY+210

; Constant Flags
; __________________________
ZEROS		EQU	0			; --> Used in _DisplayPowerAngle()
INC1		EQU	1			; if Flag Passed = 0, draw a string of all zeros
DEC1		EQU	2			;		 = 1, draw the previous power/angle + 1
NOCHANGE	EQU	3			;		 = 2, draw the previous power/angle - 1
						;		 = 4, draw the previous power/angle unchanged

PLAYER1		EQU	1			; self explanatory
PLAYER2		EQU	2

FIRE		EQU	0			; used in Player1Set & Player2Set
EXIT_GAME	EQU	1
HELP_MENU	EQU	2

MAXPOWER	EQU	100			; maximum velocity

OUTOFBOUNDS	EQU	-1
HIT		EQU	-2			; flags for the pixels drawn during a projectile


SECTION .bss
; _______________________________________________________________________________
; Define Variables & Look-UP Tables						|

_GraphicsMode	resw	1	; Graphics mode #
_TimerTick	resd	1	; Used in TimerISR
_seed		resw	1	; Random
_Dead		resb	1	; holds the value of whoever is dead, Player1 or Player2 or no one
_HitX		resw	1	; Coordinates	
_HitY		resw	1
_counter	resw	1	; temp counter
_Wind		resw	1	; Current speed & direction of wind
_p1won		resb	1	; how many times eaxh player has won
_p2won		resb	1
_p1modu		resw	1	; used to calculate how far a player is to obtaining the next highest gun size
_p2modu		resw	1
_winner		resb	1	; winner?
_kbINT		resb	1	; Keyboard interrupt #
_kbIRQ		resb	1	; Keyboard IRQ
_kbPort		resw	1	; Keyboard port
_gunsize	resw	1	; size of the gun, (diameter of blast)

; Offsets; Go to _AllocateMemory for descriptions on these variables
_CharOff	resd	1	
_Tank1		resd	1	
_Tank2		resd	1	
_TankDump	resd	1	
_TankDump2	resd	1
_TankDump3	resd	1	
_RolloverOff	resd	1	
_LandOff	resd	1
_ScreenOff	resd	1	
_ScreenTemp	resd	1
_ScreenTemp2	resd	1
_Overlay	resd	1
_GameOff	resd	1	
_FontOff	resd	1	
_MenuOff	resd	1	
_AllPurposeMenu	resd	1
_MiniMenu	resd	1
_UpArrow	resd	1
_RightArrow	resd	1
_TempSpace	resd	1
_LevelUp	resd	1

_WindFlag	resb	1		; 1 = Wind ON, 0 = Wind OFF
_SoundFlag	resb	1		; 1 = Sound ON, 0 = Sound OFF
_Rounds		resb	1		; # of rounds
_Color		resb	1		; color # of the background (sky)
_SkyColor	resd	1		; ARGB value of the background (sky)


_WindFlagS	resb	1		; these are saved copies of the flags
_SoundFlagS	resb	1		;
_RoundsS	resb	1		;	
_ColorS		resb	1		;
_SkyColorS	resd	1		;
_rnd		resw	1		; # of rounds (backup)

_specialx	resw	1		; x, y coords
_specialy	resw	1
_times		resw	1		; loop counter

_gamecounter	resw	1		; another loop counter
_MPFlags	resb	1	; program flags
				; Bit 0 - Exit program
				; Bit 6 - When key pressed
				; other bits used by KB ISR
_tmpX		resd	1		; used to draw projectile
_tmpY		resd	1

_previousX	resd	1
_previousY	resd	1

_MenuItem	resb	1		; Main Menu Item
_OptionsItem	resb	1		; Options Menu Item
_LandNumber	resw	1		; Land #
_tempx		resd	1		; temp x,y coords
_tempy		resd	1
_Ones		resw	1		; used to convert from decimal to ascii
_Tens		resw	1		;
_Hundreds	resw	1		;
_roundscore	resw	1		; pts gained after a round
_turnsp1	resw	1		; how many turns that p1 & p2 have taken
_turnsp2	resw	1		;
_key		resb	1		; used in KB_ISR
_exit		resb	1		; = 1, exit for good, = 0, go back to the menu
_F		resb	1		; Flag used in _DrawBullet()


; Constant Flags
; __________________________
_Player1Score	resw	1		; the name explains it all
_Player2Score	resw	1

_Player1Angle	resw	1
_Player2Angle	resw	1

_P1Power	resw	1
_P2Power	resw	1

_P1GunSize	resw	1
_P2GunSize	resw	1

_Turn		resw	1		; whose turn is it anyway?

_P1TankPos	resw	1		; angle positions
_P2TankPos	resw	1

_P1Tank		resb	1		; which model?
_P2Tank		resb	1

_P1TankX	resw	1		; starting locations
_P1TankY	resw	1

_P2TankX	resw	1
_P2TankY	resw	1


; Line Algorithm
; __________________________
_x		resw	1
_y		resw	1
_dx		resw	1
_dy		resw	1
_lineerror	resw	1
_xhorizinc	resw	1
_xdiaginc	resw	1
_yvertinc	resw	1
_ydiaginc	resw	1
_errordiaginc	resw	1
_errornodiaginc	resw	1
 
; Circle Algorithm
; __________________________
_x2		resw	1
_y2		resw	1
_radius		resw	1
_circleerror	resw	1
_xdist		resw	1
_ydist		resw	1

; FloodFill Variables
; __________________________
_PointQueue	resd	1
_QueueHead	resd	1
_QueueTail	resd	1


; Floating-Point Variables
; __________________________
_fx		resd	1		; x 
_fy		resd	1		; y
_fvx		resd	1		; x velocity
_fvy		resd	1		; y velocity
_ft		resd	1		; times
_tx		resd	1		; temp x (int)
_ty		resd	1		; temp y (int)

SECTION .data

; Coordinates for the rectanles in the Main Menu
_MenuLocations	dw	CANVAS_X,	CANVAS_Y,      (CANVAS_X+195), (CANVAS_Y+48)
		dw	CANVAS_X,      (CANVAS_Y+92),  (CANVAS_X+195), (CANVAS_Y+94)+48
		dw     (CANVAS_X-1),   (CANVAS_Y+184), (CANVAS_X+194), (CANVAS_Y+180)+48
		dw     (CANVAS_X-2),   (CANVAS_Y+270), (CANVAS_X+193), (CANVAS_Y+264)+48
		
; Column 1 & Column 2 hold the (x,y) coordinates of player 1's tank for each map 
; Column 3 & Column 4 hold the (x,y) coordinates of player 2's tank for each map
_TankCoords	dw	P1_L1_X,	P1_L1_Y,	P2_L1_X,	P2_L1_Y
		dw	P1_L2_X,	P1_L2_Y,	P2_L2_X,	P2_L2_Y
		dw	P1_L3_X,	P1_L3_Y,	P2_L3_X,	P2_L3_Y
		dw	P1_L4_X,	P1_L4_Y,	P2_L4_X,	P2_L4_Y
		dw	P1_L5_X,	P1_L5_Y,	P2_L5_X,	P2_L5_Y
		dw	P1_L6_X,	P1_L6_Y,	P2_L6_X,	P2_L6_Y
		dw	P1_L7_X,	P1_L7_Y,	P2_L7_X,	P2_L7_Y
		dw	P1_L8_X,	P1_L8_Y,	P2_L8_X,	P2_L8_Y
		dw	P1_L9_X,	P1_L9_Y,	P2_L9_X,	P2_L9_Y
		dw	P1_L10_X,	P1_L10_Y,	P2_L10_X,	P2_L10_Y

; Coordinates for the floodfill locations in the tank select menu
_TankMenu	dw	TankMenuX+128, TankMenuY+141
		dw	TankMenuX+270, TankMenuY+138
		dw	TankMenuX+403, TankMenuY+140
		dw	TankMenuX+126, TankMenuY+272
		dw	TankMenuX+240, TankMenuY+270
		dw	TankMenuX+407, TankMenuY+282

; Column 1 & 2  = coordinates for (x,y) position right next to the barrel for each Tank for positions 0 - 9
_TankAngle1	dw	60,	25
		dw	58,	13
		dw	54,	5
		dw	45,	0
		dw	33,	0
		dw	26,	0
		dw	14,	0
		dw	5,	5
		dw	1,	13
		dw	0,	25
		
_TankAngle2	dw	59,	29		; position 0;
		dw	56,	18		; position 1
		dw	49,	10		; etc....
		dw	40,	5
		dw	30,	4
		dw	29,	4
		dw	19,	5
		dw	10,	10
		dw	3,	18
		dw	0,	29

_TankAngle3	dw	59,	26		; position 0
		dw	56,	17		; position 1
		dw	50,	8		; etc....
		dw	42,	2
		dw	30,	0
		dw	29,	0
		dw	17,	2
		dw	9,	8
		dw	3,	17
		dw	0,	26


_TankAngle4	dw	54,	24		; position 0
		dw	53,	18		; position 1
		dw	49,	12		; etc....
		dw	44,	9
		dw	38,	8
		dw	21,	8
		dw	15,	9
		dw	10,	12
		dw	6,	18
		dw	5,	24

_TankAngle5	dw	59,	26		; position 0
		dw	58,	19		; position 1
		dw	54,	12		; etc....
		dw	48,	8
		dw	40,	7
		dw	19,	7
		dw	11,	8
		dw	5,	12
		dw	1,	19
		dw	0,	26

_TankAngle6	dw	54,	27		; position 0
		dw	53,	22		; position 1
		dw	48,	14		; etc....
		dw	44,	10
		dw	35,	8
		dw	24,	8
		dw	15,	10
		dw	11,	14
		dw	6,	22
		dw	5,	27

; Floating Point Variables
_RadianConversion	dd	0.017453	; (Angle in Degrees) * Radian Conversion = (Angle in Radians)
_Gravity		dd	-5.0		; Acceleration Downward Gravity 
_SampleFactor		dd	0.001		; # of samples


; Images Files
_FontFN		db	'.\picts\font.png',0   
_MenuFN		db	'.\picts\menu.png',0 
_PlayFN		db	'.\picts\play.png',0
_OptionsFN	db	'.\picts\options.png',0
_ExitFN		db	'.\picts\exit.png',0
_CreditsFN	db	'.\picts\credits.png',0
_MainFN		db	'.\picts\main.png',0
_LandFN		db	'.\picts\land.png',0
_Tank1FN	db	'.\picts\tank1.png',0
_Tank2FN	db	'.\picts\tank2.png',0
_Tank3FN	db	'.\picts\tank3.png',0
_Tank4FN	db	'.\picts\tank4.png',0
_Tank5FN	db	'.\picts\tank5.png',0
_Tank6FN	db	'.\picts\tank6.png',0
_P1TankMenuFN	db	'.\picts\p1tankmenu.png',0
_P2TankMenuFN	db	'.\picts\p2tankmenu.png',0
_NameMenuFN	db	'.\picts\namemenu.png',0
_OptionsMenuFN	db	'.\picts\optionsmenu.png',0
_RightArrowFN	db	'.\picts\rightarrow.png',0
_UpArrowFN	db	'.\picts\uparrow.png',0
_EndOfRoundFN	db	'.\picts\endofround.png',0
_LevelUpFN	db	'.\picts\levelup.png',0
_CreditScreenFN	db	'.\picts\credit.png',0
_ExitMainFN	db	'.\picts\exitmain.png',0
_HelpMenuFN	db	'.\picts\helpmenu.png',0
_ExitToMainFN	db	'.\picts\exittomain.png',0
_EndofGameFN	db	'.\picts\endofgame.png',0
_TrophyFN	db	'.\picts\trophy.png',0
_NewgameFN	db	'.\picts\newgame.png',0
_Tank222	db	'.\picts\intro\2.png',0
_Tank3		db	'.\picts\intro\3.png',0
_Tank4		db	'.\picts\intro\4.png',0
_Tank5		db	'.\picts\intro\5.png',0
_Tank6		db	'.\picts\intro\6.png',0
_Tank7		db	'.\picts\intro\7.png',0
_Tank8		db	'.\picts\intro\8.png',0
_Tank9		db	'.\picts\intro\9.png',0
_Tank10		db	'.\picts\intro\A.png',0
_Tank11		db	'.\picts\intro\B.png',0
_Tank12		db	'.\picts\intro\C.png',0
_Tank13		db	'.\picts\intro\D.png',0
_Tank14		db	'.\picts\intro\E.png',0
_Tank15		db	'.\picts\intro\F.png',0
_Tank16		db	'.\picts\intro\G.png',0
_Tank17		db	'.\picts\intro\H.png',0
_Tank18		db	'.\picts\intro\I.png',0
_Tank19		db	'.\picts\intro\J.png',0
_Tank20		db	'.\picts\intro\K.png',0
_Tank21		db	'.\picts\intro\L.png',0
_Tank22		db	'.\picts\intro\M.png',0
_Tank23		db	'.\picts\intro\N.png',0
_Tank24		db	'.\picts\intro\O.png',0
_Tank25		db	'.\picts\intro\P.png',0


; Some Defined Color Values
_DefaultColor	dd	000FFFFFFh
_ColorBlue	dd	0ff0033ffh
_ColorWhite	dd	0ffffffffh
_ColorBlack	dd	0ff000000h
_ColorHalfBlack dd	0cc000000h
_GunSizeColor	dd	000007700h
_ColorGrey	dd	000808080h
_FillColor	dd	0000000F0h
 
; Scan Tables
_QwertyNames
	db	0	; filler
	db	ESC,'1','2','3','4','5','6','7','8','9','0','-','=',BKSP
	db	0, 'q','w','e','r','t','y','u','i','o','p','[',']',ENTR
	db	0,'a','s','d','f','g','h','j','k','l',';',"'","`"
	db	LSHIFT,'\','z','x','c','v','b','n','m',",",'.','/',RSHIFT,'*'
	db	0, ' ', 0, 200,201,202,203,204,205,206,207,208,209 ; F1-F10
	db	0,0	; numlock, scroll lock
	db	HOME, UP, PGUP, '-'
	db	LEFT, 0, RIGHT, '+'
	db	END, DOWN, PGDN, INS
	db	DEL, 0; sysrq
_QwertyNames_end resb 0

_QwertyShift
	db	0	; filler
	db	ESC,'!','@','#','$','%','^','&','*','(',')','_','+',BKSP
	db	0, 'Q','W','E','R','T','Y','U','I','O','P','{','}',ENTR
	db	0,'A','S','D','F','G','H','J','K','L',':','"','~'
	db	LSHIFT,'|','Z','X','C','V','B','N','M',"<",'>','?',RSHIFT,'*'
	db	0, ' ', 0, 200, 201,202,203,204,205,206,207,208,209 ; F1-F10
	db	0,0	; numlock, scroll lock
	db	HOME, UP, PGUP, '-'
	db	LEFT, 0, RIGHT, '+'
	db	END, DOWN, PGDN, INS
	db	DEL, 0; sysrq
_QwertyShift_end resb 0


_TempString		times 12 db 0,'$'		; temporary string
_TextInputString	times 12 db 0,'$'		; temporary string
_Player1Name		times 12 db 0,'$'		; player 1's name in string format
_Player2Name		times 12 db 0,'$'		; likewise for player 2
_ScoreString		times 12 db 0,'$'		; score, in string format, used in _DisplayScore
_PowerAngleString	times 12 db 0,'$'		; power/angle in string format, used in _DisplayAnglePower
_RoundString		times 12 db 0,'$'		; display score at the end of the roun
_EndofGameString	times 12 db 0,'$'		; 
_WindString		times 12 db 0,'$'		; wind strength

_RoundingFactor	dd	000800080h, 00000080h		; used in mmx procedure


SECTION .text

; _______________________________________________________________________
; 
; _main()
;	
; Inputs:
;	none
;
; Purpose:
;	initializes memory, graphics, keyboard, calls the game, and
;	then unistalls everything.
; Created by: Suneil Hosmane
; -----------------------------------------------------------------------
_main
	push	eax

	call	_LibInit
	call	_AllocateMemory
	cmp	eax, -1
	je	near .memerror

	; These images files will always be needed, so just leave them in their respective buffers
	invoke	_LoadPNG, dword _FontFN, dword [_FontOff], dword 0, dword 0 
	invoke	_LoadPNG, dword _LandFN, dword [_LandOff], dword 0, dword 0
	invoke	_LoadPNG, dword _UpArrowFN, dword [_UpArrow], dword 0, dword 0 
	invoke	_LoadPNG, dword _RightArrowFN, dword [_RightArrow], dword 0, dword 0
	invoke	_LoadPNG, dword _LevelUpFN, dword [_LevelUp], dword 0, dword 0


	; Graphics init
	invoke	_InitGraphics, dword _kbINT, dword _kbIRQ, dword _kbPort
	test	eax, eax
	jnz	near .graphicserror

	; Find graphics mode: 640x480x32, allow driver-emulated modes
	invoke	_FindGraphicsMode, word 640, word 480, word 32, dword 1
	mov	[_GraphicsMode], ax

	; Timer
	call	_InstallTimer

	; Keyboard
	call	_InstallKeyboard
	test	eax, eax
	jnz	near .keyboarderror
	invoke	_SetGraphicsMode, word [_GraphicsMode]
	test	eax, eax
	jnz	.setgraphicserror

	call	_Scorch

.setgraphicserror
	call	_UnsetGraphicsMode
.keyboarderror
	call	_RemoveKeyboard
	call	_RemoveTimer
.graphicserror
	call	_ExitGraphics
.memerror
	call	_LibExit
	pop	eax
	ret

;=============================================================================================
; ____________________________________________________________________________________________
; 
; _Scorch()
;	
; Inputs:
;	none
;
; Purpose:
;	Is the very basic shell of the game. It invokes the menus, starts
;	the game, and handles the exit cases.
;Created by: Suneil Hosmane
; --------------------------------------------------------------------------------------------
_Scorch

pusha	
	
call _Intro
; _________________________
; | PROMPT with Main Menu |
; | [1] - Play Game	  |
; | [2] - Options	  |
; | [3] - Credits	  |
; | [4] - Exit Game	  |
; -------------------------
call	_InitGameVariables	; set initial variables/flags to default values

.MainMenu
	invoke	_MainMenu, dword [_ScreenOff], dword 640, dword 480
	cmp	byte [_MenuItem], 0
	je	near .Play

	cmp	byte [_MenuItem], 1
	je	near .Option

	cmp	byte [_MenuItem], 2
	je	near .Credit

	cmp	byte [_MenuItem], 3
	je	near .MainDone

	; This sub-routine handles the actual playing of the game
	; _Player1Setup() obtains player 1's tank, and screen-name
	; _Player2Setup() obtains player 2's tank, and screen-name
	; _InitializeGame draws the sreen
	; _PlayGame() handles the gameplay
	.Play:		
		call	_Player1Setup
		call	_Player2Setup
		invoke	_InitializeGame, dword [_ScreenOff], dword [_Tank1], dword [_Tank2]
		call	_PlayGame

		cmp	byte [_exit], 0
		je	near .MainMenu
		
		jmp	near .MainDone

	; This sub-routine handles the options menu
	.Option:
		call	_OptionsMenu	
		jmp	near .MainMenu

	; This sub-routine handles the credit display
	.Credit:
		; clear the screen, alpha blend it with a dark image to give a faded look
		invoke	_ClearBuffer, dword [_Overlay], word 640, word 480, dword 0A0000000h
		invoke	_CopyBuffer, dword [_ScreenOff], word 640, word 480, dword [_ScreenTemp], word 640, word 480, word 0, word 0
		invoke	_ComposeBuffers, dword [_Overlay], word 640, word 480, dword [_ScreenOff], word 640, word 480, word 0, word 0
		invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0

		; load the credit screen
		invoke	_LoadPNG, dword _CreditScreenFN, dword [_AllPurposeMenu], dword 0, dword 0 
		invoke	_CopyBuffer, dword [_AllPurposeMenu], word 480, word 360, dword [_ScreenOff], word 640, word 480, word TankMenuX, word TankMenuY
		invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0

		; wait for keypress
		and	byte [_MPFlags], 10111111b
		.wait
		test	byte [_MPFlags], 01000000b
		jz	.wait
		cmp	byte [_key], ENTR
		jne	.wait
		
		; redraw original screen
		invoke	_CopyBuffer, dword [_ScreenTemp], word 640, word 480, dword [_ScreenOff], word 640, word 480, word 0, word 0
		invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
		and	byte [_MPFlags], 10111111b
		jmp	near .MainMenu

	.MainDone
		popa
		ret


;=============================================================================================
; ____________________________________________________________________________________________
; 
; _InitGameVariables()
;	
; Inputs:
;	none
; Outputs: none
;
; Purpose:
;	Initial the game flags used in the options menu to their default values.
; Created by: Suneil Hosmane
; --------------------------------------------------------------------------------------------
_InitGameVariables
	mov	byte [_WindFlag], 0		; Wind OFF
	mov	byte [_SoundFlag], 0		; Sound OFF
	mov	byte [_Rounds], 5		; 5 Rounds
	mov	word [_rnd], 5			; backup copy of Rounds
	mov	byte [_Color], 5		; 5th color
	mov	dword [_SkyColor], 0234567h
	ret


;=============================================================================================
; ____________________________________________________________________________________________
; 
; _OptionsMenu
;	
;  Purpose:
;	Let the user be able to:
;	(1) Turn ON, and OFF the following:
;	    SOUND
;	    WIND
;	(2) Pick between 1, 3, 5, 7, or 9 Rounds of Combat
;	(3) Pick between different sky background colors
;
;	Menu Commands:
;		<== (Left Arrow) toggles OFF (or moves to the left of a field)
;		==> (Right Arrow) toggles ON (or moves to the right of a field)
;		Down\Up arrow chooes different fields
;		ENTER at "Save Changes", saves flag choices
;		'q' quits the menu, w/o saving changes
;  Inputs: none
;  Outputs: none
;
;  Created by: Terrence Janas
; --------------------------------------------------------------------------------------------
_OptionsMenu
pushad

; When the menu starts, it automatically displays the last saved flags
; Therefore, we must first retrieve our old flags, display them, and then 
; prompt the user to either change their flags or keep them as they are
mov	eax, 0
mov	al, byte [_rnd]			; get previous _Rounds choice
mov	byte [_Rounds], al

mov	al, byte [_ColorS]		; get previous _Color choice
mov	byte [_Color], al

and	byte [_MPFlags], 10111111b	
; fade screen
invoke	_ClearBuffer, dword [_Overlay], word 640, word 480, dword 0A0000000h
invoke	_ClearBuffer, dword [_TempSpace], word 32, word 32, dword 0FF000000h
invoke	_CopyBuffer, dword [_ScreenOff], word 640, word 480, dword [_ScreenTemp], word 640, word 480, word 0, word 0
invoke	_ComposeBuffers, dword [_Overlay], word 640, word 480, dword [_ScreenOff], word 640, word 480, word 0, word 0
invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0

; display the options menu
invoke	_LoadPNG, dword _OptionsMenuFN, dword [_AllPurposeMenu], dword 0, dword 0 
invoke	_CopyBuffer, dword [_AllPurposeMenu], word 480, word 360, dword [_ScreenOff], word 640, word 480, word TankMenuX, word TankMenuY
invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0

; display previous flag choices
cmp	byte [_WindFlag], 1		; WIND
jne	.CheckSound
invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word TankMenuX+290, word TankMenuY+98, dword 0FFFF00h, dword 0

.CheckSound:				; SOUND
cmp	byte [_SoundFlag], 1
jne	.CheckRnd
invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word TankMenuX+290, word TankMenuY+147, dword 0FFFF00h, dword 0

.CheckRnd:				; ROUNDS
cmp	byte [_Rounds], 1
jne	near .Rnd3
invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word TankMenuX+296, word TankMenuY+183, dword 0FFFF00h, dword 0
jmp	near .CheckColor

.Rnd3:
cmp	byte [_Rounds], 3
jne	near .Rnd5
invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word TankMenuX+334, word TankMenuY+182, dword 0FFFF00h, dword 0
jmp	near .CheckColor

.Rnd5:
cmp	byte [_Rounds], 5
jne	near .Rnd7
invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word TankMenuX+369, word TankMenuY+188, dword 0FFFF00h, dword 0
jmp	near .CheckColor

.Rnd7:
cmp	byte [_Rounds], 7
jne	near .Rnd9
invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word TankMenuX+405, word TankMenuY+182, dword 0FFFF00h, dword 0
jmp	near .CheckColor
	
.Rnd9:
invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word TankMenuX+441, word TankMenuY+189, dword 0FFFF00h, dword 0

.CheckColor:				; COLORS
cmp	byte [_Color], 1
jne	near .Clr2
invoke	_CopyBuffer, dword [_UpArrow], word 32, word 32, dword [_ScreenOff], word 640, word 480, word TankMenuX+281, word TankMenuY+260
jmp	near .Start

.Clr2:
cmp	byte [_Color], 2
jne	near .Clr3
invoke	_CopyBuffer, dword [_UpArrow], word 32, word 32, dword [_ScreenOff], word 640, word 480, word TankMenuX+316, word TankMenuY+260
jmp	near .Start

.Clr3:
cmp	byte [_Color], 3
jne	near .Clr4
invoke	_CopyBuffer, dword [_UpArrow], word 32, word 32, dword [_ScreenOff], word 640, word 480, word TankMenuX+351, word TankMenuY+260
jmp	near .Start

.Clr4:
cmp	byte [_Color], 4
jne	near .Clr5
invoke	_CopyBuffer, dword [_UpArrow], word 32, word 32, dword [_ScreenOff], word 640, word 480, word TankMenuX+386, word TankMenuY+260
jmp	near .Start
	
.Clr5:	
invoke	_CopyBuffer, dword [_UpArrow], word 32, word 32, dword [_ScreenOff], word 640, word 480, word TankMenuX+421, word TankMenuY+260

.Start
invoke	_CopyBuffer, dword [_RightArrow], word 32, word 32, dword [_ScreenOff], word 640, word 480, word TankMenuX+14, word TankMenuY+75
invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0

; This is where the real menu begins
mov	byte [_OptionsItem], 0
.Retry:		
	test	byte [_MPFlags], 01000000b	
	jz	near .Retry

	cmp	byte [_key], 'q'
	je	near .Exit

	cmp	byte [_key], DOWN
	jne	near .TryUp

	; WE HAVE PRESSED the DOWN KEY
	; now we are checking all the cases
	cmp	byte [_OptionsItem], 4
	je	near .SaveChanges

	; Draw an arrow next to where you are, and then check other keystrokes
	cmp	byte [_OptionsItem], 0
	jne	near .Try1
	invoke	_CopyBuffer, dword [_TempSpace], word 32, word 32, dword [_ScreenOff], word 640, word 480, word TankMenuX+14, word TankMenuY+75
	jmp	near .Cont
.Try1:
	cmp	byte [_OptionsItem], 1
	jne	near .Try2
	invoke	_CopyBuffer, dword [_TempSpace], word 32, word 32, dword [_ScreenOff], word 640, word 480, word TankMenuX+14, word TankMenuY+125
	jmp	near .Cont
.Try2:
	cmp	byte [_OptionsItem], 2
	jne	near .Try3
	invoke	_CopyBuffer, dword [_TempSpace], word 32, word 32, dword [_ScreenOff], word 640, word 480, word TankMenuX+14, word TankMenuY+175
	jmp	near .Cont
.Try3:
	cmp	byte [_OptionsItem], 3
	jne	near .Try4
	invoke	_CopyBuffer, dword [_TempSpace], word 32, word 32, dword [_ScreenOff], word 640, word 480, word TankMenuX+14, word TankMenuY+225
	jmp	near .Cont
.Try4:
	invoke	_CopyBuffer, dword [_TempSpace], word 32, word 32, dword [_ScreenOff], word 640, word 480, word TankMenuX+14, word TankMenuY+275

.Cont:
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	inc	byte [_OptionsItem]

	cmp	byte [_OptionsItem], 1
	je	near .SoundCase

	cmp	byte [_OptionsItem], 2
	je	near .RoundsCase

	cmp	byte [_OptionsItem], 3
	je	near .SkyColorCase

	; if we are here, we are at the bottom most bo
	; if we press enter at this location, we save our new flags, and exit
	.SaveChanges:
		invoke	_CopyBuffer, dword [_RightArrow], word 32, word 32, dword [_ScreenOff], word 640, word 480, word TankMenuX+14, word TankMenuY+275
		invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword TankMenuX+14, dword TankMenuY+275, dword 32, dword 32, dword TankMenuX+14, dword TankMenuY+275
		.MiniLoop:
		cmp	byte [_key], ENTR
		je	near .Save

		cmp	byte [_key], 'q'
		je	near .Exit

		cmp	byte [_key], UP
		je	near .Retry
		jmp	near .MiniLoop
			
	; We are at the sound check-box
	.SoundCase:
		invoke	_CopyBuffer, dword [_RightArrow], word 32, word 32, dword [_ScreenOff], word 640, word 480, word TankMenuX+14, word TankMenuY+125
		invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword TankMenuX+14, dword TankMenuY+125, dword 32, dword 32, dword TankMenuX+14, dword TankMenuY+125
		and	byte [_MPFlags], 10111111b	
		jmp	near .Retry
	; We are at the Rounds boxes
	.RoundsCase:
		invoke	_CopyBuffer, dword [_RightArrow], word 32, word 32, dword [_ScreenOff], word 640, word 480, word TankMenuX+14, word TankMenuY+175
		invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword TankMenuX+14, dword TankMenuY+175, dword 32, dword 32, dword TankMenuX+14, dword TankMenuY+175
		and	byte [_MPFlags], 10111111b	
		jmp	near .Retry

	; We are at the skycolor boxes
	.SkyColorCase:
		invoke	_CopyBuffer, dword [_RightArrow], word 32, word 32, dword [_ScreenOff], word 640, word 480, word TankMenuX+14, word TankMenuY+225
		invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword TankMenuX+14, dword TankMenuY+225, dword 32, dword 32, dword TankMenuX+14, dword TankMenuY+225
		and	byte [_MPFlags], 10111111b	
		jmp	near .Retry

; Now we check all the UP arrow cases
.TryUp:
	cmp	byte [_key], UP
	jne	near .TryLeft

	cmp	byte [_OptionsItem], 0
	je	near .Retry

	cmp	byte [_OptionsItem], 1
	jne	near .Try2_b
	invoke	_CopyBuffer, dword [_TempSpace], word 32, word 32, dword [_ScreenOff], word 640, word 480, word TankMenuX+14, word TankMenuY+125
	jmp	near .Cont_b

.Try2_b:
	cmp	byte [_OptionsItem], 2
	jne	near .Try3_b
	invoke	_CopyBuffer, dword [_TempSpace], word 32, word 32, dword [_ScreenOff], word 640, word 480, word TankMenuX+14, word TankMenuY+175
	jmp	near .Cont_b
	
.Try3_b:
	cmp	byte [_OptionsItem], 3
	jne	near .Try4_b
	invoke	_CopyBuffer, dword [_TempSpace], word 32, word 32, dword [_ScreenOff], word 640, word 480, word TankMenuX+14, word TankMenuY+225
	jmp	near .Cont_b

.Try4_b:
	invoke	_CopyBuffer, dword [_TempSpace], word 32, word 32, dword [_ScreenOff], word 640, word 480, word TankMenuX+14, word TankMenuY+275

.Cont_b:
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	dec	byte [_OptionsItem]

	cmp	byte [_OptionsItem], 0
	je	near .WindCase

	cmp	byte [_OptionsItem], 1
	je	near .SoundCase

	cmp	byte [_OptionsItem], 2
	je	near .RoundsCase

	cmp	byte [_OptionsItem], 3
	je	near .SkyColorCase

.WindCase:
	invoke	_CopyBuffer, dword [_RightArrow], word 32, word 32, dword [_ScreenOff], word 640, word 480, word TankMenuX+14, word TankMenuY+75
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword TankMenuX+14, dword TankMenuY+75, dword 32, dword 32, dword TankMenuX+14, dword TankMenuY+75
	and	byte [_MPFlags], 10111111b	
	jmp	near .Retry

; Check all the Left Arrow Cases
.TryLeft:
	cmp	byte [_key], LEFT
	je	near .Pass
	
	cmp	byte [_key], RIGHT
	jne	near .Retry
.Pass:
	

cmp	byte [_OptionsItem], 0
je	near .ToggleWind

cmp	byte [_OptionsItem], 1
je	near .ToggleSound

cmp	byte [_OptionsItem], 2
je	near .ToggleRounds

cmp	byte [_OptionsItem], 3
je	near .ToggleColor

jmp	near .Retry

; Here we see if we have to either toggle wind on or off
.ToggleWind:
	cmp	byte [_key], LEFT
	jne	near .windon
	
	cmp	byte [_WindFlag], 0
	je	near .Retry

	mov	byte [_WindFlag], 0
	invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word TankMenuX+290, word TankMenuY+98, dword 010101h, dword 0
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	and	byte [_MPFlags], 10111111b	
	jmp	near .Retry
	
	.windon:	; wind is now on
		mov	byte [_WindFlag], 1
		invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word TankMenuX+290, word TankMenuY+98, dword 0FFFF00h, dword 0
		invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
		and	byte [_MPFlags], 10111111b	
		jmp	near .Retry
		
; Here we see if we have to either toggles sound on or off
.ToggleSound:
	cmp	byte [_key], LEFT
	jne	near .soundon
	
	cmp	byte [_SoundFlag], 0
	je	near .Retry

	mov	byte [_SoundFlag], 0
	invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word TankMenuX+290, word TankMenuY+147, dword 010101h, dword 0
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	and	byte [_MPFlags], 10111111b	
	jmp	near .Retry
	
	.soundon:	; sound is now on
		mov	byte [_SoundFlag], 1
		invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word TankMenuX+290, word TankMenuY+147, dword 0FFFF00h, dword 0
		invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
		and	byte [_MPFlags], 10111111b	
		jmp	near .Retry
		
; Toggle between 1, 3, 5, 7, or 9 rounds
.ToggleRounds:
	cmp	byte [_key], LEFT
	jne	near .increase
	
	cmp	byte [_Rounds], 1
	je	near .Retry

	cmp	byte [_Rounds], 3
	jne	near .TryR5
	invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word TankMenuX+334, word TankMenuY+182, dword 0800000h, dword 0
	invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word TankMenuX+296, word TankMenuY+183, dword 0FFFF00h, dword 0
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	mov	byte [_Rounds], 1
	and	byte [_MPFlags], 10111111b	
	jmp	near .Retry

.TryR5:
	cmp	byte [_Rounds], 5
	jne	near .TryR7
	invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word TankMenuX+369, word TankMenuY+188, dword 0800000h, dword 0
	invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word TankMenuX+334, word TankMenuY+182, dword 0FFFF00h, dword 0
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	mov	byte [_Rounds], 3
	and	byte [_MPFlags], 10111111b	
	jmp	near .Retry

.TryR7:
	cmp	byte [_Rounds], 7
	jne	near .TryR9
	invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word TankMenuX+405, word TankMenuY+182, dword 0800000h, dword 0
	invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word TankMenuX+369, word TankMenuY+188, dword 0FFFF00h, dword 0
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	mov	byte [_Rounds], 5
	and	byte [_MPFlags], 10111111b	
	jmp	near .Retry
.TryR9:
	invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word TankMenuX+441, word TankMenuY+189, dword 0800000h, dword 0
	invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word TankMenuX+405, word TankMenuY+182, dword 0FFFF00h, dword 0
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	mov	byte [_Rounds], 7
	and	byte [_MPFlags], 10111111b	
	jmp	near .Retry	
.increase:	; update the rounds
	cmp	byte [_Rounds], 1
	jne	near .TryR3b
	invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word TankMenuX+296, word TankMenuY+183, dword 0800000h, dword 0
	invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word TankMenuX+334, word TankMenuY+182, dword 0FFFF00h, dword 0
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	mov	byte [_Rounds], 3
	and	byte [_MPFlags], 10111111b	
	jmp	near .Retry
.TryR3b:
	cmp	byte [_Rounds], 3
	jne	near .TryR5b
	invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word TankMenuX+334, word TankMenuY+182, dword 0800000h, dword 0
	invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word TankMenuX+369, word TankMenuY+188, dword 0FFFF00h, dword 0
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	mov	byte [_Rounds], 5
	and	byte [_MPFlags], 10111111b	
	jmp	near .Retry
.TryR5b:
	cmp	byte [_Rounds], 5
	jne	near .TryR7b
	invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word TankMenuX+369, word TankMenuY+188, dword 0800000h, dword 0
	invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word TankMenuX+405, word TankMenuY+182, dword 0FFFF00h, dword 0
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	mov	byte [_Rounds], 7
	and	byte [_MPFlags], 10111111b	
	jmp	near .Retry
.TryR7b:
	cmp	byte [_Rounds], 7
	jne	near .Retry
	invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word TankMenuX+405, word TankMenuY+182, dword 0800000h, dword 0
	invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word TankMenuX+441, word TankMenuY+189, dword 0FFFF00h, dword 0
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	mov	byte [_Rounds], 9
	and	byte [_MPFlags], 10111111b	
	jmp	near .Retry
	
.ToggleColor:	; toggles the color schemes
	cmp	byte [_key], LEFT
	jne	near .moveright
	
	cmp	byte [_Color], 1
	je	near .Retry

	cmp	byte [_Color], 2
	jne	near .Co3
	invoke	_CopyBuffer, dword [_TempSpace], word 32, word 32, dword [_ScreenOff], word 640, word 480, word TankMenuX+316, word TankMenuY+260
	invoke	_CopyBuffer, dword [_UpArrow], word 32, word 32, dword [_ScreenOff], word 640, word 480, word TankMenuX+281, word TankMenuY+260
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	mov	byte [_Color], 1
 	and	byte [_MPFlags], 10111111b	
	jmp	near .Retry

.Co3:
	cmp	byte [_Color], 3
	jne	near .Co4
	invoke	_CopyBuffer, dword [_TempSpace], word 32, word 32, dword [_ScreenOff], word 640, word 480, word TankMenuX+351, word TankMenuY+260
	invoke	_CopyBuffer, dword [_UpArrow], word 32, word 32, dword [_ScreenOff], word 640, word 480, word TankMenuX+316, word TankMenuY+260
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	mov	byte [_Color], 2
	and	byte [_MPFlags], 10111111b	
	jmp	near .Retry

.Co4:
	cmp	byte [_Color], 4
	jne	near .Co5
	invoke	_CopyBuffer, dword [_TempSpace], word 32, word 32, dword [_ScreenOff], word 640, word 480, word TankMenuX+386, word TankMenuY+260
	invoke	_CopyBuffer, dword [_UpArrow], word 32, word 32, dword [_ScreenOff], word 640, word 480, word TankMenuX+351, word TankMenuY+260
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	mov	byte [_Color], 3
	and	byte [_MPFlags], 10111111b	
	jmp	near .Retry

.Co5:
	invoke	_CopyBuffer, dword [_TempSpace], word 32, word 32, dword [_ScreenOff], word 640, word 480, word TankMenuX+421, word TankMenuY+260
	invoke	_CopyBuffer, dword [_UpArrow], word 32, word 32, dword [_ScreenOff], word 640, word 480, word TankMenuX+386, word TankMenuY+260
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	mov	byte [_Color], 4
	and	byte [_MPFlags], 10111111b	
	jmp	near .Retry

.moveright:
	cmp	byte [_Color], 1
	jne	near .Co2b
	invoke	_CopyBuffer, dword [_TempSpace], word 32, word 32, dword [_ScreenOff], word 640, word 480, word TankMenuX+281, word TankMenuY+260
	invoke	_CopyBuffer, dword [_UpArrow], word 32, word 32, dword [_ScreenOff], word 640, word 480, word TankMenuX+316, word TankMenuY+260
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	mov	byte [_Color], 2
	and	byte [_MPFlags], 10111111b	
	jmp	near .Retry
.Co2b:
	cmp	byte [_Color], 2
	jne	near .Co3b
	invoke	_CopyBuffer, dword [_TempSpace], word 32, word 32, dword [_ScreenOff], word 640, word 480, word TankMenuX+316, word TankMenuY+260
	invoke	_CopyBuffer, dword [_UpArrow], word 32, word 32, dword [_ScreenOff], word 640, word 480, word TankMenuX+351, word TankMenuY+260
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	mov	byte [_Color], 3
	and	byte [_MPFlags], 10111111b	
	jmp	near .Retry

.Co3b:
	cmp	byte [_Color], 3
	jne	near .Co4b
	invoke	_CopyBuffer, dword [_TempSpace], word 32, word 32, dword [_ScreenOff], word 640, word 480, word TankMenuX+351, word TankMenuY+260
	invoke	_CopyBuffer, dword [_UpArrow], word 32, word 32, dword [_ScreenOff], word 640, word 480, word TankMenuX+386, word TankMenuY+260
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	mov	byte [_Color], 4
	and	byte [_MPFlags], 10111111b	
	jmp	near .Retry

.Co4b:
	cmp	byte [_Color], 4
	jne	near .Retry
	invoke	_CopyBuffer, dword [_TempSpace], word 32, word 32, dword [_ScreenOff], word 640, word 480, word TankMenuX+386, word TankMenuY+260
	invoke	_CopyBuffer, dword [_UpArrow], word 32, word 32, dword [_ScreenOff], word 640, word 480, word TankMenuX+421, word TankMenuY+260
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	mov	byte [_Color], 5
	and	byte [_MPFlags], 10111111b	
	jmp	near .Retry

.Save:	; if we are here, we are intending to save our flags
	cmp	byte [_Color], 1
	jne	.Color2
	mov	dword [_SkyColor], 0h
	jmp	near .Store
.Color2:
	cmp	byte [_Color], 2
	jne	.Color3
	mov	dword [_SkyColor], 04040h
	jmp	near .Store
.Color3:
	cmp	byte [_Color], 3
	jne	.Color4
	mov	dword [_SkyColor], 0D24B00h
	jmp	near .Store
.Color4:
	cmp	byte [_Color], 4
	jne	.Color5
	mov	dword [_SkyColor], 408080h
	jmp	near .Store
.Color5:
	mov	dword [_SkyColor], 0234567h
	jmp	near .Store
.Store:
	mov	al, byte [_WindFlag]
	mov	byte [_WindFlagS], al

	mov	al, byte [_SoundFlag]
	mov	byte [_SoundFlagS], al

	mov	al, byte [_Rounds]
	mov	byte [_RoundsS], al

	mov	eax, dword [_SkyColor]
	mov	dword [_SkyColorS], eax
	
	mov	al, byte [_Color]
	mov	byte [_ColorS], al

	mov	eax, 0
	mov	al, byte [_Rounds]
	mov	byte [_rnd], al	

.Exit:	; since we are exiting without saving our flags at this point, restore previous flags

	mov	al, byte [_WindFlagS]
	mov	byte [_WindFlag], al

	mov	al, byte [_SoundFlagS]
	mov	byte [_SoundFlag], al

	mov	al, byte [_RoundsS]
	mov	byte [_Rounds], al

	mov	eax, dword [_SkyColorS]
	mov	dword [_SkyColor], eax
	
	mov	al, byte [_ColorS]
	mov	byte [_Color], al

	invoke	_CopyBuffer, dword [_ScreenTemp], word 640, word 480, dword [_ScreenOff], word 640, word 480, word 0, word 0
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0

.End:
	and	byte [_MPFlags], 10111111b	
	popad
	ret


;=============================================================================================
; ____________________________________________________________________________________________
; 
; _InitializeGame(dword *Screen, dword *PlTankOffset, dword *P2TankOffset)
;	
;  Inputs:
;	Screen	-> offset to the screen
;	P1TankOffset	->	Offset to Player 1's Tank
;	P2TankOffset	->	Offset to Player 2's Tank
;	
;  Purpose:
;	Draws the main game screen, with land, background color, and tanks
; Created by: Terrence Janas
; --------------------------------------------------------------------------------------------
proc _InitializeGame
.Screen		arg	4
.P1TankOff	arg	4
.P2TankOff	arg	4

pushad

; Draw the bare-bone main screen
invoke	_DrawMainScreen, dword [ebp+.Screen]


; Initialize Variables
mov	ax, 0
mov	al, byte [_rnd]
mov	word [_Rounds], ax

mov	word [_p1modu], 0
mov	word [_p2modu], 0

mov	byte [_p1won], 0
mov	byte [_p2won], 0

mov	word [_roundscore], 0
mov	word [_turnsp1], 0
mov	word [_turnsp2], 0

mov	byte [_winner], 0

mov	byte [_Dead], 0
mov	word [_Player1Score], 0
mov	word [_Player2Score], 0

mov	word [_Player1Angle], 0
mov	word [_Player2Angle], 180

mov	word [_P1GunSize], 15
mov	word [_P2GunSize], 15

mov	word [_Turn], PLAYER1

mov	word [_P1TankPos], 0
mov	word [_P2TankPos], 9

mov	word [_P1Power], 0
mov	word [_P2Power], 0

mov	byte [_exit], 0

mov	word [_LandNumber], 0
; Draw the Land
invoke	_GetLand, dword [_GameOff], word LandWidth, word LandHeight, dword [ebp+.Screen], word 640, word 480, word [_LandNumber], dword [_SkyColor]

; Display Scores, Angles, and Power
invoke	_DisplayScore, word [_Player1Score], dword [ebp+.Screen], word P1_Score_X, word P1_Score_Y
invoke	_DisplayScore, word [_Player2Score], dword [ebp+.Screen], word P2_Score_X, word P2_Score_Y

invoke	_DrawString, dword _Player1Name, dword [_ScreenOff], word P1_Name_X, word P1_Name_Y, dword [_DefaultColor]
invoke	_DrawString, dword _Player2Name, dword [_ScreenOff], word P2_Name_X, word P2_Name_Y, dword [_DefaultColor]

invoke	_DisplayPowerAngle, word ZEROS, word [_Player1Angle], dword [ebp+.Screen], word PosAngle_X, word PosAngle_Y
invoke	_DisplayPowerAngle, word ZEROS, word [_P1Power], dword [ebp+.Screen], word PosPower_X, word PosPower_Y

; Draw the tanks
invoke	_GetTankBK, word PLAYER1, dword [ebp+.Screen], word [_LandNumber]
invoke	_GetTankBK, word PLAYER2, dword [ebp+.Screen], word [_LandNumber]

invoke	_DrawTank, dword [_Tank1], word [_P1TankPos], word PLAYER1, dword [ebp+.Screen], word [_LandNumber]
invoke	_DrawTank, dword [_Tank2], word [_P2TankPos], word PLAYER2, dword [ebp+.Screen], word [_LandNumber]

popad
ret
endproc
_InitializeGame_arglen	EQU	12



;=============================================================================================
; ____________________________________________________________________________________________
; 
; _SetScoreGun(word player, word turns)
;	
;  Inputs:
;	player	-> Player 1 or Player 2?
;	turns	-> How many turns it took to hit someone
;  Purpose:
;	Depending on how many turns the player took... we obtain a different round score
;	0 attempts (i.e... the other person blew themselves up)		-> 1600pts
;	1 attempt							-> 1500pts, etc....
;	Also, the function also displays when the player has reached a new gun-size level
;  Created by: Yajur Parikh
; --------------------------------------------------------------------------------------------
proc	_SetScoreGun
.player		arg	2
.turns		arg	2

pushad

mov	word [_roundscore], 5
cmp	word [ebp+.turns], 8
jg	near .dispscore

; calculate score
mov	ax, 16
sub	ax, word [ebp+.turns]
mov	word [_roundscore], ax

; display score
.dispscore:
	invoke	_DisplayScore, word [_roundscore], dword [_ScreenOff], word TankMenuX+273, word TankMenuY+204

; now either update player 1, or player 2's score, depending on who it is
cmp	word [ebp+.player], PLAYER1
jne	near .itsplayer2

mov	ax, word [_roundscore]
add	word [_Player1Score], ax

cmp	word [_Player1Score], 15
jl	near .normalp1

cmp	word [ebp+.turns], 1
jle	near .drawp1

; now see if the person upgraded gun levels
.normalp1:
mov	ax, word [_Player1Score]
mov	dx, 0
mov	cx, 15
div	cx			; dx: ax	dx = remainder
add	word [_p1modu], dx
cmp	word [_p1modu], 15
jl	near .Done
sub	word [_p1modu], 15

.drawp1:
call _LevelUpSound		; celebration music
invoke	_CopyBuffer, dword [_LevelUp], word 224, word 54, dword [_ScreenOff], word 640, word 480, word TankMenuX+126, word TankMenuY+273
invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
jmp	near .Done

; do the same checks for player 2
.itsplayer2:
mov	ax, word [_roundscore]
add	word [_Player2Score], ax

cmp	word [_Player2Score], 15
jl	near .normalp2

cmp	word [ebp+.turns], 1
jle	near .drawp2

.normalp2:
mov	ax, word [_Player2Score]
mov	dx, 0
mov	cx, 15
div	cx		; dx: ax	dx = remainder
add	word [_p2modu], dx
cmp	word [_p2modu], 15
jl	near .Done
sub	word [_p2modu], 15
.drawp2:
call	_LevelUpSound
invoke	_CopyBuffer, dword [_LevelUp], word 224, word 54, dword [_ScreenOff], word 640, word 480, word TankMenuX+126, word TankMenuY+273
invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0

.Done:
popad
ret
endproc
_SetScoreGun_arglen	EQU	4


;=============================================================================================
; ____________________________________________________________________________________________
; 
; _FillGunBox(word player, word score)
;	
;  Inputs:
;	player	-> Player 1 or Player 2?
;	score	-> end of round add-on score
;  Purpose:
;	depending on the player's score, we determine by how much (or if any) we increase 
;	the players gun detonation size.
;  Created by: Terrence Janas
; --------------------------------------------------------------------------------------------
proc	_FillGunBox
.player		arg	2
.score		arg	2

pushad

; PLAYER 1's Gun BOXES
cmp	word [ebp+.player], PLAYER1
jne	near .player2

cmp	byte [ebp+.score], 75
jl	near .try60

invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word 84+100, word 456, dword [_FillColor], dword [_FillColor]
add	word [_P1GunSize], 5

.try60:
cmp	byte [ebp+.score], 60
jl	near .try45
invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word 84+75, word 456, dword [_FillColor], dword [_FillColor]
add	word [_P1GunSize], 5

.try45:
cmp	byte [ebp+.score], 45
jl	near .try30
invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word 84+50, word 456, dword [_FillColor], dword [_FillColor]
add	word [_P1GunSize], 5

.try30:
cmp	byte [ebp+.score], 30
jl	near .try15
invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word 84+25, word 456, dword [_FillColor], dword [_FillColor]
add	word [_P1GunSize], 5

.try15:
cmp	byte [ebp+.score], 15
jl	near .done
invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word 84, word 456, dword [_FillColor], dword [_FillColor]
add	word [_P1GunSize], 5
jmp	near .done

; PLAYER 2's GUN BOXES
.player2:
cmp	byte [ebp+.score], 75
jl	.try60b
invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word 507+100, word 456, dword [_FillColor], dword [_FillColor]
add	word [_P2GunSize], 5

.try60b:
cmp	byte [ebp+.score], 60
jl	.try45b
invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word 507+75, word 456, dword [_FillColor], dword [_FillColor]
add	word [_P2GunSize], 5

.try45b:
cmp	byte [ebp+.score], 45
jl	.try30b
invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word 507+50, word 456, dword [_FillColor], dword [_FillColor]
add	word [_P2GunSize], 5

.try30b:
cmp	byte [ebp+.score], 30
jl	.try15b
invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word 507+25, word 456, dword [_FillColor], dword [_FillColor]
add	word [_P2GunSize], 5

.try15b:
cmp	byte [ebp+.score], 15
jl	near .done
invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word 507, word 456, dword [_FillColor], dword [_FillColor]
add	word [_P2GunSize], 5

.done:
invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
popad
ret
endproc
_FillGunBox_arglen	EQU	4




;=============================================================================================
; ____________________________________________________________________________________________
; 
; _PlayGame
;
;  Inputs: none
;  Outputs: none	
;  Purpose:
;	Directs traffic during the game.  Sets up, and follows the flow of the game
;  Created by: Suneil Hosmane
; --------------------------------------------------------------------------------------------
_PlayGame
	
.LoopGame:

; check to see if the wind flag is on
; if so, display wind speed
cmp	byte [_WindFlag], 1
jne	near .movealong
call	_GetWind
push	ax
push	cx
push	dx
mov	ax, 0
mov	al, byte [_Wind]
and	al, 01111111b
mov	dx, 0
mov	cx, 10
div	cx		; dx = ones digit, ax = tens digit
call	_ReturnAsciiChar
mov	byte [_WindString+0], al
mov	ax, dx
call	_ReturnAsciiChar
mov	byte [_WindString+1], dl
mov	byte [_WindString+2], '$'
pop	dx
pop	cx
pop	ax
invoke	_DrawString, dword _WindString, dword [_ScreenOff], word 373, word 430, dword [_DefaultColor]
test	byte [_Wind], 10000000b
jnz	near .drawleft
; now draw arrows indicating wind direction
invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word 383, word 465, dword 010101h, dword 0
invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word 398, word 461, dword 0FFFF00h, dword 0
jmp	near .movealong
.drawleft
invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word 383, word 465, dword 0FFFF00h, dword 0
invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word 398, word 461, dword 010101h, dword 0

; now flood fill the player's star (indicating player's turn)
.movealong:
cmp	word [_Turn], PLAYER1
jne	near .PLAYA2
; Flood Fill Player 1's star
invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word 189, word 425, dword 0FFFF00h, dword 0
invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word 613, word 425, dword 010101h, dword 0
invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0

invoke	_DisplayPowerAngle, word NOCHANGE, word [_Player1Angle], dword [_ScreenOff], word PosAngle_X, word PosAngle_Y
invoke	_DisplayPowerAngle, word NOCHANGE, word [_P1Power], dword [_ScreenOff], word PosPower_X, word PosPower_Y
call	_Player1Set	; this function allows the player to move the barrel or fire the gun

; we obtain a flag from _Player1Set
; FIRE = Its time to fire the gun
; EXIT_GAME = I want to leave the game/program
cmp	al, FIRE
je	near .DrawProjectile

cmp	al, EXIT_GAME
je	near .ExitGame

; This screen makes the explosion
.BlowUP:
	call _ImpactSound	; musi
	mov	word [_gamecounter], 0
	.BlowBigger
	invoke	_DrawCircle, dword [_ScreenOff], word 640, word 480, word [_HitX], word [_HitY], word [_gamecounter], dword 0FFA00000h, dword 1
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword GameScreenX, dword GameScreenY, dword 640, dword 397, dword GameScreenX, dword GameScreenY
	inc	word [_gamecounter]
	cmp	word [_gamecounter], 600
	jne	near .BlowBigger

	; now display the "winner's" screen
	invoke	_ClearBuffer, dword [_Overlay], word 640, word 480, dword 0A0000000h
	invoke	_ComposeBuffers, dword [_Overlay], word 640, word 480, dword [_ScreenOff], word 640, word 480, word 0, word 0
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	invoke	_LoadPNG, dword _EndOfRoundFN, dword [_AllPurposeMenu], dword 0, dword 0
	invoke	_CopyBuffer, dword [_AllPurposeMenu], word 480, word 360, dword [_ScreenOff], word 640, word 480, word TankMenuX, word TankMenuY
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	
	; Now Display what round it is
	push	eax
	mov	ax, 0
	mov	al, byte [_rnd]
	sub	al, byte [_Rounds]
	inc	al

	call	_ReturnAsciiChar
	mov	byte [_RoundString+0], al
	mov	byte [_RoundString+1], '$'
	pop	eax
	dec	byte [_Rounds]
	invoke	_DrawString, dword _RoundString, dword [_ScreenOff], word TankMenuX+233, word TankMenuY+94, dword [_DefaultColor]
	
	
	cmp	byte [_winner], PLAYER1
	jne	.PLAYER2WON
	
	; Display player 1's name, because he won
	invoke	_DrawString, dword _Player1Name, dword [_ScreenOff], word TankMenuX+273, word TankMenuY+160, dword [_DefaultColor]
	invoke	_SetScoreGun, word PLAYER1, word [_turnsp1]
	inc	byte [_p1won]
	jmp	near .Reinitialize
	
	.PLAYER2WON:
	; Display player 2's name, because he won
	inc	byte [_p2won]
	invoke	_DrawString, dword _Player2Name, dword [_ScreenOff], word TankMenuX+273, word TankMenuY+160, dword [_DefaultColor]
	invoke	_SetScoreGun, word PLAYER2, word [_turnsp2]

	.Reinitialize:		; Now that the round is over, we must reinitialize some of our variables
	
	and	byte [_MPFlags], 10111111b
	mov	byte [_key], 0

	.pause:	; wait for ENTER key
		test	byte [_MPFlags], 01000000b	
		jz	near .pause

		cmp	byte [_key], ENTR
		jne	.pause
	
	and	byte [_MPFlags], 10111111b	

	; reset some variables
	
	cmp	byte [_Rounds], 0
	je	near .EndOfGame

	mov	word [_roundscore], 0
	mov	byte [_turnsp1], 0
	mov	byte [_turnsp2], 0

	mov	byte [_winner], 0

	mov	word [_Player1Angle], 0
	mov	word [_Player2Angle], 180

	push	ax
	mov	al, byte [_Dead]
	mov	word [_Turn], ax
	pop	ax

	mov	byte [_Dead], 0

	mov	word [_P1GunSize], 15
	mov	word [_P2GunSize], 15

	mov	word [_P1TankPos], 0
	mov	word [_P2TankPos], 9

	mov	word [_P1Power], 0
	mov	word [_P2Power], 0

	inc	word [_LandNumber]

	; redraw the land
	invoke	_DrawMainScreen, dword [_ScreenOff]
	invoke	_GetLand, dword [_GameOff], word LandWidth, word LandHeight, dword [_ScreenOff], word 640, word 480, word [_LandNumber], dword [_SkyColor]
	invoke	_DisplayScore, word [_Player1Score], dword [_ScreenOff], word P1_Score_X, word P1_Score_Y
	invoke	_DisplayScore, word [_Player2Score], dword [_ScreenOff], word P2_Score_X, word P2_Score_Y
	invoke	_DrawString, dword _Player1Name, dword [_ScreenOff], word P1_Name_X, word P1_Name_Y, dword [_DefaultColor]
	invoke	_DrawString, dword _Player2Name, dword [_ScreenOff], word P2_Name_X, word P2_Name_Y, dword [_DefaultColor]
	invoke _FillGunBox, word PLAYER1, word [_Player1Score]
	invoke _FillGunBox, word PLAYER2, word [_Player2Score]
	invoke	_DisplayPowerAngle, word ZEROS, word [_Player1Angle], dword [_ScreenOff], word PosAngle_X, word PosAngle_Y
	invoke	_DisplayPowerAngle, word ZEROS, word [_P1Power], dword [_ScreenOff], word PosPower_X, word PosPower_Y
	invoke	_GetTankBK, word PLAYER1, dword [_ScreenOff], word [_LandNumber]
	invoke	_GetTankBK, word PLAYER2, dword [_ScreenOff], word [_LandNumber]
	invoke	_DrawTank, dword [_Tank1], word [_P1TankPos], word PLAYER1, dword [_ScreenOff], word [_LandNumber]
	invoke	_DrawTank, dword [_Tank2], word [_P2TankPos], word PLAYER2, dword [_ScreenOff], word [_LandNumber]
	jmp	near .LoopGame	

; Here, we are at the end of the game,
; first display who won, their name, score, and victories
.EndOfGame:
	invoke	_ClearBuffer, dword [_Overlay], word 640, word 480, dword 0A0000000h
	invoke	_ComposeBuffers, dword [_Overlay], word 640, word 480, dword [_ScreenOff], word 640, word 480, word 0, word 0
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0

	invoke	_LoadPNG, dword _EndofGameFN, dword [_AllPurposeMenu], dword 0, dword 0 
	invoke	_CopyBuffer, dword [_AllPurposeMenu], word 480, word 360, dword [_ScreenOff], word 640, word 480, word TankMenuX, word TankMenuY
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0

	invoke	_DisplayScore, word [_Player1Score], dword [_ScreenOff], word TankMenuX+45, word TankMenuY+174
	invoke	_DisplayScore, word [_Player2Score], dword [_ScreenOff], word TankMenuX+308, word TankMenuY+174

	invoke	_DrawString, dword _Player1Name, dword [_ScreenOff], word TankMenuX+45, word TankMenuY+142, dword [_DefaultColor]
	invoke	_DrawString, dword _Player2Name, dword [_ScreenOff], word TankMenuX+308, word TankMenuY+142, dword [_DefaultColor]

	push	eax
	mov	al, byte [_p1won]
	call	_ReturnAsciiChar
	mov	byte [_EndofGameString], al
	mov	byte [_EndofGameString+1], ':'
	mov	al, byte [_p2won]
	call	_ReturnAsciiChar
	mov	byte [_EndofGameString+2], al
	mov	byte [_EndofGameString+3], '$'
	pop	eax
	invoke	_DrawString, dword _EndofGameString, dword [_ScreenOff], word TankMenuX+218, word TankMenuY+216, dword [_DefaultColor]

	call _BattleHymn

	push	eax
	mov	al, byte [_p2won]
	cmp	byte [_p1won], al
	pop	eax
	jb	near .player2won
	
	invoke	_LoadPNG, dword _TrophyFN, dword [_TankDump], dword 0, dword 0 
	invoke	_CopyBuffer, dword [_TankDump], word 60, word 60, dword [_ScreenOff], word 640, word 480, word TankMenuX+82, word TankMenuY+269
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	jmp	near .exitselection

.player2won:
	invoke	_LoadPNG, dword _TrophyFN, dword [_TankDump], dword 0, dword 0 
	invoke	_CopyBuffer, dword [_TankDump], word 60, word 60, dword [_ScreenOff], word 640, word 480, word TankMenuX+338, word TankMenuY+269
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	
; now, the person has a choice between exiting to the main menu, exit altogether, or play another match
.exitselection:
	and	byte [_MPFlags], 10111111b
	mov	byte [_key], 0
	.holdon:
		test	byte [_MPFlags], 01000000b	
		jz	near .holdon

		cmp	byte [_key], ENTR
		jne	.holdon
	
		and	byte [_MPFlags], 10111111b	
	
	invoke	_ClearBuffer, dword [_Overlay], word 640, word 480, dword 0A0000000h
	invoke	_ComposeBuffers, dword [_Overlay], word 640, word 480, dword [_ScreenOff], word 640, word 480, word 0, word 0
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0

	invoke	_LoadPNG, dword _NewgameFN, dword [_MiniMenu], dword 0, dword 0 
	invoke	_CopyBuffer, dword [_MiniMenu], word 400, word 160, dword [_ScreenOff], word 640, word 480, word 120, word 160
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	and	byte [_MPFlags], 10111111b

; second exit menu
.check:
	test	byte [_MPFlags], 01000000b	
	jz	near .check

	cmp	byte [_key], 'y'
	jne	near .tryno
	jmp	near .startnewgame

	.tryno:
	cmp	byte [_key], 'n'
	jne	near .check
	and	byte [_MPFlags], 10111111b	

.secondmenu:
	invoke	_LoadPNG, dword _ExitToMainFN, dword [_MiniMenu], dword 0, dword 0 
	invoke	_CopyBuffer, dword [_MiniMenu], word 400, word 160, dword [_ScreenOff], word 640, word 480, word 120, word 160
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	
	and	byte [_MPFlags], 10111111b
	mov	byte [_key], 0

.pause2:
	test	byte [_MPFlags], 01000000b	
	jz	near .pause2

	cmp	byte [_key], 'm'
	jne	near .quit
	mov	byte [_exit], 0
	jmp	near .End
	
	.quit:
	cmp	byte [_key], 'q'
	jne	near .pause2
	mov	byte [_exit], 1
	jmp	near .End

.startnewgame:
	invoke	_InitializeGame, dword [_ScreenOff], dword [_Tank1], dword [_Tank2]
	jmp	near .LoopGame

.ExitGame:
jmp	near .End


; we have hit ENTER somewhere, so draw a projectile
.DrawProjectile:
call _FiringSound
cmp	word [_Turn], PLAYER1
jne	.p2tries
inc	word [_turnsp1]
jmp	.startcommand
.p2tries:
inc	word [_turnsp2]
.startcommand
call	_DrawProjectile
and	byte [_MPFlags], 10111111b	
cmp	byte [_Dead], 0
jne	near .BlowUP
jmp	near .Cont


; Same exact procedure except for player 2
.PLAYA2:
; Flood Fill Player 1's star
invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word 189, word 425, dword 010101h, dword 0
invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word 613, word 425, dword 0FFFF00h, dword 0
invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0

invoke	_DisplayPowerAngle, word NOCHANGE, word [_P2Power], dword [_ScreenOff], word PosPower_X, word PosPower_Y
invoke	_DisplayPowerAngle, word NOCHANGE, word [_Player2Angle], dword [_ScreenOff], word PosAngle_X, word PosAngle_Y
call	_Player2Set

cmp	al, FIRE
je	near .DrawProjectile
cmp	al, EXIT_GAME
je	near .ExitGame

.Cont:
cmp	word [_Turn], PLAYER1
je	near .SwitchToPlayer2

mov	word [_Turn], PLAYER1
jmp	near .LoopGame

.SwitchToPlayer2:
	mov	word [_Turn], PLAYER2
	jmp	near .LoopGame
.End:
ret	
	

;=============================================================================================
; ____________________________________________________________________________________________
; 
; _DrawProjectile
;	
;  Inputs: none
;  Outputs: none
;  Purpose:
;	When a person has hit the enter button, know the starting location, we can
;	perfrom physics equations to obtain the final location.  Also determines whether or 
;	not a player has been hit
; Created by: Yajur Parikh	
;  
;	y = yo + vy * t - 1/2 * at^2
;	x = vt
; --------------------------------------------------------------------------------------------
_DrawProjectile

invoke	_CopyBuffer, dword [_ScreenOff], word 640, word 480, dword [_ScreenTemp], word 640, word 480, word 0, word 0

cmp	word [_Turn], PLAYER2
je	near .PLAYA2

movzx	esi, word [_P1TankPos]
cmp	byte [_P1Tank], 1
jne	near .T2

.T1set:
movzx	ecx, word [_TankAngle1+esi*4+0]
movzx	edx, word [_TankAngle1+esi*4+2]
jmp	near .Start

.T2:
	cmp	byte [_P1Tank], 2
	jne	near .T3
.T2set:
	movzx	ecx, word [_TankAngle2+esi*4+0]
	movzx	edx, word [_TankAngle2+esi*4+2]
	jmp	near .Start
	
.T3:
	cmp	byte [_P1Tank], 3
	jne	near .T4
.T3set:	
	movzx	ecx, word [_TankAngle3+esi*4+0]
	movzx	edx, word [_TankAngle3+esi*4+2]
	jmp	near .Start

.T4:
	cmp	byte [_P1Tank], 4
	jne	near .T5
.T4set:
	movzx	ecx, word [_TankAngle4+esi*4+0]
	movzx	edx, word [_TankAngle4+esi*4+2]
	jmp	near .Start
	
.T5:
	cmp	byte [_P1Tank], 5
	jne	near .T6
.T5set:	
	movzx	ecx, word [_TankAngle5+esi*4+0]
	movzx	edx, word [_TankAngle5+esi*4+2]
	jmp	near .Start

.T6:
	movzx	ecx, word [_TankAngle6+esi*4+0]
	movzx	edx, word [_TankAngle6+esi*4+2]
	
.Start:
cmp	word [_Turn], PLAYER2
jne	near .SetSC1
movzx	esi, word [_LandNumber]
movzx	eax, word [_TankCoords+esi*8+4]
movzx	ebx, word [_TankCoords+esi*8+6]
jmp	near .AddCoords

.SetSC1:
	movzx	esi, word [_LandNumber]
	movzx	eax, word [_TankCoords+esi*8+0]
	movzx	ebx, word [_TankCoords+esi*8+2]
	

.AddCoords:
	add	ecx, eax
	add	edx, ebx


mov	dword [_tmpX], ecx
mov	dword [_tmpY], edx	

mov	dword [_previousX], ecx
mov	dword [_previousY], edx
	
finit
emms
	
cmp	word [_Turn], PLAYER2
je	near .SetDifferentAngle
fild	word [_Player1Angle]
jmp	near .SetAngle

.SetDifferentAngle
	fild	word [_Player2Angle]

.SetAngle
fmul	dword [_RadianConversion]
fsincos			; sto = cos theta
			; st1 = sin theta

cmp	word [_Turn], PLAYER2
je	near .SetDifferentPower

fimul	word [_P1Power]
fstp	dword [_fvx]	; x velocity

fimul	word [_P1Power]	
fstp	dword [_fvy]	; y velocity
jmp	near .SetPower


.SetDifferentPower:
	fimul	word [_P2Power]
	fstp	dword [_fvx]	; x velocity
	
	fimul	word [_P2Power]	
	fstp	dword [_fvy]	; y velocity

.SetPower:
fld	dword [_SampleFactor]
fstp	dword [_ft]
	
mov	byte [_F], 0

.OnceAgain:

	fld	dword [_Gravity]	
	fmul	dword [_ft]

	fadd	dword [_fvy]
	fmul	dword [_ft]	; = vy*t - 1/2*a*t^2

	fistp	dword [_ty]

	fld	dword [_fvx]
	cmp	byte [_WindFlag], 1
	jne	.skip
	cmp	byte [_Wind], 0
	jl	near .sub
	fiadd	word [_Wind]
	jmp	near .skip
	.sub:
	fisub	word [_Wind]
	.skip:
	fmul	dword [_ft]
	fistp	dword [_tx]

	mov	eax, dword [_tx]
	mov	ebx, dword [_ty]

	add	dword [_tmpX], eax
	sub	dword [_tmpY], ebx

	invoke	_DrawBullet, dword [_ScreenOff], word 640, word 397, word [_previousX], word [_previousY], word [_tmpX], word [_tmpY], dword 00FFFFFFh
	cmp	byte [_F], HIT
	je	near .Hit
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword GameScreenX, dword GameScreenY, dword 640, dword 397, dword GameScreenX, dword GameScreenY
	pushad
	invoke	_Delay, dword 1
	popad

	cmp	byte [_F], OUTOFBOUNDS
	je	near .SetUpForPlayer2
	
	mov	ecx, dword [_tmpX]
	mov	dword [_previousX], ecx
	
	mov	edx, dword [_tmpY]
	mov	dword [_previousY], edx

	sub	dword [_tmpX], eax
	add	dword [_tmpY], ebx

	fld	dword [_ft]
	fadd	dword [_ft]
	fstp	dword [_ft]
	
	finit
	emms
	jmp	near .OnceAgain

.PLAYA2
movzx	esi, word [_P2TankPos]

cmp	byte [_P2Tank], 1
je	near .T1set

cmp	byte [_P2Tank], 2
je	near .T2set
	
cmp	byte [_P2Tank], 3
je	near .T3set

cmp	byte [_P2Tank], 4
je	near .T4set
	
cmp	byte [_P2Tank], 5
je	near .T5set

jmp	near .T6
	

	.SetUpForPlayer2:
		mov	byte [_F], 0
		invoke	_CopyBuffer, dword [_ScreenTemp], word 640, word 480, dword [_ScreenOff], word 640, word 480, word 0, word 0
		pushad
		invoke	_Delay, dword 20
		popad
		invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
		jmp	near .END


.Hit:
	movzx	eax, word [_P2GunSize]
	cmp	byte [_Turn], PLAYER1
	jne	near .Proceed
	mov	ax, word [_P1GunSize]

	.Proceed
	mov	word [_gunsize], ax
	movzx	esi, word [_LandNumber]
	movzx	eax, word [_TankCoords+esi*8+0]
	movzx	ebx, word [_TankCoords+esi*8+2]
	mov	ecx, eax
	mov	edx, ebx

	cmp	byte [_P1Tank], 5
	je	near .Special_3

	cmp	byte [_P1Tank], 2
	je	near .Special_1

	add	eax, 11
	sub	ax, word [_gunsize]
	
	add	ebx, 11
	sub	bx, word [_gunsize]
	
	add	ecx, 41
	add	cx, word [_gunsize]
	
	add	edx, 43
	add	dx, word [_gunsize]
	jmp	near .inspect_a

	.Special_1:	
	add	eax, 23
	sub	ax, word [_gunsize]
	
	add	ebx, 23
	sub	bx, word [_gunsize]
	
	add	ecx, 50
	add	cx, word [_gunsize]
	
	add	edx, 50
	add	dx, word [_gunsize]
	jmp	near .inspect_a
	
	.Special_3:	
	add	eax, 10
	sub	ax, word [_gunsize]
	
	add	ebx, 10
	sub	bx, word [_gunsize]
	
	add	ecx, 45
	add	cx, word [_gunsize]
	
	add	edx, 45
	add	dx, word [_gunsize]


	.inspect_a:
	cmp	word [_HitX], ax
	jb	near .Maybe

	cmp	word [_HitX], cx
	ja	near .Maybe

	cmp	word [_HitY], bx
	jb	near .Maybe

	cmp	word [_HitY], dx
	ja	near .Maybe
	
	mov	byte [_Dead], PLAYER1
	mov	byte [_winner], PLAYER2
	jmp	near .END

	.Maybe:

	movzx	eax, word [_TankCoords+esi*8+4]
	movzx	ebx, word [_TankCoords+esi*8+6]
	mov	ecx, eax
	mov	edx, ebx

	cmp	byte [_P2Tank], 2
	je	near .Special_2

	cmp	byte [_P1Tank], 5
	je	near .Special_4

	add	eax, 11
	sub	ax, word [_gunsize]
	
	add	ebx, 11
	sub	bx, word [_gunsize]
	
	add	ecx, 41
	add	cx, word [_gunsize]
	
	add	edx, 43
	add	dx, word [_gunsize]

	jmp	near .inspect_b

	.Special_2:
	add	eax, 23
	sub	ax, word [_gunsize]
	
	add	ebx, 23
	sub	bx, word [_gunsize]
	
	add	ecx, 50
	add	cx, word [_gunsize]
	
	add	edx, 50
	add	dx, word [_gunsize]
	jmp	near .inspect_b
	
	.Special_4:
	add	eax, 10
	sub	ax, word [_gunsize]
	
	add	ebx, 10
	sub	bx, word [_gunsize]
	
	add	ecx, 45
	add	cx, word [_gunsize]
	
	add	edx, 45
	add	dx, word [_gunsize]


	.inspect_b
	cmp	word [_HitX], ax
	jb	near .END

	cmp	word [_HitX], cx
	ja	near .END

	cmp	word [_HitY], bx
	jb	near .END

	cmp	word [_HitY], dx
	ja	near .END
	
	mov	byte [_Dead], PLAYER2
	mov	byte [_winner], PLAYER1

.END:
ret


;______________________________________________________________
;                         DrawBullet()                  
; 
; Inputs: X1 & X2 Coords, Y1 & Y2 Coods, Destination Offset, 
;         Destination Height, Destination Width, and Color
; 
; Outputs: Draw a line with color Color from point (X1,Y1) to
;	   (X2,Y2) using the graphics algorithm given
; Created by: Yajur Parikh	
;--------------------------------------------------------------
proc _DrawBullet
.DestOff	arg	4
.DestWidth	arg	2
.DestHeight	arg	2
.X1		arg	2
.Y1		arg	2
.X2		arg	2
.Y2		arg	2
.Color		arg	4

push	eax
push	ebx
push	ecx
push	edx

; The lines below perform:
; dx = abs(x2-x1)
mov	ax, word [ebp+.X1]	
mov	bx, word [ebp+.X2]
cmp	ax, bx
jge	near .A_IS_BIGGER
sub	bx, ax
mov	word [_dx], bx
jmp	near .NowForTheYs

.A_IS_BIGGER:
	sub	ax, bx
	mov	word [_dx], ax

; Same process as above
; instead we are now calculating
; dy = abs(y2-y1)
.NowForTheYs:
mov	ax, word [ebp+.Y1]
mov	bx, word [ebp+.Y2]
cmp	ax, bx
jge	near .A_IS_BIGGER2
sub	bx, ax
mov	word [_dy], bx
jmp	near .SetVars

.A_IS_BIGGER2:
	sub	ax, bx
	mov	word [_dy], ax

; The code below sets up the variables for the line function prior to
; looping
.SetVars:
mov	ax, word [_dx]
mov	bx, word [_dy]
cmp	word [_dx], bx
jge	near .DX_IS_BIGGER

mov	cx, bx
inc	cx				; numpixels = dy + 1

mov	word [_lineerror], ax		; line error = dx
shl	word [_lineerror], 1		; line error = dx * 2
sub	word [_lineerror], bx		; line error = (2 * dx) - dy

mov	word [_errornodiaginc], ax	; errornodiaginc = dx
shl	word [_errornodiaginc], 1	; errornodiaginc = dx * 2

mov	word [_errordiaginc], ax	; = dx
sub	word [_errordiaginc], bx	; = dx - dy
shl	word [_errordiaginc], 1		; = (dx - dy) * 2

mov	word [_xhorizinc], word 0
mov	word [_xdiaginc], word 1
mov	word [_yvertinc], word 1
mov	word [_ydiaginc], word 1
jmp	near .ADJUSTMENTS

.DX_IS_BIGGER:
	mov	cx, ax		; numpixels = dx
	inc	cx		; numpixels = dx + 1

	mov	word [_lineerror], bx		; line error = dy
	shl	word [_lineerror], 1		; line error = dy * 2
	sub	word [_lineerror], ax		; line error = (2 * dy) - dx

	mov	word [_errornodiaginc], bx	; errornodiaginc = dy
	shl	word [_errornodiaginc], 1	; errornodiaginc = dy * 2

	mov	word [_errordiaginc], bx	; = dy
	sub	word [_errordiaginc], ax	; = dy - dx
	shl	word [_errordiaginc], 1		; = (dy - dx) * 2

	mov	word [_xhorizinc], word 1
	mov	word [_xdiaginc], word 1
	mov	word [_yvertinc], word 0
	mov	word [_ydiaginc], word 1

.ADJUSTMENTS:
mov	ax, word [ebp+.X1]
mov	bx, word [ebp+.X2]

cmp	ax, bx
jle	near .NEXT_TEST
	neg	word [_xhorizinc]
	neg	word [_xdiaginc]

.NEXT_TEST:
mov	ax, word [ebp+.Y1]
mov	bx, word [ebp+.Y2]
cmp	ax, bx
jle	near .BEGIN_LOOPING
	neg	word [_yvertinc]
	neg	word [_ydiaginc]
	
.BEGIN_LOOPING:
mov	ax, word [ebp+.X1]
mov	bx, word [ebp+.Y1]

mov	word [_x], ax		; x = X1
mov	word [_y], bx		; y = Y1

mov	dx, 1

.AGAIN:
	cmp	dx, cx
	je	near .END

	cmp	word [_x], 640
	je	near .OutofBounds

	cmp	word [_x], 0
	je	near .OutofBounds
	
	invoke	_PointInBox, word [_x], word [_y], word GameScreenX, word GameScreenY, word GameScreenX+640, word GameScreenY+397
	cmp	eax, 0
	je	near .Skip
	
	invoke	_GetPixel, dword [ebp+.DestOff], word 640, word 480, word [_x], word [_y]
	cmp	eax, dword [_SkyColor]
	jne	near .QUIT

	cmp	word [_y], 13
	jbe	near .OutofBounds

	cmp	word [_y], 410
	jae	near .OutofBounds

	invoke	_DrawPixel, dword [ebp+.DestOff], word [ebp+.DestWidth], word [ebp+.DestHeight], word [_x], word [_y], dword [ebp+.Color]
	.Skip:
	cmp	word [_lineerror], 0
	jge	near .PHASE2	
	mov	ax, word [_errornodiaginc]
	add	word [_lineerror], ax
	mov	ax, word [_xhorizinc]
	mov	bx, word [_yvertinc]
	add	word [_x], ax
	add	word [_y], bx
	inc	dx
	jmp	near .AGAIN

	.PHASE2:
	
		mov	ax, word [_errordiaginc]
		add	word [_lineerror], ax
		mov	ax, word [_xdiaginc]
		mov	bx, word [_ydiaginc]
		add	word [_x], ax
		add	word [_y], bx
		inc	dx
		jmp	near .AGAIN

.OutofBounds:
	mov	byte [_F], OUTOFBOUNDS
	jmp	near .END

.QUIT:
	mov	byte [_F], HIT

	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0

	pushad
	invoke _Delay, dword 5
	popad	

	mov	word [_times], 0

	push	eax
	mov	ax, word [_x]
	mov	word [_specialx], ax
	mov	ax, word [_y]
	mov	word [_specialy], ax
	pop	eax


	.DoItAgain:
	invoke	_DrawCircle, dword [_ScreenOff], word 640, word 480, word [_specialx], word [_specialy], word [_times], dword 0FFA00000h, dword 1
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword GameScreenX, dword GameScreenY, dword 640, dword 397, dword GameScreenX, dword GameScreenY
	
	inc	word [_times]
	push	eax
	mov	ax, word [_P2GunSize]
	cmp	byte [_Turn], PLAYER1
	jne	near .Proceed
	mov	ax, word [_P1GunSize]
	.Proceed
	cmp	word [_times], ax
	pop	eax
	jne	near .DoItAgain
	
	invoke _Delay, dword 10
	
	invoke	_CopyBuffer, dword [_ScreenTemp], word 640, word 480, dword [_ScreenOff], word 640, word 480, word 0, word 0
	
	push	eax
	mov	ax, word [_P2GunSize]
	cmp	byte [_Turn], PLAYER1
	jne	near .Proceed2
	mov	ax, word [_P1GunSize]
	.Proceed2
	mov	word [_times], ax
	pop	eax

	.DoItAgain2:
	invoke	_DrawCircle, dword [_ScreenOff], word 640, word 480, word [_specialx], word [_specialy], word [_times], dword [_SkyColor], dword [_SkyColor]
	
	dec	word [_times]
	cmp	word [_times], 0
	jne	near .DoItAgain2

	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	push	eax	
	mov	ax, word [_specialx]
	mov	word [_HitX], ax
	mov	ax, word [_specialy]
	mov	word [_HitY], ax
	pop	eax

.END:
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax
	ret

endproc
_DrawBullet_arglen	EQU	20


; _______________________________________________________________________
; 
; void Player1Set()
;
; Inputs: none
; Outputs: none
; Function:
;	Handles moving around the tank, set power & angle
;	FIRE		
;	EXIT_GAME	
;	HELP_MENU	flags are set in al
; Created by: Yajur Parikh
; -----------------------------------------------------------------------

_Player1Set

; Display your angle & velocity
invoke	_DisplayPowerAngle, word NOCHANGE, word [_Player1Angle], dword [_ScreenOff], word PosAngle_X, word PosAngle_Y
invoke	_DisplayPowerAngle, word NOCHANGE, word [_P1Power], dword [_ScreenOff], word PosPower_X, word PosPower_Y

.Retry
test	byte [_MPFlags], 01000000b;	
jz	near .Retry

cmp	byte [_key], 'q'
je	near .Exit_Case

cmp	byte [_key], 200
je	near .Help_Case

cmp	byte [_key], ENTR
je	near .Fire_Case

cmp	byte [_key], DOWN
jne	near .TryUp

; we can only angles > 0
cmp	word [_Player1Angle], 0
jle	near .Retry

; PRESS DOWN
invoke	_DisplayPowerAngle, word DEC1, word [_Player1Angle], dword [_ScreenOff], word PosAngle_X, word PosAngle_Y
dec	word [_Player1Angle]
and	byte [_MPFlags], 10111111b	
jmp	near .CheckTank
	
.TryUp
	cmp	byte [_key], UP
	jne	near .TryLeft

	cmp	word [_Player1Angle], 180
	jge	near .Retry

; PRESS UP
invoke	_DisplayPowerAngle, word INC1, word [_Player1Angle], dword [_ScreenOff], word PosAngle_X, word PosAngle_Y
inc	word [_Player1Angle]
and	byte [_MPFlags], 10111111b	
jmp	near .CheckTank
	
.TryLeft
	cmp	byte [_key], LEFT
	jne	near .TryRight

	cmp	word [_P1Power], 0
	je	near .Retry
	
; PRESS LEFT
invoke	_DisplayPowerAngle, word DEC1, word [_P1Power], dword [_ScreenOff], word PosPower_X, word PosPower_Y
dec	word [_P1Power]
and	byte [_MPFlags], 10111111b	
jmp	near .Retry
	
.TryRight:
	cmp	byte [_key], RIGHT
	jne	near .Retry

	cmp	word [_P1Power], MAXPOWER
	je	near .Retry

; PRESS RIGHT
invoke	_DisplayPowerAngle, word INC1, word [_P1Power], dword [_ScreenOff], word PosPower_X, word PosPower_Y
inc	word [_P1Power]
and	byte [_MPFlags], 10111111b	
jmp	near .Retry
		

.CheckTank:
cmp	word [_Player1Angle], 0
jne	near .Pos1
mov	word [_P1TankPos], 0
jmp	near .Draw

.Pos1:
cmp	word [_Player1Angle], 22
jne	near .Pos2
mov	word [_P1TankPos], 1
jmp	near .Draw

.Pos2:
	cmp	word [_Player1Angle], 44
	jne	near .Pos3
	mov	word [_P1TankPos], 2
	jmp	near .Draw

.Pos3:
	cmp	word [_Player1Angle], 66
	jne	near .Pos4
	mov	word [_P1TankPos], 3
	jmp	near .Draw

.Pos4:
	cmp	word [_Player1Angle], 89
	jne	near .Pos5
	mov	word [_P1TankPos], 4
	jmp	near .Draw

.Pos5:
	cmp	word [_Player1Angle], 91
	jne	near .Pos6
	mov	word [_P1TankPos], 5
	jmp	near .Draw

.Pos6:
	cmp	word [_Player1Angle], 114
	jne	near .Pos7
	mov	word [_P1TankPos], 6
	jmp	near .Draw

.Pos7:
	cmp	word [_Player1Angle], 136
	jne	near .Pos8
	mov	word [_P1TankPos], 7
	jmp	near .Draw

.Pos8:
	cmp	word [_Player1Angle], 158
	jne	near .Pos9
	mov	word [_P1TankPos], 8
	jmp	near .Draw

.Pos9:
	cmp	word [_Player1Angle], 180
	jne	near .Retry
	mov	word [_P1TankPos], 9
	jmp	near .Draw

.Draw:
	invoke	_DrawTank, dword [_Tank1], word [_P1TankPos], word PLAYER1, dword [_ScreenOff], word [_LandNumber]
	jmp	near .Retry

; if you made it this far, you have pressed either enter, F1, or 'q'
.Fire_Case:
	mov	al, FIRE
	jmp	near .End

.Exit_Case:
	invoke	_ClearBuffer, dword [_Overlay], word 640, word 480, dword 0A0000000h
	invoke	_CopyBuffer, dword [_ScreenOff], word 640, word 480, dword [_ScreenTemp], word 640, word 480, word 0, word 0
	invoke	_ComposeBuffers, dword [_Overlay], word 640, word 480, dword [_ScreenOff], word 640, word 480, word 0, word 0
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0

	invoke	_LoadPNG, dword _ExitMainFN, dword [_MiniMenu], dword 0, dword 0 
	invoke	_CopyBuffer, dword [_MiniMenu], word 400, word 160, dword [_ScreenOff], word 640, word 480, word 120, word 160
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0

	and	byte [_MPFlags], 10111111b

.pause:
	test	byte [_MPFlags], 01000000b	
	jz	near .pause

	cmp	byte [_key], 'y'
	jne	near .tryno
	jmp	near .secondmenu

	.tryno:
	cmp	byte [_key], 'n'
	jne	near .pause
	invoke	_CopyBuffer, dword [_ScreenTemp], word 640, word 480, dword [_ScreenOff], word 640, word 480, word 0, word 0
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	and	byte [_MPFlags], 10111111b	
	jmp	near .Retry

.secondmenu:
	invoke	_LoadPNG, dword _ExitToMainFN, dword [_MiniMenu], dword 0, dword 0 
	invoke	_CopyBuffer, dword [_MiniMenu], word 400, word 160, dword [_ScreenOff], word 640, word 480, word 120, word 160
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	
	and	byte [_MPFlags], 10111111b
	mov	byte [_key], 0

.pause2:
	test	byte [_MPFlags], 01000000b	
	jz	near .pause2

	cmp	byte [_key], 'm'
	jne	near .quit
	mov	byte [_exit], 0
	mov	al, EXIT_GAME
	jmp	near .End
	
	.quit:
	cmp	byte [_key], 'q'
	jne	near .pause2
	mov	byte [_exit], 1
	mov	al, EXIT_GAME
	jmp	near .End

.Help_Case:
		invoke	_ClearBuffer, dword [_Overlay], word 640, word 480, dword 0A0000000h
		invoke	_CopyBuffer, dword [_ScreenOff], word 640, word 480, dword [_ScreenTemp], word 640, word 480, word 0, word 0
		invoke	_ComposeBuffers, dword [_Overlay], word 640, word 480, dword [_ScreenOff], word 640, word 480, word 0, word 0
		invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0

		invoke	_LoadPNG, dword _HelpMenuFN, dword [_AllPurposeMenu], dword 0, dword 0 
		invoke	_CopyBuffer, dword [_AllPurposeMenu], word 480, word 360, dword [_ScreenOff], word 640, word 480, word TankMenuX, word TankMenuY
		invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
		and	byte [_MPFlags], 10111111b
		mov	byte [_key], 0
	
.wait:
	test	byte [_MPFlags], 01000000b	
	jz	near .wait

	cmp	byte [_key], ENTR
	jne	near .wait
	invoke	_CopyBuffer, dword [_ScreenTemp], word 640, word 480, dword [_ScreenOff], word 640, word 480, word 0, word 0
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	and	byte [_MPFlags], 10111111b	
	jmp	near .Retry

.End:
	and	byte [_MPFlags], 10111111b	
	ret


; _______________________________________________________________________
; 
; void Player2Set()
;
; Function:
;	Handles moving around the tank, set power & angle
;	FIRE		
;	EXIT_GAME	
;	HELP_MENU	flags are set in al
; Created by: Yajur Parikh
; -----------------------------------------------------------------------

_Player2Set

.Retry
test	byte [_MPFlags], 01000000b;	
jz	near .Retry

cmp	byte [_key], 'q'
je	near .Exit_Case

cmp	byte [_key], 200
je	near .Help_Case

cmp	byte [_key], ENTR
je	near .Fire_Case

cmp	byte [_key], DOWN
jne	near .TryUp

cmp	word [_Player2Angle], 0
jle	near .Retry

; PRESS DOWN
invoke	_DisplayPowerAngle, word DEC1, word [_Player2Angle], dword [_ScreenOff], word PosAngle_X, word PosAngle_Y
dec	word [_Player2Angle]
and	byte [_MPFlags], 10111111b	
jmp	near .CheckTank
	
.TryUp:
	cmp	byte [_key], UP
	jne	near .TryLeft

	cmp	word [_Player2Angle], 180
	jge	near .Retry

; PRESS UP
invoke	_DisplayPowerAngle, word INC1, word [_Player2Angle], dword [_ScreenOff], word PosAngle_X, word PosAngle_Y
inc	word [_Player2Angle]
and	byte [_MPFlags], 10111111b	
jmp	near .CheckTank
	
.TryLeft:
	cmp	byte [_key], LEFT
	jne	near .TryRight

	cmp	word [_P2Power], 0
	je	near .Retry
	
; PRESS LEFT
invoke	_DisplayPowerAngle, word DEC1, word [_P2Power], dword [_ScreenOff], word PosPower_X, word PosPower_Y
dec	word [_P2Power]
and	byte [_MPFlags], 10111111b	
jmp	near .Retry

.TryRight:
	cmp	byte [_key], RIGHT
	jne	near .Retry

	cmp	word [_P2Power], MAXPOWER
	je	near .Retry

; PRESS RIGHT
invoke	_DisplayPowerAngle, word INC1, word [_P2Power], dword [_ScreenOff], word PosPower_X, word PosPower_Y
inc	word [_P2Power]
and	byte [_MPFlags], 10111111b	
jmp	near .Retry


.CheckTank
cmp	word [_Player2Angle], 0
jne	near .Pos1
mov	word [_P2TankPos], 0
jmp	near .Draw

.Pos1:
cmp	word [_Player2Angle], 22
jne	near .Pos2
mov	word [_P2TankPos], 1
jmp	near .Draw

.Pos2:
	cmp	word [_Player2Angle], 44
	jne	near .Pos3
	mov	word [_P2TankPos], 2
	jmp	near .Draw

.Pos3:
	cmp	word [_Player2Angle], 66
	jne	near .Pos4
	mov	word [_P2TankPos], 3
	jmp	near .Draw

.Pos4:
	cmp	word [_Player2Angle], 89
	jne	near .Pos5
	mov	word [_P2TankPos], 4
	jmp	near .Draw

.Pos5:
	cmp	word [_Player2Angle], 91
	jne	near .Pos6
	mov	word [_P2TankPos], 5
	jmp	near .Draw

.Pos6:
	cmp	word [_Player2Angle], 114
	jne	near .Pos7
	mov	word [_P2TankPos], 6
	jmp	near .Draw

.Pos7:
	cmp	word [_Player2Angle], 136
	jne	near .Pos8
	mov	word [_P2TankPos], 7
	jmp	near .Draw

.Pos8:
	cmp	word [_Player2Angle], 158
	jne	near .Pos9
	mov	word [_P2TankPos], 8
	jmp	near .Draw

.Pos9:
	cmp	word [_Player2Angle], 180
	jne	near .Retry
	mov	word [_P2TankPos], 9

.Draw:
	invoke	_DrawTank, dword [_Tank2], word [_P2TankPos], word PLAYER2, dword [_ScreenOff], word [_LandNumber]
	jmp	near .Retry

.Fire_Case:
	mov	al, FIRE
	jmp	near .End

.Exit_Case:
	invoke	_ClearBuffer, dword [_Overlay], word 640, word 480, dword 0A0000000h
	invoke	_CopyBuffer, dword [_ScreenOff], word 640, word 480, dword [_ScreenTemp], word 640, word 480, word 0, word 0
	invoke	_ComposeBuffers, dword [_Overlay], word 640, word 480, dword [_ScreenOff], word 640, word 480, word 0, word 0
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0

	invoke	_LoadPNG, dword _ExitMainFN, dword [_MiniMenu], dword 0, dword 0 
	invoke	_CopyBuffer, dword [_MiniMenu], word 400, word 160, dword [_ScreenOff], word 640, word 480, word 120, word 160
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0

	and	byte [_MPFlags], 10111111b

.pause:
	test	byte [_MPFlags], 01000000b	
	jz	near .pause

	cmp	byte [_key], 'y'
	jne	near .tryno
	jmp	near .secondmenu

	.tryno:
	cmp	byte [_key], 'n'
	jne	near .pause
	invoke	_CopyBuffer, dword [_ScreenTemp], word 640, word 480, dword [_ScreenOff], word 640, word 480, word 0, word 0
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	and	byte [_MPFlags], 10111111b	
	jmp	near .Retry

.secondmenu:
	mov	al, EXIT_GAME
	invoke	_LoadPNG, dword _ExitToMainFN, dword [_MiniMenu], dword 0, dword 0 
	invoke	_CopyBuffer, dword [_MiniMenu], word 400, word 160, dword [_ScreenOff], word 640, word 480, word 120, word 160
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	
	and	byte [_MPFlags], 10111111b
	mov	byte [_key], 0

.pause2:
	test	byte [_MPFlags], 01000000b	
	jz	near .pause2

	cmp	byte [_key], 'm'
	jne	near .quit
	mov	byte [_exit], 0
	mov	byte [_key], 0
	mov	al, EXIT_GAME
	jmp	near .End
	
	.quit:
	cmp	byte [_key], 'q'
	jne	near .pause2
	mov	byte [_exit], 1
	mov	byte [_key], 0
	mov	al, EXIT_GAME
	jmp	near .End


.Help_Case:
		invoke	_ClearBuffer, dword [_Overlay], word 640, word 480, dword 0A0000000h
		invoke	_CopyBuffer, dword [_ScreenOff], word 640, word 480, dword [_ScreenTemp], word 640, word 480, word 0, word 0
		invoke	_ComposeBuffers, dword [_Overlay], word 640, word 480, dword [_ScreenOff], word 640, word 480, word 0, word 0
		invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0

		invoke	_LoadPNG, dword _HelpMenuFN, dword [_AllPurposeMenu], dword 0, dword 0 
		invoke	_CopyBuffer, dword [_AllPurposeMenu], word 480, word 360, dword [_ScreenOff], word 640, word 480, word TankMenuX, word TankMenuY
		invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
		and	byte [_MPFlags], 10111111b
		mov	byte [_key], 0
	
.wait:
	test	byte [_MPFlags], 01000000b	
	jz	near .wait

	cmp	byte [_key], ENTR
	jne	near .wait
	invoke	_CopyBuffer, dword [_ScreenTemp], word 640, word 480, dword [_ScreenOff], word 640, word 480, word 0, word 0
	invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	and	byte [_MPFlags], 10111111b	
	jmp	near .Retry


.End:
	and	byte [_MPFlags], 10111111b	
	ret

































;_____________________________________________________________________________________________
;=============================================================================================
;_____________________________________________________________________________________________
; void AllocateMemory()
; 
; Inputs: nothing
; 
; Purpose: Allocate memory for all the variables that need
;	   memory allocated.
; Created by: Suneil Hosmane
;--------------------------------------------------------------

_AllocateMemory

; 16 x 16 Character Buffer
invoke	_AllocMem, dword 16*16*4
cmp	eax, -1
je	near .error
mov	[_CharOff], eax

; 264 x 311 Rollover Buffer
invoke	_AllocMem, dword 264*311*4
cmp	eax, -1
je	near .error
mov	[_RolloverOff], eax

; 640 x 480 Screen Buffer
invoke	_AllocMem, dword 640*480*4
cmp	eax, -1
je	near .error
mov	[_ScreenOff], eax

; Font Image Buffer
invoke	_AllocMem, dword 2048*16*4
cmp	eax, -1
je	near .error
mov	[_FontOff], eax  

; Menu Image Buffer
invoke	_AllocMem, dword 640*480*4
cmp	eax, -1
je	near .error
mov	[_MenuOff], eax 

; Point Queue used in FloodFill
invoke	_AllocMem, dword 480*400*4*40
cmp	eax, -1
je	near .error
mov	[_PointQueue], eax

; Land Screen 
invoke	_AllocMem, dword 640*397*4
cmp	eax, -1
je	near .error
mov	[_GameOff], eax

; File full of different Lands
invoke	_AllocMem, dword 640*3970*4
cmp	eax, -1
je	near .error
mov	[_LandOff], eax
	
; Player 1 & Player 2's tanks
invoke	_AllocMem, dword 60*600*4
cmp	eax, -1
je	near .error
mov	[_Tank1], eax

invoke	_AllocMem, dword 60*600*4
cmp	eax, -1
je	near .error
mov	[_Tank2], eax

; Place to dump a single tank
invoke	_AllocMem, dword 60*60*4
cmp	eax, -1
je	near .error
mov	[_TankDump], eax

; Overlay the screen (dim)
invoke	_AllocMem, dword 640*480*4
cmp	eax, -1
je	near .error
mov	[_Overlay], eax

; Temporary Screen Buffers
invoke	_AllocMem, dword 640*480*4
cmp	eax, -1
je	near .error
mov	[_ScreenTemp], eax

invoke	_AllocMem, dword 640*480*4
cmp	eax, -1
je	near .error
mov	[_ScreenTemp2], eax

; Swap Spaces for the Tanks
invoke	_AllocMem, dword 60*60*4
cmp	eax, -1
je	near .error
mov	[_TankDump2], eax

invoke	_AllocMem, dword 60*60*4
cmp	eax, -1
je	near .error
mov	[_TankDump3], eax

; Used for all images requiring 480 x 360
invoke	_AllocMem, dword 480*360*4
cmp	eax, -1
je	near .error
mov	[_AllPurposeMenu], eax

; Used for all images requiring 400 x 160
invoke	_AllocMem, dword 400*160*4
cmp	eax, -1
je	near .error
mov	[_MiniMenu], eax

invoke _AllocMem, dword 32*32*4
cmp	eax, -1
je	near .error
mov	[_UpArrow], eax

invoke _AllocMem, dword 32*32*4
cmp	eax, -1
je	near .error
mov	[_RightArrow], eax

invoke _AllocMem, dword 32*32*4
cmp	eax, -1
je	near .error
mov	[_TempSpace], eax

invoke	_AllocMem, dword 224*54*4
cmp	eax, -1
je	near .error
mov	[_LevelUp], eax

.error:
ret
;=============================================================================================
;_____________________________________________________________________________________________


;_____________________________________________________________________________________________
;=============================================================================================
; ____________________________________________________________________________________________
; 
; void MainMenu(dword *DestOff, word Width, word Height)
;	
; Inputs:
;	DestOff = Destination to a screen buffer
;	Width	= Width of buffer
;	Height	= Height of buffer
;	
; Purpose:
;	Draws the main, and depending on what was picked, sets _MenuItem 
;	to the right value. 
;	0 - Play Game
;	1 - Options
;	2 - Credits
;	3 - Exit Game
;
;  Created by: Terrence Janas
; -----------------------------------------------------------------------
proc _MainMenu
.DestOff	arg	4
.Width		arg	4
.Height		arg	4

pusha		; save all registers
	
; Draw the initial screen
invoke	_LoadPNG, dword _MenuFN, dword [_MenuOff], dword 0, dword 0 
invoke	_CopyBuffer, dword [_MenuOff], word [ebp+.Width], word [ebp+.Height], dword [_ScreenOff], word [ebp+.Width], word [ebp+.Height], word 0, word 0
invoke	_CopyToScreen, dword [ebp+.DestOff], dword 640*4, dword 0, dword 0, dword [ebp+.Width], dword [ebp+.Height], dword 0, dword 0

; Let the user scroll through the choices... 0-4 as stated above until
; the enter key is pressed. At that time, the choice the user has selected is
; returned to the main program.
mov	esi, 0
mov	byte [_MenuItem], 0
	
; Draw rectangles around selected menu item
.Display:
	movzx	esi, byte [_MenuItem]

	mov	ax, [_MenuLocations+esi*8+0]
	mov	bx, [_MenuLocations+esi*8+2]
	mov	cx, [_MenuLocations+esi*8+4]
	mov	dx, [_MenuLocations+esi*8+6]
	push	eax
	push	ebx
	push	ecx
	push	edx
	invoke	_DrawRect, dword [ebp+.DestOff], word [ebp+.Width], word [ebp+.Height], ax, bx, cx, dx, dword [_ColorWhite], dword 0
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax
	inc	ax
	inc	bx
	dec	cx
	dec	dx
	
	invoke	_DrawRect, dword [ebp+.DestOff], word [ebp+.Width], word [ebp+.Height], ax, bx, cx, dx, dword [_ColorGrey], dword 0		
	invoke	_CopyToScreen, dword [ebp+.DestOff], dword 640*4, dword 0, dword 0, dword [ebp+.Width], dword [ebp+.Height], dword 0, dword 0
	
	; Draw the picture to the right of the choices
	cmp	byte [_MenuItem], 0
	jne	.Item2
	invoke	_LoadPNG, dword _PlayFN, dword [_RolloverOff], dword 0, dword 0 
	jmp	.Copy
	
	.Item2:
	cmp	byte [_MenuItem], 1
	jne	.Item3
	invoke	_LoadPNG, dword _OptionsFN, dword [_RolloverOff], dword 0, dword 0
	jmp	.Copy
	
	.Item3:
	cmp	byte [_MenuItem], 2
	jne	.Item4
	invoke	_LoadPNG, dword _CreditsFN, dword [_RolloverOff], dword 0, dword 0
	jmp	.Copy

	.Item4
	invoke	_LoadPNG, dword _ExitFN, dword [_RolloverOff], dword 0, dword 0

	; Draw to screen
	.Copy:
		invoke	_CopyBuffer, dword [_RolloverOff], word 264, word 311, dword [ebp+.DestOff], word 640, word 480, word 333, word 88
		invoke	_CopyToScreen, dword [ebp+.DestOff], dword 640*4, dword 333, dword 88, dword 246, dword 311, dword 320, dword 88
	.Retry:
	; Handles UP and DOWN arrow key presses
	test	byte [_MPFlags], 01000000b
	jz	.Retry

	cmp	byte [_key], ENTR
	je	near .Done

	cmp	byte [_key], DOWN
	jne	near .TryUpArrow
	cmp	byte [_MenuItem], 3
	je	near .WrapAround
	and	byte [_MPFlags], 10111111b	
	inc	byte [_MenuItem]
	jmp	near .SetUp
	
	; If we are at the bottom menu item, and you press DOWN, go to the first menu item
	.WrapAround:
		mov	byte [_MenuItem], 0
		and	byte [_MPFlags], 10111111b	
		jmp	near .SetUp
	
	.TryUpArrow:
		cmp	byte [_key], UP
		jne	near .Retry
		cmp	byte [_MenuItem], 0
		je	near .WrapAround2
		and	byte [_MPFlags], 10111111b	
		dec	byte [_MenuItem]
		jmp	near .SetUp
	
	; If we are at the top menu item, and you press UP, go to the last menu item
	.WrapAround2:
		mov	byte [_MenuItem], 3
		and	byte [_MPFlags], 10111111b
	
	
	.SetUp
		invoke	_CopyBuffer, dword [_MenuOff], word [ebp+.Width], word [ebp+.Height], dword [_ScreenOff], word [ebp+.Width], word [ebp+.Height], word 0, word 0
		invoke	_CopyToScreen, dword [ebp+.DestOff], dword 640*4, dword 0, dword 0, dword [ebp+.Width], dword [ebp+.Height], dword 0, dword 0

	jmp	near .Display
	
.Done:
	and	byte [_MPFlags], 10111111b
	popa		; restore all registers
	ret
endproc
_MainMenu_arglen	EQU	12
;=============================================================================================
;_____________________________________________________________________________________________

;_____________________________________________________________________________________________
;=============================================================================================
; _______________________________________________________________________
; 
; void DrawMainScreen(dword *DestOff)
;	
; Inputs:
;	DestOff = Destination to a screen buffer
;
; Function:
;	Draws the game screen and outputs to the monitor
; Created by: Suneil Hosmane
;------------------------------------------------------------------------
proc _DrawMainScreen
.DestOff	arg	4

; First load main.png onto the screen
invoke	_LoadPNG, dword _MainFN, dword [ebp+.DestOff], dword 0, dword 0 

; draw the lines on the top of the screen
invoke	_DrawLine, dword [ebp+.DestOff], word 640, word 480, word 0, word 12, word 639, word 12, dword 000808080h
invoke	_DrawLine, dword [ebp+.DestOff], word 640, word 480, word 0, word 13, word 639, word 13, dword 000404040h
		
; bottom line, above the player name, score, etc....
invoke	_DrawRect, dword [ebp+.DestOff], word 640, word 480, word 0, word 410, word 639, word 479, dword [_ColorWhite], dword 0

; in the stat box, left-most divider, divides player 1 & power & angle 
invoke	_DrawRect, dword [ebp+.DestOff], word 640, word 480, word 0, word 410, word 215, word 479, dword [_ColorWhite], dword 0
invoke	_DrawRect, dword [ebp+.DestOff], word 640, word 480, word 1, word 411, word 214, word 478, dword [_ColorGrey], dword 0

; in the stat box, right-most divider, divides player 2 & power & angle
invoke	_DrawRect, dword [ebp+.DestOff], word 640, word 480, word 420, word 410, word 639, word 479, dword [_ColorWhite], dword 0
invoke	_DrawRect, dword [ebp+.DestOff], word 640, word 480, word 421, word 411, word 638, word 478, dword [_ColorGrey], dword 0

; draw a gray inner border inbetween the other two rectangles
invoke	_DrawRect, dword [ebp+.DestOff], word 640, word 480, word 216, word 411, word 419, word 478, dword [_ColorGrey], dword 0

; draw the Gun Size boxes for player 1
invoke	_DrawRect, dword [ebp+.DestOff], word 640, word 480, word P1_Gun_X, word P1_Gun_Y, word P1_Gun_X + BoxWidth, word P1_Gun_Y + BoxHeight, dword [_GunSizeColor], dword 0
invoke	_DrawRect, dword [ebp+.DestOff], word 640, word 480, word P1_Gun_X + BoxWidth, word P1_Gun_Y, word P1_Gun_X + 2*BoxWidth, word P1_Gun_Y + BoxHeight, dword [_GunSizeColor], dword 0
invoke	_DrawRect, dword [ebp+.DestOff], word 640, word 480, word P1_Gun_X + 2*BoxWidth, word P1_Gun_Y, word P1_Gun_X + 3*BoxWidth, word P1_Gun_Y + BoxHeight, dword [_GunSizeColor], dword 0
invoke	_DrawRect, dword [ebp+.DestOff], word 640, word 480, word P1_Gun_X + 3*BoxWidth, word P1_Gun_Y, word P1_Gun_X + 4*BoxWidth, word P1_Gun_Y + BoxHeight, dword [_GunSizeColor], dword 0
invoke	_DrawRect, dword [ebp+.DestOff], word 640, word 480, word P1_Gun_X + 4*BoxWidth, word P1_Gun_Y, word P1_Gun_X + 5*BoxWidth, word P1_Gun_Y + BoxHeight, dword [_GunSizeColor], dword 0

; draw the Gun Size boxes for player 2
invoke	_DrawRect, dword [ebp+.DestOff], word 640, word 480, word P2_Gun_X, word P2_Gun_Y, word P2_Gun_X + BoxWidth, word P2_Gun_Y + BoxHeight, dword [_GunSizeColor], dword 0
invoke	_DrawRect, dword [ebp+.DestOff], word 640, word 480, word P2_Gun_X + BoxWidth, word P2_Gun_Y, word P2_Gun_X + 2*BoxWidth, word P2_Gun_Y + BoxHeight, dword [_GunSizeColor], dword 0
invoke	_DrawRect, dword [ebp+.DestOff], word 640, word 480, word P2_Gun_X + 2*BoxWidth, word P2_Gun_Y, word P2_Gun_X + 3*BoxWidth, word P2_Gun_Y + BoxHeight, dword [_GunSizeColor], dword 0
invoke	_DrawRect, dword [ebp+.DestOff], word 640, word 480, word P2_Gun_X + 3*BoxWidth, word P2_Gun_Y, word P2_Gun_X + 4*BoxWidth, word P2_Gun_Y + BoxHeight, dword [_GunSizeColor], dword 0
invoke	_DrawRect, dword [ebp+.DestOff], word 640, word 480, word P2_Gun_X + 4*BoxWidth, word P2_Gun_Y, word P2_Gun_X + 5*BoxWidth, word P2_Gun_Y + BoxHeight, dword [_GunSizeColor], dword 0

; draw another rectangle over each set of gun size boxes to add to the thickness of the rectangles
invoke	_DrawRect, dword [ebp+.DestOff], word 640, word 480, word P1_Gun_X-1, word P1_Gun_Y-1, word P1_Gun_X+5*BoxWidth+1, word P1_Gun_Y+BoxHeight+1, dword [_FillColor], dword 0
invoke	_DrawRect, dword [ebp+.DestOff], word 640, word 480, word P2_Gun_X-1, word P2_Gun_Y-1, word P2_Gun_X+5*BoxWidth+1, word P2_Gun_Y+BoxHeight+1, dword [_FillColor], dword 0
invoke	_CopyToScreen, dword [ebp+.DestOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
ret
endproc
_DrawMainScreen_arglen	EQU 4
;=============================================================================================
;_____________________________________________________________________________________________


;_____________________________________________________________________________________________
;=============================================================================================
; _______________________________________________________________________
; 
; void _Player1Setup
; Inputs: none
; Outputs: none
; Function:
;	Player selects tank, and types his/her name here. 
;Created by: Suneil Hosmane
; -----------------------------------------------------------------------

_Player1Setup
pusha	
;and	byte [_MPFlags], 10111111b	

; Darken the main menu
invoke	_ClearBuffer, dword [_Overlay], word 640, word 480, dword 0A0000000h
invoke	_CopyBuffer, dword [_ScreenOff], word 640, word 480, dword [_ScreenTemp], word 640, word 480, word 0, word 0
invoke	_ComposeBuffers, dword [_Overlay], word 640, word 480, dword [_ScreenOff], word 640, word 480, word 0, word 0
invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
invoke	_CopyBuffer, dword [_ScreenOff], word 640, word 480, dword [_ScreenTemp2], word 640, word 480, word 0, word 0

; Display the tank select menu
invoke	_LoadPNG, dword _P1TankMenuFN, dword [_AllPurposeMenu], dword 0, dword 0 
invoke	_CopyBuffer, dword [_AllPurposeMenu], word 480, word 360, dword [_ScreenOff], word 640, word 480, word TankMenuX, word TankMenuY
invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0

mov	esi, 0		; tank #
.Again
mov	ax, [_TankMenu+esi*4+0]
mov	bx, [_TankMenu+esi*4+2]		; Grab the location to flood fill

mov	word [_tempx], ax
mov	word [_tempy], bx

; Flood Fill a selected tank with yellow
invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word [_tempx], word [_tempy], dword 00FFFF00h, dword 0
invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
		
; Prompt user for next input	
.Retry:
	; Handles UP and DOWN arrow key presses
	test	byte [_MPFlags], 01000000b
	jz	.Retry

	cmp	byte [_key], ENTR
	je	near .Done

	cmp	byte [_key], DOWN
	je	near .Down

	cmp	byte [_key], UP
	je	near .Up

	cmp	byte [_key], LEFT
	je	near .LT

	cmp	byte [_key], RIGHT
	je	near .RT
	
	and	byte [_MPFlags], 10111111b	
	jmp	near .Retry
	
	.Down
	cmp	esi, 2
	jg	near .WrapAround
	add	esi, 3
	and	byte [_MPFlags], 10111111b	
	jmp	near .SetUp
	
	; If we are at the bottom menu item, and you press DOWN, go to the first menu item
	.WrapAround:
		sub	esi, 3
		and	byte [_MPFlags], 10111111b	
		jmp	near .SetUp
	
	.Up:
		cmp	esi, 2
		jle	near .WrapAround2
		sub	esi, 3		
		and	byte [_MPFlags], 10111111b	
		jmp	near .SetUp
	
	; If we are at the top menu item, and you press UP, go to the last menu item
	.WrapAround2:
		add	esi, 3
		and	byte [_MPFlags], 10111111b
		jmp	near .SetUp
	
	.LT:
		cmp	esi, 0
		je	near .WrapAround3
		cmp	esi, 3
		je	near .WrapAround3
		sub	esi, 1
		and	byte [_MPFlags], 10111111b
		jmp	near .SetUp
	
	; If we are at the left menu item, and you press LEFT, go the right menu item
	.WrapAround3:
		add	esi, 2
		and	byte [_MPFlags], 10111111b
		jmp	near .SetUp

	.RT:
		cmp	esi, 2
		je	near .WrapAround4
		cmp	esi, 5
		je	near .WrapAround4
		add	esi, 1
		and	byte [_MPFlags], 10111111b
		jmp	near .SetUp
	
	; If we are at the right menu item, and you press RIGHT, go the left menu item
	.WrapAround4:
		sub	esi, 2
		and	byte [_MPFlags], 10111111b	
	
	.SetUp
		; Flood fill an unselected image back to what it was, and continue
		invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word [_tempx], word [_tempy], dword 0010101h, dword 0
		invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
		jmp	near .Again

.Done:
inc	esi

; Load the right tank into player 1's offset 

cmp	esi, 1
jne	near .Tank2
invoke	_LoadPNG, dword _Tank1FN, dword [_Tank1], dword 0, dword 0 
mov	byte [_P1Tank], 1
jmp	near .Cont

.Tank2:
	cmp	esi, 2
	jne	near .Tank3
	invoke	_LoadPNG, dword _Tank2FN, dword [_Tank1], dword 0, dword 0 
	mov	byte [_P1Tank], 2
	jmp	near .Cont

.Tank3:
	cmp	esi, 3
	jne	near .Tank4
	invoke	_LoadPNG, dword _Tank3FN, dword [_Tank1], dword 0, dword 0 
	mov	byte [_P1Tank], 3
	jmp	near .Cont

.Tank4:
	cmp	esi, 4
	jne	near .Tank5
	invoke	_LoadPNG, dword _Tank4FN, dword [_Tank1], dword 0, dword 0 
	mov	byte [_P1Tank], 4
	jmp	near .Cont

.Tank5:
	cmp	esi, 5
	jne	near .Tank6
	invoke	_LoadPNG, dword _Tank5FN, dword [_Tank1], dword 0, dword 0 
	mov	byte [_P1Tank], 5
	jmp	near .Cont

.Tank6:
	invoke	_LoadPNG, dword _Tank6FN, dword [_Tank1], dword 0, dword 0 
	mov	byte [_P1Tank], 6

; Now Enter Phase II, Entering the name
.Cont:

; Dim the Screen Again, and display the name select menu
invoke	_LoadPNG, dword _NameMenuFN, dword [_MiniMenu], dword 0, dword 0 
invoke	_ComposeBuffers, dword [_Overlay], word 640, word 480, dword [_ScreenOff], word 640, word 480, word 0, word 0
invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	
invoke	_CopyBuffer, dword [_MiniMenu], word 400, word 160, dword [_ScreenOff], word 640, word 480, word 120, word 160
invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0

; now grab the name
and	byte [_MPFlags], 10111111b					
mov	edi, _Player1Name
mov	esi, _TextInputString
mov	ecx, 112+TEXT_X
mov	ebx, 0
		
.OneMoreTime:
	; Handles UP and DOWN arrow key presses
	test	byte [_MPFlags], 01000000b
	jz	.OneMoreTime

	cmp	byte [_key], BKSP
	je	near .BackSpace

	cmp	byte [_key], ENTR
	je	near .Finished

	cmp	ebx, 10
	je	near .OneMoreTime

	cmp	byte [_key], ' '
	je	near .Valid

	cmp	byte [_key], 'a'
	jl	near .OneMoreTime

	cmp	byte [_key], 'z'
	jg	near .OneMoreTime

	; Character 'a' - 'z', 'A' - 'Z', and space
	; Draw the text on the screen & set player 1's name in the allocated variable
	.Valid:
		and	byte [_MPFlags], 10111111b	
		mov	al, byte [_key]
		add	edi, ebx
		mov	byte [edi], al
		mov	byte [edi+1], '$'
		sub	edi, ebx

		mov	byte [esi+0], al
		mov	byte [esi+1], '$'
		invoke	_DrawString, dword _TextInputString, dword [_ScreenOff], word cx, word 160+TEXT_Y, dword [_DefaultColor]
		add	ecx, 14
		inc	ebx
		jmp	near .OneMoreTime

	; Erase character on the screen as well as from the variable
	.BackSpace:
		cmp	ebx, 0
		je	near .OneMoreTime

		and	byte [_MPFlags], 10111111b	
		dec	ebx
		add	edi, ebx
		sub	ecx, 14
		mov	byte [edi], '$'
		mov	byte [edi+1], ' '
		sub	edi, ebx

		mov	byte [esi+0], ' '
		mov	byte [esi+1], '$'
		invoke	_DrawString, dword _TextInputString, dword [_ScreenOff], word cx, word 160+TEXT_Y, dword [_DefaultColor]
		jmp	near .OneMoreTime

.Finished:		
		; return the dimed menu select screen
		invoke	_CopyBuffer, dword [_ScreenTemp2], word 640, word 480, dword [_ScreenOff], word 640, word 480, word 0, word 0
		invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
		and	byte [_MPFlags], 10111111b
		popa		
		ret
;=============================================================================================
;_____________________________________________________________________________________________

;_____________________________________________________________________________________________
;=============================================================================================
; _______________________________________________________________________
; 
; void _Player2Setup
; Inputs: none
; Outputs: none
; Function:
;	same as _Player1Setup, except sets up player 2
; Created by: Suneil Hosmane
; -----------------------------------------------------------------------
_Player2Setup
pusha	

;and	byte [_MPFlags], 10111111b	

invoke	_LoadPNG, dword _P2TankMenuFN, dword [_AllPurposeMenu], dword 0, dword 0 
invoke	_CopyBuffer, dword [_AllPurposeMenu], word 480, word 360, dword [_ScreenOff], word 640, word 480, word TankMenuX, word TankMenuY
invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0

mov	esi, 0		; tank #

.Again
mov	ax, [_TankMenu+esi*4+0]
mov	bx, [_TankMenu+esi*4+2]

mov	word [_tempx], ax
mov	word [_tempy], bx

invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word [_tempx], word [_tempy], dword 00FFFF00h, dword 0
invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
			
.Retry:
	; Handles UP and DOWN arrow key presses
	test	byte [_MPFlags], 01000000b
	jz	.Retry

	cmp	byte [_key], ENTR
	je	near .Done

	cmp	byte [_key], DOWN
	je	near .Down

	cmp	byte [_key], UP
	je	near .Up

	cmp	byte [_key], LEFT
	je	near .LT

	cmp	byte [_key], RIGHT
	je	near .RT
	
	and	byte [_MPFlags], 10111111b	
	jmp	near .Retry
	
	.Down
	cmp	esi, 2
	jg	near .WrapAround
	add	esi, 3
	and	byte [_MPFlags], 10111111b	
	jmp	near .SetUp
	
	; If we are at the bottom menu item, and you press DOWN, go to the first menu item
	.WrapAround:
		sub	esi, 3
		and	byte [_MPFlags], 10111111b	
		jmp	near .SetUp
	
	.Up:
		cmp	esi, 2
		jle	near .WrapAround2
		sub	esi, 3		
		and	byte [_MPFlags], 10111111b	
		jmp	near .SetUp
	
	; If we are at the top menu item, and you press UP, go to the last menu item
	.WrapAround2:
		add	esi, 3
		and	byte [_MPFlags], 10111111b
		jmp	near .SetUp
	
	.LT:
		cmp	esi, 0
		je	near .WrapAround3
		cmp	esi, 3
		je	near .WrapAround3
		sub	esi, 1
		and	byte [_MPFlags], 10111111b
		jmp	near .SetUp
	
	.WrapAround3:
		add	esi, 2
		and	byte [_MPFlags], 10111111b
		jmp	near .SetUp


	.RT:
		cmp	esi, 2
		je	near .WrapAround4
		cmp	esi, 5
		je	near .WrapAround4
		add	esi, 1
		and	byte [_MPFlags], 10111111b
		jmp	near .SetUp
	
	.WrapAround4:
		sub	esi, 2
		and	byte [_MPFlags], 10111111b	
	
	.SetUp
		invoke	_FloodFill, dword [_ScreenOff], word 640, word 480, word [_tempx], word [_tempy], dword 0010101h, dword 0
		invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
		jmp	near .Again

.Done:
inc	esi

cmp	esi, 1
jne	near .Tank2
invoke	_LoadPNG, dword _Tank1FN, dword [_Tank2], dword 0, dword 0 
mov	byte [_P2Tank], 1
jmp	near .Cont

.Tank2:
	cmp	esi, 2
	jne	near .Tank3
	invoke	_LoadPNG, dword _Tank2FN, dword [_Tank2], dword 0, dword 0 
	mov	byte [_P2Tank], 2
	jmp	near .Cont

.Tank3:
	cmp	esi, 3
	jne	near .Tank4
	invoke	_LoadPNG, dword _Tank3FN, dword [_Tank2], dword 0, dword 0 
	mov	byte [_P2Tank], 3
	jmp	near .Cont

.Tank4:
	cmp	esi, 4
	jne	near .Tank5
	invoke	_LoadPNG, dword _Tank4FN, dword [_Tank2], dword 0, dword 0 
	mov	byte [_P2Tank], 4
	jmp	near .Cont

.Tank5:
	cmp	esi, 5
	jne	near .Tank6
	invoke	_LoadPNG, dword _Tank5FN, dword [_Tank2], dword 0, dword 0 
	mov	byte [_P2Tank], 5
	jmp	near .Cont

.Tank6:
	invoke	_LoadPNG, dword _Tank6FN, dword [_Tank2], dword 0, dword 0 
	mov	byte [_P2Tank], 6

.Cont:

invoke	_LoadPNG, dword _NameMenuFN, dword [_MiniMenu], dword 0, dword 0 
invoke	_ComposeBuffers, dword [_Overlay], word 640, word 480, dword [_ScreenOff], word 640, word 480, word 0, word 0
invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0
	
invoke	_CopyBuffer, dword [_MiniMenu], word 400, word 160, dword [_ScreenOff], word 640, word 480, word 120, word 160
invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0

and	byte [_MPFlags], 10111111b					
mov	edi, _Player2Name
mov	esi, _TextInputString
mov	byte [esi], '$'
mov	ecx, 112+TEXT_X
mov	ebx, 0
		
.OneMoreTime:
	; Handles UP and DOWN arrow key presses
	test	byte [_MPFlags], 01000000b
	jz	.OneMoreTime

	cmp	byte [_key], BKSP
	je	near .BackSpace

	cmp	byte [_key], ENTR
	je	near .Finished

	cmp	ebx, 10
	je	near .OneMoreTime

	cmp	byte [_key], 'a'
	jl	near .OneMoreTime

	cmp	byte [_key], 'z'
	jg	near .OneMoreTime

	.Valid:
		and	byte [_MPFlags], 10111111b	
		mov	al, byte [_key]
		add	edi, ebx
		mov	byte [edi], al
		mov	byte [edi+1], '$'
		sub	edi, ebx

		mov	byte [esi+0], al
		mov	byte [esi+1], '$'
		invoke	_DrawString, dword _TextInputString, dword [_ScreenOff], word cx, word 160+TEXT_Y, dword [_DefaultColor]
		add	ecx, 14
		inc	ebx
		jmp	near .OneMoreTime

	.BackSpace:
		cmp	ebx, 0
		je	near .OneMoreTime

		and	byte [_MPFlags], 10111111b	
		dec	ebx
		add	edi, ebx
		sub	ecx, 14
		mov	byte [edi], '$'
		mov	byte [edi+1], ' '
		sub	edi, ebx

		mov	byte [esi+0], ' '
		mov	byte [esi+1], '$'
		invoke	_DrawString, dword _TextInputString, dword [_ScreenOff], word cx, word 160+TEXT_Y, dword [_DefaultColor]
		jmp	near .OneMoreTime
.Finished:		
	and	byte [_MPFlags], 10111111b	
	popa		
	ret
;=============================================================================================
;_____________________________________________________________________________________________



; _______________________________________________________________________
; 
; void GetLand(dword *DestOff, word Num)
;	
; Inputs:
;	GameWindow - Offset to the mini window in the screen that the
;		     game is played in
;	GameW	   - GameWindow Width
;	GameH	   - GameWindow Height
;	Screen	   - Offset to the screen
;	ScreenW	   - Screen Width
;	ScreenH	   - Screen Height
;	Num	   = The # of the land (0-9)
;	SkyColor   = Color of the sky
;
; Function:
;	Takes an integer (Num), and copies that land # from the land.png
;	to the buffer specified
; Created by: Suneil Hosmane
; -----------------------------------------------------------------------
proc _GetLand
.GameWindow	arg 4
.GameW		arg 2
.GameH		arg 2
.Screen		arg 4
.ScreenW	arg 2
.ScreenH	arg 2
.Num		arg 2
.SkyColor	arg 4

pusha		; save all registers

invoke	_ClearBuffer, dword [ebp+.GameWindow], word [ebp+.GameW], word [ebp+.GameH], dword [ebp+.SkyColor]
invoke	_CopyBuffer, dword [ebp+.GameWindow], word [ebp+.GameW], word [ebp+.GameH], dword [ebp+.Screen], word [ebp+.ScreenW], word [ebp+.ScreenH], word GameScreenX, word GameScreenY
invoke	_CopyToScreen, dword [ebp+.Screen], dword 640*4, dword GameScreenX, dword GameScreenY, dword LandWidth, dword LandHeight, dword GameScreenX, dword GameScreenY

mov	esi, dword [_LandOff]		; Land Offset
mov	edi, dword [ebp+.GameWindow]

movzx	eax, word [ebp+.Num]
movzx	ecx, word [ebp+.GameH]
mul	ecx
movzx	ecx, word [ebp+.GameW]
mul	ecx
shl	eax, 2
add	esi, eax			; Proper Offset
CLD
movzx	ebx, word [ebp+.GameH]

.Again
movzx	ecx, word [ebp+.GameW]
repnz	movsd				; copy land
dec	ebx
cmp	ebx, 0
jne	.Again

invoke	_ComposeBuffers, dword [ebp+.GameWindow], word LandWidth, word LandHeight, dword [ebp+.Screen], word 640, word 480, word GameScreenX, word GameScreenY
invoke	_CopyToScreen, dword [ebp+.Screen], dword 640*4, dword GameScreenX, dword GameScreenY, dword LandWidth, dword LandHeight, dword GameScreenX, dword GameScreenY
popa
ret
endproc
_GetLand_arglen	EQU 22


; _______________________________________________________________________
; 
; void DrawString(dword *StringOff, word X, word Y)
;	
; Inputs:
;	String     - String
;	Screen	   - Screen
;	X	   - X Coord of place to display text
;	Y	   - Y Coord of place to display text
;	Color	   - Color of Text
;
; Function:
;	Displays a string on the screen
;	special characters:
;       SPACE - function creates a blank
;	;     - function does not draw here
;Created by: Yajur Parikh
; -----------------------------------------------------------------------
proc _DrawString
.String		arg 4
.Screen		arg 4
.X		arg 2
.Y		arg 2
.Color		arg 4

pusha		; save all registers

movzx	eax, word [ebp+.X]
movzx	ebx, word [ebp+.Y]
mov	dword [_tempx], eax
mov	dword [_tempy], ebx
mov	esi, dword [ebp+.String]
mov	edi, _TempString

.Again:

invoke	_ClearBuffer, dword [_CharOff], word CharWidth, word CharHeight, dword 0FF000000h
mov	al, byte [esi]
cmp	al, '$'
je	near .Quit
cmp	al, ' '
je	near .SpaceCase
cmp	al, ';'
je	near .ReturnToLoop
mov	byte [edi], al
mov	byte [edi+1], '$'
invoke	_CopyBuffer, dword [_CharOff], word CharWidth, word CharHeight, dword [ebp+.Screen], word 640, word 480, word [_tempx], word [_tempy]
invoke	_DrawText, dword _TempString, dword [_CharOff], word 16, word 16, word 0, word 0, dword [ebp+.Color]
invoke	_ComposeBuffers, dword [_CharOff], word CharWidth, word CharHeight, dword [ebp+.Screen], word 640, word 480, word [_tempx], word [_tempy]
.Display:
invoke	_CopyToScreen, dword [ebp+.Screen], dword 640*4, dword [_tempx], dword [_tempy], dword CharWidth, dword CharHeight, dword [_tempx], dword [_tempy]
.ReturnToLoop:
add	word [_tempx], 13
add	esi, 1
jmp	near .Again

.SpaceCase:
	invoke	_CopyBuffer, dword [_CharOff], word CharWidth, word CharHeight, dword [ebp+.Screen], word 640, word 480, word [_tempx], word [_tempy]
	jmp	near .Display
.Quit:
popa
ret
endproc
_DrawString_arglen	EQU 16


; _______________________________________________________________________
; 
; void DrawTank(dword *TankOff, word TankPos, dword *Screen, word LandNumber)
;	
; Inputs:
;	TankOff	   - Offset to buffer with tank images
;	TankPos	   - Between 0-9
;	Player	   - Player#
;	Screen	   - Screen
;	LandNumber - Which terrain are we on?
;
; Function:
;	Displays the battle tank in the right place, and right position
; Created by: Terrence Janas
; -----------------------------------------------------------------------
proc _DrawTank
.TankOff	arg 4
.TankPos	arg 2
.Player		arg 2
.Screen		arg 4
.LandNumber	arg 2

pusha		; save all registers

movzx	esi, word [ebp+.LandNumber]
cmp	word [ebp+.Player], 1
jne	near .Player2Coords

movzx	eax, word [_TankCoords+esi*8+0]
movzx	ebx, word [_TankCoords+esi*8+2]
jmp	near .Next

.Player2Coords:
movzx	eax, word [_TankCoords+esi*8+4]
movzx	ebx, word [_TankCoords+esi*8+6]

.Next:
mov	dword [_tempx], eax
mov	dword [_tempy], ebx

mov	esi, dword [ebp+.TankOff]		; Tank Offset
mov	edi, dword [_TankDump]

movzx	eax, word [ebp+.TankPos]
mov	ecx, TankSize
mul	ecx
mov	ecx, TankSize
mul	ecx
shl	eax, 2
add	esi, eax			; Proper Offset
CLD
mov	ebx, TankSize

.Again:
mov	ecx, TankSize
repnz	movsd				; copy tank
dec	ebx
cmp	ebx, 0
jne	near .Again

cmp	word [ebp+.Player], 1
jne	.Try2
invoke	_CopyBuffer, dword [_TankDump2], word TankSize, word TankSize, dword [ebp+.Screen], word 640, word 480, word [_tempx], word [_tempy]
jmp	.Draw
.Try2:
invoke	_CopyBuffer, dword [_TankDump3], word TankSize, word TankSize, dword [ebp+.Screen], word 640, word 480, word [_tempx], word [_tempy]
.Draw:
invoke	_ComposeBuffers, dword [_TankDump], word TankSize, word TankSize, dword [ebp+.Screen], word 640, word 480, word [_tempx], word [_tempy]
invoke	_CopyToScreen, dword [_ScreenOff], dword 640*4, dword [_tempx], dword [_tempy], dword TankSize, dword TankSize, dword [_tempx], dword [_tempy]

popa
ret
endproc
_DrawTank_arglen	EQU 14

; _______________________________________________________________________
; 
; void GetTankBK(word Player, dword *Screen, word LandNumber)
;	
; Inputs:
;	Player	   - Player#
;	Screen	   - Screen
;	LandNumber - Which terrain are we on?
;
; Function:
;	Obtains the 60x60 square chunk of the bk, so that when we 
;	redraw the tanks, you only redraw the 60x60 slice to reduce flickering
; Created by: Terrence Janas
; -----------------------------------------------------------------------
proc _GetTankBK
.Player		arg 2
.Screen		arg 4
.LandNumber	arg 2

pusha		; save all registers

movzx	esi, word [ebp+.LandNumber]
cmp	word [ebp+.Player], 1
jne	near .Player2Coords

movzx	eax, word [_TankCoords+esi*8+0]
movzx	ebx, word [_TankCoords+esi*8+2]
jmp	near .Next

.Player2Coords:
movzx	eax, word [_TankCoords+esi*8+4]
movzx	ebx, word [_TankCoords+esi*8+6]

.Next:
mov	dword [_tempx], eax
mov	dword [_tempy], ebx

mov	esi, dword [ebp+.Screen]		; Tank Offset
cmp	word [ebp+.Player], 1
jne	.Try2
mov	edi, dword [_TankDump2]
jmp	.Cont
.Try2:
mov	edi, dword [_TankDump3]
.Cont:
mov	eax, dword [_tempy]
mov	ecx, 640
mul	ecx
mov	ecx, dword [_tempx]
add	eax, ecx
shl	eax, 2
add	esi, eax			; Proper Offset
CLD
mov	ebx, TankSize

.Again:
mov	ecx, TankSize
repnz	movsd				; copy tank
dec	ebx
cmp	ebx, 0
je	near .Quit
add	esi, 2320
jmp	near .Again

.Quit:
popa
ret
endproc
_GetTankBK_arglen	EQU 8

; _______________________________________________________________________
; 
; void DisplayScore()
;
; Function:
;	Displays a score, in the right place
; Inputs: Score to display, offset of the screen, X and Y coords where
;  score is to be displayed
; Outputs: score to screen
; Created by: Suneil Hosmane
; -----------------------------------------------------------------------
proc	_DisplayScore
.Score		arg	2
.Screen		arg	4
.Xcoord		arg	2
.Ycoord		arg	2
pusha

mov	edi, _ScoreString
mov	byte [edi+0], '0'
mov	byte [edi+1], '0'
mov	byte [edi+2], '0'
mov	byte [edi+3], '0'
mov	byte [edi+4], '0'
mov	byte [edi+5], '$'

mov	ax, word [ebp+.Score]

cmp	ax, 100
jge	near .TenGrand

cmp	ax, 10
jge	near .Grand

cmp	ax, 1
jge	near .Hundred

jmp	near .Draw

.TenGrand:
mov	edi, _ScoreString
mov	dx, 0
mov	cx, 100
div	cx		; dx:ax = remainder|quotient
call	_ReturnAsciiChar
mov	byte [edi+0], al
mov	ax, dx
.Grand:
mov	dx, 0
mov	cx, 10
div	cx
call	_ReturnAsciiChar
mov	byte [edi+1], al
mov	ax, dx
.Hundred:
call	_ReturnAsciiChar
mov	byte [edi+2], al

.Draw:
invoke	_DrawString, dword _ScoreString, dword [ebp+.Screen], word [ebp+.Xcoord], word [ebp+.Ycoord], dword [_DefaultColor]


popa
ret
endproc
_DisplayScore_arglen	EQU	10


; _______________________________________________________________________
; 
; void DisplayPowerAngle()
;
; Inputs: Flag, value of attribute, offset of screen, X and Y coords
;  value will go
; Function:
;	Displays an angle or power, depending on coords passed
;	if Flag = 0;		Display all zeros
;	   Flag = 1;		Increment value by 1
;	   Flag = 2		Decrement value	by 1
;	   Flag = 3		JUST DISPLAY
; Created by: Yajur Parikh
; -----------------------------------------------------------------------
proc	_DisplayPowerAngle
.Flag		arg	2
.Value		arg	2
.Screen		arg	4
.Xcoord		arg	2
.Ycoord		arg	2

pusha

mov	edi, _PowerAngleString
mov	byte [edi+0], '0'
mov	byte [edi+1], '0'
mov	byte [edi+2], '0'
mov	byte [edi+3], '$'

cmp	word [ebp+.Flag], ZEROS
je	near .Display

mov	dx, 0
mov	ax, word [ebp+.Value]
mov	cx, 100
div	cx		; dx:ax = remainder|quotient

mov	word [_Hundreds], ax
mov	ax, dx		; ax contains Value%100

mov	dx, 0
mov	cx, 10
div	cx		

mov	word [_Tens], ax	
mov	word [_Ones], dx

cmp	word [ebp+.Flag], INC1
je	near .Add_1

cmp	word [ebp+.Flag], DEC1
je	near .Sub_1

cmp	word [ebp+.Flag], NOCHANGE
je	near .NoChange

.Add_1:	
	cmp	word [_Ones], 9
	je	.WrapAroundOnes
	inc	word [_Ones]
	mov	ax, word [_Ones]
	call	_ReturnAsciiChar
	mov	byte [edi+0], ';'
	mov	byte [edi+1], ';'
	mov	byte [edi+2], al
	jmp	near .Display

	.WrapAroundOnes:
	mov	byte [edi+2], '0'
	cmp	word [_Tens], 9
	je	.WrapAroundTens
	inc	word [_Tens]
	mov	ax, word [_Tens]
	call	_ReturnAsciiChar
	mov	byte [edi+0], ';'
	mov	byte [edi+1], al
	jmp	near .Display

	.WrapAroundTens:
	mov	byte [edi+1], '0'
	inc	word [_Hundreds]
	mov	ax, word [_Hundreds]
	call	_ReturnAsciiChar
	mov	byte [edi+0], al
	jmp	near .Display

.Sub_1:	
	cmp	word [_Ones], 0
	je	.WrapBelowOnes
	dec	word [_Ones]
	mov	ax, word [_Ones]
	call	_ReturnAsciiChar
	mov	byte [edi+0], ';'
	mov	byte [edi+1], ';'
	mov	byte [edi+2], al
	jmp	near .Display

	.WrapBelowOnes:
	mov	byte [edi+2], '9'
	cmp	word [_Tens], 0
	je	.WrapBelowTens
	dec	word [_Tens]
	mov	ax, word [_Tens]
	call	_ReturnAsciiChar
	mov	byte [edi+0], ';'
	mov	byte [edi+1], al
	jmp	near .Display

	.WrapBelowTens:
	mov	byte [edi+1], '9'
	dec	word [_Hundreds]
	mov	ax, word [_Hundreds]
	call	_ReturnAsciiChar
	mov	byte [edi+0], al
	jmp	near .Display

.NoChange:
	mov	ax, word [_Ones]
	call	_ReturnAsciiChar
	mov	byte [edi+2], al
	mov	ax, word [_Tens]
	call	_ReturnAsciiChar
	mov	byte [edi+1], al
	mov	ax, word [_Hundreds]
	call	_ReturnAsciiChar
	mov	byte [edi+0], al
	jmp	near .Display

.Display:
invoke	_DrawString, dword _PowerAngleString, dword [ebp+.Screen], word [ebp+.Xcoord], word [ebp+.Ycoord], dword [_DefaultColor]

popa
ret
endproc
_DisplayPowerAngle_arglen	EQU	12

; _______________________________________________________________________
; 
; void ReturnAsciiChar()
;
; Function:
;	given a number, it will return the ascii value in eax
; Created by: Terrence Janas
; -----------------------------------------------------------------------
_ReturnAsciiChar

cmp	al, 0
jne	.ONE
mov	al, '0'
jmp	near .End

.ONE:
cmp	al, 1
jne	.TWO
mov	al, '1'
jmp	near .End

.TWO:
cmp	al, 2
jne	.THREE
mov	al, '2'
jmp	near .End

.THREE:
cmp	al, 3
jne	.FOUR
mov	al, '3'
jmp	near .End

.FOUR:
cmp	al, 4
jne	.FIVE
mov	al, '4'
jmp	near .End

.FIVE:
cmp	al, 5
jne	.SIX
mov	al, '5'
jmp	near .End

.SIX:
cmp	al, 6
jne	.SEVEN
mov	al, '6'
jmp	near .End

.SEVEN:
cmp	al, 7
jne	.EIGHT
mov	al, '7'
jmp	near .End

.EIGHT:
cmp	al, 8
jne	.NINE
mov	al, '8'
jmp	near .End

.NINE:
mov	al, '9'
.End:
ret




















; OLD FUNCTIONS

;______________________________________________________________
;                       PointInBox()                  
; 
; Inputs: X Coord, Y Coord, Upper Left Hand Corner Coords,
;         Lower Right Hand Coords
; 
; Outputs: EAX holds 1 if the point (X,Y) lies within the 
;	   bounds specified, 0 otherwise
; Created by: entire group
;--------------------------------------------------------------
proc _PointInBox
.X		arg	2
.Y		arg	2
.BoxULCornerX	arg	2
.BoxULCornerY	arg	2
.BoxLRCornerX	arg	2
.BoxLRCornerY	arg	2

mov	ax, word [ebp+.X]		
cmp	ax, word [ebp+.BoxULCornerX]	; if X < Upper Left Hand Corner, error
jb	near .Error			
cmp	ax, word [ebp+.BoxLRCornerX]	; if X > Lower Right Hand Corner, error
ja	near .Error			

mov	ax, word [ebp+.Y]		
cmp	ax, word [ebp+.BoxULCornerY]	; if Y < Upper Left Hand Corner, error
jb	near .Error			
cmp	ax, word [ebp+.BoxLRCornerY]	; if Y > Lower Right Hand Corner, error
ja	near .Error			

mov	eax, 1
ret

.Error:
	mov	eax, 0
	ret
endproc
_PointInBox_arglen	EQU	12	   


;______________________________________________________________
;                         GetPixel()                  
; 
; Inputs: X Coord, Y Coord, Destination Offset, 
;         Destination Height, Destination Width
; 
; Outputs: EAX holds the pixel specified at point (X,Y) (if it is valid),
;	   0 otherwise
;
; Created by: entire group
;--------------------------------------------------------------
proc _GetPixel
.DestOff	arg	4
.DestWidth	arg	2
.DestHeight	arg	2
.X		arg	2
.Y		arg	2

push	ebx
push	ecx
push	edx

; first we see if the point (X,Y) is located within the boundaries
invoke _PointInBox, word [ebp+.X], word [ebp+.Y], word 0, word 0, word [ebp+.DestWidth], word [ebp+.DestHeight]
cmp	eax, 0	
je	near .Exit


; if we made it this far, we know our coords are valid
; first calculate the offset of the (X,Y) pixel
; then return whatever dword is located at that offset

movzx	ecx, word [ebp+.DestWidth]
movzx	eax, word [ebp+.Y]

mul	ecx	
mov	edx, eax
movzx	eax, word [ebp+.X]
add	eax, edx
shl	eax, 2		; = ((Width * Y) + X) = 4

mov	ebx, dword [ebp+.DestOff]
add	ebx, eax
mov	eax, dword [ebx]	; grab the color at point X,Y
.Exit:
	pop	edx
	pop	ecx		; pop, and leave
	pop	ebx
	ret

endproc
_GetPixel_arglen	EQU	12

;______________________________________________________________
;                        DrawPixel()                  
; 
; Inputs: X Coord, Y Coord, Destination Offset, 
;         Destination Height, Destination Width, and Color
; 
; Outputs: Color drawn to buffer at point X, Y
; Created by: entire group
;--------------------------------------------------------------
proc _DrawPixel
.DestOff	arg	4
.DestWidth	arg	2
.DestHeight	arg	2
.X		arg	2
.Y		arg	2
.Color		arg	4

push	eax
push	ebx
push	ecx
push	edx

; first we see if the point (X,Y) is located within the boundaries
invoke _PointInBox, word [ebp+.X], word [ebp+.Y], word 0, word 0, word [ebp+.DestWidth], word [ebp+.DestHeight]
cmp	eax, 0	
je	near .Exit

; if we made it this far, we know our coords are valid
; first calculate the offset of the (X,Y) pixel
; then we set the dword located at that offset

movzx	ecx, word [ebp+.DestWidth]
movzx	eax, word [ebp+.Y]

mul	ecx		; edx:eax equals result
mov	edx, eax

movzx	eax, word [ebp+.X]
add	eax, edx
shl	eax, 2		; = ((Y * Width) + X)*4

mov	ebx, dword [ebp+.DestOff]
add	ebx, eax

mov	eax, dword [ebp+.Color]
mov	dword [ebx], eax		; set the color at offset pertaining to coord X,Y

.Exit:
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax
	ret

endproc
_DrawPixel_arglen	EQU	16


;______________________________________________________________
;                         DrawLine()                  
; 
; Inputs: X1 & X2 Coords, Y1 & Y2 Coords, Destination Offset, 
;         Destination Height, Destination Width, and Color
; 
; Outputs: Draw a line with color Color from point (X1,Y1) to
;	   (X2,Y2) using the graphics algorithm given
; Created by: entire group
;--------------------------------------------------------------
proc _DrawLine
.DestOff	arg	4
.DestWidth	arg	2
.DestHeight	arg	2
.X1		arg	2
.Y1		arg	2
.X2		arg	2
.Y2		arg	2
.Color		arg	4

push	eax
push	ebx
push	ecx
push	edx

; The lines below perform:
; dx = abs(x2-x1)
mov	ax, word [ebp+.X1]	
mov	bx, word [ebp+.X2]
cmp	ax, bx
jge	near .A_IS_BIGGER
sub	bx, ax
mov	word [_dx], bx
jmp	near .NowForTheYs

.A_IS_BIGGER:
	sub	ax, bx
	mov	word [_dx], ax

; Same process as above
; instead we are now calculating
; dy = abs(y2-y1)
.NowForTheYs:
mov	ax, word [ebp+.Y1]
mov	bx, word [ebp+.Y2]
cmp	ax, bx
jge	near .A_IS_BIGGER2
sub	bx, ax
mov	word [_dy], bx
jmp	near .SetVars

.A_IS_BIGGER2:
	sub	ax, bx
	mov	word [_dy], ax

; The code below sets up the variables for the line function prior to
; looping
.SetVars:
mov	ax, word [_dx]
mov	bx, word [_dy]
cmp	word [_dx], bx
jge	near .DX_IS_BIGGER

mov	cx, bx
inc	cx				; numpixels = dy + 1

mov	word [_lineerror], ax		; line error = dx
shl	word [_lineerror], 1		; line error = dx * 2
sub	word [_lineerror], bx		; line error = (2 * dx) - dy

mov	word [_errornodiaginc], ax	; errornodiaginc = dx
shl	word [_errornodiaginc], 1	; errornodiaginc = dx * 2

mov	word [_errordiaginc], ax	; = dx
sub	word [_errordiaginc], bx	; = dx - dy
shl	word [_errordiaginc], 1		; = (dx - dy) * 2

mov	word [_xhorizinc], word 0
mov	word [_xdiaginc], word 1
mov	word [_yvertinc], word 1
mov	word [_ydiaginc], word 1
jmp	near .ADJUSTMENTS

.DX_IS_BIGGER:
	mov	cx, ax		; numpixels = dx
	inc	cx		; numpixels = dx + 1

	mov	word [_lineerror], bx		; line error = dy
	shl	word [_lineerror], 1		; line error = dy * 2
	sub	word [_lineerror], ax		; line error = (2 * dy) - dx

	mov	word [_errornodiaginc], bx	; errornodiaginc = dy
	shl	word [_errornodiaginc], 1	; errornodiaginc = dy * 2

	mov	word [_errordiaginc], bx	; = dy
	sub	word [_errordiaginc], ax	; = dy - dx
	shl	word [_errordiaginc], 1		; = (dy - dx) * 2

	mov	word [_xhorizinc], word 1
	mov	word [_xdiaginc], word 1
	mov	word [_yvertinc], word 0
	mov	word [_ydiaginc], word 1

.ADJUSTMENTS:
mov	ax, word [ebp+.X1]
mov	bx, word [ebp+.X2]

cmp	ax, bx
jle	near .NEXT_TEST
	neg	word [_xhorizinc]
	neg	word [_xdiaginc]

.NEXT_TEST:
mov	ax, word [ebp+.Y1]
mov	bx, word [ebp+.Y2]
cmp	ax, bx
jle	near .BEGIN_LOOPING
	neg	word [_yvertinc]
	neg	word [_ydiaginc]
	
.BEGIN_LOOPING:
mov	ax, word [ebp+.X1]
mov	bx, word [ebp+.Y1]

mov	word [_x], ax		; x = X1
mov	word [_y], bx		; y = Y1

mov	dx, 1

.AGAIN:
	cmp	dx, cx
	je	near .END

	invoke	_DrawPixel, dword [ebp+.DestOff], word [ebp+.DestWidth], word [ebp+.DestHeight], word [_x], word [_y], dword [ebp+.Color]

	cmp	word [_lineerror], 0
	jge	near .PHASE2	
	mov	ax, word [_errornodiaginc]
	add	word [_lineerror], ax
	mov	ax, word [_xhorizinc]
	mov	bx, word [_yvertinc]
	add	word [_x], ax
	add	word [_y], bx
	inc	dx
	jmp	near .AGAIN

	.PHASE2:
		mov	ax, word [_errordiaginc]
		add	word [_lineerror], ax
		mov	ax, word [_xdiaginc]
		mov	bx, word [_ydiaginc]
		add	word [_x], ax
		add	word [_y], bx
		inc	dx
		jmp	near .AGAIN

.END:
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax
	ret

endproc
_DrawLine_arglen	EQU	20
	  
;______________________________________________________________
;                         DrawRect()                  
; 
; Inputs: X1 & X2 Coords, Y1 & Y2 Coords, Destination Offset, 
;         Destination Height, Destination Width, Color,
;	  Flood Fill Tag
; 
; Outputs: Draw a rectangle with color Color from point (X1,Y1) to
;	   (X2,Y2). Essentially draw four lines that make up
;	   a rectangle. top, right, left, and bottom line
;	   Flood Fill if tag is set
; Created by: entire group
;--------------------------------------------------------------
proc _DrawRect
.DestOff	arg	4
.DestWidth	arg	2
.DestHeight	arg	2
.X1		arg	2
.Y1		arg	2
.X2		arg	2
.Y2		arg	2
.Color		arg	4
.FillRectFlag	arg	4

push	eax
push	ebx
push	ecx
push	edx

; draw four lines from the four different pairs of coordinates
invoke	_DrawLine, dword [ebp+.DestOff], word [ebp+.DestWidth], word [ebp+.DestHeight], word [ebp+.X1], word [ebp+.Y1], word [ebp+.X2], word [ebp+.Y1], dword [ebp+.Color]
invoke	_DrawLine, dword [ebp+.DestOff], word [ebp+.DestWidth], word [ebp+.DestHeight], word [ebp+.X1], word [ebp+.Y1], word [ebp+.X1], word [ebp+.Y2], dword [ebp+.Color]
invoke	_DrawLine, dword [ebp+.DestOff], word [ebp+.DestWidth], word [ebp+.DestHeight], word [ebp+.X2], word [ebp+.Y1], word [ebp+.X2], word [ebp+.Y2], dword [ebp+.Color]
invoke	_DrawLine, dword [ebp+.DestOff], word [ebp+.DestWidth], word [ebp+.DestHeight], word [ebp+.X1], word [ebp+.Y2], word [ebp+.X2], word [ebp+.Y2], dword [ebp+.Color]

; check to see if we need to flood fill
cmp	dword [ebp+.FillRectFlag], 0
je	near .Exit

mov	ax, word [ebp+.X1]
mov	bx, word [ebp+.X2]
mov	cx, word [ebp+.Y1]
mov	dx, word [ebp+.Y2]

; if the differences in x or y coords = 0, we have either a straightline or a dot
; therefore, in this SPECIAL case, we should not floodfill even if we are supposed to
; because we will end up floodfilling the entire screen.

cmp	ax, bx
jz	near .Exit

cmp	cx, dx
jz	near .Exit

add	ax, bx
shr	ax, 1
mov	word [_x], ax

add	cx, dx
shr	cx, 1
mov	word [_y], cx

invoke	_FloodFill, dword [ebp+.DestOff], word [ebp+.DestWidth], word [ebp+.DestHeight], word [_x], word [_y], dword [ebp+.Color], dword 0 

.Exit:
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax
	ret

endproc
_DrawRect_arglen	EQU	24


;______________________________________________________________
;                         DrawCircle()                  
; 
; Inputs: X Coord, Y Coord, Destination Offset, 
;         Destination Height, Destination Width, Color, 
;	  Radius and FillFlag
; 
; Outputs: Draw a circle with color Color at (X,Y) with
;	   radius Radius. Flood fill if tag is set.
;	   Based off of the circle algorithm provided
; Created by: entire group
;--------------------------------------------------------------
proc _DrawCircle
.DestOff	arg	4
.DestWidth	arg	2
.DestHeight	arg	2
.X		arg	2
.Y		arg	2
.Radius		arg	2
.Color		arg	4
.FillCircleFlag	arg	4

pushad

mov	ax, word [ebp+.Radius]
mov	word [_radius], ax		; _radius = Radius

mov	word [_xdist], word 0		; _xdist = 0
mov	word [_ydist], ax		; _ydist = radius
mov	word [_circleerror], 1
sub	word [_circleerror], ax		; _circleerror = 1 - radius

mov	cx, word [_xdist]
mov	dx, word [_ydist]

; CX = xDist
; DX = yDist
;----------
.Again:

cmp	cx, dx
jg	near .Done

; AX = X
; BX = Y
; -------

mov	ax, word [ebp+.X]
mov	bx, word [ebp+.Y]

mov	word [_x2], ax		; _x = X
mov	word [_y2], bx		; _y = Y

add	word [_x2], cx		; _x = X + xDist
add	word [_y2], dx		; _y = Y + yDist

push	eax
invoke	_PointInBox, word [_x2], word [_y2], word GameScreenX, word GameScreenY, word GameScreenX+640, word GameScreenY+397
cmp	eax, 0
pop	eax
je	near .Next
invoke _DrawPixel, dword [ebp+.DestOff], word [ebp+.DestWidth], word [ebp+.DestHeight], word [_x2], word [_y2], dword [ebp+.Color]

.Next
mov	word [_x2], ax
sub	word [_x2], cx		; _x = X - xDist
push	eax
invoke	_PointInBox, word [_x2], word [_y2], word GameScreenX, word GameScreenY, word GameScreenX+640, word GameScreenY+397
cmp	eax, 0
pop	eax
je	near .Next2
invoke _DrawPixel, dword [ebp+.DestOff], word [ebp+.DestWidth], word [ebp+.DestHeight], word [_x2], word [_y2], dword [ebp+.Color]



.Next2:
mov	word [_x2], ax
mov	word [_y2], bx

add	word [_x2], cx		; _x = X + xDist
sub	word [_y2], dx		; _y = Y - yDist
push	eax
invoke	_PointInBox, word [_x2], word [_y2], word GameScreenX, word GameScreenY, word GameScreenX+640, word GameScreenY+397
cmp	eax, 0
pop	eax
je	near .Next3
invoke _DrawPixel, dword [ebp+.DestOff], word [ebp+.DestWidth], word [ebp+.DestHeight], word [_x2], word [_y2], dword [ebp+.Color]


.Next3:
mov	word [_x2], ax
sub	word [_x2], cx		; _x = X - xDist
push	eax
invoke	_PointInBox, word [_x2], word [_y2], word GameScreenX, word GameScreenY, word GameScreenX+640, word GameScreenY+397
cmp	eax, 0
pop	eax
je	near .Next4
invoke _DrawPixel, dword [ebp+.DestOff], word [ebp+.DestWidth], word [ebp+.DestHeight], word [_x2], word [_y2], dword [ebp+.Color]


.Next4:
mov	word [_x2], ax
mov	word [_y2], bx

add	word [_x2], dx		; _x = X + yDist
add	word [_y2], cx		; _y = Y + xDist
push	eax
invoke	_PointInBox, word [_x2], word [_y2], word GameScreenX, word GameScreenY, word GameScreenX+640, word GameScreenY+397
cmp	eax, 0
pop	eax
je	near .Next5
invoke _DrawPixel, dword [ebp+.DestOff], word [ebp+.DestWidth], word [ebp+.DestHeight], word [_x2], word [_y2], dword [ebp+.Color]


.Next5:
mov	word [_x2], ax
sub	word [_x2], dx		; _x = X - yDist
push	eax
invoke	_PointInBox, word [_x2], word [_y2], word GameScreenX, word GameScreenY, word GameScreenX+640, word GameScreenY+397
cmp	eax, 0
pop	eax
je	near .Next6
invoke _DrawPixel, dword [ebp+.DestOff], word [ebp+.DestWidth], word [ebp+.DestHeight], word [_x2], word [_y2], dword [ebp+.Color]

.Next6:
mov	word [_x2], ax
mov	word [_y2], bx

add	word [_x2], dx		; _x = X + yDist		
sub	word [_y2], cx		; _y = Y - xDist
push	eax
invoke	_PointInBox, word [_x2], word [_y2], word GameScreenX, word GameScreenY, word GameScreenX+640, word GameScreenY+397
cmp	eax, 0
pop	eax
je	near .Next7
invoke _DrawPixel, dword [ebp+.DestOff], word [ebp+.DestWidth], word [ebp+.DestHeight], word [_x2], word [_y2], dword [ebp+.Color]


.Next7:
mov	word [_x2], ax
sub	word [_x2], dx		; _x = X - yDist
push	eax
invoke	_PointInBox, word [_x2], word [_y2], word GameScreenX, word GameScreenY, word GameScreenX+640, word GameScreenY+397
cmp	eax, 0
pop	eax
je	near .Next8
invoke _DrawPixel, dword [ebp+.DestOff], word [ebp+.DestWidth], word [ebp+.DestHeight], word [_x2], word [_y2], dword [ebp+.Color]



.Next8:
inc	word [_xdist]

mov	cx, word [_xdist]
mov	dx, word [_ydist]

cmp	word [_circleerror], 0
jge	near .Other
shl	cx, 1				;xDist * 2
add	word [_circleerror], cx
inc	word [_circleerror]
mov	dx, word [_ydist]
mov	cx, word [_xdist]
jmp	near .Again

.Other:
	dec	word [_ydist]
	mov	dx, word [_ydist]
	mov	cx, word [_xdist]

	mov	ax, cx
	sub	ax, dx
	shl	ax, 1	; 2(dx- dy)

	add	word [_circleerror], ax
	inc	word [_circleerror]
	
	mov	dx, word [_ydist]
	mov	cx, word [_xdist]
	jmp	near .Again

.Done:
	cmp	dword [ebp+.FillCircleFlag], 0
	je	near .Exit

	cmp	word [_radius], 0
	je	near .Exit

	invoke	_FloodFill, dword [ebp+.DestOff], word [ebp+.DestWidth], word [ebp+.DestHeight], word [ebp+.X], word [ebp+.Y], dword [ebp+.Color], dword 0 

.Exit:
popad
ret

endproc
_DrawCircle_arglen	EQU	22


;______________________________________________________________
;                         DrawText()                  
; 
; Inputs: String Offset, Destination Offset, Destination Width,
;	  Destination Height, X, Y, Color
; 
; Outputs: Draw whatever text string is in String Offset to the
;	   Destination Offset Buffer
; Created by: entire group
;--------------------------------------------------------------
proc _DrawText
.StringOff	arg	4
.DestOff	arg	4
.DestWidth	arg	2
.DestHeight	arg	2
.X		arg	2
.Y		arg	2
.Color		arg	4

pushad

mov	word [_dx], 0				; offset to string of text

mov	ax, word [ebp+.X]
mov	word [_x], ax				; _x = X coord

mov	ax, word [ebp+.Y]
mov	word [_y], ax				; _y = Y coord

; This is how this function is set up.....
; Basically, I grab a character from the String Offset, making sure its not
; NULL or $ --> signifying the end of the string. If my character is not one
; of those two, I hold that ascii value and then calculate the offset to the
; ascii character in question in respect to FontOff. This offset is equal to
; ascii character value (decimal) * 16 (width of each character) * 4 (bytes per pixels)
; Once I find the right offset, I jump to that position and copy each pixel to
; the Destination Offset. But... before I right to DestOff, I make sure that it is
; a valid location.  I continue till I recursed through all of FontOff & all of
; StringOff.  However during this whole process I could of possibly only written
; to part of the DestOff (depending on the location of DestOff). 
.Again:

mov	eax, dword [ebp+.StringOff]
movzx	ebx, word [_dx]
add	eax, ebx

mov	bl, byte [eax]				; bl = character
cmp	bl, '$'
je	near .Exit

cmp	bl, 0
je	near .Exit

mov	esi, dword [_FontOff]
movzx	ecx, bl
shl	ecx, 6
add	esi, ecx				; ESI = FontOff

xor	cx, cx
xor	dx, dx

.LOOP_AGAIN:
	invoke	_PointInBox, word [_x], word [_y], word 0, word 0, word [ebp+.DestWidth], word [ebp+.DestHeight]
	cmp	eax, 0
	je	near .Cont
	
	cmp	cx, 0
	jne	near .Cont2
	
	cmp	dx, 16
	je	near .Done

	.Cont2:

	push	ecx
	push	edx

	mov	dword edi, dword [ebp+.DestOff]
	movzx	eax, word [ebp+.DestWidth]
	movzx	ecx, word [_y]
	mul	ecx
	mov	edx, eax
	movzx	eax, word [_x]
	add	edx, eax
	shl	edx, 2
	add	edi, edx				; EDI has the proper offset = DestOff

	mov	eax, dword [ebp+.Color]
	mov	dword [edi], eax
	and	dword [edi], 00FFFFFFh
	mov	eax, dword [esi]
	and	eax, 0FF000000h
	or	dword [edi], eax
	
	pop	edx
	pop	ecx
	.Cont:
		add	esi, 4

	inc	word [_x]
	inc	cx

	cmp	cx, 16
	je	near .Special			; if we reach delta x = 16, or x = width, wraparound

	cmp	dx, 16
	je	near .Done
	
	jmp	near .LOOP_AGAIN

.Special:
	inc	word [_y]
	inc	dx
	add	esi, dword 8128
	sub	word [_x], 16
	mov	cx, 0
	
	jmp	near .LOOP_AGAIN

.Done:
	inc	word [_dx]
	mov	ax, word [ebp+.Y]
	mov	word [_y], ax
	mov	ax, word [ebp+.X]
	mov	word [_x], ax
	mov	ax, word [_dx]
	shl	ax, 4
	add	word [_x], ax
	jmp	near .Again

.Exit:
	popad
	ret

endproc
_DrawText_arglen	EQU	20

;______________________________________________________________
;                         ClearBuffer()                  
; 
; Inputs: Destination Offset, Destination Width,
;	  Destination Height, Color
; 
; Outputs: Clear everything in the buffer to the color specified
; Created by: entire group
;--------------------------------------------------------------
proc _ClearBuffer
.DestOff	arg	4
.DestWidth	arg	2
.DestHeight	arg	2
.Color		arg	4

pushad
CLD		; This will make the internal counter in STOSD add 4 during each rep.

mov	edi, dword [ebp+.DestOff]
movzx	ecx, word [ebp+.DestWidth]	; Width	
movzx	eax, word [ebp+.DestHeight]	; Height
mul	ecx
mov	ecx, eax			; Counter
mov	eax, dword [ebp+.Color]		; What we are storing each time
rep	stosd				; [edi] = eax, add edi+=4

popad
ret

endproc
_ClearBuffer_arglen	EQU	12


;______________________________________________________________
;                         CopyBuffer()                  
; 
; Inputs: Source Offset, Src Width, Src Height, Destination Offset, 
;	  Destination Width, Destination Height, X, Y
; 
; Outputs: Copy everything at Src Offset to Dest Off at point X,Y
;--------------------------------------------------------------
proc _CopyBuffer

.SrcOff		arg	4
.SrcWidth	arg	2
.SrcHeight	arg	2
.DestOff	arg	4
.DestWidth	arg	2
.DestHeight	arg	2
.X		arg	2
.Y		arg	2

pushad

CLD				; This will make the internal counter in STOSD add 4 during each rep.

mov	edi, dword [ebp+.DestOff]
mov	esi, dword [ebp+.SrcOff]

movzx	ecx, word [ebp+.Y]
movzx	eax, word [ebp+.DestWidth]
mul	ecx
mov	edx, eax
movzx	eax, word [ebp+.X]
add	edx, eax
shl	edx, 2
add	edi, edx			; edi is set to the right place in terms of DestOff


movzx	ecx, word [ebp+.SrcWidth]	; Width	
mov	ax, 1

.Part1:
	rep	movsd
	cmp	ax, word [ebp+.SrcHeight]
	je	near .Exit
	
	inc	ax
	movzx	edx, word [ebp+.DestWidth]
	shl	edx, 2
	add	edi, edx
	movzx	edx, word [ebp+.SrcWidth]
	shl	edx, 2
	sub	edi, edx

	movzx	ecx, word [ebp+.SrcWidth]
	jmp	near .Part1

.Exit:
	popad
	ret


endproc
_CopyBuffer_arglen	EQU	20


;______________________________________________________________
;                         ComposeBuffer()                  
; 
; This function alpha composes two pixels using the graphics
; algorithm given
;
; Inputs: a source offset, the dimensions of that source offset,
;  a destination offset, the dimensions of the dest buffer, 
;  X and Y coordinates of the pixel to be drawn
; Outputs: the pixel into a register
; Created by: entire group
;--------------------------------------------------------------
proc _ComposeBuffers
.SrcOff		arg	4
.SrcWidth	arg	2
.SrcHeight	arg	2
.DestOff	arg	4
.DestWidth	arg	2
.DestHeight	arg	2
.X	        arg	2
.Y		arg	2

pushad
 
mov	edi, dword [ebp+.DestOff]	; edi = DestOff
mov	esi, dword [ebp+.SrcOff]	; esi = SrcOff

movzx	eax, word [ebp+.DestWidth]
movzx	ecx, word [ebp+.Y]
mul	ecx
movzx   ecx, word [ebp+.X]
add	eax, ecx
shl	eax, 2
add	edi, eax			; edi is set to the right place

mov	bx, word [ebp+.SrcHeight] 
 
.HeightLoop:
	cmp	bx, 0
	je	near .Exit
	movzx	ecx, word [ebp+.SrcWidth] 
.WidthLoop:
  	cmp	cx, 0
	je	near .Adjust

	pxor	mm0, mm0
	pxor	mm1, mm1
	pxor	mm2, mm2
	pxor	mm3, mm3				; just for good measure, clear all these MMX registers
	pxor	mm4, mm4
	pxor	mm5, mm5
	pxor	mm6, mm6
	pxor	mm7, mm7

	movq	mm0, qword [esi]			; mm0 = 2 SRC pixels
	movq	mm1, qword [edi]			; mm1 = 2 DEST pixels

	movq	mm5, mm0		
	PUNPCKLBW mm5, mm3	
	movq	mm2, mm5	
	punpckhwd	mm2, mm2			; contains the alphas 
	punpckhdq	mm2, mm2
	pmullw	mm5, mm2
	
	paddw	mm5, qword [_RoundingFactor]
	psrlw	mm5, 8				; mm3 = 2nd ORIGINAL SRC pixel

	movq	mm6, mm1
	punpcklbw	mm6, mm3

	paddw	mm5, mm6
	pmullw	mm6, mm2

	paddw	mm6, qword [_RoundingFactor]
	psrlw	mm6, 8

	psubw	mm5, mm6

	pxor	mm2, mm2
	pxor	mm6, mm6

	punpckhbw mm0, mm6
	movq	mm2, mm0
	punpckhwd mm2, mm2
	punpckhdq mm2, mm2

	pmullw	mm0, mm2
	paddw	mm0, qword [_RoundingFactor]
	psrlw	mm0, 8

	punpckhbw mm1, mm6
	paddw mm0, mm1
	pmullw mm1, mm2
	paddw mm1, qword [_RoundingFactor]
	psrlw mm1, 8
	psubw mm0, mm1

	pxor mm6, mm6
	packuswb mm5, mm0

	movq qword [edi], mm5
	emms
	add	edi, 8
	add	esi, 8

	sub cx, 2
	jmp	near .WidthLoop 


	.Adjust:
		movzx eax, word [ebp+.DestWidth]
		sub	ax, word [ebp+.SrcWidth]
		shl	eax, 2
		add edi, eax
		dec	bx
		jmp	near .HeightLoop

	.Exit
		emms
		popad
		ret

endproc
_ComposeBuffers_arglen	EQU	20


;-------------------------------------------------------------------------;
; FloodFill()								  ;
;									  ;
;   void _CopyBuffer(dword DestOff, word DestWidth, word DestHeight,	  ;
;                     word X, word Y, dword .Color, dword ComposeFlag)	  ;
;									  ;
;   Inputs: DestOff= offset of an image buffer in memory		  ;
;           DestWidth = width of destination buffer			  ;
;	    DestHeight = height of destination buffer			  ;
;	    X = x coordinate of point in the region			  ;
;	    Y = y coordinate of point in the region			  ;
;	    Color = new color for region				  ;
;	    ComposeFlag = flag to determine whether or not to alpha	  ;
;	               compose the current color of the region with Color ;
;									  ;
;   Outputs: Region filled with color Color in buffer			  ;
;									  ;
;   Calls: _PointInBox, _GetPixel, _DrawPixel				  ;
;									  ;
;   Returns: none							  ;
;									  ;
;   Purpose: Performs a flood fill operation on a region in the buffer	  ;
;	     pointed to by DestOff					  ;
; Created by: entire group						  ; 	
;-------------------------------------------------------------------------;
proc _FloodFill
.DestOff	arg	4
.DestWidth	arg	2
.DestHeight	arg	2
.X		arg	2
.Y		arg	2
.Color		arg	4
.ComposeFlag	arg	4

pushad

; First make sure to have _Head & _Tail point to the same place in Point Queue
mov	ebx, dword[_PointQueue]
mov	dword [_QueueHead], ebx
mov	dword [_QueueTail], ebx

; Remember that we are dealing with a width from 0 to width - 1 and so on for height
dec	word[ebp+.DestWidth]
dec	word[ebp+.DestHeight]
invoke _PointInBox, word[ebp+.X], word [ebp+.Y], word 0, word 0, word[ebp+.DestWidth], word[ebp+.DestHeight]
inc	word[ebp+.DestWidth]
inc	word[ebp+.DestHeight]

cmp	ax, 1
jne near .Exit

mov	ebx, dword[_QueueTail]
mov	dx, word[ebp+.X]
mov	word[ebx], dx
mov	dx, word[ebp+.Y]
mov	word [ebx+2], dx
add	dword[_QueueTail], 4		; When you ENQUEUE, you add 4 to the _QueueTail

invoke _GetPixel, dword[ebp+.DestOff], word[ebp+.DestWidth], word [ebp+.DestHeight], word[ebp+.X], word [ebp+.Y]
mov	edx, eax

cmp	dword[ebp+.ComposeFlag], 1
jne	near .Again

; This is the alpha composing taken from Compose Buffers
movd	mm0, dword [ebp+.Color]
movd	mm1, edx

pxor	mm2, mm2
pxor	mm3, mm3

punpcklbw	mm0, mm3
movq	mm2, mm0
punpckhwd	mm2, mm2
punpckhdq	mm2, mm2
pmullw	mm0, mm2
	
paddw	mm0, qword[_RoundingFactor]
psrlw	mm0, 8
	
punpcklbw	mm1, mm3
paddw	mm0, mm1
pmullw	mm1, mm2
paddw	mm1, qword[_RoundingFactor]
psrlw	mm1, 8
psubw	mm0, mm1

packuswb	mm0, mm3
movd	eax, mm0
emms
mov	dword[ebp+.Color], eax
.Again:
	mov	ecx, [_QueueHead]
	cmp	ecx, [_QueueTail]
	jnb	near .Exit
	
	mov	ebx, dword[_QueueHead]
	mov	si, [ebx]
	mov	di, [ebx+2]
	add	dword[_QueueHead], 4
	dec	word[ebp+.DestWidth]
	dec	word[ebp+.DestHeight]
	invoke _PointInBox, si, di, word 0, word 0, word [ebp+.DestWidth], word[ebp+.DestHeight]
	inc	word[ebp+.DestWidth]
	inc	word[ebp+.DestHeight]
	cmp	eax, 1
	jne	near .Again

	invoke _GetPixel, dword[ebp+.DestOff], word[ebp+.DestWidth], word[ebp+.DestHeight], si, di
	cmp	edx, eax
	jne	near .Again

	cmp	edx, dword[ebp+.Color]
	je	near .Again
	
	invoke _DrawPixel, dword[ebp+.DestOff], word[ebp+.DestWidth], word[ebp+.DestHeight], si, di, dword[ebp+.Color]
	
	mov	ebx, dword[_QueueTail]
	inc	si
	dec	word[ebp+.DestWidth]
	dec	word[ebp+.DestHeight]
	invoke _PointInBox, si, di, word 0, word 0, word[ebp+.DestWidth], word[ebp+.DestHeight]
	inc	word[ebp+.DestWidth]
	inc	word[ebp+.DestHeight]
	cmp	eax, 1
	jne	near .Case1
	
	mov	[ebx], si
	mov	[ebx+2], di
	add	dword[_QueueTail], 4	

.Case1:
	dec	si
	dec	si
	mov	ebx, dword[_QueueTail]
	dec	word[ebp+.DestWidth]
	dec	word[ebp+.DestHeight]
	invoke _PointInBox, si, di, word 0, word 0, word[ebp+.DestWidth], word[ebp+.DestHeight]
	inc	word[ebp+.DestWidth]
	inc	word[ebp+.DestHeight]
	cmp	eax, 1
	jne	near .Case2

	mov	[ebx], si
	mov	[ebx+2], di
	add	dword[_QueueTail], 4

.Case2:
	inc	si
	inc	di
	mov	ebx, dword[_QueueTail]
	dec	word[ebp+.DestWidth]
	dec	word[ebp+.DestHeight]
	invoke _PointInBox, si, di, word 0, word 0, word[ebp+.DestWidth], word[ebp+.DestHeight]
	inc	word[ebp+.DestWidth]
	inc	word[ebp+.DestHeight]
	cmp	eax, 1
	jne	near .Case3	
	mov	[ebx], si
	mov	[ebx+2], di
	add	dword[_QueueTail], 4

.Case3:
	sub	di, 2
	mov	ebx, dword[_QueueTail]
	dec	word[ebp+.DestWidth]
	dec	word[ebp+.DestHeight]
	invoke _PointInBox, si, di, word 0, word 0, word[ebp+.DestWidth], word[ebp+.DestHeight]
	inc	word[ebp+.DestWidth]
	inc	word[ebp+.DestHeight]
	cmp	eax, 1
	jne	near .Setup
	mov	[ebx], si
	mov	[ebx+2], di
	add	dword[_QueueTail], 4
	
.Setup:
	inc di
	jmp .Again

.Exit:
	emms
	popad
	ret


endproc
_FloodFill_arglen	EQU	20

;-------------------------------------------------------------------------;
; InstallKeyboard()							  ;
;									  ;
;   dword _InstallKeyboard(void)					  ;
;									  ;
;   Inputs: none							  ;
;									  ;
;   Outputs: none							  ;
;									  ;
;   Calls: _LockArea							  ;
;									  ;
;   Returns: 1 on error, 0 otherwise					  ;
;									  ;
;   Purpose: Installs the keyboard ISR					  ;
;									  ;
;-------------------------------------------------------------------------;
; Created by: entire group
_InstallKeyboard

movzx	eax, byte [_kbINT]
invoke	_Install_Int, dword eax, dword _KeyboardISR
cmp	eax, 0
jne	near .Error

invoke	_LockArea, cs, dword _KeyboardISR, dword _KeyboardISR_end-_KeyboardISR
cmp	eax, 0
jne	near .Error

invoke	_LockArea, ds, dword _MPFlags, dword 1
cmp	eax, 0
jne	near .Error

invoke	_LockArea, ds, dword _key, dword 1
cmp	eax, 0
jne	near .Error

mov	eax, 0
jmp	.End

.Error:
	mov	eax, 1
	ret
.End:
	ret

;-------------------------------------------------------------------------;
; RemoveKeyboard()							  ;
;									  ;
;   void _RemoveKeyboard(void)						  ;
;									  ;
;   Inputs: none							  ;
;									  ;
;   Outputs: none							  ;
;									  ;
;   Calls: _Remove_Int							  ;
;									  ;
;   Returns: none							  ;
;									  ;
;   Purpose: Uninstalls the keyboard ISR				  ;
;									  ;
;-------------------------------------------------------------------------;
; Created by: entire group
_RemoveKeyboard

push	eax
movzx	eax, byte [_kbINT]

invoke	_Remove_Int, dword eax
pop	eax
ret

;-------------------------------------------------------------------------;
; KeyboardISR()								  ;
;									  ;
;   void _RemoveKeyboard(void)						  ;
;									  ;
;   Inputs: Keypress waiting at port [_kbPort], [_kbIRQ]		  ;
;									  ;
;   Outputs: [_key], [_MPFlags]						  ;
;									  ;
;   Calls: none								  ;
;									  ;
;   Returns: none							  ;
;									  ;
;   Purpose: Handles keyboard input from the user			  ;
;									  ;
;-------------------------------------------------------------------------;
; Created by: entire group
_KeyboardISR

pushad

mov	dx, word [_kbPort]
IN	al, dx

cmp	al, 1
jne	near .CONT
mov	byte [_key], 27
or	byte [_MPFlags], 01h
or	byte [_MPFlags], 01000000b
jmp	near .POP

.CONT:
	and	byte [_MPFlags], 0FEh
	cmp	al, 80h
	jnb	near .RELEASED_KEY

	cmp	al, 42
	jne	.RSHIFT
	or	byte [_MPFlags], 16
	jmp	near .EXIT

.RSHIFT:
	cmp	al, 54
	jne	.NORMAL_CHAR
	or	byte [_MPFlags], 8
	jmp	near .EXIT

.NORMAL_CHAR:
	mov	dl, byte [_MPFlags]
	and	dl, 00011000b
	cmp	dl, 0
	jne	near .SHIFT

	movzx	ebx, al
	mov	cl, byte [_QwertyNames + ebx]
	or	byte [_MPFlags], 01000000b
	mov	byte [_key], cl
	or	byte [_MPFlags], 32
	jmp	near .EXIT

.SHIFT:
	movzx	ebx, al
	mov	cl, byte [_QwertyShift + ebx]
	or	byte [_MPFlags], 01000000b
	mov	byte [_key], cl
	or	byte [_MPFlags], 32
	jmp	near .EXIT

.RELEASED_KEY:
	cmp	al, 170
	jne	.CLEAR_SHIFT
	and	byte [_MPFlags], 11101111b
	jmp	near .EXIT

.CLEAR_SHIFT:
	cmp	al, 182
	jne	near .EXIT
	and	byte [_MPFlags], 11110111b
	jmp	near .EXIT

.EXIT:
	mov	al, 20h
	out	20h, al
	cmp	byte [_kbIRQ], 8
	jl	near .POP
	out	0A0h, al

.POP:
	popad
	ret

_KeyboardISR_end



;-------------------------------------------------------------------------;
; Delay()								  ;
;									  ;
;   void _Delay(void)							  ;
;									  ;
;   Inputs: NumTicks							  ;
;									  ;
;   Outputs: none							  ;
;									  ;
;   Calls: none								  ;
;									  ;
;   Returns: none							  ;
;									  ;
;   Purpose: Delays the program by the number of ticks specified	  ;
;									  ;
;   Written by: Edwin Daniels						  ;
;									  ;
;-------------------------------------------------------------------------;
proc _Delay
.NumTicks	arg	4
	pushad

	mov eax, dword [ebp + .NumTicks]
	mov ebx, dword [_TimerTick]
	add eax, ebx

	.delayloop
	cmp [_TimerTick], eax
	jb .delayloop

	mov [_TimerTick], ebx

	popad
	ret

endproc
_Delay_arglen	EQU	4






;-------------------------------------------------------------------------;
; InstallTimer()							  ;
;									  ;
;   void _InstallTimer(void)						  ;
;									  ;
;   Inputs: none							  ;
;									  ;
;   Outputs: eax=1 if error, 0 otherwise				  ;
;									  ;
;   Calls: Install_Int, LockArea (pmodelib routine)			  ;
;									  ;
;   Returns: none							  ;
;									  ;
;   Purpose: Install TimerISR						  ;
;									  ;
;   Written by: Terrence Janas						  ;
;									  ;
;-------------------------------------------------------------------------;

_InstallTimer

push eax
invoke _LockArea, word cs, dword _TimerISR, dword _TimerISR_end-_TimerISR
invoke _LockArea, word ds, dword _TimerTick, dword 2
xor eax, eax
mov al, 8
invoke _Install_Int, dword eax, dword _TimerISR
pop eax
ret




;-------------------------------------------------------------------------;
; RemoveTimer()								  ;
;									  ;
;   void _RemoveTimer(void)						  ;
;									  ;
;   Inputs: none							  ;
;									  ;
;   Outputs: none							  ;
;									  ;
;   Calls: Remove_Int (pmodelib routine)				  ;
;									  ;
;   Returns: none							  ;
;									  ;
;   Purpose: Uninstalls TimerISR and restores original handler		  ;
;									  ;
;   Written by: Terrence Janas						  ;
;									  ;
;-------------------------------------------------------------------------;

_RemoveTimer

push eax
xor eax, eax
mov al, 8
invoke _Remove_Int, dword eax
pop eax
ret




;-------------------------------------------------------------------------;
; TimerISR()								  ;
;									  ;
;   dword _TimerISR(void)						  ;
;									  ;
;   Inputs: [_TimerTick]						  ;
;									  ;
;   Outputs: [_TimerTick]						  ;
;									  ;
;   Calls: none								  ;
;									  ;
;   Returns: none							  ;
;									  ;
;   Purpose: Handles timer ticks from the system timer			  ;
;									  ;
;   Written by: Edwin Daniels (previous ECE291 student)			  ;
;									  ;
;-------------------------------------------------------------------------;

_TimerISR

inc dword [_TimerTick]
mov eax, 1
ret

_TimerISR_end



;-------------------------------------------------------------------------;
; LevelUpSound()							  ;
;									  ;
;   void _LevelUpSound(void)						  ;
;									  ;
;   Inputs: none							  ;
;									  ;
;   Outputs: makes the PC speaker beep					  ;
;									  ;
;   Calls: Delay							  ;
;									  ;
;   Returns: none							  ;
;									  ;
;   Purpose: Play a very short melody when a player levels up		  ;
;									  ;
;   Written by: Terrence Janas						  ;
;									  ;
;-------------------------------------------------------------------------;

_LevelUpSound

	push ax
	push cx

cmp	byte [_SoundFlag], 1
jne	near .Skip

	mov al, 182		; Prepare the PC speaker for the notes
	out 43h, al
	in al, 61h
	or al, 00000011b
	out 61h, al

	mov cl, 2



	.Notes:
	mov ax, 3100
	out 42h, al
	mov al, ah
	out 42h, al
	invoke _Delay, dword 2


	mov ax, 2600
	out 42h, al
	mov al, ah
	out 42h, al
	invoke _Delay, dword 2


	mov ax, 2850
	out 42h, al
	mov al, ah
	out 42h, al
	invoke _Delay, dword 2


	mov ax, 2200
	out 42h, al
	mov al, ah
	out 42h, al
	invoke _Delay, dword 2

	dec cl
	jz .SoundOff
	jmp .Notes


	.SoundOff:
	in al, 61h		; Turn off the speaker
	and al, 11111100b
	out 61h, al

.Skip:
	pop cx
	pop ax
	ret



;-------------------------------------------------------------------------;
; Random()								  ;
;									  ;
;   word _Random(void)							  ;
;									  ;
;   Inputs: MaxNum							  ;
;									  ;
;   Outputs: none							  ;
;									  ;
;   Calls: none								  ;
;									  ;
;   Returns: randomly-generated number within bounds			  ;
;									  ;
;   Purpose: Generates a random number that is between 0 and MaxNum	  ;
;									  ;
;   Written by: provided to ECE291 Sp2001 students for MP4		  ;
;									  ;
;-------------------------------------------------------------------------;

proc _Random
.MaxNum		arg	2

	push bx
	push cx
	push dx

	mov ax, word [_seed]
	mov bx, 37549

	mul bx
	add ax, 37747
	adc dx, 0
	mov bx, 0FFFFh
	div bx
	mov ax, dx
	mov word [_seed], dx

	xor dx, dx
	mov cx, [ebp + .MaxNum]
	div cx
	mov ax, dx

	pop dx
	pop cx
	pop bx

	ret

endproc
_Random_arglen		EQU	2


;-------------------------------------------------------------------------;
; GetWind()								  ;
;									  ;
;   void _GetWind(void)							  ;
;									  ;
;   Inputs: none							  ;
;									  ;
;   Outputs: [_Wind]							  ;
;									  ;
;   Calls: Random							  ;
;									  ;
;   Returns: none							  ;
;									  ;
;   Purpose: Pseudo-randomly generates a current wind velocity		  ;
;									  ;
;   Written by: Terrence Janas						  ;
;									  ;
;-------------------------------------------------------------------------;
_GetWind

;  push ax
;  invoke _Random, word 20
;  cmp ax, 10
;  jbe .Done
;
;  sub ax, 10
;  neg ax

;  .Done:
;  mov word [_Wind], 0
;  mov byte [_Wind], al
;  pop ax

;  ret












;-------------------------------------------------------------------------;
; FiringSound()								  ;
;									  ;
;   void _FiringSound(void)						  ;
;									  ;
;   Inputs: none							  ;
;									  ;
;   Outputs: makes the PC speaker beep					  ;
;									  ;
;   Calls: Delay							  ;
;									  ;
;   Returns: none							  ;
;									  ;
;   Purpose: Play a very short melody when a player fires weapon	  ;
;									  ;
;   Written by: Terrence Janas						  ;
;									  ;
;-------------------------------------------------------------------------;

_FiringSound

		push ax
		push cx

		mov al, 182		; Prepare the PC speaker for the beeps
		out 43h, al
		in al, 61h
		or al, 00000011b
		out 61h, al

		cmp	byte [_SoundFlag], 1
		jne	near .SoundOff

		mov cl, 9
		mov word [_x], 1320


		.IncFreq:
		mov ax, word [_x]
		out 42h, al
		mov al, ah
		out 42h, al
		dec cl
		jz .SoundOff
		sub word [_x], 400
		invoke _Delay, dword 1	; delay the beep so it's noticable
		jmp .IncFreq


		.SoundOff
					; Turn off speaker
		in al, 61h
		and al, 11111100b
		out 61h, al


		pop cx
		pop ax
		ret













;-------------------------------------------------------------------------;
; ImpactSound()								  ;
;									  ;
;   void _InmpactSound(void)						  ;
;									  ;
;   Inputs: none							  ;
;									  ;
;   Outputs: none							  ;
;									  ;
;   Calls: Delay							  ;
;									  ;
;   Returns: none							  ;
;									  ;
;   Purpose: Play a very short melody when a player gets hit		  ;
;									  ;
;   Written by: Terrence Janas						  ;
;									  ;
;-------------------------------------------------------------------------;

_ImpactSound

		push ax
		push cx
		

		mov al, 182		; Prepare the PC speaker for the notes
		out 43h, al
		in al, 61h
		or al, 00000011b
		out 61h, al

		cmp	byte [_SoundFlag], 1
		jne	near .skip



		mov cx, 6

		.Repeat

		mov ax, 6220			; 820
		out 42h, al
		mov al, ah
		out 42h, al
		invoke _Delay, dword 1

		mov ax, 4600			; 600
		out 42h, al
		mov al, ah
		out 42h, al
		invoke _Delay, dword 1


		;mov ax, 1
		;out 42h, al
		;mov al, ah
		;out 42h, al

		dec cx
		jnz .Repeat

.skip:
	; Turn off speaker
		in al, 61h
		and al, 11111100b
		out 61h, al
	pop cx
		pop ax
		ret

;-------------------------------------------------------------------------;
; BattleHymn()								  ;
;									  ;
;   void _BattleHymn(void)						  ;
;									  ;
;   Inputs: none							  ;
;									  ;
;   Outputs: none							  ;
;									  ;
;   Calls: _Delay							  ;
;									  ;
;   Returns: Generates a series of beeps from the PC speaker		  ;
;									  ;
;   Purpose: Play the first 7 seconds of the Battle Hymn of the Republic  ;
;									  ;
;-------------------------------------------------------------------------;
_BattleHymn


pushad


		mov al, 182			; Prepare the speaker to play the notes
		out 43h, al
		in al, 61h
		or al, 00000011b
		out 61h, al

		cmp	byte [_SoundFlag], 1
		jne	near .skip


		mov ax, 6087
		out 42h, al			; Play G note
		mov al, ah			; and hold it for 8 ticks
		out 42h, al
		invoke _Delay, dword 8



		mov ax, 1
		out 42h, al			; No sound for 2 ticks
		mov al, ah			; in between notes
		out 42h, al
		invoke _Delay, dword 2


		mov ax, 6087			; Play G note
		out 42h, al			; and hold it for 4 ticks
		mov al, ah
		out 42h, al
		invoke _Delay, dword 4



		mov ax, 1
		out 42h, al			; No sound for 2 ticks
		mov al, ah			; in between notes
		out 42h, al
		invoke _Delay, dword 2




		mov ax, 6087			; Play G note
		out 42h, al			; and hold it for 8 ticks
		mov al, ah
		out 42h, al
		invoke _Delay, dword 8




		mov ax, 1
		out 42h, al			; No sound for 2 ticks
		mov al, ah			; in between notes
		out 42h, al
		invoke _Delay, dword 2



		mov ax, 6833			; Play F note
		out 42h, al			; and hold it for 4 ticks
		mov al, ah
		out 42h, al
		invoke _Delay, dword 4




		mov ax, 1
		out 42h, al			; No sound for 2 ticks
		mov al, ah			; in between notes
		out 42h, al
		invoke _Delay, dword 2



		mov ax, 7239			; Play E note
		out 42h, al			; and hold it for 8 ticks
		mov al, ah
		out 42h, al
		invoke _Delay, dword 8



		mov ax, 1
		out 42h, al			; No sound for 2 ticks
		mov al, ah			; in between notes
		out 42h, al
		invoke _Delay, dword 2



		mov ax, 6087			; Play G note
		out 42h, al			; and hold it for 4 ticks
		mov al, ah
		out 42h, al
		invoke _Delay, dword 4




		mov ax, 1
		out 42h, al			; No sound for 2 ticks
		mov al, ah			; in between notes
		out 42h, al
		invoke _Delay, dword 2



		mov ax, 4560			; Play C note
		out 42h, al			; and hold it for 8 ticks
		mov al, ah
		out 42h, al
		invoke _Delay, dword 8



		mov ax, 1
		out 42h, al			; No sound for 2 ticks
		mov al, ah			; in between notes
		out 42h, al
		invoke _Delay, dword 2



		mov ax, 4063			; Play D note
		out 42h, al			; and hold it for 4 ticks
		mov al, ah
		out 42h, al
		invoke _Delay, dword 4




		mov ax, 1
		out 42h, al			; No sound for 2 ticks
		mov al, ah			; in between notes
		out 42h, al
		invoke _Delay, dword 2



		mov ax, 3619			; Play E note
		out 42h, al			; and hold it for 8 ticks
		mov al, ah
		out 42h, al
		invoke _Delay, dword 8



		mov ax, 1
		out 42h, al			; No sound for 2 ticks
		mov al, ah			; in between notes
		out 42h, al
		invoke _Delay, dword 2



		mov ax, 3619			; Play E note
		out 42h, al			; and hold it for 4 ticks
		mov al, ah
		out 42h, al
		invoke _Delay, dword 4



		mov ax, 1
		out 42h, al			; No sound for 2 ticks
		mov al, ah			; in between notes
		out 42h, al
		invoke _Delay, dword 2



		mov ax, 3619			; Play E note
		out 42h, al			; and hold it for 8 ticks
		mov al, ah
		out 42h, al
		invoke _Delay, dword 8



		mov ax, 1
		out 42h, al			; No sound for 2 ticks
		mov al, ah			; in between notes
		out 42h, al
		invoke _Delay, dword 2



		mov ax, 4063			; Play D note
		out 42h, al			; and hold it for 4 ticks
		mov al, ah
		out 42h, al
		invoke _Delay, dword 4



		mov ax, 1
		out 42h, al			; No sound for 2 ticks
		mov al, ah			; in between notes
		out 42h, al
		invoke _Delay, dword 2


		mov ax, 4560			; Play C note
		out 42h, al			; and hold it for 12 ticks
		mov al, ah
		out 42h, al
		invoke _Delay, dword 12

	.skip:


		; Turn off speaker
		in al, 61h			; Silence the speaker
		and al, 11111100b
		out 61h, al			; SOUND IS OFF

		popad
		ret





;-------------------------------------------------------------------------;
; Intro()								  ;
;									  ;
;   void _Intro(void)							  ;
;									  ;
;   Inputs: none							  ;
;									  ;
;   Outputs: none							  ;
;									  ;
;   Calls: Delay, ClearBuffer, CopyToScreen, LoadPNG, ComposeBuffers	  ;
;									  ;
;   Returns: draws to the screen					  ;
;									  ;
;   Purpose: Intro scene where tank moves across screen & fades		  ;
;									  ;
;   Written by: Terrence Janas						  ;
;									  ;
;-------------------------------------------------------------------------;

_Intro


	invoke _ClearBuffer, dword [_ScreenOff], word 640, word 480, dword 0
	invoke _CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0

	invoke _Delay, dword 15


	invoke _LoadPNG, dword _Tank222, dword [_ScreenOff], dword 0, dword 0
	invoke _CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0


	invoke _LoadPNG, dword _Tank3, dword [_ScreenOff], dword 0, dword 0
	invoke _CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0


	invoke _LoadPNG, dword _Tank4, dword [_ScreenOff], dword 0, dword 0
	invoke _CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0


	invoke _LoadPNG, dword _Tank5, dword [_ScreenOff], dword 0, dword 0
	invoke _CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0


	invoke _LoadPNG, dword _Tank6, dword [_ScreenOff], dword 0, dword 0
	invoke _CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0


	invoke _LoadPNG, dword _Tank7, dword [_ScreenOff], dword 0, dword 0
	invoke _CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0


	invoke _LoadPNG, dword _Tank8, dword [_ScreenOff], dword 0, dword 0
	invoke _CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0


	invoke _LoadPNG, dword _Tank9, dword [_ScreenOff], dword 0, dword 0
	invoke _CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0


	invoke _LoadPNG, dword _Tank10, dword [_ScreenOff], dword 0, dword 0
	invoke _CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0


	invoke _LoadPNG, dword _Tank11, dword [_ScreenOff], dword 0, dword 0
	invoke _CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0


	invoke _LoadPNG, dword _Tank12, dword [_ScreenOff], dword 0, dword 0
	invoke _CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0


	invoke _LoadPNG, dword _Tank13, dword [_ScreenOff], dword 0, dword 0
	invoke _CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0


	invoke _LoadPNG, dword _Tank14, dword [_ScreenOff], dword 0, dword 0
	invoke _CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0


	invoke _LoadPNG, dword _Tank15, dword [_ScreenOff], dword 0, dword 0
	invoke _CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0


	invoke _LoadPNG, dword _Tank16, dword [_ScreenOff], dword 0, dword 0
	invoke _CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0


	invoke _LoadPNG, dword _Tank17, dword [_ScreenOff], dword 0, dword 0
	invoke _CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0


	invoke _LoadPNG, dword _Tank18, dword [_ScreenOff], dword 0, dword 0
	invoke _CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0


	invoke _LoadPNG, dword _Tank19, dword [_ScreenOff], dword 0, dword 0
	invoke _CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0


	invoke _LoadPNG, dword _Tank20, dword [_ScreenOff], dword 0, dword 0
	invoke _CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0


	invoke _LoadPNG, dword _Tank21, dword [_ScreenOff], dword 0, dword 0
	invoke _CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0


	invoke _LoadPNG, dword _Tank22, dword [_ScreenOff], dword 0, dword 0
	invoke _CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0


	invoke _LoadPNG, dword _Tank23, dword [_ScreenOff], dword 0, dword 0
	invoke _CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0


	invoke _LoadPNG, dword _Tank24, dword [_ScreenOff], dword 0, dword 0
	invoke _CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0


	invoke _LoadPNG, dword _Tank25, dword [_ScreenOff], dword 0, dword 0
	invoke _CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0




	;----- START FADEOUT -------;

	mov	word [_counter], 40


	invoke	_ClearBuffer, dword [_Overlay], word 640, word 480, dword 010000000h

	.FadeToBlack:
	invoke _ComposeBuffers, dword [_Overlay], word 640, word 480, dword [_ScreenOff], word 640, word 480, word 0, word 0
	invoke _CopyToScreen, dword [_ScreenOff], dword 640*4, dword 0, dword 0, dword 640, dword 480, dword 0, dword 0

	dec	word [_counter]
	cmp	word [_counter], 0
	jne	near .FadeToBlack

	;----- END FADEOUT -------;

	invoke _Delay, dword 15

	ret
