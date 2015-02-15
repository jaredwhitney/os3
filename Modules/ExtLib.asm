[bits 32]
writeLib :
pusha
mov eax, 0x2000	; where the library is stored
mov ecx, funcNames
writeLib.loop :
mov ebx, [ecx]
cmp ebx, 0x0
je writeLib.done
mov [eax], ebx
add eax, 4
add ecx, 4
jmp writeLib.loop
writeLib.done :
popa
ret

funcNames:
dd os.setEcatch, retfunc, Dolphin.create, Dolphin.textUpdate, Dolphin.clear, clearScreenG, debug.print, debug.println, debug.num, debug.clear, 0x0