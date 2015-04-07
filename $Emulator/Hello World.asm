[bits 32]
dd endt-start
db "TEXT"
db "HELOWRLD"
start :
db "Hello world, I am a text file :)", 0xA0
db "This is on a new line!", 0xA0
db "As is this :O"
endt :
;	loading text files through View is currently VERY, VERY broken :(
;	not anymore! :)
