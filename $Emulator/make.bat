@SET x=%cd%
@cd "../programs/new console"
@java Jasm > build.asm
@cd %x%
@C:\Users\Jared\AppData\Local\nasm\nasm.exe -o kernel.bin -f bin ..\kernel\kernel.asm
@C:\Users\Jared\AppData\Local\nasm\nasm.exe -o boot.bin -f bin ..\boot\boot.asm
@C:\Users\Jared\AppData\Local\nasm\nasm.exe -o fstest.bin -f bin "Hello World.asm"
@cd %x%
@pause
@cat boot.bin kernel.bin fstest.bin ../image/sine.bin ../image/gradient.bin ../image/league.file > os.img
@pause
@start run.bxrc