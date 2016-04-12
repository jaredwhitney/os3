[bits 32]

console.init :
pusha
	
	call ProgramManager.getProgramNumber	; register program with the OS
	mov [console.pnum], bl
	call ProgramManager.setActive	; Make removable Later
	
	;mov ebx, 0x10fa	; sectors
	;cmp byte [Graphics.VESA_MODE], 0x0
	;	je console.init.novesa
	call Window.getSectorSize	; <- eax
	add eax, 0x1
	add eax, 4050
	mov ebx, eax
	console.init.novesa :
	call ProgramManager.requestMemory
			;mov eax, [ProgramManager.memoryStart]
			;call DebugLogEAX
	push dword console.title
	push word Window.TYPE_TEXT
	call Window.create	; essentially: Window windowStructLoc = new Window(title, Window.TYPE_TEXT)
	mov [console.windowStructLoc], ecx
	mov [console.winNum], bl	; PHASE OUT winNum/wnum !!! Dolphin.currentWindow should contain the window struct pointer! NOTE: in this case, 'winNum' should become 'window' and contain the same data 'windowStructLoc' does right now, and 'windowStructLoc' should be removed	
	
	mov ebx, [console.windowStructLoc]
	add bl, [Window.WIDTH]
	mov word [ebx], 0x3C0	; need to fix window width so it is NOT dependent on bpp!
	mov ebx, [console.windowStructLoc]
	add bl, [Window.HEIGHT]
	mov word [ebx], 0xC8
	
	mov ebx, [console.windowStructLoc]
	mov word [ebx+Window_xpos], 300*4
	mov word [ebx+Window_ypos], 80
	
	call console.createWindow
	
	;mov ah, 0xF	; yellow
	;call JASM.console.init	; initiallize the console
	
	;call console.clearScreen
	
	;mov ah, 0xFF
	;call Time.printToConsole
	
	;call JASM.console.post_init
	
	;call debug.toggleView	; fine to turn off debugging, the console should be under the user's control by now
	
	;call console.update
	
	call ProgramManager.finalize	; Make removable Later

popa
ret

console.createWindow :
	pusha
		
	mov ebx, 0x1
	mov [console.draw], ebx

	call console.clearScreen
	;call JASM.console.post_init		; FIX THIS!!!
	;call console.update
	popa
	ret

console.rereg :
pusha
	;mov eax, [console.windowStructLoc]
	;call Dolphin.registerWindow
	;mov [console.winNum], bl
popa
ret

;console.loop :	; UNUSED
;pusha
;
;	mov bl, [console.pnum]
;	call ProgramManager.setActive	; Make removable Later
;	
;	xor ebx, ebx
;	mov bl, [console.winNum]
;	mov [Dolphin.currentWindow], ebx
;
;mov ebx, [console.draw]
;cmp ebx, 0x0
;je console.update.gone
;	mov [console.dat], ebx
;	;call console.update
;;mov bl, [console.winNum]
;;mov [Dolphin.currentWindow], bl
;	console.loop.checkKeyBuffer :
;		mov ebx, [KeyManager.bufferpos]
;		cmp ebx, 0x0	; is there any data avaliable?
;			je console.loop.ret
;		call Keyboard.getKey
;		cmp bl, 0x0		; was the program allowed to get data?
;			je console.loop.ret
;		cmp bl, 0xff	; was the character a backspace?
;			je console.doBackspace
;		cmp bl, 0xfe	; was the character an enter?
;			jne console.loop.notEnter
;		call JASM.console.handleEnter
;		jmp console.loop.checkKeyBuffer
;		console.loop.notEnter :
;			cmp bl, 0xfb
;				jne console.loop.notUp
;			mov ah, 0xFF
;			mov ebx, console.lastLine
;			call console.print
;			jmp console.loop.checkKeyBuffer
;		console.loop.notUp :
;			mov al, bl
;			mov ah, 0xFF
;			call console.cprint
;		jmp console.loop.checkKeyBuffer
;console.loop.ret :
;
;	call ProgramManager.finalize	; Make removable Later
;
;popa
;ret

console.runOHLL_workaround :
		mov bl, [OHLLPROTO_PNUM]
		call ProgramManager.setActive
			call iConsole._loop
		call ProgramManager.finalize
	ret

