Guppy2.TABLE_POSITION	equ 0xAA0000	; use same actual # as in Guppy

Debug.methodTraceStackBase :
	dd 0xA80000
Debug.methodTraceStack :
	dd 0xA80000
	
Debug.methodTraceStackBase2 :
	dd 0xA90000
Debug.methodTraceStack2 :
	dd 0xA90000

Guppy2.init :
	methodTraceEnter
	pusha
		
		mov eax, Guppy2.TABLE_POSITION
		mov ebx, 0x10000
		call Buffer.clear
		
		mov eax, 0x0
		mov ebx, 0xFFFFFFFF
		mov ecx, Guppy2_Entry.TYPE_FREE
		call Guppy2.setBlockNoChecks
		
		mov eax, 0x0		; should use actual memory map
		mov ebx, S2_CODE_LOC+KERNEL_SIZE*0x200
		mov ecx, Guppy2_Entry.TYPE_SYSTEM_RESERVED
		call Guppy2.setBlock
		
;		call Guppy2.proccessMemoryMap	; no memory map present atm
		
		mov eax, [Debug.methodTraceStackBase]
		mov ebx, 0x30000
		mov ecx, Guppy2_Entry.TYPE_SYSTEM_RESERVED
		call Guppy2.setBlock
		
		push dword Guppy2.COMMAND_PRINT_BLOCKS
		call iConsole2.RegisterCommand
		
		push dword Guppy2.COMMAND_MALLOC_TEST
		call iConsole2.RegisterCommand
		
	popa
	methodTraceLeave
	ret

Guppy2.proccessMemoryMap :	; dword 0x3050-4 = size, 0x3050 on = list
	methodTraceEnter
	pusha
		mov edx, [0x3050-4]
		mov ecx, 0x3050
		.loop :
		cmp edx, 0
			je .done
		
				push ecx
					mov eax, [ecx+0x0]
					mov ebx, [ecx+0x8]
					mov ecx, Guppy2_Entry.TYPE_UNUSABLE
					call Guppy2.setBlock
				pop ecx
		
		add ecx, 0x14
		dec edx
		jmp .loop
		.done :
	popa
	methodTraceLeave
	ret

Guppy2.malloc :	; ebx = size : ebx = pos
	methodTraceEnter
	push ecx
	push eax
	push edx
		cmp ebx, 0
			je .kret
		mov [.size], ebx
		call Guppy2.getFreeMemoryRegion
		mov ecx, Guppy2_Entry.TYPE_IN_USE
		call Guppy2.setBlock
		mov ebx, eax
		mov eax, [.size]
		xchg eax, ebx
		call Buffer.clear
		xchg eax, ebx
	.kret :
	pop edx
	pop eax
	pop ecx
	methodTraceLeave
	ret
	.size :
		dd 0x0

Guppy2.mallocPageAligned :	; ebx = size : ebx = pos
	methodTraceEnter
	push ecx	; WHICH IS BROKEN SOMEHOW D:
	push eax
		cmp ebx, 0
			je .kret
		mov [.size], ebx
		add ebx, 0x1000
		call Guppy2.getFreeMemoryRegion
		and eax, ~0xFFF ; or whatever
		add eax, 0x1000
		sub ebx, 0x1000
		mov ecx, Guppy2_Entry.TYPE_IN_USE
		call Guppy2.setBlock
		mov ebx, eax
		mov eax, [.size]
		xchg eax, ebx
		call Buffer.clear
		xchg eax, ebx
	.kret :
	pop eax
	pop ecx
	methodTraceLeave
	ret
	.size :
		dd 0x0

Guppy2.free :	; ebx = pos
	methodTraceEnter
	pusha
		mov eax, [Guppy2.tableBase]
		.loop :
		cmp [eax+Guppy2.Entry_pos], ebx
			je .foundBlock
		mov eax, [eax+Guppy2.Entry_nextPointer]
		cmp eax, null
			je .ret
		jmp .loop
		.foundBlock :
		mov ebx, eax
		call Guppy2.markFreeAndMerge ;call Guppy2.deleteNode
	.ret :
	popa
	methodTraceLeave
	ret

Guppy2.getRegionEntry :	; ecx=loc : ecx=entry
	methodTraceEnter
	push eax
	push edx
		mov eax, [Guppy2.tableBase]
		.loop :
		mov edx, [eax+Guppy2.Entry_pos]
		cmp edx, ecx
			ja .notFoundBlock
		add edx, [eax+Guppy2.Entry_size]
		cmp edx, ecx
			jb .notFoundBlock
		jmp .aret
		.notFoundBlock :
		mov eax, [eax+Guppy2.Entry_nextPointer]
		cmp eax, null
			je .aret
		jmp .loop
		.aret :
		mov ecx, eax
	pop edx
	pop eax
	methodTraceLeave
	ret

