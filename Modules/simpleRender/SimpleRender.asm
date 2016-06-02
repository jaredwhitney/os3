Point2D_x	equ 0
Point2D_y	equ 4

Point_x		equ 0
Point_y		equ 4
Point_z		equ 8

SimpleRender.init :
	pusha
		push dword SimpleRender.COMMAND_RUN
		call iConsole2.RegisterCommand
	popa
	ret

SimpleRender.trinumber :
	dd 0x8
	
SimpleRender.tridata :

	dd -100, -100, 500	; tri 1
	dd 100, -100, 500
	dd -100, 100, 500
	
	dd 100, -100, 500	; tri 2
	dd -100, 100, 500
	dd 100, 100, 500
	
	dd -100, -100, 500
	dd -100, 100, 500
	dd -100, -100, 700
	
	dd -100, 100, 500
	dd -100, 100, 700
	dd -100, -100, 700
	
	dd 100, -100, 500
	dd 100, 100, 500
	dd 100, -100, 700
	
	dd 100, 100, 500
	dd 100, 100, 700
	dd 100, -100, 700
	
	dd -100, -100, 700
	dd 100, -100, 700
	dd 100, 100, 700
	
	dd -100, -100, 700
	dd -100, 100, 700
	dd 100, 100, 700

SimpleRender.TRI_SIZE	equ SimpleRender.POINT_SIZE*3
SimpleRender.POINT_SIZE	equ 4*3

SimpleRender.drawTri :
	times 2*3 dd 0x0

SimpleRender.currentTri :
	dd SimpleRender.tridata
	
SimpleRender.newPoint :
	times 3 dd 0x0
	
SimpleRender.window :
	dd 0x0

SimpleRender.image :
	dd 0x0
SimpleRender.tempZ :
	dd 0x0
SimpleRender.mxacc :
	dd 0	
SimpleRender.mxaccf :
	times 2 dd 0x0
SimpleRender.lockMouse :
	dd FALSE
SimpleRender.STR_SIMPLERENDER :
	db "3dengine", 0x0
SimpleRender.COMMAND_RUN :
	dd SimpleRender.STR_SIMPLERENDER
	dd SimpleRender.main
	dd null
SimpleRender.main :
	pusha
	
		push dword .STR_TITLE
		push dword 0*4
		push dword 0
		push dword 400*4
		push dword 400
		call Dolphin2.makeWindow
		mov [SimpleRender.window], ecx
		
		mov ebx, 400*400*4
		call ProgramManager.reserveMemory
		mov [SimpleRender.image], ebx
		
		push ebx
		push dword 400*4
		push dword 400
		push dword 0*4
		push dword 0
		push dword 400*4
		push dword 400
		call Image.Create
		mov ebx, [SimpleRender.window]
		mov eax, ecx
		call Grouping.Add
		mov [Dolphin2.focusedComponent], ecx
		mov dword [ecx+Component_keyHandlerFunc], SimpleRender.keyFunc
		
		mov eax, [SimpleRender.image]
		mov ebx, 400
		mov ecx, 400
		call L3gxImage.FromBuffer
		mov [SimpleRender.ximage], ecx
		
		push dword SimpleRender.TASK_MAINLOOP
		call iConsole2.RegisterTask
		
		mov eax, SimpleRender.exit
		mov ebx, [SimpleRender.window]
		call WindowGrouping.RegisterCloseCallback
	
	popa
	ret
	.STR_TITLE :
		db "SimpleRender v2", 0

SimpleRender.ximage :
	dd 0x0

SimpleRender.keyFunc :
		xor dword [SimpleRender.lockMouse], TRUE
		cmp dword [SimpleRender.lockMouse], TRUE
			jne .aret
		mov dword [Mouse.cursor], Mouse.CURSOR_TRANSPARENT
		jmp .ret
		.aret :
		mov dword [Mouse.cursor], Mouse.CURSOR_DEFAULT
	.ret :
	ret
SimpleRender.exit :
	pusha
		push dword SimpleRender.TASK_MAINLOOP
		call iConsole2.UnregisterTask
	popa
	ret
SimpleRender.TASK_MAINLOOP :
	dd SimpleRender.loop
	dd null
SimpleRender.loop :
	pusha
		
		cmp dword [SimpleRender.lockMouse], TRUE
			jne .dontUseMouse
		
		mov eax, [Mouse.x]
		mov ebx, [Graphics.SCREEN_WIDTH]
		shr ebx, 2	; /4 to get in pixels
		shr ebx, 1	; /2 to get center of width
		sub eax, ebx
		add [SimpleRender.mxacc], eax
	;add dword [SimpleRender.mxacc], 20
		
		mov [Mouse_xsum], ebx
		;mov [Mouse_ysum], 
		.dontUseMouse :
		; repaint the thing!
		
		mov eax, [SimpleRender.image]
		mov ebx, 400*400*4
		call Buffer.clear
		
		fild dword [SimpleRender.mxacc]
		fdiv dword [.f500]
		fstp dword [SimpleRender.mxaccf]
		
		mov dword [SimpleRender.currentTri], SimpleRender.tridata
		mov edx, [SimpleRender.trinumber]
		
		.loop :
		call SimpleRender.goDrawTri
		add dword [SimpleRender.currentTri], SimpleRender.TRI_SIZE
		dec edx
		cmp edx, 0x0
			jg .loop
		
	popa
	ret