console.setWidth :
pusha
and ebx, 0xFFFF
mov eax, [Graphics.bytesPerPixel]
imul ebx, eax
mov eax, ebx
mov bl, [Window.WIDTH]
call Dolphin.setAttribWord
popa
ret

console.setHeight :
pusha
	mov ax, bx
	mov bl, [Window.HEIGHT]	; -> ecx
	call Dolphin.setAttribWord
popa
ret

console.setPos :
pusha
mov al, [console.winNum]
mov [Dolphin.currentWindow], al
mov eax, ebx
call Dolphin.moveWindowAbsolute
popa
ret

JASM.console.safeFullscreen :
pusha

	mov ebx, [console.windowStructLoc]
	mov word [ebx+Window_xpos], 0
	mov word [ebx+Window_ypos], 8
	mov eax, [Graphics.SCREEN_WIDTH]
	mov [ebx+Window_width], ax
	mov eax, [Graphics.SCREEN_HEIGHT]
	mov [ebx+Window_height], ax
	
popa
ret

console.test :	; command that can be used to test anything.
pusha
mov bl, [console.pnum]
call ProgramManager.setActive	; Make removable Later

	mov byte [INTERRUPT_DISABLE], 0xFF
	
	mov eax, [os_imageDataBaseLBA]
	xor ebx, ebx
	mov edx, 1024*4*768
	call rmATA.DMAread
	mov [Dolphin2.bgimg], ecx

	
	call Dolphin2.createCompositorGrouping
	
	push consoletest_title
	push dword 80*4
	push dword 80
	push dword 300*4
	push dword 100
	call Dolphin2.makeWindow
	mov edx, ecx
	;mov dword [edx+Grouping_backingColor], 0xFF202000
	
		push dword 0
		push dword 0
		push dword 300*4
		push dword 100
		call SelectionPanel.Create
		mov eax, ecx
		mov ebx, edx
		call Grouping.Add
		mov dword [ecx+Grouping_backingColor], 0xFFC01010
		mov ebx, ecx

		push dword 100
		push dword 0
		push dword 0
		push dword 200*4
		push dword 80
		push dword FALSE
		call TextArea.Create
		mov eax, ecx
		call SelectionPanel.Add

		push dword consoletest_type
		push dword screen.wipe
		push dword 10*4
		push dword 10
		push dword 30*4
		push dword 30
		call Button.Create
		mov eax, ecx
		call SelectionPanel.Add

		push dword consoletest_type
		push dword screen.wipe
		push dword 50*4
		push dword 10
		push dword 30*4
		push dword 30
		call Button.Create
		mov eax, ecx
		call SelectionPanel.Add
		
		call SimpleRender.init
		call Dolphin2.showLoginScreen
		
;	mov ebx, eax
	GoDoLoop :
	call SimpleRender.runOnce
	call Dolphin2.renderScreen
;	mov al, '!'
;	call TextArea.AppendChar
	;mov eax, 500
	;call System.sleep
	jmp GoDoLoop
	
	mov eax, [Dolphin2.compositorGrouping]
	mov ebx, [eax+Grouping_subcomponent]
	call console.numOut
	mov ebx, [ebx+Grouping_subcomponent]
	call console.numOut
	
	mov byte [INTERRUPT_DISABLE], 0x00
	
;push dword 0x0
;push dword consoletest_title
;push dword consoletest_type
;push dword consoletest_text
;mov ebx, consoletest_text
;call String.getLength
;push edx
;call Minnow3.makeFile

call ProgramManager.finalize
popa
ret
consoletest_title :
	db "Window Test", 0
consoletest_text :
	db "This is some sample text that should be displayed in the test window.", 0
consoletest_type :
	db "Text", 0
SimpleRender.init :
	pusha
		push consoletest_title
		push dword 0*4
		push dword 0
		push dword 400*4
		push dword 400
		call Dolphin2.makeWindow
		mov [SimpleRender.window], ecx

		mov eax, 400*400*4
		mov ecx, 0x1000
		xor edx, edx
		idiv ecx
		mov ebx, eax
		mov al, 0x7
		call Guppy.malloc
		
		push ebx
		push 400*4
		push 400
		push 0
		push 0
		push 400*4
		push 400
		call Image.Create
		mov eax, ecx
		mov ebx, [SimpleRender.window]
		call Grouping.Add
		mov [SimpleRender.image], eax
		add eax, Image_source
		mov [SimpleRender.imagebuffer], eax
		
	popa
	ret
