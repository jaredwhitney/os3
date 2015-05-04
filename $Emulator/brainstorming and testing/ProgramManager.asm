;ProgramStruct :
;
;	dw pnum
;	times ? db name, 0
;	db priority
;	dd entryPoint
;	dd stackLocation
;	dd stackSize (memory usage!)
;	dw wNum (if applicable)
;
;EX:
;	dw     0x0000
;	db "iConsole", 0
;	db       0x05		(five times normal priority (00 = disabled))
;	dd console.init
;	dd 0xf0c00000
;	dd 0x00000082
;	dw     0x0001
;

;ProgramStack :
;
;	dd stackSize
;	dd cs
;	stack
;	  |
;	  |
;	  V
;	program
;	  |
;	  |
;	  V


;	ProgramManager calls malloc to acquire memory to store ProgramStructs in.
;	When a program wants to run it must first provide the relevant data in its declaration.
;	This data will be checked over by the ProgramManager.
;	If it is valid, ProgramManager will create a new ProgramStruct filled with the given information.
;	It will also allocate a new ProogramStack with (the size of the program plus 2) sectors worth of space.
;	The program will be loaded into its newly allocated memory space.
;	ProgramManager will then iterate over it with the other programs every time the timer interrupt fires.
;	...
;	When the program calls to exit or is forcably terminated, it's ProgramStack is deallocated.
;	ProgramManager then removes the program's ProgramStruct from the pool, so it will not be executed any longer.
;	Execution the continues as normal.


;Programs must supply the following in their Program Header:
;	db requestedPriority
;	dd entryPoint
;	times ? db programName, 0
;
;EX: 
;	db 0x05
;	dd console.init
;	db "iConsole", 0