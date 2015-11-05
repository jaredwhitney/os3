; ******************************************************* #header

; Guppy2.asm
; ---------------------------------------------
; Memory management using a linked list to store
; allocated memory sections; is able to compress
; memory chunks if space becomes badly needed,
; at which point all runnning programs will be
; notified to reconstruct any pointers that they
; had stored.
; This functionality will be incorporated per
; default in OrcaHLL, but the user must handle
; any pointers which they manage themselves.
; If a program is unable to feasably handle such
; an invalidation, it should terminated upon
; recieving the WARN_M2_PRESHUFFLE message.
; NOT YET IMPLEMENTED IN OS:
; 	kernel.broadcastMessage : broadcast a message to all running programs
;	Catfish.notify : send a notification to the user

; ******************************************************* #main

Guppy2.malloc :	; size in eax, returns offs
pusha
	
popa
ret

Guppy2.dealloc :	; offs in eax
pusha
	
popa
ret

Guppy2.init :
pusha
	; zero out the memory table
	mov eax, GUPPY2_TABLE
	mov ebx, MEMORY_START-GUPPY2_TABLE
	call Buffer.clear
popa
ret


GUPPY2_TABLE	equ 0x0a10000
MEMORY_START	equ 0x1000000

; ******************************************************* #functions

; Table
G2.getNewEntryPos :	; returns offs
pusha
	
popa
ret

; Node
G2.checkBlankSpace :	; offs in eax, returns space available
pusha
	
popa
ret

; Main
G2.findOpenSpace :	; size in eax, returns offs
pusha

popa
ret

; Main
G2.compressAll :
pusha
	call G2.sendShuffleWarn
	
	call G2.messageShuffleFinished
popa
ret

; Table
G2.compressTable :
pusha
	
popa
ret

; ******************************************************* #integration

G2.sendShuffleWarn :
pusha
	mov ebx, MESSAGE.WARN_M2_PRESHUFFLE
	call kernel.broadcastMessage
popa
ret

G2.messageShuffleFinished :
pusha
	mov ebx, G2.SHUFFLE_MESSAGE
	call Catfish.notify
popa
ret

G2.SHUFFLE_MESSAGE :
	db "Warning", 0, "The computer's memory has been compressed. If any program appears to be malfunctioning please terminate it immediately.", 0
