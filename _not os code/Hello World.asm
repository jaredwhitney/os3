[bits 32]
dd endt-start
db "TEXT"
db "HeloWrld"
start :
db "Hello world, I am a text file :)", 0x0A
db "This is on a new line!", 0x0A, 0x0A, 0x0A
db "As is this :O"
endt :
;	loading text files through View is currently VERY, VERY broken :(
;	not anymore! :)
