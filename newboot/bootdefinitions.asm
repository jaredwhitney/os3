KERNEL_LOADER_LOC	equ S2_CODE_LOC
;KERNEL_LOC			equ 0x100000
MAX_XRES			equ DESIRED_XRES
MAX_YRES			equ DESIRED_YRES
%include "../newboot/oldconfig.asm"

VESA_CLOSEST_MATCH		equ closestMatch
VESA_CLOSEST_XRES		equ closestXres
VESA_CLOSEST_YRES		equ closestYres
VESA_CLOSEST_BPP		equ 32
VESA_CLOSEST_BUFFERLOC	equ closestBufferLoc