SimpleRender.runOnce :
	pusha
		mov ebx, [SimpleRender.rval]
		add dword [tri+0+8], ebx
		add dword [tri+12+8], ebx
		add dword [tri+24+8], ebx
		
		cmp dword [tri+0+8], 50
			jle .upgood
		jmp .worry
		.upgood :
		cmp dword [tri+0+8], 10
			jge .dontworry
		.worry :
		mov ebx, [SimpleRender.rval]
		imul ebx, -1
		mov [SimpleRender.rval], ebx
		.dontworry :
		
		call SimpleRender.goRender
		
		mov ebx, [SimpleRender.image]
		call Component.RequestUpdate
	popa
	ret
SimpleRender.window :
	dd 0
SimpleRender.image :
	dd 0
SimpleRender.imagebuffer :
	dd 0
SimpleRender.rval :
	dd 1
tri :
	dd -1000, -1000, 10
	dd 1000, -1000, 10
	dd 1000, 1000, 10
drawtri :
	dd 0, 0
	dd 1, 1
	dd 0, 0
	
SimpleRender.goRender :
	pusha
		mov eax, [SimpleRender.imagebuffer]
		mov ebx, 0xFF000000
		mov edx, 400*400*4
		call Image.clear
		
		xor esi, esi
		xor edi, edi
		.loop :
			mov eax, [tri+esi]
			mov ebx, [tri+8+esi]
			call SimpleRender.p_func
			add ecx, 200
			mov edx, ecx
			
			mov eax, [tri+4+esi]
			mov ebx, [tri+8+esi]
			call SimpleRender.p_func
			add ecx, 200
			
			mov [drawtri+edi], edx
			mov [drawtri+4+edi], ecx
			
		add esi, 12
		add edi, 8
		cmp esi, 36
			jl .loop
			
		mov esi, 0
		mov eax, [drawtri]
		mov ebx, [drawtri+4]
		mov ecx, [drawtri+8]
		mov edx, [drawtri+8+4]
		call SimpleRender.drawLine	
		mov eax, [drawtri+8]
		mov ebx, [drawtri+8+4]
		mov ecx, [drawtri+16]
		mov edx, [drawtri+16+4]
		call SimpleRender.drawLine	
		mov eax, [drawtri+16]
		mov ebx, [drawtri+16+4]
		mov ecx, [drawtri]
		mov edx, [drawtri+4]
		call SimpleRender.drawLine
		
		
	popa
	ret
SimpleRender.p_func :
	push edx
		cmp ebx, 0
			jne .nret0
		mov ecx, 0
	pop edx
	ret
	.nret0 :
		mov ecx, ebx
		xor edx, edx
		cdq
		idiv ecx
		mov ecx, eax
	pop edx
	ret
SimpleRender.drawLine :	; Image in [SimpleRender.imagebuffer], eax = x1, ebx = y1, ecx = x2, edx = y2
	cmp eax, ecx
		je SimpleRender.drawVerticalLine
	pusha
		cmp eax, ecx
			jg .otherway
		mov [SimpleRender.x1], eax
		mov [SimpleRender.y1], ebx
		mov [SimpleRender.x2], ecx
		mov [SimpleRender.y2], edx
		jmp .kdone
		.otherway :
		mov [SimpleRender.x1], ecx
		mov [SimpleRender.y1], edx
		mov [SimpleRender.x2], eax
		mov [SimpleRender.y2], ebx		
		.kdone :
		mov eax, [SimpleRender.y2]
		sub eax, [SimpleRender.y1]
		mov [SimpleRender.delta_y], eax
		
		mov ecx, [SimpleRender.x2]
		sub ecx, [SimpleRender.x1]
		mov [SimpleRender.delta_x], ecx
		
		fild dword [SimpleRender.delta_y]
		fidiv dword [SimpleRender.delta_x]
		fstp dword [SimpleRender.slope]
		
		xor edx, edx
		idiv ecx
		imul eax, 400*4
		
		mov ebx, [SimpleRender.imagebuffer]
		mov ecx, [SimpleRender.x1]
		shl ecx, 2
		add ebx, ecx
		mov ecx, [SimpleRender.y1]
		imul ecx, 400*4
		add ebx, ecx
		mov [SimpleRender.drawbase], ebx
		mov edx, [SimpleRender.x1]
		fldz
		.loop :
		mov dword [ebx], 0xFFFFFFFF
		; ; ;
			fadd dword [SimpleRender.slope]
			fist dword [SimpleRender.drawpos]
			mov ebx, [SimpleRender.drawpos]
			imul ebx, 400*4
			add ebx, [SimpleRender.drawbase]
		; ; ;
		add dword [SimpleRender.drawbase], 4
		add edx, 1
		cmp edx, [SimpleRender.x2]
			jle .loop
		fistp dword [SimpleRender.drawbase]	; junk data
	popa
	.ret :
	ret
