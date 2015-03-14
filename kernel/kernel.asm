[bits 32]
[org 0x7e00]
db 0x4a
kernel :

mov ebx, 0xFFFFFFFF
mov [0xa0000], ebx
mov ebx, 0x0F0F0F0F
mov [0xa0008], ebx

call Dolphin.setGrayscalePalette
call Dolphin.setVGApalette

call debug.init
call Guppy.init

;mov ebx, 0xff00
;mov eax, 0xFFFFFFFF
;lbl1:
;mov [ebx], eax
;add ebx, 4
;cmp ebx, 0x10000
;jle lbl1

;mov cx, 0	; cylinder number
;mov ah, 0	; head number
;pusha
;mov ebx, bg_name
;call Minnow.byName
;mov edi, 0xF00000;ebx	; where to read it to (start of image file in RAM)
;popa
;mov bh, 1	; sector number
;mov bl, 1	; number of sectors to read
;call os.load

;call writeLib

;call Mouse.init


;mov ebx, retfunc
;call os.setEcatch

call Minnow.dtree

mov ebx, FILE_DESCR
call debug.print
mov ebx, bg_name	; bg_name = "TEAMBLDR"
call debug.println

call Minnow.byName	; find the file
;mov ebx, 0x95f0
call Dolphin.makeBG

call console.init

mov ebx, LOAD_FINISH
call debug.log.system

;mov ebx, txt_name
;call View.file
;jmp $

kernel.loop:
call os.pollKeyboard
call console.loop
call Dolphin.updateScreen
jmp kernel.loop

jmp $

Mouse.init :
push ax
mov al, 0xA8
out 0x64, al	; aux input enable
mov al, 0xD4
out 0x64, al	; we are going to be sending a command to the mouse:
mov al, 0xF4
out 0x60, al	; 	start sending us packets!
pop ax
ret

os.setEcatch :
pusha
mov eax, [os.ecatch]
mov [eax], ebx
popa
ret

os.pollKeyboard :
pusha
in al, 0x64
and al, 0x20
cmp al, 0x0
je os.pollKeyboard.kcol
	mov eax, 0x0	; start mouse handle code
	;in al, 0x60			needs to be remade so debugging does not rely on console.
	;mov ebx, eax
	;call console.numOut
	;call console.newline
	;in al, 0x60
	;mov ebx, eax
	;call console.numOut
	;call console.newline
	;in al, 0x60
	;mov ebx, eax
	;call console.numOut
	;call console.newline
	;call console.newline
	jmp os.pollKeyboard.return	; end mouse handle code
os.pollKeyboard.kcol :
in al, 0x60	; get last keycode
mov bl, al	; storing code in bl
and al, 0x80	; 1 if release code, 0 if not
cmp al, 0x0	; if a key has not been released
je os.pollKeyboard.checkKey
mov cx, 0x1	; otherwise a key was released
mov [os.pollKeyboard.isReady], cx	; store 1 so we know we are ready to read next time
jmp os.pollKeyboard.return

os.pollKeyboard.checkKey :
	; key in bl
	mov al, [os.lastKey]
	cmp al, bl
	jne os.pollKeyboard.checkKey.override
	;jmp os.pollKeyboard.return
mov cx, [os.pollKeyboard.isReady]
cmp cx, 0x0
je os.pollKeyboard.return	; if not ready, a key is being held down, dont reprint it
	os.pollKeyboard.checkKey.override :
	push bx
call os.keyboard.toChar
;cmp al, 0xFF
;je console.doBackspace;	SHOULD NOT BE COMMENTED OUT
cmp al, 0x1
je os.doEnter
mov bl, al
call os.keyPress	; keypress will be sent to the currently registered program in al
os.pollKeyboard.drawKeyFinalize :
mov cx, 0x0
mov [os.pollKeyboard.isReady], cx	; so we know that we have already printed the character, and should not do so again
pop bx
mov [os.lastKey], bl
os.pollKeyboard.return :
popa
ret

os.doEnter :
mov eax, [os.ecatch]
mov ebx, [eax]
mov ah, 0xB
call ebx
		; DEBUGGING ONLY	(PRINT LAST CONSOLE COMMAND)
		;	call debug.clear
		;	mov ebx, console.line
		;	call debug.println
jmp os.pollKeyboard.drawKeyFinalize

os.keyPress :
pusha
mov [0x1030], bl
mov al, 0xFF
mov [0x1031], al
popa
ret

os.getKey :
push eax
;	 check the program is allowed to get keypresses here
mov bl, 0x0
mov al, [0x1031]
cmp al, 0xFF
jne os.getKey.ret
mov bl, [0x1030]
mov al, 0x0
mov [0x1031], al
os.getKey.ret :
pop eax
ret

