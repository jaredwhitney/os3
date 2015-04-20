@SET x=%cd%
@cd "../programs/new console"
@java Jasm > build.asm
@cd %x%
@nasm.exe -o kernel.bin -f bin ..\boot\stage2.asm
@nasm.exe -o boot.bin -f bin ..\boot\boot.asm
@nasm.exe -o fstest.bin -f bin "Hello World.asm"
@cd %x%
@pause
@cat boot.bin kernel.bin fstest.bin ../image/sine.bin ../image/iConsole.file ../image/gradient.bin ../image/jax.file ../image/league.file > os.img
@pause
@start run.bxrc