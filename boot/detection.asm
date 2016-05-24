[bits 16]	; Should only be used in 16-bit real mode


;	A simple function to detect continuous RAM (unreliable, should not be used)

	rm_detectRAM :
		xor bx, bx
		mov ax, 0xe801	; BIOS detect continuous ram
		int 0x15
		cmp bx, 0x0
			jne rmdramnc
		mov bx, dx
		rmdramnc :
		mov [0x10C0], bx
	ret

	
;	A function to return a memory map of the entire computer's RAM

	rmDetectAllRAM :
		pusha
			mov si, 0x0
			mov di, 0x3050
			xor ebx, ebx
			mov edx, rmDetectAllRAM.MAGIC_NUMBER
			mov dword [0x3050-4], 0x0
			.loop :
			inc dword [0x3050-4]
			mov eax, 0xe820
			mov ecx, 24
			int 0x15
			cmp eax, rmDetectAllRAM.MAGIC_NUMBER
				jne .fail
			jc .done
			cmp ebx, 0x0
				je .done
			add di, 20
			jmp .loop
		.done :
		.fail :
		popa
		ret

RAMMap :
	dd 0x0

region_base		equ 0x0		; qword
region_length	equ 0x8		; qword
region_type		equ 0x10	; dword
region_attribs	equ 0x14	; dword

rmDetectAllRAM.MAGIC_NUMBER	equ 0x534d4150


[bits 32]	; Make sure that whichever file is included after this one is 32-bits unless otherwise specified.
