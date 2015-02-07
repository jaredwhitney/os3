@SET x=%cd%
@cd "../programs/new console"
@java Jasm > build.asm
@cd %x%
@C:\Users\Jared\AppData\Local\nasm\nasm.exe -o kernel.bin -f bin ..\kernel\kernel.asm
@C:\Users\Jared\AppData\Local\nasm\nasm.exe -o boot.bin -f bin ..\boot\boot.asm
@pause
@cat boot.bin kernel.bin "../programs/new console/console.bin" > os.img
@pause
@start run.bxrc