Guppy2.COMMAND_MALLOC_TEST :
	dd .mallocStr
	dd Guppy2.mallocTest
	dd null
	.mallocStr :
		db "mallocTest", 0
	Guppy2.mallocTest :
		methodTraceEnter
		pusha
			mov ebx, 0x100000
			call Guppy2.malloc
			mov [.l1], ebx
	;		mov ebx, 0x100000
	;		call Guppy2.malloc
	;		mov [.l2], ebx
	;		mov ebx, 0x100000
	;		call Guppy2.mallocPageAligned
	;		mov [.l3], ebx
	;		mov ebx, 0x7
	;		call Guppy2.malloc
	;		mov [.s1], ebx
	;		mov ebx, 0x9D
	;		call Guppy2.malloc;PageAligned
	;		mov [.s2], ebx
	;		mov ebx, 0xABCDEF0
	;		call Guppy2.malloc
	;		mov [.l4], ebx
			
			mov dword [.l1+0xC7654], 0xDEADF145
		;	mov dword [.l2+0x7654], 0xDEADF145
		;	mov dword [.l3+0xFFFFC], 0xDEADF145
		;	mov dword [.l4], 0xDEADF145
		;	mov dword [.s1+3], 0x0BA5ED07
		;	mov dword [.s2+0xCDEF0], 0x0BA5ED07
			
;			cmp dword [.l1+0xC7654], 0xDEADF145
;				jne kernel.halt
;			cmp dword [.l2+0x7654], 0xDEADF145
;				jne kernel.halt
;		;	cmp dword [.l3+0xFFFFC], 0xDEADF145
;		;		jne kernel.halt
;			cmp dword [.l4], 0xDEADF145
;				jne kernel.halt
;			cmp dword [.s1+3], 0x0BA5ED07
;				jne kernel.halt
;		;	cmp dword [.s2+0xCDEF0], 0x0BA5ED07
;		;		jne kernel.halt
			
	;		mov ebx, [.l3]
	;		call Guppy2.free
	;		mov ebx, [.s2]
	;		call Guppy2.free
			mov ebx, [.l1]
			call Guppy2.free
	;		mov ebx, [.l4]
	;		call Guppy2.free
	;		mov ebx, [.s1]
	;		call Guppy2.free
	;		mov ebx, [.l2]
	;		call Guppy2.free
		popa
		methodTraceLeave
		ret
	.l1 :
		dd 0x0
	.l2 :
		dd 0x0
	.l3 :
		dd 0x0
	.l4 :
		dd 0x0
	.s1 :
		dd 0x0
	.s2 :
		dd 0x0

Guppy2.COMMAND_PRINT_BLOCKS :
	dd .printBlocksStr
	dd Guppy2.printBlocks
	dd null
	.printBlocksStr :
		db "G2printBlocks", 0

Guppy2.printBlocks :
	methodTraceEnter
	pusha
		mov eax, [Guppy2.tableBase]
	;;	mov edx, 2
		.loop :
	;		; echo block pos:
	;		push dword .STR_BLOCKPOS
	;		call iConsole2.Echo
	;		; echohex block pos
	;		push eax
	;		call iConsole2.EchoHex
							cmp dword [eax+Guppy2.Entry_type], Guppy2_Entry.TYPE_FREE
								jne .noprint
			; echo pos:
			push dword .STR_POS
			call iConsole2.Echo
			; echohex pos
			push dword [eax+Guppy2.Entry_pos]
			call iConsole2.EchoHex
			; echo size:
			push dword .STR_SIZE
			call iConsole2.Echo
			; echohex size
			push dword [eax+Guppy2.Entry_size]
			call iConsole2.EchoHex
			; echo type:
			push dword .STR_TYPE
			call iConsole2.Echo
			; echo type
		cmp dword [eax+Guppy2.Entry_type], Guppy2_Entry.TYPE_IN_USE
			jne .notInUse
		push dword .BLOCK_IN_USE
		call iConsole2.Echo
		jmp .typeOutDone
		.notInUse :
		cmp dword [eax+Guppy2.Entry_type], Guppy2_Entry.TYPE_FREE
			jne .notFree
		push dword .BLOCK_IS_FREE
		call iConsole2.Echo
		jmp .typeOutDone
		.notFree :
		cmp dword [eax+Guppy2.Entry_type], Guppy2_Entry.TYPE_SYSTEM_RESERVED
			jne .notSystem
		push dword .BLOCK_IS_SYSTEM
		call iConsole2.Echo
		jmp .typeOutDone
		.notSystem :
		cmp dword [eax+Guppy2.Entry_type], Guppy2_Entry.TYPE_UNUSABLE
			jne .notUnusable
		push dword .BLOCK_IS_UNUSABLE
		call iConsole2.Echo
		jmp .typeOutDone
		.notUnusable :
		push dword .BLOCK_TYPE_UNKNOWN
		call iConsole2.Echo
		.typeOutDone :
	;		; echo next:
	;		push dword .STR_NEXT
	;		call iConsole2.Echo
	;		; echohex next
	;		push dword [eax+Guppy2.Entry_nextPointer]
	;		call iConsole2.EchoHex
			push dword .STR_NEWLINE
			call iConsole2.Echo
											.noprint :
		mov eax, [eax+Guppy2.Entry_nextPointer]
	;;	dec edx
		cmp eax, null
			jne .loop
	popa
	methodTraceLeave
	ret
	.BLOCK_IN_USE :
		db "Allocated space", 0
	.BLOCK_IS_FREE :
		db "Free block", 0
	.BLOCK_IS_SYSTEM :
		db "Unusable [system reserved]", 0
	.BLOCK_IS_UNUSABLE :
		db "Unusable [unspecified]", 0
	.BLOCK_TYPE_UNKNOWN :
		db "Unrecognized block type", 0
