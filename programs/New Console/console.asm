; DESCRIPTION
;	console.asm
;
;	contains the system's built in console
;	in standard program format
;

; DIRECTIVES
	[bits 32]

; FILESYSTEM INFO
	dd console.asm.end - console.asm.start
	db "PRGM"
	db "_CONSOLE"

; FILE START TAG
	console.asm.start :

; CONSTANTS
	LOOP_PROGRAM   equ 0x1

; PROGRAM INFO
	db LOOP_PROGRAM
	dd console.asm.post_init
	
; PROGRAM INIT
	console.asm.init :
		mov bl, 0xF
		mov [0xa0001], bl
			push debug.clear	; clearing the debug buffer
			call it
			push clearScreenG	; wiping the screen
			call it
			push debug.println	; printing a message
			mov ebx, console.EXT_CALL
			call fmtEBX	; need to reformat because it is a pointer to a location
			call it
			ret
		
		mov bl, 0xF
		mov [0xa0002], bl
		mov bl, 0x2				; setting the console as PNUM 2
		push Dolphin.create
		call it	; and creating a window
		
		mov ebx, 0x9000	; ignoring malloc for now
		mov [console.buffer], ebx	; storing our window's buffer position to be used later
		
		mov ebx, 0x18
		mov [console.width], ebx
		mov [console.height], ebx
		mov ah, 0xB		; setting font color
		call JASM.console.init	; run JASM initialization code
		
		mov ah, 0xE
		
		call JASM.console.post_init	; finalizing the JASM initialization
		
		call console.asm.post_init
		mov bl, 0xC
		mov [0xa0003], bl
		jmp $
		ret
	
; PROGRAM POST-INIT
	console.asm.post_init :
	
		;call os.pollKeyboard	; pulling keyboard data into the console's text buffer [function should be migrated into console.asm]
	
		mov eax, [console.buffer]
		mov ebx, [console.pos]
		mov ecx, [console.width]
		mov edx, [console.height]
		call Dolphin.textUpdate	; telling Dolphin (window manager) to update the window (text will be pushed from buffer to screen)		[Dolphin should eventually handle this automatically]
			;	NOTE: JASM.console.post_init registers control to be transferred to JASM.console upon press of the ENTER key. The console's code then takes over.
		ret
	
