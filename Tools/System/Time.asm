RTC.recalc :
	pusha
	mov al, 0x9
	call RTC.readValSub
	mov [Time.year], al
	mov al, 0x8
	call RTC.readValSub
	mov [Time.month], al
	mov al, 0x7
	call RTC.readValSub
	mov [Time.day], al
	mov al, 0x4
	call RTC.readValSub
	mov [Time.hour], al
	mov al, 0x2
	call RTC.readValSub
	mov [Time.minute], al
	mov al, 0x0
	call RTC.readValSub
	mov [Time.second], al
	popa
	ret
	RTC.readValSub :
		mov dx, 0x70
		or al, 0b10000000
		out dx, al
		mov dx, 0x71
		in al, dx
		ret
	
RTC.getYear :
	call RTC.recalc
	mov bl, [Time.year]
	ret

RTC.getMonth :
	call RTC.recalc
	mov bl, [Time.month]
	
RTC.getDay :
	call RTC.recalc
	mov bl, [Time.day]
	ret

RTC.getHour :
	call RTC.recalc
	mov bl, [Time.hour]
	ret

RTC.getMinute :
	call RTC.recalc
	mov bl, [Time.minute]
	ret

RTC.getSecond :
	call RTC.recalc
	mov bl, [Time.second]
	ret

Time.printToConsole :
	pusha
	mov ebx, Time.preface
	call console.print
	xor ebx, ebx
	call RTC.getHour
		cmp ebx, 0x12
			jg Time.printToConsole.doPM
				push ebx
					mov ebx, Time.am
					mov [Time.swapped], ebx
				pop ebx
		jmp Time.printToConsole.hhandleDone
		Time.printToConsole.doPM :
			push ebx
				mov ebx, Time.pm
				mov [Time.swapped], ebx
			pop ebx
			cmp ebx, 0x20
				jl Time.printToConsole.doPM.kgo
			cmp ebx, 0x21
				jg Time.printToConsole.doPM.kgo
			sub ebx, 0x6
			Time.printToConsole.doPM.kgo :
			sub ebx, 0x12
	Time.printToConsole.hhandleDone :
	call console.numOut
	mov ah, 0xFF
	mov al, ':'
	call console.cprint
	call RTC.getMinute
	cmp ebx, 0x10
		jge Time.ptC.noexMin
	mov al, '0'
	call console.cprint
	Time.ptC.noexMin :
	call console.numOut
		mov ebx, [Time.swapped]
	call console.print
	mov al, ','
	call console.cprint
	mov al, ' '
	call console.cprint
	xor ebx, ebx
	call RTC.getYear
	add ebx, 0x2000
	call console.numOut
	call console.newline
	popa
	ret

Time.year :
	db 0
Time.month :
	db 0
Time.day :
	db 0
Time.hour :
	db 0
Time.minute :
	db 0
Time.second :
	db 0
Time.preface :
	db "System Time:  ", 0
Time.am :
	db "am", 0
Time.pm :
	db "pm", 0
Time.swapped :
	dd 0x0