;	.STR_BLOCKPOS :
;		db newline, "BLK: ", 0
	.STR_POS :
		db newline, "pos: ", 0
	.STR_SIZE :
		db newline, "size: ", 0
	.STR_TYPE :
		db newline, "type: ", 0
;	.STR_NEXT :
;		db newline, "next: ", 0
	.STR_NEWLINE :
		db newline, 0

Guppy2.getFreeMemoryRegion :	; size in ebx : eax
	methodTraceEnter
		mov eax, [Guppy2.tableBase]
		.loop :
		cmp dword [eax+Guppy2.Entry_size], null
			je .ret
		cmp dword [eax+Guppy2.Entry_type], Guppy2_Entry.TYPE_FREE
			jne .keepLooking
		cmp [eax+Guppy2.Entry_size], ebx
			jae .foundFreeSpace
		.keepLooking :
		mov eax, [eax+Guppy2.Entry_nextPointer]
		cmp eax, null
			jne .loop
		call Guppy2.throwFatalError
		.foundFreeSpace :
		mov eax, [eax+Guppy2.Entry_pos]
	.ret :
	methodTraceLeave
	ret

Guppy2.getFreeMemorySize :	; : ecx
	methodTraceEnter
	push eax
		xor ecx, ecx
		mov eax, [Guppy2.tableBase]
		.loop :
		cmp dword [eax+Guppy2.Entry_size], null
			je .ret
		cmp dword [eax+Guppy2.Entry_type], Guppy2_Entry.TYPE_FREE
			jne .notFree
		add ecx, [eax+Guppy2.Entry_size]
		.notFree :
		mov eax, [eax+Guppy2.Entry_nextPointer]
		cmp eax, null
			jne .loop
	.ret :
	pop eax
	methodTraceLeave
	ret

Guppy2.setBlock :
	methodTraceEnter
	pusha
		call Guppy2.setBlockMain
		call Guppy2.runOverlapTests
	popa
	methodTraceLeave
	ret
Guppy2.setBlockNoChecks :
	methodTraceEnter
	pusha
		call Guppy2.setBlockMain
	popa
	methodTraceLeave
	ret

Guppy2.setBlockMain :
	methodTraceEnter
		
		mov edx, ecx
		
		; Find an open place to place the new block
		call Guppy2.getFirstOpenSlot
		
		; Place the new block in
		mov [ecx+Guppy2.Entry_pos], eax
		mov [ecx+Guppy2.Entry_size], ebx
		mov [ecx+Guppy2.Entry_type], edx
		mov dword [ecx+Guppy2.Entry_nextPointer], null
		;;;mov [.newEntry], ecx
		
		
		mov [Guppy2.runOverlapTests.start], eax
		add eax, ebx
;;		sub eax, 1
		mov [Guppy2.runOverlapTests.end], eax
		
		cmp dword [Guppy2.tableBase], null
			jne .notNull
		mov [Guppy2.tableBase], ecx
		jmp .linkDone
		.notNull :
		mov ebx, [Guppy2.tableBase]
		mov [ecx+Guppy2.Entry_nextPointer], ebx
		mov [Guppy2.tableBase], ecx
		.linkDone :
		
	methodTraceLeave
	ret