; PROGRAM EXTRA CODE
	console.setWidth :
		call console.wipe
		mov [console.width], ebx
		call console.clearScreen
		ret
	
	console.setHeight :
		call console.wipe
		mov [console.height], ebx
		call console.clearScreen
		ret
	
	console.setPos :
		call console.wipe
		mov [console.pos], ebx
		call console.clearScreen
		ret
		
	console.wipe :
		pusha
		mov ebx, [console.pos]
		add ebx, 0xa0000
		mov ecx, [console.width]
		mov edx, [console.height]
		call Dolphin.clear
		popa
		ret
	
	console.update :
		pusha
		mov eax, [console.buffer]
		mov ebx, [console.pos]
		mov ecx, [console.width]
		mov edx, [console.height]
		call Dolphin.textUpdate
		popa
		ret
	
	console.checkClear :
		mov ebx, [console.charPos]
		cmp ebx, 0x1000
		jle cseret
		call console.clearScreen
		cseret :
		ret
		
	console.print :
		pusha
		mov edx, [console.buffer]
		mov ecx, [console.charPos]
		add edx, ecx
		printitp :
		mov al, [ebx]
		cmp al, 0
		je printdonep
		mov [edx], ax
		add ebx, 1
		add edx, 2
		push ebx
		mov ebx, [console.charPos]
		add ebx, 0x2
		mov [console.charPos], ebx
		pop ebx
		jmp printitp
		printdonep :
		call console.update
		popa
		ret
	
	console.println :
		call console.print
		call console.newline
		ret
	
	console.numOut :
		pusha
		mov cl, 28
		mov ch, 0x0
	
		console.numOut.start :
		mov edx, ebx
		shr edx, cl
		and edx, 0xF
		
		cmp dx, 0x0
		je console.numOut.checkZ
		mov ch, 0x1
		console.numOut.dontcare :
		push ebx
		mov eax, edx
		
		cmp dx, 0x9
		jg console.numOut.g10
		add eax, 0x30
		jmp console.numOut.goPrint
		console.numOut.g10 :
		add eax, 0x37
		console.numOut.goPrint :
		call console.cprint
		pop ebx
		console.numOut.goCont :
		cmp cl, 0
		jle console.numOut.end
		sub cl, 4
		jmp console.numOut.start
		console.numOut.end :
		popa
		ret
	
		console.numOut.checkZ :
		cmp ch, 0x0
		je console.numOut.goCont
		jmp console.numOut.dontcare
		
	console.newline :
		pusha
		mov edx, [console.width]
		add edx, edx
		mov eax, [console.charPos]
		add eax, [console.buffer]
		mov bx, 0x0
		mov [eax], bx
		mov eax, [console.charPos]
		mov ecx, 0x0
		add eax, 0x2
		dloop :
		sub eax, edx
		add ecx, 0x1
		cmp eax, 0
		jg dloop
		mov eax, ecx
		mov ebx, edx
		mul ebx
		mov [console.charPos], eax
		popa
		ret
		
	console.cprint :
		mov ah, 0x0f
		mov ebx, [console.charPos]
		add ebx, [console.buffer]
		mov [ebx], ax
		mov ebx, [console.charPos]
		add ebx, 0x2
		mov [console.charPos], ebx
		call console.update
		ret
		
	console.clearScreen :
		pusha
		call clearScreenG
		mov eax, [console.buffer]
		mov cx, 0x0
		console.clearScreen.loop :
		mov [eax], cx
		add eax, 2
		push ebx
		mov ebx, [console.buffer]
		add ebx, 0x1000
		cmp eax, ebx
		pop ebx
		jl console.clearScreen.loop
		mov ecx, 0x0
		mov [console.charPos], ecx
		popa
		ret
	
	console.setColor :
		mov ah, bl
		ret
	
	console.getLine :
		pusha
		mov eax, [console.charPos]
		mov ecx, 0x0
		add eax, 0x2
		gldloop :
		push edx
		mov edx, [console.width]
		add edx, edx
		sub eax, edx
		pop edx
		add ecx, 0x1
		cmp eax, 0
		jg gldloop
		mov eax, ecx
		
		push edx
		mov edx, [console.width]
		add edx, edx
		mov ebx, edx
		pop edx
		mul ebx
		add eax, [console.buffer]
		push edx
		mov edx, [console.width]
		add edx, edx
		sub eax, edx
		pop edx
		mov ebx, eax
		
		mov edx, console.line
		glrloop :
		mov al, [ebx]
		cmp al, 0x0
		je glrloopDone
		mov [edx], al
		add ebx, 2
		add edx, 1
		jmp glrloop
		glrloopDone :
		mov al, 0x0
		mov [edx], al
		mov eax, console.line
		mov [retval], eax
		popa
		ret
		
	console.doBackspace :	; NEEDS TO BE MIGRATED OVER!
		mov eax, [console.charPos]
		mov edx, 0x0
		bsdloop :
		push edx
		mov edx, [console.width]
		add edx, edx
		sub eax, edx
		pop edx
		add edx, 0x1
		cmp eax, 0
		jg bsdloop
		cmp eax, 0x0
		mov ecx, 2
		jne bsfnoloop
		mov ebx, [console.charPos]
		add ebx, [console.buffer]
		mov [ebx], edx
		mov eax, edx
		push bx
		push edx
		mov edx, [console.width]
		add edx, edx
		mov bx, dx
		pop edx
		mul bx
		pop bx
		sub eax, 2
		add eax, [console.buffer]
		mov bx, 0x0
		bsfcloop :
		add ecx, 2
		sub eax, 2
		cmp [eax], bx
		je bsfcloop
		sub ecx, 2
		bsfnoloop :
		mov eax, [console.charPos]
		sub eax, ecx
		cmp eax, 0
		jl console.doBackspace.stop
		mov [console.charPos], eax
		console.doBackspace.stop :
		;add eax, [console.buffer]
		;mov bx, 0x0
		;mov [eax], bx
		;add eax, 2
		;mov [eax], bx
		;call kernel.update
		;	jmp os.pollKeyboard.drawKeyFinalize
		ret
		
; PROGRAM EXTERNAL FILES
	%include "..\..\programs\New Console\build.asm"
	%include "..\..\modules\shlib.asm"
	
; PROGRAM DATA
	console.width :
		dd 0x0
	console.height :
		dd 0x0
	console.pos :
		dd 0x0
	console.buffer :
		dd 0x0
	console.charPos :
		dd 0xA2
	console.line :
		dd 0x0, 0x0, 0x0, 0x0
	console.EXT_CALL :
		db "Hello from an external program!",0

; FILE END TAG
	console.asm.end :
