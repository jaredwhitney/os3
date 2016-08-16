; DEBUG's CURRENT FORM WILL NO LONGER
; APPEAER IN OS3
debug.init :
ret

debug.println :
cmp dword [DisplayMode], MODE_TEXT
	je TextMode.println
	ret
	
debug.log.system :
cmp dword [DisplayMode], MODE_TEXT
	je TextMode.println
	ret
	
debug.log.info :
cmp dword [DisplayMode], MODE_TEXT
	je TextMode.println
	ret
	
debug.log.error :
cmp dword [DisplayMode], MODE_TEXT
	je TextMode.println
	ret

debug.print :	; string loc in ebx
cmp dword [DisplayMode], MODE_TEXT
	je TextMode.print
	ret
	
debug.update :
	ret

debug.clear :
cmp dword [DisplayMode], MODE_TEXT
	je TextMode.clearScreen
	ret

debug.flush :
ret

debug.num :		; num in ebx
cmp dword [DisplayMode], MODE_TEXT
	je console.numOut
	ret
	
debug.cprint :	; char in al
cmp dword [DisplayMode], MODE_TEXT
	je TextMode.cprint
	ret

debug.newl :
cmp dword [DisplayMode], MODE_TEXT
	je TextMode.newline
	ret
	
debug.setColor :
	ret
	
debug.restoreColor :
	ret
	
debug.useFallbackColor :
	ret
	
debug.internal.fallcheck :
	ret
	
debug.toggleView :
	ret