Guppy2.runOverlapTests : ; Traverse the list and modify or delete conflicting entries
	methodTraceEnter
		mov eax, [Guppy2.tableBase]
		mov eax, [eax+Guppy2.Entry_nextPointer]
		mov ecx, [.start]
		mov edx, [.end]
		.loop :
		cmp eax, null
			je .ret
		
			;; 5 seperate cases:
			;	non-intersecting: do nothing
			;	fully overlapping: delete
			;	fully inside: split into 2 entries
			;	overlapping start: shrink from start
			;	overlapping end: shrink size
			mov ebx, [eax+Guppy2.Entry_pos]
			add ebx, [eax+Guppy2.Entry_size]
;;			sub ebx, 1
			cmp [eax+Guppy2.Entry_pos], edx
				jae .fnointersect
			cmp ecx, ebx
				jae .fnointersect
			cmp [eax+Guppy2.Entry_pos], ecx
				jbe .notCase2
			cmp edx, ebx
				jbe .notCase2
			; is case 2 here
			call Guppy2.handleCase2
			jmp .ret
			.notCase2 :
			cmp [eax+Guppy2.Entry_pos], ecx
				jb .notCase4
			cmp edx, [eax+Guppy2.Entry_pos]
				jb .notCase4
			cmp ebx, edx
				jbe .notCase4
			; is case 4 here
			call Guppy2.handleCase4
			jmp .ret
			.notCase4 :
			cmp ecx, [eax+Guppy2.Entry_pos]
				jb .notCase3
			cmp ebx, edx
				jb .notCase3
			; is case 3 here
			call Guppy2.handleCase3
			jmp .ret
			.notCase3 :
			cmp ecx, [eax+Guppy2.Entry_pos]
				jb .notCase5
			cmp ebx, ecx
				jb .notCase5
			cmp edx, ebx
				jbe .notCase5
			; is case 5 here
			call Guppy2.handleCase5
			jmp .ret
			.notCase5 :
			call Guppy2.throwFatalError
			;;
		.fnointersect :
		mov eax, [eax+Guppy2.Entry_nextPointer]
		jmp .loop
		
		
	.ret :
	methodTraceLeave
	ret
	.start :
		dd 0x0
	.end :
		dd 0x0

; eax is the node, Guppy2.setBlock.start, Guppy2.setBlock.end
Guppy2.handleCase2 :
	methodTraceEnter
	pusha
		mov ebx, eax
		call Guppy2.deleteNode
		
		push dword .s
		call iConsole2.Echo
	popa
	methodTraceLeave
	ret
	.s :
		db "Case 2 allocation.", newline, 0
Guppy2.handleCase3 :
	methodTraceEnter
	pusha
		
		; Handles the part before
		mov ebx, [Guppy2.runOverlapTests.start]
		sub ebx, [eax+Guppy2.Entry_pos]
			mov edx, [eax+Guppy2.Entry_size]
		mov [eax+Guppy2.Entry_size], ebx
		
		; Handles the part after
		mov ebx, [eax+Guppy2.Entry_pos]
		add ebx, edx
		sub ebx, [Guppy2.runOverlapTests.end]		; size
		mov ecx, [eax+Guppy2.Entry_type]	; type
		mov eax, [Guppy2.runOverlapTests.end]		; start
		call Guppy2.setBlockNoChecks
		
;		push dword .s
;		call iConsole2.Echo
	popa
	methodTraceLeave
	ret
;	.s :
;		db "Case 3 allocation.", newline, 0
Guppy2.handleCase4 :
	methodTraceEnter
	pusha
		mov edx, [Guppy2.runOverlapTests.end]
		sub edx, [eax+Guppy2.Entry_pos]
		sub [eax+Guppy2.Entry_size], edx
		
		mov ebx, [Guppy2.runOverlapTests.end]
		mov [eax+Guppy2.Entry_pos], ebx
		
;		push dword .s
;		call iConsole2.Echo
	popa
	methodTraceLeave
	ret
;	.s :
;		db "Case 4 allocation.", newline, 0
Guppy2.handleCase5 :
	methodTraceEnter
	pusha
		mov edx, [eax+Guppy2.Entry_pos]
		add edx, [eax+Guppy2.Entry_size]
		sub edx, [Guppy2.runOverlapTests.start]
		sub [eax+Guppy2.Entry_size], edx
		
;		push dword .s
;		call iConsole2.Echo
	popa
	methodTraceLeave
	ret
;	.s :
;		db "Case 5 allocation.", newline, 0

