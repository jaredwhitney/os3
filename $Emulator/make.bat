@nasm.exe -o kernel.bin -f bin ..\boot\stage2.asm
@nasm.exe -o boot.bin -f bin ..\boot\boot.asm
@pause
@cat boot.bin kernel.bin > os.img