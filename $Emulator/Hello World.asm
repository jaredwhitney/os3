[bits 32]
dd endt-start
db "TEXT"
db "HELOWRLD"
start :
db "Hello world, I am a text file :)", 0x0, 0x0, 0x0, 0x0
times 510-($-$$) db 0
endt :
;	loading text files through View is currently VERY, VERY broken :(