Guppy2.deleteNode :	; node in ebx
	methodTraceEnter
	pusha
	;	call SysHaltScreen.show
		mov edx, [ebx+Guppy2.Entry_nextPointer]
		mov eax, [Guppy2.tableBase]
		cmp dword [eax+Guppy2.Entry_size], null
			jne .keepGoing1
		call Guppy2.throwFatalError
		jmp .ret
		.keepGoing1 :
		cmp eax, ebx
			jne .baseNotMatch
		mov [Guppy2.tableBase], edx
		jmp .ret
		.baseNotMatch :
		.loop :
		mov eax, [eax+Guppy2.Entry_nextPointer]
		cmp [eax+Guppy2.Entry_nextPointer], ebx
			je .foundBefore
		cmp dword [eax+Guppy2.Entry_nextPointer], null
			jne .loop
		mov edx, [ebx+Guppy2.Entry_nextPointer]
		mov [Guppy2.tableBase], edx
		jmp .ret
		;;;call Guppy2.throwFatalError
		.foundBefore :
		mov edx, [ebx+Guppy2.Entry_nextPointer]
		mov [eax+Guppy2.Entry_nextPointer], edx
	.ret :
	popa
	methodTraceLeave
	ret

Guppy2.getFirstOpenSlot :	; : ecx
	methodTraceEnter
	push eax
		mov eax, Guppy2.TABLE_POSITION
		.loop :
		cmp dword [eax+Guppy2.Entry_size], null
			je .foundFreeSlot
		add eax, Guppy2.EntrySize
		jmp .loop
		.foundFreeSlot :
		mov ecx, eax
	pop eax
	methodTraceLeave
	ret

Guppy2.markFreeAndMerge :
	methodTraceEnter
	pusha
		; ebx is node to merge into others, eax select from all
		mov eax, [Guppy2.tableBase]
		mov dword [.counter], 0
		.loop :
		cmp dword [eax+Guppy2.Entry_type], Guppy2_Entry.TYPE_FREE
			jne .dontBother
		mov edx, [eax+Guppy2.Entry_pos]
		add edx, [eax+Guppy2.Entry_size]
		cmp edx, [ebx+Guppy2.Entry_pos]
			jne .noMergeToEnd
		mov ecx, [ebx+Guppy2.Entry_size]
		add [eax+Guppy2.Entry_size], ecx
		inc dword [.counter]
		.noMergeToEnd :
		mov edx, [ebx+Guppy2.Entry_pos]
		add edx, [ebx+Guppy2.Entry_size]
		cmp edx, [eax+Guppy2.Entry_pos]
			jne .noMergeToStart
		mov ecx, [ebx+Guppy2.Entry_size]
		sub [eax+Guppy2.Entry_pos], ecx
		add [eax+Guppy2.Entry_size], ecx
		inc dword [.counter]
		.noMergeToStart :
		.dontBother :
		mov eax, [eax+Guppy2.Entry_nextPointer]
		cmp eax, null
			jne .loop
		cmp dword [.counter], 0
			je .dontDelete
		call Guppy2.deleteNode
		jmp .kret
		.dontDelete :
		mov dword [ebx+Guppy2.Entry_type], Guppy2_Entry.TYPE_FREE
		.kret :
	popa
	methodTraceLeave
	ret
	.counter :
		dd 0x0

Guppy2.throwFatalError :
	methodTraceEnter
	pusha
		mov eax, SysHaltScreen.KILL
		mov ebx, GUPPY2_FATALERROR
		mov ecx, 4
		call SysHaltScreen.show
	popa
	methodTraceLeave
	ret
GUPPY2_FATALERROR :
	db "[Guppy2] Fatal Error.", 0

Guppy2.tableBase :
	dd null


Guppy2.EntrySize		equ 0x10

	Guppy2.Entry_pos		equ 0x0
	Guppy2.Entry_size		equ 0x4
	Guppy2.Entry_type		equ 0x8
	Guppy2.Entry_nextPointer	equ 0xC


Guppy2_Entry.TYPE_FREE			equ 1
Guppy2_Entry.TYPE_IN_USE		equ 2
Guppy2_Entry.TYPE_ON_HOLD		equ 3
Guppy2_Entry.TYPE_SYSTEM_RESERVED	equ 4
Guppy2_Entry.TYPE_UNUSABLE		equ 5


; LinkedList :
; 	
; 	POSITION
; 	TYPE
; 	SIZE
; 	NEXTPOINTER
; 	
; 	--------
; 	----
; 	----
; 	-----------
; 	
; 	POSITION
; 	TYPE
; 	SIZE
; 	NEXTPOINTER
; 	
; 	POSITION
; 	TYPE
; 	SIZE
; 	NEXTPOINTER


