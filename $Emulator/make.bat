@SET x=%cd%
@cd "../programs/new console"
@java Jasm > build.asm
@C:\Users\Jared\AppData\Local\nasm\nasm.exe -o console.bin -f bin console.asm
@cd %x%
@C:\Users\Jared\AppData\Local\nasm\nasm.exe -o kernel.bin -f bin ..\kernel\kernel.asm
@C:\Users\Jared\AppData\Local\nasm\nasm.exe -o boot.bin -f bin ..\boot\boot.asm
@C:\Users\Jared\AppData\Local\nasm\nasm.exe -o fstest.bin -f bin "Hello World.asm"
@pause
@cat boot.bin kernel.bin fstest.bin "../programs/new console/console.bin" > os.img
@pause
@start run.bxrc