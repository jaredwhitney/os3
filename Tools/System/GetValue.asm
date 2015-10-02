

System.getValue :	; val in ebx, returns in ecx
	imul ebx, 4
	add ebx, System.valueLocations
	mov ecx, [ebx]
	mov ecx, [ecx]
ret

System.valueLocations :
	dd Graphics.VESA_MODE, Graphics.SCREEN_WIDTH, Graphics.SCREEN_HEIGHT, Graphics.bytesPerPixel, Guppy.totalRAM, Guppy.usedRAM, Clock.tics, Graphics.CARDNAME, ProgramManager.PnumCounter