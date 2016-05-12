ImageEditor.init :
	pusha
		push dword ImageEditor.placeholderTitle
		push dword 0*4
		push dword 0
		mov edx, 45+10+7*FONTWIDTH
		add edx, 200	; default image width
		shl edx, 2	; mul by 4
		push edx
		mov edx, 200	; default image height
		cmp edx, 5+(10+5)*5+5
			jge ._max0
		mov edx, 5+(10+5)*5+5
		._max0 :
		push edx
		call Dolphin2.makeWindow
		mov [ImageEditor.window], ecx
		mov ebx, ecx
		
		push dword ImageEditor.STR_SIZE
		push dword 5*4
		push dword (5+(10+5)*0)
		push dword 7*FONTWIDTH*4
		push dword 10
		call TextLine.Create
		mov eax, ecx
		call Grouping.Add
		
		push dword ImageEditor.STR_COLOR
		push dword 5*4
		push dword (5+(10+5)*1)
		push dword 7*FONTWIDTH*4
		push dword 10
		call TextLine.Create
		mov eax, ecx
		call Grouping.Add
		
		push dword ImageEditor.STR_RED
		push dword 5*4
		push dword (5+(10+5)*2)
		push dword 7*FONTWIDTH*4
		push dword 10
		call TextLine.Create
		mov eax, ecx
		call Grouping.Add
		
		push dword ImageEditor.STR_GREEN
		push dword 5*4
		push dword (5+(10+5)*3)
		push dword 7*FONTWIDTH*4
		push dword 10
		call TextLine.Create
		mov eax, ecx
		call Grouping.Add
		
		push dword ImageEditor.STR_BLUE
		push dword 5*4
		push dword (5+(10+5)*4)
		push dword 7*FONTWIDTH*4
		push dword 10
		call TextLine.Create
		mov eax, ecx
		call Grouping.Add

		; Brush size controls ;
		
		push dword ImageEditor.STR_MINUS
		push dword ImageEditor.decBrushSize
		push dword (5+7*FONTWIDTH)*4
		push dword (5+(10+5)*0)
		push dword 10*4
		push dword 10
		call Button.Create
		mov eax, ecx
		call Grouping.Add
		
		push dword ImageEditor.SIZE_VALSTR
		push dword (5+7*FONTWIDTH+10+25/2-2*(FONTWIDTH+4)/2)*4
		push dword (5+(10+5)*0)
		push dword 2*(FONTWIDTH+4)*4
		push dword 10
		call TextLine.Create
		mov eax, ecx
		call Grouping.Add
		mov dword [ecx+Component_transparent], false
		
		push dword ImageEditor.STR_PLUS
		push dword ImageEditor.incBrushSize
		push dword (5+7*FONTWIDTH+35)*4
		push dword (5+(10+5)*0)
		push dword 10*4
		push dword 10
		call Button.Create
		mov eax, ecx
		call Grouping.Add
		
		; Color preview ;
		push dword (5+7*FONTWIDTH)*4
		push dword (5+(10+5)*1)
		push dword 45*4
		push dword 10
		call Grouping.Create
		mov eax, ecx
		call Grouping.Add
		mov dword [ecx+Grouping_backingColor], 0xFF000000
		mov dword [ecx+Grouping_renderFlag], true
		mov [ImageEditor.colorPreview], ecx

		; Red value controls ;
		
		push dword ImageEditor.STR_MINUS
		push dword ImageEditor.decRedValue
		push dword (5+7*FONTWIDTH)*4
		push dword (5+(10+5)*2)
		push dword 10*4
		push dword 10
		call Button.Create
		mov eax, ecx
		call Grouping.Add
		
		push dword ImageEditor.RED_VALSTR
		push dword (5+7*FONTWIDTH+10+25/2-2*(FONTWIDTH+4)/2)*4
		push dword (5+(10+5)*2)
		push dword 2*(FONTWIDTH+4)*4
		push dword 10
		call TextLine.Create
		mov eax, ecx
		call Grouping.Add
		mov dword [ecx+Component_transparent], false
		
		push dword ImageEditor.STR_PLUS
		push dword ImageEditor.incRedValue
		push dword (5+7*FONTWIDTH+35)*4
		push dword (5+(10+5)*2)
		push dword 10*4
		push dword 10
		call Button.Create
		mov eax, ecx
		call Grouping.Add

		; Green value controls ;
		
		push dword ImageEditor.STR_MINUS
		push dword ImageEditor.decGreenValue
		push dword (5+7*FONTWIDTH)*4
		push dword (5+(10+5)*3)
		push dword 10*4
		push dword 10
		call Button.Create
		mov eax, ecx
		call Grouping.Add
		
		push dword ImageEditor.GREEN_VALSTR
		push dword (5+7*FONTWIDTH+10+25/2-2*(FONTWIDTH+4)/2)*4
		push dword (5+(10+5)*3)
		push dword 2*(FONTWIDTH+4)*4
		push dword 10
		call TextLine.Create
		mov eax, ecx
		call Grouping.Add
		mov dword [ecx+Component_transparent], false
		
		push dword ImageEditor.STR_PLUS
		push dword ImageEditor.incGreenValue
		push dword (5+7*FONTWIDTH+35)*4
		push dword (5+(10+5)*3)
		push dword 10*4
		push dword 10
		call Button.Create
		mov eax, ecx
		call Grouping.Add

		; Blue value controls ;
		
		push dword ImageEditor.STR_MINUS
		push dword ImageEditor.decBlueValue
		push dword (5+7*FONTWIDTH)*4
		push dword (5+(10+5)*4)
		push dword 10*4
		push dword 10
		call Button.Create
		mov eax, ecx
		call Grouping.Add
		
		push dword ImageEditor.BLUE_VALSTR
		push dword (5+7*FONTWIDTH+10+25/2-2*(FONTWIDTH+4)/2)*4
		push dword (5+(10+5)*4)
		push dword 2*(FONTWIDTH+4)*4
		push dword 10
		call TextLine.Create
		mov eax, ecx
		call Grouping.Add
		mov dword [ecx+Component_transparent], false
		
		push dword ImageEditor.STR_PLUS
		push dword ImageEditor.incBlueValue
		push dword (5+7*FONTWIDTH+35)*4
		push dword (5+(10+5)*4)
		push dword 10*4
		push dword 10
		call Button.Create
		mov eax, ecx
		call Grouping.Add
		
		; Image view ;
		
		mov edx, ebx
		mov ebx, 200*200*4
		call ProgramManager.reserveMemory
		push ebx
		push 200*4
		push 200
		push (45+10+7*FONTWIDTH)*4
		push 0
		push 200*4
		push 200
		call Image.Create
		mov eax, ecx
		mov ebx, edx
		call Grouping.Add
		mov dword [ecx+Component_mouseHandlerFunc], ImageEditor.drawStroke
		mov [ImageEditor.image], ecx
		
	popa
	ret
