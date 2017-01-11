@echo %date% (%time%) > build_time.log
@echo ; FILE CLEARED FOR PRE-BUILD > ..\$Emulator\map.asm
@echo Debug.methodTraceLookupTable : >> ..\$Emulator\map.asm
@echo Debug.methodTraceStringTable : >> ..\$Emulator\map.asm
@nasm.exe -o boot.bin -f bin ..\newboot\boot.asm
@nasm.exe -o kernel.bin -f bin ..\newboot\kernelLoader.asm
@pause
@java MapFormatter > map.asm
@nasm.exe -o kernel.bin -f bin ..\newboot\kernelLoader.asm
@pause
@cat boot.bin kernel.bin > os.img