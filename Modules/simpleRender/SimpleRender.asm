Point2D_x	equ 0
Point2D_y	equ 4

Point_x		equ 0
Point_y		equ 4
Point_z		equ 8

SimpleRender.tri :
	dd -100, -100, 500
	dd 100, -100, 500
	dd 100, 100, 500

SimpleRender.drawTri :
	times 2*3 dd 0x0

SimpleRender.newPoint :
	times 3 dd 0x0
	
SimpleRender.window :
	dd 0x0

SimpleRender.image :
	dd 0x0
	
SimpleRender.mxacc :
	dd 0	
SimpleRender.mxaccf :
	times 2 dd 0x0

SimpleRender.init :
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
		
	popa
	ret
	.STR_TITLE :
		db "SimpleRender v2", 0

SimpleRender.loop :
	pusha
		
		mov eax, [Mouse.x]
		mov ebx, [Graphics.SCREEN_WIDTH]
		shr ebx, 2	; /4 to get in pixels
		shr ebx, 1	; /2 to get center of width
		sub eax, ebx
		add [SimpleRender.mxacc], eax
	;add dword [SimpleRender.mxacc], 20
		
		mov [Mouse_xsum], ebx
		;mov [Mouse_ysum], 
		
		; repaint the thing!
		
		mov eax, [SimpleRender.image]
		mov ebx, 400*400*4
		call Buffer.clear
		
		fild dword [SimpleRender.mxacc]
		fdiv dword [.f500]
		fstp dword [SimpleRender.mxaccf]
		
		xor ecx, ecx
		mov [SimpleRender.loop.count], ecx
		
		.loop :
		
		mov eax, SimpleRender.tri
		mov ecx, [SimpleRender.loop.count]
		imul ecx, 4*3
		add eax, ecx
		mov [SimpleRender.triS], eax
		mov ebx, SimpleRender.drawTri
		mov ecx, [SimpleRender.loop.count]
		imul ecx, 4*2
		add ebx, ecx
		mov [SimpleRender.drawTriS], eax
		
		; jmp .nor0y
			; r0y (not working)
		
			mov ebx, [SimpleRender.triS]
			mov ecx, SimpleRender.newPoint
			
			fld dword [SimpleRender.mxaccf]
			fcos
			fimul dword [ebx+Point_x]
			fstp dword [.fstor0]
			fld dword [SimpleRender.mxaccf]
			fsin
			fimul dword [ebx+Point_z]
			fsub dword [.fstor0]
			fistp dword [ecx+Point_x]
			
			
			fld dword [SimpleRender.mxaccf]
			fsin
			fimul dword [ebx+Point_x]
			fstp dword [.fstor0]
			fld dword [SimpleRender.mxaccf]
			fcos
			fimul dword [ebx+Point_z]
			fadd dword [.fstor0]
			fistp dword [ecx+Point_z]
			
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
		
		cmp dword [.u], 0
			jl .noDraw
		cmp dword [.u], 400
			jge .noDraw
		cmp dword [.v], 0
			jl .noDraw
		cmp dword [.v], 400
			jge .noDraw
		
		mov ebx, [SimpleRender.image]
		mov edx, [.u]
		shl edx, 2
		add ebx, edx
		mov eax, [.v]
		imul eax, 400*4
		add ebx, eax
		
		mov dword [ebx], 0xFF00FF00
		
		.noDraw :
		
		inc dword [SimpleRender.loop.count]
		cmp dword [SimpleRender.loop.count], 3
			jl .loop
		
	popa
	ret
	.u :
		dd 0x0
	.v :
		dd 0x0
	.count :
		dd 0x0
	.f500 :
		dd 500.
	.fstor0 :
		dd 0x0
	SimpleRender.triS :
		dd 0x0
	SimpleRender.drawTriS :
		dd 0x0

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
		dd 80.