ImageEditor.placeholderTitle :
	db "ImageEditor- Untitled", 0x0
ImageEditor.promptTitle :
	db "ImageEditor", 0x0
ImageEditor.promptMessage :
	db "File Name: ", 0x0
ImageEditor.STR_SIZE :
	db "Size: ", 0x0
ImageEditor.SIZE_VALSTR :
	db '0'
	times 4 dq 0x0
ImageEditor.STR_COLOR :
	db "Color: ", 0x0
ImageEditor.STR_RED :
	db "Red: ", 0x0
ImageEditor.RED_VALSTR :
	db '0'
	times 4 dq 0x0
ImageEditor.STR_GREEN :
	db "Green: ", 0x0
ImageEditor.GREEN_VALSTR :
	db '0'
	times 4 dq 0x0
ImageEditor.STR_BLUE :
	db "Blue: ", 0x0
ImageEditor.BLUE_VALSTR :
	db '0'
	times 4 dq 0x0
ImageEditor.STR_LOAD :
	db "Load: ", 0x0
ImageEditor.STR_SAVE :
	db "Save: ", 0x0
ImageEditor.STR_MINUS :
	db "-", 0x0
ImageEditor.STR_PLUS :
	db "+", 0x0
ImageEditor.fileTitle :
	times 20 dq 0x0
ImageEditor.window :
	dd 0x0
ImageEditor.image :
	dd 0x0
ImageEditor.colorPreview :
	dd 0x0
ImageEditor.brushSize :
	dd 0x0
ImageEditor.redVal :
	dd 0x0
