@echo %date% (%time%) > build_time.log
@nasm.exe -o boot.bin -f bin ..\newboot\boot.asm
@nasm.exe -o kernel.bin -f bin ..\newboot\kernelLoader.asm
@pause
@cat boot.bin kernel.bin > os.img