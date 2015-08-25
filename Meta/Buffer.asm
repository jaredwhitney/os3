Buffer.clear :	; buffer pos in eax, size in ebx
pusha
	mov dl, 0x0
	Buffer.clear.loop :
	mov [eax], dl
	add eax, 1
	sub ebx, 1
	cmp ebx, 0x0
		jg Buffer.clear.loop
popa
ret