SimpleRender.drawVerticalLine :
	cmp ebx, edx
		je SimpleRender.drawVerticalLine.ret
	pusha
		cmp ebx, edx
			jg SimpleRender.drawVerticalLine.kcont
		xchg ebx, edx
		SimpleRender.drawVerticalLine.kcont :
		mov [SimpleRender.y1], edx
		mov [SimpleRender.y2], ebx
		mov [SimpleRender.x1], eax
		
		mov dword [SimpleRender.drawpos], 0
		mov ebx, [SimpleRender.imagebuffer]
		mov ecx, [SimpleRender.x1]
		shl ecx, 2
		add ebx, ecx
		mov ecx, [SimpleRender.y1]
		imul ecx, 400*4
		add ebx, ecx
		mov [SimpleRender.drawbase], ebx
		mov edx, [SimpleRender.y1]
		SimpleRender.drawVerticalLine.loop :
		mov dword [ebx], 0xFFFFFFFF
		; ; ;
			mov ebx, [SimpleRender.drawpos]
			imul ebx, 400*4
			add ebx, [SimpleRender.drawbase]
		; ; ;
		add dword [SimpleRender.drawpos], 1
		add edx, 1
		cmp edx, [SimpleRender.y2]
			jle SimpleRender.drawVerticalLine.loop
	SimpleRender.drawVerticalLine.ret :
	popa
	ret

SimpleRender.x1 :
	dd 0x0
SimpleRender.y1 :
	dd 0x0
SimpleRender.x2 :
	dd 0x0
SimpleRender.y2 :
	dd 0x0
SimpleRender.slope :
	dd 0.5
SimpleRender.drawbase :
	dd 0x0
SimpleRender.drawpos :
	dd 0x0
SimpleRender.delta_x :
	dd 0x0
SimpleRender.delta_y :
	dd 0x0

console.memstat :
	mov ah, 0xFF
	pusha
	mov ebx, [Guppy.usedRAM]
	mov edx, ebx
	mov ebx, [Guppy.totalRAM]
	mov ecx, ebx
	cmp ecx, 0x0
		je console.FUNCTION_UNSUPPORTED
	push eax
	mov eax, edx
	imul eax, 100
	xor edx, edx
	idiv ecx
	mov ebx, eax
	pop eax
	call console.numOut
	mov ebx, Guppy.div3
	call console.println
popa
ret

console.checkColor :
	cmp ah, 0x0
		jne console.checkColor_ret
	mov ah, 0xFF
	console.checkColor_ret :
	ret

console.FUNCTION_UNSUPPORTED :
mov ah, 0x3	; RED
mov ebx, console.UNSUP_MSG
call console.println
popa
ret

screen.wipe :
;pusha
;mov ebx, [console.pos]
;add ebx, [Dolphin.SCREEN_BUFFER]
;mov cx, [console.width]
;mov dx, [console.height]
;call Dolphin.clear
;popa
ret

; console.update :
; pusha
; mov ebx, [console.draw]
; cmp ebx, 0x0
; je console.update.gone
	; xor ebx, ebx
	; mov bl, [console.winNum]
	; mov [Dolphin.currentWindow], ebx
	
	; call Dolphin.uUpdate
	
; popa
; ret

console.update.gone :
mov bl, [console.winNum]
call Dolphin.windowExists
cmp eax, 0x0
je console.update.gone.ret
call Dolphin.unregisterWindow
console.update.gone.ret :
popa
ret

