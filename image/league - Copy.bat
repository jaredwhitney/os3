@C:\Users\Jared\AppData\Local\nasm\nasm.exe -o sine.bin -f bin sine.asm
@C:\Users\Jared\AppData\Local\nasm\nasm.exe -o gradient.bin -f bin gradient.asm
@nasm.exe -o jax.bin -f bin jax.asm
@cat jax.bin jax.dsp > jax.file