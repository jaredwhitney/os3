init_GDT : ; AAH DONT UNDERSTAND MUCH OF THIS SECTION D:

GDTnull : ; okay get this part
dd 0x0 ; null required to catch improper
dd 0x0 ; porting of old registers

GDTcode :
dw 0x0ffff ; upper limits
dw 0x0 ; define base
db 0x0 ; define it again...
db 10011010b ; 1st+type flags NOTE 100 changed to 111 to fix permission issues
db 11001111b ; 2nd flags, limit for 2nd time
db 0x0 ; and base again???

GDTdata : ; apparently only type flags different from code sector
dw 0xffff ; upper limits again
dw 0x0 ; base
db 0x0 ; base (2nd time)
db 10010010b ; 5th bit is only changed, specifies data storage vs. executable NOTE 100 changed to 111 to fix permission issuescode
db 11001111b ; second flags again, repeated limit
db 0x0 ; base (3rd time)

GDTend : ; to allow assembler to calculate GDT size

GDTdescriptor :
dw GDTend - init_GDT - 1
dd init_GDT

; defining constants to make segment offsets
; easier to work with during/after the switch

segOFFcode equ GDTcode - init_GDT ; offset from the start of the GDT to the code segment
segOFFdata equ GDTdata - init_GDT ; offset from the start of the GDT to the data segment