; THIS WINDOW TEST SHOULD BE KEPT UPDATED TO THE MOST RECENT STABLE VERSION OF DOLPHIN. (In the future, it should remain compatible with the most recent WCMS specification.)

HelloWorld.init :
pusha
	call HelloWorld.initProgram
	call HelloWorld.initWindow
	call HelloWorld.printWelcomeMessage
	call ProgramManager.finalize
popa
ret

HelloWorld.initProgram :
	call ProgramManager.getProgramNumber
	mov [HelloWorld.programNumber], bl
	call ProgramManager.setActive
	call Window.getSectorSize
	add eax, 1
	mov ebx, eax
	call ProgramManager.requestMemory
ret

HelloWorld.initWindow :
	push dword HelloWorld.windowTitle
	push word Window.TYPE_TEXT
	call Window.create
	mov [HelloWorld.window], ecx
	mov [HelloWorld.windowNumber], bl
ret

HelloWorld.printWelcomeMessage :
	mov ebx, [HelloWorld.window]
	add bl, [Window.BUFFER]
	mov eax, [ebx]
	
	mov ebx, HelloWorld.welcomeMessage
	call String.copyRawToWhite_auto
	mov ebx, ecx
	call String.append
ret


HelloWorld.window :
	dd 0x0
HelloWorld.windowNumber :
	dd 0x0
HelloWorld.programNumber :
	db 0x0
HelloWorld.windowTitle :
	db "Window Test", endstring
HelloWorld.welcomeMessage :
	db "Hello World!", newline, "This is a test window.", endstring
