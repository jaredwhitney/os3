os.load :	; head number in ah, sector number in bh, sectors to read in bl, cylinder number in cx, edi is the location to read to, BROKEN RIGHT NOW
pusha

mov dx, 0x1f6
mov al, ah
and al, 0xF	; head is 1 nibble long
or al, 0xA0	; magic number required by disk, usually 0xA0
out dx, al

mov dx, 0x1f2
mov al, bl
out dx, al

mov dx, 0x1f3
mov al, bh
out dx, al

mov dx, 0x1f4
mov al, cl
out dx, al

mov dx, 0x1f5
mov al, ch
out dx, al

mov edx, 0x1f7
mov al, 0x20	; read command (retry on failiure)	[throws error!]
out dx, al

os.load.waitForDisk :
in al, dx
test al, 8		; tests for bit 4 (0b00001000), the buffer is not ready until the bit is 1
jz os.load.waitForDisk

	mov ebx, STRING.K
	call debug.println

mov ax, es	; force es (segment) to be 0
push ax
mov ax, 0
mov es, ax

mov ax, 256	; 256 words = 512 bytes = 0x200 bytes = 1 sector
mov bh, 0x0
mul bx		; 1 sector * number of sectors to be read


mov cx, ax	; cx is the number of times to repeat the read
mov dx, 0x1f0	; data port

rep insw	; do the actual reading

pop cx		; restore the value of es
mov es, cx

popa
ret

STRING.K :
db "K.", 0