;console.checkClear :
;mov ebx, [console.bufferPos]
;cmp ebx, 0x1000
;jle cseret
;call console.clearScreen
;cseret :
;ret

console.print :
cmp dword [DisplayMode], MODE_TEXT
	je TextMode.print
pusha
push ebx
	xor ebx, ebx
	mov bl, [console.winNum]
	mov [Dolphin.currentWindow], ebx
pop ebx
		mov ah, [console.vgacolor]
		push eax
		push bx
		mov bl, [Window.BUFFER]	; -> edx
		call Dolphin.getAttribDouble
		mov edx, eax
		
		mov bl, [Window.BUFFERSIZE]	; -> ecx
		call Dolphin.getAttribDouble
		mov ecx, eax
		pop bx
		pop eax
add edx, ecx
printitp :
mov al, [ebx]
;mov ah, 0x0c ; or 0x0f... you get the point
cmp al, 0
je printdonep
mov [edx], ax
;call TextHandler.drawChar
add ebx, 1
add edx, 2
push ebx
		push eax
		mov bl, [Window.BUFFERSIZE]	; -> ebx
		call Dolphin.getAttribDouble
		mov ebx, eax
		pop eax
add ebx, 0x2
	push eax
	mov eax, ebx
	mov bl, [Window.BUFFERSIZE]	; <- ebx
	call Dolphin.setAttribDouble
	pop eax
pop ebx
jmp printitp
printdonep :
mov word [edx], 0x0
;call console.update
popa
ret

;console.drawCursor :
;pusha
;mov edx, [console.buffer]
;mov ecx, [console.bufferPos]
;add edx, ecx
;mov cl, 0x5f
;mov ch, 0x0F
;mov [edx], cx
;popa
;ret

console.println :
call console.print
call console.newline
ret

console.numOutFakeDecimal :	; just go base 10 -> the same characters in hex (ONLY WORKS WITH 2-DIGIT DECIMAL NUMBERS)
pusha
	mov eax, ebx
	xor edx, edx
	mov ecx, 0xA
	push ebx
	idiv ecx
	pop ebx
	imul eax, 0x6
	add [cnOFDchange], eax
add ebx, [cnOFDchange]
call console.numOut
popa
ret
cnOFDchange :
dd 0x0

console.numOut :
pusha
call console.checkColor
mov [console.cstor], ah
mov cl, 28
mov ch, 0x0

; num out
console.numOut.start :
	cmp ebx, 0x0
	jne console.numOut.cont
	mov ah, [console.cstor]
	mov al, '0'
	call console.cprint
	popa
	ret
	console.numOut.cont :
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
push ax
mov ah, [console.cstor]
call console.cprint
pop ax
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

; newline
console.newline :
	cmp dword [DisplayMode], MODE_TEXT
		je TextMode.newline
	pusha
		push ebx
	xor ebx, ebx
	mov bl, [console.winNum]
	mov [Dolphin.currentWindow], ebx
	pop ebx
			push eax
			push bx
			mov bl, [Window.BUFFER]	; -> edx
			call Dolphin.getAttribDouble
			mov edx, eax
			mov bl, [Window.BUFFERSIZE]	; -> ecx
			call Dolphin.getAttribDouble
			mov ecx, eax
			pop bx
			pop eax
		add edx, ecx
		mov al, 0x0A
		mov ah, 0xFF
		mov [edx], ax
			push eax
			mov bl, [Window.BUFFERSIZE]	; -> ebx
			call Dolphin.getAttribDouble
			mov ebx, eax
			pop eax
		add ebx, 0x2
			mov eax, ebx
			mov bl, [Window.BUFFERSIZE]	; <- ebx
			call Dolphin.setAttribDouble
	popa
	ret

console.doBackspace :
		mov bl, [Window.BUFFERSIZE]	; -> eax
		call Dolphin.getAttribDouble
mov edx, 0x0
bsdloop :
push edx
xor edx, edx
		push eax
		push bx
		mov bl, [Window.WIDTH]	; -> dx
		call Dolphin.getAttribWord
		mov dx, ax
		pop bx
		pop eax
;add dx, dx
sub eax, edx
pop edx
add edx, 0x1
cmp eax, 0
jg bsdloop
cmp eax, 0x0
mov ecx, 2
jne bsfnoloop
		push eax
		mov bl, [Window.BUFFERSIZE]	; -> ebx
		call Dolphin.getAttribDouble
		mov ebx, eax
		pop eax
