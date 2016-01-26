Video.display :
	pusha
	
		mov dword [Video.proccessRawFramecount], 0
		
		mov byte [INTERRUPT_DISABLE], 0xFF
			mov ah, [Dolphin.activeWindow]
			mov [Dolphin.currentWindow], ah
		
		mov eax, [Graphics.SCREEN_MEMPOS]
		mov ebx, [Graphics.SCREEN_HEIGHT]
		shr ebx, 1
		sub ebx, (Video.IMAGE_HEIGHT)/2
		imul ebx, [Graphics.SCREEN_WIDTH]
		add eax, ebx
		mov ebx, [Graphics.SCREEN_WIDTH]
		shr ebx, 1
		sub ebx, (Video.IMAGE_WIDTH*4)/2
		add eax, ebx
		mov [Video.outputBuffer], eax
		
		mov [rmATA.DMAread.dataBuffer], ecx
		mov eax, [os_imageDataBaseLBA]	; lba low
		mov bx, 0x0	; lba high
		mov edx, Video.IMAGE_WIDTH*Video.IMAGE_HEIGHT*4	; sectorcount
		call rmATA.DMAread;ToBuffer
		mov [console_testbuffer], ecx	; original image is in [console_testbuffer]
		
		mov eax, 0x9	; need to standardize
		mov ebx, console.test.FRAME_SIZE/0x200
		call Guppy.malloc
		;mov ebx, 0x7c00
		mov [rmATA.DMAread.dataBuffer], ebx
		mov eax, [os_imageDataBaseLBA]
		add eax, (Video.IMAGE_WIDTH*Video.IMAGE_HEIGHT*4)/0x200
		mov bx, 0
		mov edx, console.test.FRAME_SIZE
		
		console.test.loop :
		call Video.readData
		call Video.proccessRawFrame
		add eax, console.test.FRAME_SIZE/0x200
		call Keyboard.poll
		call Keyboard.getKey
		cmp bl, 0xfe
			jne console.test.loop
		
		mov byte [INTERRUPT_DISABLE], 0x00
		
	popa
	ret
console.test.FRAME_SIZE equ 0x200*48
Video.IMAGE_WIDTH	equ 1024/2
Video.IMAGE_HEIGHT	equ 576/2
Video.outputBuffer :
	dd 0x0
Video.proccessFrame :
pusha
	mov ebx, console.test.FRAME_SIZE
	console.test.proccessFrame.loop :
	mov eax, [ecx]	; eax: DATA | POSH | POSM | POSL
	and eax, 0xFFFFFF	; here check eax, if less than last then ensure that 5000/FPS tics have passed (wait until they have if not) to lock the FPS to the desired value
		cmp eax, [console.test.proccessFrame.lastVal]
			jg console.test.proccessFrame.cont
			pusha	; draw the frame to the screen
					mov eax, [console_testbuffer]
					mov ebx, [Graphics.SCREEN_MEMPOS]
					mov ecx, Video.IMAGE_WIDTH*4
					mov edx, Video.IMAGE_HEIGHT
					call Image.copy
				mov eax, [Clock.tics]
				sub eax, [console.test.proccessFrame.startTime]
				cmp eax, 5000/30	; 5000/FPS
					jge console.test.proccessFrame.onTimeOrSlow
				mov ebx, 5000/30	; the time the frame should be shown for
				sub ebx, eax	; subtract the time that has passed
				mov eax, ebx
				;call System.sleep	; and sleep for the remainder [nope because this freezes it up a lot??]
				console.test.proccessFrame.onTimeOrSlow :
				mov eax, [Clock.tics]
				mov [console.test.proccessFrame.startTime], eax
			popa
		console.test.proccessFrame.cont :
		mov [console.test.proccessFrame.lastVal], eax
	mov edx, [console_testbuffer]
	add edx, eax
	mov eax, [ecx]
	shr eax, 24
	mov [edx], al
	add ecx, 4
	sub ebx, 4
	cmp ebx, 0
		jg console.test.proccessFrame.loop
popa
ret

Video.proccessRawFrame :
pusha
mov eax, (Video.IMAGE_WIDTH*Video.IMAGE_HEIGHT*4)
sub eax, [Video.proccessRawFramecount]
cmp eax, console.test.FRAME_SIZE
	jle Video.proccessRawFrame.handleIntersection
