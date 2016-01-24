; 'Device' definition
Device_$objsize			equ 0x22
Device_objectGrouping	equ 0x0
Device_hardwareType		equ 0x4
Device_interfaceType	equ 0x8
Device_internalID		equ 0xC
Device_friendlyName		equ 0x10
Device_deviceStatus		equ 0x14
Device_interfaceValues	equ 0x18

; Device types
Device.TYPE_STORAGE		equ 0x0
Device.TYPE_FILESYSTEM	equ 0x1
Device.TYPE_GRAPHICS	equ 0x2
Device.TYPE_INPUT		equ 0x3

; Device statuses
Status.CONNECTED		equ 1<<0
Status.INITIALIZED		equ 1<<1
Status.UNRESPONSIVE		equ 1<<2
Status.NEEDS_REINIT		equ 1<<3
Status.ENABLED			equ 1<<4