push ecx
		push eax
		push bx
		mov bl, [Window.BUFFER]	; -> ecx
		call Dolphin.getAttribDouble
		mov ecx, eax
		pop bx
		pop eax
add ebx, ecx
pop ecx
mov [ebx], edx
mov eax, edx
push bx
push edx
xor edx, edx
		push eax
		push bx
		mov bl, [Window.WIDTH]	; -> dx
		call Dolphin.getAttribWord
		mov dx, ax
		pop bx
		pop eax
;add dx, dx
mov bx, dx
pop edx
mul bx
pop bx
sub eax, 2
push ecx
		push eax
		push bx
		mov bl, [Window.BUFFER]	; -> ecx
		call Dolphin.getAttribDouble
		mov ecx, eax
		pop bx
		pop eax
add eax, ecx
pop ecx
mov bx, 0x0
bsfcloop :
add ecx, 2
sub eax, 2
cmp [eax], bx
je bsfcloop
sub ecx, 2
bsfnoloop :
		push bx
		mov bl, [Window.BUFFERSIZE]	; -> eax
		call Dolphin.getAttribDouble
		pop bx
sub eax, ecx
cmp eax, 0
jl console.doBackspace.stop
		push bx
		mov bl, [Window.BUFFERSIZE]	; <- eax
		call Dolphin.setAttribDouble
		pop bx
console.doBackspace.stop :
push ecx
		push eax
		push bx
		mov bl, [Window.BUFFER]	; -> ecx
		call Dolphin.getAttribDouble
		mov ecx, eax
		pop bx
		pop eax
add eax, ecx
pop ecx
mov bx, 0x0
mov [eax], bx
add eax, 2
mov [eax], bx
;call console.update
;jmp console.loop.checkKeyBuffer
jmp kernel.halt

console.cprint :
cmp dword [DisplayMode], MODE_TEXT
	je TextMode.cprint
pusha

	mov ah, [console.vgacolor]

	push ebx
	xor ebx, ebx
	mov bl, [console.winNum]
	mov [Dolphin.currentWindow], ebx
	pop ebx

		push eax
		mov bl, [Window.BUFFERSIZE]	; -> ebx
		call Dolphin.getAttribDouble
		mov edx, eax

		push bx
		mov bl, [Window.BUFFER]	; -> ecx
		call Dolphin.getAttribDouble
		pop bx

add edx, eax

pop eax

mov [edx], ax
add edx, 2
mov word [edx], 0x0
;call TextHandler.drawChar
		push eax
		mov bl, [Window.BUFFERSIZE]	; -> ebx
		call Dolphin.getAttribDouble
		mov ebx, eax
		pop eax
add ebx, 0x2
		push eax
		mov eax, ebx
		mov bl, [Window.BUFFERSIZE]	; <- ebx
		call Dolphin.setAttribDouble
		pop eax
;call console.update

popa
ret

console.clearScreen :	; something about this corrupts subComponents...
cmp dword [DisplayMode], MODE_TEXT
	je TextMode.clearScreen
pusha
	xor ebx, ebx
	mov bl, [console.winNum]
	call Window.forceFlush
	
	mov edx, [Dolphin.currentWindow]
	add edx, Dolphin.windowStructs
	mov edx, [edx]
	mov eax, [edx+Window_buffer]
	;mov ebx, eax
	;call String.getLength
	mov ebx, [Graphics.SCREEN_SIZE];edx
	call Buffer.clear

		mov dword [edx+Window_buffersize], 0
popa
ret
console.clearScreen.end :
	dd 0x0

console.setColor :
mov [console.vgacolor], bl
ret

console.vgacolor :
	db 0xC
console.color :
	dd 0xFF0000

console.pos :	; should be removed, use the window's position instead
dd 0x0

console.draw :
dd 0x0

console.cstor :
db 0x0

console.winNum :
db 0x0

console.pnum :
db 0x0

console.dat :
dd 0x0

console.UNSUP_MSG :
db "The specified function is unsupported on your computer.", 0

console.bufferstor :
dd 0x0

counter1 :
dd 0x0

console.title :
db "iConsole VER_1.1", 0

console.windowStructLoc :
	dd 0