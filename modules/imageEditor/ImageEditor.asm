ImageEditor.COMMAND_RUN :
	dd ImageEditor.STR_IMAGEEDITORNAME
	dd ImageEditor.main
	dd null
ImageEditor.BINDING_RAWIMAGE :
	dd ImageEditor.STR_RAWIMAGETYPE
	dd ImageEditor.mainFromConsoleFile
	dd null
ImageEditor.init :
	pusha
		push dword ImageEditor.COMMAND_RUN
		call iConsole2.RegisterCommand
		push dword ImageEditor.BINDING_RAWIMAGE
		call iConsole2.RegisterFiletypeBinding
	popa
	ret
ImageEditor.STR_IMAGEEDITORNAME :
	db "imageedit", 0x0
ImageEditor.STR_RAWIMAGETYPE :
	db "rawimage", 0x0

ImageEditor.main :
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
		call WinMan.CreateWindow;Dolphin2.makeWindow
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
		
		; Load button ;
		
		push dword ImageEditor.STR_LOAD
		push dword ImageEditor.promptLoadFile
		push dword 5*4
		push dword 5+(10+5)*5
		push dword 4*FONTWIDTH*4
		push dword FONTHEIGHT
		call Button.Create
		mov eax, ecx
		call Grouping.Add
		
		; Save button ;
		
		push dword ImageEditor.STR_SAVE
		push dword ImageEditor.promptSaveFile
		push dword (5+7*FONTWIDTH)*4
		push dword 5+(10+5)*5
		push dword 4*FONTWIDTH*4
		push dword FONTHEIGHT
		call Button.Create
		mov eax, ecx
		call Grouping.Add
		
		
		
		; New image button ;
		
		
		
		; Image view ;
		
		mov edx, ebx
		mov ebx, 200*200*4+8	; +8 gives room for width and height
		call ProgramManager.reserveMemory
		add ebx, 8	; data starts at offs 8
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
;ImageEditor.promptSaveTitle :
;	db "Save an Image", 0x0
;ImageEditor.promptLoadTitle :
;	db "Open an Image", 0x0
;ImageEditor.promptMessage :
;	db "Open", 0x0
ImageEditor.STR_SIZE :
	db "Size: ", 0x0
ImageEditor.SIZE_VALSTR :
	db '1'
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
	db "Load", 0x0
ImageEditor.STR_SAVE :
	db "Save", 0x0
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
	dd 1
ImageEditor.redVal :
	dd 0x0
ImageEditor.greenVal :
	dd 0x0
ImageEditor.blueVal :
	dd 0x0
ImageEditor.color :
	dd 0xFF000000

ImageEditor.mainFromConsoleFile :
	pusha
		mov eax, iConsole2.commandStore
		mov [PromptBox.response], eax
		call ImageEditor.main
		call ImageEditor.loadFile
	popa
	ret
	
ImageEditor.promptLoadFile :
		push dword .promptLoadTitle
		push dword .promptLoadMessage
		push dword ImageEditor.loadFile
		call FileChooser.Prompt
	ret
	.promptLoadTitle :
		db "Open an Image", 0x0
	.promptLoadMessage :
		db "Open", 0x0
ImageEditor.loadFile :
	pusha
		mov ebx, 200*200*4+8;[Graphics.SCREEN_WIDTH]
		;imul ebx, [Graphics.SCREEN_HEIGHT]
		call ProgramManager.reserveMemory
		add ebx, 8
		mov edx, [ImageEditor.image]
		mov [edx+Image_source], ebx
		
		mov eax, [FileChooser.fileName]
		call Minnow4.getFilePointer
		mov ecx, [ImageEditor.image]
		mov ecx, [ecx+Image_source]
		mov edx, 200*200*4;[Graphics.SCREEN_WIDTH]
		;imul edx, [Graphics.SCREEN_HEIGHT]
		call Minnow4.readBuffer
		
		; should resize the window etx here
		
	popa
	ret
ImageEditor.promptSaveFile :
		push dword .promptSaveTitle
		push dword .promptSaveMessage
		push dword ImageEditor.saveFile
		call FileChooser.Prompt
	ret
	.promptSaveTitle :
		db "Save an Image", 0x0
	.promptSaveMessage :
		db "Save", 0x0
ImageEditor.saveFile :
	pusha
		mov edx, [ImageEditor.image]
		mov eax, [edx+Image_source]
		sub eax, 8
		mov ecx, [edx+Image_sw]
		shr ecx, 2	; so its in pixels
		mov [eax], ecx
		mov ebx, [edx+Image_sh]
		mov [eax+4], ebx
		imul ecx, ebx
		shl ecx, 2
		add ecx, 8	; ecx is the size of the buffer
		mov edx, ecx
		mov ecx, eax
		mov eax, [FileChooser.fileName]
		call Minnow4.getFilePointer
		cmp ebx, Minnow4.SUCCESS
			je .dontMake
		mov eax, [FileChooser.fileName]
		call Minnow4.createFile
		.dontMake :
		call Minnow4.writeBuffer
	popa
	ret