ImageEditor.greenVal :
	dd 0x0
ImageEditor.blueVal :
	dd 0x0
ImageEditor.color :
	dd 0xFF000000

ImageEditor.loadFile :

ImageEditor.saveFile :

ImageEditor.getFileName :

ImageEditor.mouseHandlerFunc :

ImageEditor.decBrushSize :
		dec dword [ImageEditor.brushSize]
		pusha
			mov eax, ImageEditor.SIZE_VALSTR
			mov dword [eax], 0x0
			mov dword [eax+4], 0x0
			mov ebx, [ImageEditor.brushSize]
			call String.fromHex
		popa
	ret
ImageEditor.incBrushSize :
		inc dword [ImageEditor.brushSize]
		pusha
			mov eax, ImageEditor.SIZE_VALSTR
			mov dword [eax], 0x0
			mov dword [eax+4], 0x0
			mov ebx, [ImageEditor.brushSize]
			call String.fromHex
		popa
	ret
ImageEditor.decRedValue :
		dec dword [ImageEditor.redVal]
		pusha
			mov eax, ImageEditor.RED_VALSTR
			mov dword [eax], 0x0
			mov dword [eax+4], 0x0
			mov ebx, [ImageEditor.redVal]
			call String.fromHex
		popa
		call ImageEditor.updateColorPreview
	ret
ImageEditor.incRedValue :
		inc dword [ImageEditor.redVal]
		pusha
			mov eax, ImageEditor.RED_VALSTR
			mov dword [eax], 0x0
			mov dword [eax+4], 0x0
			mov ebx, [ImageEditor.redVal]
			call String.fromHex
		popa
		call ImageEditor.updateColorPreview
	ret
ImageEditor.decGreenValue :
		dec dword [ImageEditor.greenVal]
		pusha
			mov eax, ImageEditor.GREEN_VALSTR
			mov dword [eax], 0x0
			mov dword [eax+4], 0x0
			mov ebx, [ImageEditor.greenVal]
			call String.fromHex
		popa
		call ImageEditor.updateColorPreview
	ret
ImageEditor.incGreenValue :
		inc dword [ImageEditor.greenVal]
		pusha
			mov eax, ImageEditor.GREEN_VALSTR
			mov dword [eax], 0x0
			mov dword [eax+4], 0x0
			mov ebx, [ImageEditor.greenVal]
			call String.fromHex
		popa
		call ImageEditor.updateColorPreview
	ret
ImageEditor.decBlueValue :
		dec dword [ImageEditor.blueVal]
		pusha
			mov eax, ImageEditor.BLUE_VALSTR
			mov dword [eax], 0x0
			mov dword [eax+4], 0x0
			mov ebx, [ImageEditor.blueVal]
			call String.fromHex
		popa
		call ImageEditor.updateColorPreview
	ret
ImageEditor.incBlueValue :
		inc dword [ImageEditor.blueVal]
		pusha
			mov eax, ImageEditor.BLUE_VALSTR
			mov dword [eax], 0x0
			mov dword [eax+4], 0x0
			mov ebx, [ImageEditor.blueVal]
			call String.fromHex
		popa
		call ImageEditor.updateColorPreview
	ret
ImageEditor.updateColorPreview :
	pusha
		mov ecx, [ImageEditor.colorPreview]
		mov bh, 0xFF
		mov bl, [ImageEditor.redVal]
		shl ebx, 16
		mov bh, [ImageEditor.greenVal]
		mov bl, [ImageEditor.blueVal]
		mov [ImageEditor.color], ebx
		mov [ecx+Grouping_backingColor], ebx
		mov dword [ecx+Grouping_renderFlag], true
	popa
	ret
ImageEditor.drawStroke :
	cmp dword [Component.mouseEventType], MOUSE_NOBTN
		je .ret
	pusha
		mov ebx, [ImageEditor.image]
		mov edx, [ebx+Image_source]
		add edx, [Component.mouseEventX]
		mov ecx, [Component.mouseEventY]
		imul ecx, [ebx+Image_sw]
		add edx, ecx
		mov eax, [ImageEditor.color]
		mov dword [edx], eax
		
		mov ebx, [ImageEditor.image]
		call Component.RequestUpdate
	popa
	.ret :
	ret
