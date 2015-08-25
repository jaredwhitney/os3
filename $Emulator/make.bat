@SET x=%cd%
@cd "..\Modules\console"
@java Jasm > build.asm
@cd %x%
@nasm.exe -o kernel.bin -f bin ..\boot\stage2.asm
@nasm.exe -o boot.bin -f bin ..\boot\boot.asm
@nasm.exe -o fstest.bin -f bin "../_not os code/Hello World.asm"
@nasm.exe -o fspadding.bin -f bin "fspadding.asm"
@cd %x%
@pause
@cat boot.bin kernel.bin fstest.bin "../_not os code/image/iConsole.file" "fspadding.bin" > os.img
@pause
@start run.bxrc