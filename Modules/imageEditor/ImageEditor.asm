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
		push dword (5+7*FONTWIDTH+10)*4
		push dword (5+(10+5)*0)
		push dword 25*4
		push dword 10
		call TextLine.Create
		mov eax, ecx
		call Grouping.Add
		
		push dword ImageEditor.STR_PLUS
		push dword ImageEditor.incBrushSize
		push dword (5+7*FONTWIDTH+35)*4
		push dword (5+(10+5)*0)
		push dword 10*4
		push dword 10
		call Button.Create
		mov eax, ecx
		call Grouping.Add
		
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
	db "???"
	times 4 dq 0x0
ImageEditor.STR_COLOR :
	db "Color: ", 0x0
ImageEditor.STR_RED :
	db "Red: ", 0x0
ImageEditor.STR_GREEN :
	db "Green: ", 0x0
ImageEditor.STR_BLUE :
	db "Blue: ", 0x0
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
ImageEditor.brushSize :
	dd 0x0
ImageEditor.redVal :
	dd 0x0
ImageEditor.greenVal :
	dd 0x0
ImageEditor.blueVal :
	dd 0x0

ImageEditor.loadFile :

ImageEditor.saveFile :

ImageEditor.getFileName :

ImageEditor.mouseHandlerFunc :

ImageEditor.decBrushSize :
		dec dword [ImageEditor.brushSize]
	ret
ImageEditor.incBrushSize :
		inc dword [ImageEditor.brushSize]
	ret