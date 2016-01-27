; ; ; ; ; ; ; ; ; ; ; ; ;
;  Os3 Boot Constants   ;
; ; ; ; ; ; ; ; ; ; ; ; ;

S2_CODE_LOC	equ		0xB000			; Where the second stage bootloader and kernel are loaded to.
DISPLAY_MODE equ	MODE_TEXT	; Which display mode to boot into (MODE_TEXT or MODE_GRAPHICS).
DESIRED_XRES equ	1366			; The width of the main display.
DESIRED_YRES equ	768				; The height of the main display.


; DO NOT CHANGE THE BELOW VALUES ;
MODE_TEXT equ		0x0
MODE_GRAPHICS equ	0x1