os.keyboard.toChar :
cmp bl, 0x1E
mov al, 'A'
je os.keyboard.toChar.ret
cmp bl, 0x30
mov al, 'B'
je os.keyboard.toChar.ret
cmp bl, 0x2E
mov al, 'C'
je os.keyboard.toChar.ret
cmp bl, 0x20
mov al, 'D'
je os.keyboard.toChar.ret
cmp bl, 0x12
mov al, 'E'
je os.keyboard.toChar.ret
cmp bl, 0x21
mov al, 'F'
je os.keyboard.toChar.ret
cmp bl, 0x22
mov al, 'G'
je os.keyboard.toChar.ret
cmp bl, 0x23
mov al, 'H'
je os.keyboard.toChar.ret
cmp bl, 0x17
mov al, 'I'
je os.keyboard.toChar.ret
cmp bl, 0x24
mov al, 'J'
je os.keyboard.toChar.ret
cmp bl, 0x25
mov al, 'K'
je os.keyboard.toChar.ret
cmp bl, 0x26
mov al, 'L'
je os.keyboard.toChar.ret
cmp bl, 0x32
mov al, 'M'
je os.keyboard.toChar.ret
cmp bl, 0x31
mov al, 'N'
je os.keyboard.toChar.ret
cmp bl, 0x18
mov al, 'O'
je os.keyboard.toChar.ret
cmp bl, 0x19
mov al, 'P'
je os.keyboard.toChar.ret
cmp bl, 0x10
mov al, 'Q'
je os.keyboard.toChar.ret
cmp bl, 0x13
mov al, 'R'
je os.keyboard.toChar.ret
cmp bl, 0x1F
mov al, 'S'
je os.keyboard.toChar.ret
cmp bl, 0x14
mov al, 'T'
je os.keyboard.toChar.ret
cmp bl, 0x16
mov al, 'U'
je os.keyboard.toChar.ret
cmp bl, 0x2F
mov al, 'V'
je os.keyboard.toChar.ret
cmp bl, 0x11
mov al, 'W'
je os.keyboard.toChar.ret
cmp bl, 0x2D
mov al, 'X'
je os.keyboard.toChar.ret
cmp bl, 0x15
mov al, 'Y'
je os.keyboard.toChar.ret
cmp bl, 0x2C
mov al, 'Z'
je os.keyboard.toChar.ret
cmp bl, 0x39
mov al, ' '
je os.keyboard.toChar.ret
cmp bl, 0x34
mov al, '.'
je os.keyboard.toChar.ret
cmp bl, 0x33
mov al, ','
je os.keyboard.toChar.ret
cmp bl, 0x02
mov al, '1'
je os.keyboard.toChar.ret
cmp bl, 0x03
mov al, '2'
je os.keyboard.toChar.ret
cmp bl, 0x04
mov al, '3'
je os.keyboard.toChar.ret
cmp bl, 0x05
mov al, '4'
je os.keyboard.toChar.ret
cmp bl, 0x06
mov al, '5'
je os.keyboard.toChar.ret
cmp bl, 0x07
mov al, '6'
je os.keyboard.toChar.ret
cmp bl, 0x08
mov al, '7'
je os.keyboard.toChar.ret
cmp bl, 0x09
mov al, '8'
je os.keyboard.toChar.ret
cmp bl, 0x0A
mov al, '9'
je os.keyboard.toChar.ret
cmp bl, 0x0B
mov al, '0'
je os.keyboard.toChar.ret
cmp bl, 0x0E	; backspace
mov al, 0xff
je os.keyboard.toChar.ret
cmp bl, 0x1C
mov al, 0x1
je os.keyboard.toChar.ret
mov al, 0x3f
mov ecx, charSPACE
os.keyboard.toChar.ret :
ret

retfunc :
ret

os.String.removeColor :	; pointer to String in ebx
pusha
;mov eax, ebx
;os.String.removeColor.loop1 :
;mov cx, [ebx]
;cmp cx, 0x0
;je os.String.removeColor.loop1_end
;mov [eax], cl
;add ebx, 2
;add eax, 1
;jmp os.String.removeColor.loop1
;os.String.removeColor.loop1_end :
;mov [eax], cl
popa
ret


%include "..\boot\init_GDT.asm"
%include "..\kernel\drawChar.asm"
%include "..\modules\Guppy.asm"
%include "..\modules\Dolphin.asm"
%include "..\modules\programLoader.asm"
%include "..\modules\minnow.asm"
%include "..\modules\iConsole.asm"
%include "..\modules\View.asm"
%include "..\boot\realMode.asm"
%include "..\debug\print.asm"

KERNEL_BOOT :
db "Kernel Successfully Loaded!", 0

OK_MSG :
db "The operating system is now halted.", 0

HARDWARE_BOOT :
db "STATE: Hardware", 0

BOCHS_BOOT :
db "STATE: Emulator", 0

bg_name :
db "TEAMBLDR", 0
txt_name :
db "HELOWRLD", 0

LOAD_FINISH :
db "Transferring control to user!", 0

FILE_DESCR :
db "File name: ", 0

os.pollKeyboard.isReady :
dd 0x0

os.ecatch :
dd 0x10F0

os.lastKey :
dw 0x0

MINNOW_START :