ImageEditor.getFileName :

ImageEditor.mouseHandlerFunc :

ImageEditor.decBrushSize :
		cmp dword [ImageEditor.brushSize], 1
			je .ret
		dec dword [ImageEditor.brushSize]
		pusha
			mov eax, ImageEditor.SIZE_VALSTR
			mov dword [eax], 0x0
			mov dword [eax+4], 0x0
			mov ebx, [ImageEditor.brushSize]
			call String.fromHex
		popa
	.ret :
	ret
ImageEditor.incBrushSize :
		cmp dword [ImageEditor.brushSize], 255
			je .ret
		inc dword [ImageEditor.brushSize]
		pusha
			mov eax, ImageEditor.SIZE_VALSTR
			mov dword [eax], 0x0
			mov dword [eax+4], 0x0
			mov ebx, [ImageEditor.brushSize]
			call String.fromHex
		popa
	.ret :
	ret
ImageEditor.decRedValue :
		cmp dword [ImageEditor.redVal], 0
			je .ret
		dec dword [ImageEditor.redVal]
		pusha
			mov eax, ImageEditor.RED_VALSTR
			mov dword [eax], 0x0
			mov dword [eax+4], 0x0
			mov ebx, [ImageEditor.redVal]
			call String.fromHex
		popa
		call ImageEditor.updateColorPreview
	.ret :
	ret
ImageEditor.incRedValue :
		cmp dword [ImageEditor.redVal], 255
			je .ret
		inc dword [ImageEditor.redVal]
		pusha
			mov eax, ImageEditor.RED_VALSTR
			mov dword [eax], 0x0
			mov dword [eax+4], 0x0
			mov ebx, [ImageEditor.redVal]
			call String.fromHex
		popa
		call ImageEditor.updateColorPreview
	.ret :
	ret
ImageEditor.decGreenValue :
		cmp dword [ImageEditor.greenVal], 0
			je .ret
		dec dword [ImageEditor.greenVal]
		pusha
			mov eax, ImageEditor.GREEN_VALSTR
			mov dword [eax], 0x0
			mov dword [eax+4], 0x0
			mov ebx, [ImageEditor.greenVal]
			call String.fromHex
		popa
		call ImageEditor.updateColorPreview
	.ret :
	ret
ImageEditor.incGreenValue :
		cmp dword [ImageEditor.greenVal], 255
			je .ret
		inc dword [ImageEditor.greenVal]
		pusha
			mov eax, ImageEditor.GREEN_VALSTR
			mov dword [eax], 0x0
			mov dword [eax+4], 0x0
			mov ebx, [ImageEditor.greenVal]
			call String.fromHex
		popa
		call ImageEditor.updateColorPreview
	.ret :
	ret
ImageEditor.decBlueValue :
		cmp dword [ImageEditor.blueVal], 0
			je .ret
		dec dword [ImageEditor.blueVal]
		pusha
			mov eax, ImageEditor.BLUE_VALSTR
			mov dword [eax], 0x0
			mov dword [eax+4], 0x0
			mov ebx, [ImageEditor.blueVal]
			call String.fromHex
		popa
		call ImageEditor.updateColorPreview
	.ret :
	ret
ImageEditor.incBlueValue :
		cmp dword [ImageEditor.blueVal], 255
			je .ret
		inc dword [ImageEditor.blueVal]
		pusha
			mov eax, ImageEditor.BLUE_VALSTR
			mov dword [eax], 0x0
			mov dword [eax+4], 0x0
			mov ebx, [ImageEditor.blueVal]
			call String.fromHex
		popa
		call ImageEditor.updateColorPreview
	.ret :
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
	;	mov ebx, [ImageEditor.image]
	;	mov edx, [ebx+Image_source]
	;	add edx, [Component.mouseEventX]
	;	mov ecx, [Component.mouseEventY]
	;	imul ecx, [ebx+Image_sw]
	;	add edx, ecx
	;	mov eax, [ImageEditor.color]
	;	mov dword [edx], eax
		
		mov eax, [ImageEditor.image]
		mov ebx, [eax+Image_w]
		shr ebx, 2
		mov ecx, [eax+Image_h]
		shr ecx, 2
		mov eax, [eax+Image_source]
		call L3gxImage.FromBuffer
		push ecx
		mov edx, [Component.mouseEventX]
		shr edx, 2
		push edx
		push dword [Component.mouseEventY]
		push dword [ImageEditor.brushSize]
		push dword [ImageEditor.brushSize]
		push dword [ImageEditor.color]
		call L3gx.fillRect
		
		mov ebx, [ImageEditor.image]
		call Component.RequestUpdate
	popa
	.ret :
	ret
