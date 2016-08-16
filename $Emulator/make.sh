echo Running miscelaneous tasks...
date > build_time.log
echo Assembling code...
nasm -o kernel.bin -f bin ../boot/stage2.asm
nasm -o boot.bin -f bin ../boot/boot.asm
read -n1 -r -p "Press any key to build image..."
cat boot.bin kernel.bin > os.img
echo
read -n1 -r -p "Press any key to launch bochs..."
bochs -f run.bxrc