; copy over entire buffer (from:0x3000 to:[console_testbuffer]+[Video.proccessRawFramecount] size:FRAME_SIZE)
		mov eax, 0x3000
		mov ebx, [console_testbuffer]
		add ebx, [Video.proccessRawFramecount]
		mov ecx, console.test.FRAME_SIZE
		mov esi, eax
		mov edi, ebx
		Video.proccessRawFrame.memloop_0 :
		movdqu xmm0, [esi]
		movdqu xmm1, [esi+0x10]
		movdqu xmm2, [esi+0x20]
		movdqu xmm3, [esi+0x30]
		movdqu xmm4, [esi+0x40]
		movdqu xmm5, [esi+0x50]
		movdqu xmm6, [esi+0x60]
		movdqu xmm7, [esi+0x70]
		movdqu [edi], xmm0
		movdqu [edi+0x10], xmm1
		movdqu [edi+0x20], xmm2
		movdqu [edi+0x30], xmm3
		movdqu [edi+0x40], xmm4
		movdqu [edi+0x50], xmm5
		movdqu [edi+0x60], xmm6
		movdqu [edi+0x70], xmm7
		add edi, 0x80
		add esi, 0x80
		sub ecx, 0x80
		cmp ecx, 0x0
			jg Video.proccessRawFrame.memloop_0
	mov ecx, [Video.proccessRawFramecount]
	add ecx, console.test.FRAME_SIZE
	mov [Video.proccessRawFramecount], ecx
jmp Video.proccessRawFrame.doneHandling
Video.proccessRawFrame.handleIntersection :
; copy over eax bytes of the buffer (from:0x3000 to:[console_testbuffer]+[Video.proccessRawFramecount] size:eax)
		mov ecx, eax
		mov esi, 0x3000
		mov edi, [console_testbuffer]
		add edi, [Video.proccessRawFramecount]
		Video.proccessRawFrame.memloop_1 :
			movdqu xmm0, [esi]
			movdqu xmm1, [esi+0x10]
			movdqu xmm2, [esi+0x20]
			movdqu xmm3, [esi+0x30]
			movdqu xmm4, [esi+0x40]
			movdqu xmm5, [esi+0x50]
			movdqu xmm6, [esi+0x60]
			movdqu xmm7, [esi+0x70]
			movdqu [edi], xmm0
			movdqu [edi+0x10], xmm1
			movdqu [edi+0x20], xmm2
			movdqu [edi+0x30], xmm3
			movdqu [edi+0x40], xmm4
			movdqu [edi+0x50], xmm5
			movdqu [edi+0x60], xmm6
			movdqu [edi+0x70], xmm7
			add edi, 0x80
			add esi, 0x80
			sub ecx, 0x80
			cmp ecx, 0x0
				jg Video.proccessRawFrame.memloop_1
pusha
	mov eax, [console_testbuffer]
	mov ebx, [Video.outputBuffer]
	mov ecx, Video.IMAGE_WIDTH*4
	mov edx, Video.IMAGE_HEIGHT
	call Video.imagecopy
	xor ecx, ecx
	mov [Video.proccessRawFramecount], ecx
popa
mov ecx, console.test.FRAME_SIZE
sub ecx, eax
; copy over ebx bytes of the buffer (from:0x3000+eax to:[console_testbuffer]+[Video.proccessRawFramecount]+eax size:ecx)
push ecx
		mov ebx, [console_testbuffer]
		add ebx, [Video.proccessRawFramecount]
		add ebx, eax
		add eax, 0x3000
		mov esi, eax
		mov edi, ebx
		Video.proccessRawFrame.memloop_2 :
			movdqu xmm0, [esi]
			movdqu xmm1, [esi+0x10]
			movdqu xmm2, [esi+0x20]
			movdqu xmm3, [esi+0x30]
			movdqu xmm4, [esi+0x40]
			movdqu xmm5, [esi+0x50]
			movdqu xmm6, [esi+0x60]
			movdqu xmm7, [esi+0x70]
			movdqu [edi], xmm0
			movdqu [edi+0x10], xmm1
			movdqu [edi+0x20], xmm2
			movdqu [edi+0x30], xmm3
			movdqu [edi+0x40], xmm4
			movdqu [edi+0x50], xmm5
			movdqu [edi+0x60], xmm6
			movdqu [edi+0x70], xmm7
			add edi, 0x80
			add esi, 0x80
			sub ecx, 0x80
			cmp ecx, 0x0
				jg Video.proccessRawFrame.memloop_2
