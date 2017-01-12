date > build_time.log

echo '; FILE CLEARED FOR PRE-BUILD' > map.asm
echo 'Debug.methodTraceLookupTable : ' >> map.asm
echo 'Debug.methodTraceStringTable : ' >> map.asm

nasm -o boot.bin -f bin ../newboot/boot.asm
nasm -o kernel.bin -f bin ../newboot/kernelLoader.asm

read -n1 -r -p "Press any key to continue . . ."

java MapFormatter > map.asm

nasm.exe -o kernel.bin -f bin ../newboot/kernelLoader.asm

read -n1 -r -p "Press any key to continue . . ."

cat boot.bin kernel.bin > os.img