SimpleRender.goDrawTri :
	push edx
		xor ecx, ecx
		mov [SimpleRender.loop.count], ecx
		
		.loop :
		
		mov eax, [SimpleRender.currentTri]
		mov ecx, [SimpleRender.loop.count]
		imul ecx, 4*3
		add eax, ecx
		mov [SimpleRender.triS], eax
		mov ebx, SimpleRender.drawTri
		mov ecx, [SimpleRender.loop.count]
		imul ecx, 4*2
		add ebx, ecx
		mov [SimpleRender.drawTriS], eax
		
			; r0y
		
			mov ebx, [SimpleRender.triS]
			mov ecx, SimpleRender.newPoint
			mov edx, [ebx+Point_z]
			sub edx, 600
			mov [SimpleRender.tempZ], edx
			fld dword [SimpleRender.mxaccf]
			fcos
			fimul dword [ebx+Point_x]
			fstp dword [.fstor0]
			fld dword [SimpleRender.mxaccf]
			fsin
			fimul dword [SimpleRender.tempZ]
			fsub dword [.fstor0]
			fistp dword [ecx+Point_x]
			
			
			fld dword [SimpleRender.mxaccf]
			fsin
			fimul dword [ebx+Point_x]
			fstp dword [.fstor0]
			fld dword [SimpleRender.mxaccf]
			fcos
			fimul dword [SimpleRender.tempZ]
			fadd dword [.fstor0]
			fistp dword [ecx+Point_z]
			
			add dword [ecx+Point_z], 600
			
			mov eax, [ebx+Point_y]
			mov [ecx+Point_y], eax
		.nor0y :
		
		mov edx, SimpleRender.newPoint
		mov eax, [edx+Point_x]
		mov ebx, [edx+Point_z]
		call SimpleRender.p_func
		add ecx, 200
		mov [.u], ecx
		
		mov eax, [edx+Point_y]
		mov ebx, [edx+Point_z]
		call SimpleRender.p_func
		add ecx, 200
		mov [.v], ecx
	
		cmp dword [SimpleRender.loop.count], 0
			jne .goon
		mov eax, [.u]
		mov [.u0], eax
		mov eax, [.v]
		mov [.v0], eax
		jmp .noDraw
		
		.goon :
		push dword [SimpleRender.ximage]
		push dword [.u]
		push dword [.v]
		push dword [.ul]
		push dword [.vl]
		call SimpleRender.drawLine
		
		cmp dword [SimpleRender.loop.count], 2
			jne .noDraw
	
		push dword [SimpleRender.ximage]
		push dword [.u]
		push dword [.v]
		push dword [.u0]
		push dword [.v0]
		call SimpleRender.drawLine
		
		.noDraw :
		
		mov eax, [.u]
		mov [.ul], eax
		mov eax, [.v]
		mov [.vl], eax
		
		inc dword [SimpleRender.loop.count]
		cmp dword [SimpleRender.loop.count], 3
			jl .loop
	pop edx
	ret

	.u :
		dd 0x0
	.v :
		dd 0x0
	.u0 :
		dd 0x0
	.v0 :
		dd 0x0
	.ul :
		dd 0x0
	.vl :
		dd 0x0
	.fstor0 :
		dd 0x0
	SimpleRender.triS :
		dd 0x0
	SimpleRender.drawTriS :
		dd 0x0
	SimpleRender.loop.count :
		dd 0x0
	SimpleRender.loop.f500 :
		dd 500.

SimpleRender.p_func :
	push eax
	push ebx
	push edx
		
		xor ecx, ecx
		
		cmp ebx, 0
			jle .ret
		
		mov [.zstor], ebx
		mov [.astor], eax
		
		fild dword [.zstor]
		fdiv dword [.f80]
		fstp dword [.zdstor]
		
		fild dword [.astor]
		fdiv dword [.zdstor]
		fistp dword [.rstor]
		mov ecx, [.rstor]
	
	.ret :
	pop edx
	pop ebx
	pop eax
	ret
	.zstor :
		dd 0x0
	.astor :
		dd 0x0
	.zdstor :
		dd 0x0
	.rstor :
		dd 0x0
	.f80 :
		dd 160.

%include "..\modules\simpleRender\lineFunc.asm"