pop ecx
	mov edx, [Video.proccessRawFramecount]
	add edx, ecx
	mov [Video.proccessRawFramecount], edx
Video.proccessRawFrame.doneHandling :
;	mov eax, ecx
;	mov ebx, console.test.FRAME_SIZE
;	mov ecx, [Video.proccessRawFramecount]
;	mov edx, [console_testbuffer]
;	add edx, ecx
;	Video.proccessRawFrame.loop :
;	push eax
;	mov eax, [eax]
;	mov [edx], eax
;	pop eax
;	add eax, 4
;	add edx, 4
;	cmp ecx, (Video.IMAGE_WIDTH*Video.IMAGE_HEIGHT*4)
;		jl Video.proccessRawFrame.cont
;	pusha	; draw the frame
;		mov eax, [console_testbuffer]
;		mov ebx, [Graphics.SCREEN_MEMPOS]
;		mov ecx, Video.IMAGE_WIDTH*4
;		mov edx, Video.IMAGE_HEIGHT
;		call Image.copy
;	popa
;	mov ecx, 0x0
;	mov edx, [console_testbuffer]
;	Video.proccessRawFrame.cont :
;	add ecx, 4
;	sub ebx, 4
;	cmp ebx, 0x0
;		jg Video.proccessRawFrame.loop
;	mov [Video.proccessRawFramecount], ecx
popa
ret
Video.proccessRawFramecount :
	dd 0x0
	
Video.imagecopy :	; eax = src, ebx = dest, ecx = width, edx = height
;pusha
push ebx
mov ebx, [Graphics.SCREEN_WIDTH]
sub ebx, ecx
mov [Video.imagecopy.tadd], ebx
pop ebx
mov esi, eax
mov edi, ebx
cld
; repeat height times
mov ebx,  ecx
Video.imagecopy.loop :
		movdqu xmm0, [esi]
		movdqu xmm1, [esi+0x10]
		movdqu xmm2, [esi+0x20]
		movdqu xmm3, [esi+0x30]
		movdqu xmm4, [esi+0x40]
		movdqu xmm5, [esi+0x50]
		movdqu xmm6, [esi+0x60]
		movdqu xmm7, [esi+0x70]
		movntdq [edi], xmm0
		movntdq [edi], xmm0
		movntdq [edi+0x10], xmm1
		movntdq [edi+0x20], xmm2
		movntdq [edi+0x30], xmm3
		movntdq [edi+0x40], xmm4
		movntdq [edi+0x50], xmm5
		movntdq [edi+0x60], xmm6
		movntdq [edi+0x70], xmm7
		add edi, 0x80
		add esi, 0x80
		sub ecx, 0x80
		cmp ecx, 0x0
			jg Video.imagecopy.loop
			add edi, ecx	; if it has gone negative make sure edi and esi are moved back
			add esi, ecx
mov ecx, ebx
add edi, [Video.imagecopy.tadd]

sub edx, 1
cmp edx, 0
	jg Video.imagecopy.loop
;popa
ret
Video.imagecopy.tadd :
	dd 0x0

Video.readData :
push bx
push eax
	mov dword [os_RealMode_functionPointer], Video.loadFunc
	mov [Video.ATAdata_low], eax
	and ebx, 0xFFFF
	mov [Video.ATAdata_high], ebx
	call os.hopToRealMode
	mov ecx, 0x3000
pop eax
pop bx
ret
[bits 16]
Video.loadFunc :
		xor di, di
		mov si, Video.ATAdata
		mov dl, 0x80
		mov ah, 0x42
		int 0x13
	ret
Video.ATAdata :
	db 0x10	; size of struct
	db 0
	dw console.test.FRAME_SIZE/0x200	; sectors to load
	dw 0x3000	; offs
	dw 0x0	; seg
	Video.ATAdata_low:
	dd 0x0
	Video.ATAdata_high:
	dd 0x0
[bits 32]

console_testval:
	dd 0x0
console_testbuffer :
	dd 0x0
console.test.proccessFrame.lastVal :
	dd 0x0
console.test.proccessFrame.startTime :
	dd 0x0