PCI_TABLES.lookupVendorString :
push eax
push ebx
push edx
	mov ebx, PCI_VENDOR_LOOPKUP_TABLE
	xchg cl, ch
	PCI_TABLES.lookupVendorString.loop :
	cmp word [ebx], cx
		je PCI_TABLES.lookupVendorString.ret
	cmp word [ebx], 0xFFFF
		je PCI_TABLES.lookupVendorString.ret
	add ebx, 2
	call String.getLength
	add ebx, edx
	jmp PCI_TABLES.lookupVendorString.loop
	PCI_TABLES.lookupVendorString.ret :
	mov ecx, ebx
	add ecx, 2
pop edx
pop ebx
pop eax
ret

PCI_TABLES.lookupHardwareType :
push ebx
push edx
	mov ebx, PCI_TYPE_LOOKUP_TABLE
	.loop :
	cmp byte [ebx], cl
		je .ret
	cmp byte [ebx], 0xFE
		je .ret
	inc ebx
	call String.getLength
	add ebx, edx
	jmp .loop
	.ret :
	mov ecx, ebx
	inc ecx
pop edx
pop ebx
ret

PCI_TYPE_LOOKUP_TABLE :
db 0x0, "Legacy Device", 0
db 0x1, "Mass Storage Controller", 0
db 0x2, "Network Controller", 0
db 0x3, "Display Controller", 0
db 0x4, "Multimedia Controller", 0
db 0x5, "Memory Controller", 0
db 0x6, "Bridge Device", 0
db 0x7, "Simple Communcations Controller", 0
db 0x8, "Base System Peripheral", 0
db 0x9, "Input Device", 0
db 0xA, "Docking Station", 0
db 0xB, "Processor", 0
db 0xC, "Serial Bus Controller", 0
db 0xD, "Wireless Controller", 0
db 0xE, "Intelligent I/O Controller", 0
db 0xF, "Satellite Communication Controller", 0
db 0x10, "Encryption/Decryption Controller", 0
db 0x11, "Data Acquisition / Signal Processing Controller", 0
db 0xFF, "[DEVICE CLASS UNDEFINED]", 0
db 0xFE, "[DEVICE CLASS UNRECOGNIZED]", 0

; The following is a modified and formatted derivitive of the list found at http://pcidatabase.com/vendors.php
PCI_VENDOR_LOOPKUP_TABLE :
db 0x00, 0x33, "Paradyne Corporation", 0
db 0x00, 0x3d, "Master", 0
db 0x00, 0x70, "Hauppauge Computer Works Incorporated", 0
db 0x01, 0x00, "USBPDO-8", 0
db 0x01, 0x23, "General Dynamics", 0
db 0x03, 0x15, "SK Electronics Corporation Limited", 0
db 0x04, 0x02, "Acer Aspire One", 0
db 0x04, 0x6D, "Logitech Incorporated", 0
db 0x04, 0x83, "UPEK", 0
db 0x04, 0xA9, "Canon", 0
db 0x04, 0xB3, "IBM", 0
db 0x04, 0xD9, "Filco", 0
db 0x04, 0xF2, "Chicony Electronics Co.", 0
db 0x05, 0x1D, "ACPI\VEN_INT&DEV_33A0", 0
db 0x05, 0x29, "Aladdin E-Token", 0
db 0x05, 0x53, "Aiptek USA", 0
db 0x05, 0x8f, "Alcor Micro Corporation", 0
db 0x05, 0x90, "Omron Corporation", 0
db 0x05, 0xac, "Apple Incorporated", 0
db 0x05, 0xE1, "D-MAX", 0
db 0x06, 0x4e, "SUYIN Corporation", 0
db 0x06, 0x7B, "Prolific Technology Incorporated", 0
db 0x06, 0xFE, "Acresso Software Incorporated", 0
db 0x07, 0x11, "SIIG, Incorporated", 0
db 0x09, 0x3a, "KYE Systems Corporation / Pixart Imaging", 0
db 0x09, 0x6E, "USB Rockey dongle from Feitain", 0
db 0x0A, 0x5C, "Broadcom Corporation", 0
db 0x0A, 0x89, "BREA Technologies Incorporated", 0
db 0x0A, 0x92, "Egosys, Incorporated", 0
db 0x0A, 0xC8, "ASUS", 0
db 0x0b, 0x05, "Toshiba Bluetooth RFBUS, RFCOM, RFHID", 0
db 0x0c, 0x45, "Microdia Limited", 0
db 0x0c, 0xf3, "TP-Link", 0
db 0x0D, 0x2E, "Feedback Instruments Limited", 0
db 0x0D, 0x8C, "C-Media Electronics, Incorporated", 0
db 0x0D, 0xF6, "Sitecom", 0
db 0x0E, 0x11, "Compaq Computer Corporation", 0
db 0x0E, 0x8D, "MediaTek Incorporated", 0
db 0x10, 0x00, "LSI Logic", 0
db 0x10, 0x01, "Kolter Electronic - Germany", 0
db 0x10, 0x02, "Advanced Micro Devices, Incorporated", 0
db 0x10, 0x03, "ULSI", 0
db 0x10, 0x04, "VLSI Technology", 0
db 0x10, 0x06, "Reply Group", 0
db 0x10, 0x07, "Netframe Systems Incorporated", 0
db 0x10, 0x08, "Epson", 0
db 0x10, 0x0A, "Ã‚as Limited de Phoenix del Âƒ de TecnologÃƒ", 0
db 0x10, 0x0B, "National Semiconductors", 0
db 0x10, 0x0C, "Tseng Labs", 0
db 0x10, 0x0D, "AST Research", 0
db 0x10, 0x0E, "Weitek", 0
db 0x10, 0x10, "Video Logic Limited", 0
db 0x10, 0x11, "Digital Equipment Corporation", 0
db 0x10, 0x12, "Micronics Computers Incorporated", 0
db 0x10, 0x13, "Cirrus Logic", 0
db 0x10, 0x14, "International Business Machines Corporation", 0
db 0x10, 0x16, "Fujitsu ICL Computers", 0
db 0x10, 0x17, "Spea Software AG", 0
db 0x10, 0x18, "Unisys Systems", 0
db 0x10, 0x19, "Elitegroup Computer System", 0
db 0x10, 0x1A, "NCR Corporation", 0
db 0x10, 0x1B, "Vitesse Semiconductor", 0
db 0x10, 0x1E, "American Megatrends Incorporated", 0
db 0x10, 0x1F, "PictureTel Corporation", 0
db 0x10, 0x20, "Hitachi Computer Electronics", 0
db 0x10, 0x21, "Oki Electric Industry", 0
db 0x10, 0x22, "Advanced Micro Devices", 0
db 0x10, 0x23, "Trident Mirco", 0
db 0x10, 0x25, "Acer Incorporated", 0
db 0x10, 0x28, "Dell Incorporated", 0
db 0x10, 0x2A, "LSI Logic Headland Division", 0
db 0x10, 0x2B, "Matrox Electronic Systems Limited", 0
db 0x10, 0x2C, "Asiliant (Chips And Technologies)", 0
db 0x10, 0x2D, "Wyse Technology", 0
db 0x10, 0x2E, "Olivetti Advanced Technology", 0
db 0x10, 0x2F, "Toshiba America", 0
db 0x10, 0x30, "TMC Research", 0
db 0x10, 0x31, "Miro Computer Products AG", 0
db 0x10, 0x33, "NEC Electronics", 0
db 0x10, 0x34, "Burndy Corporation", 0
db 0x10, 0x36, "Future Domain", 0
db 0x10, 0x37, "Hitachi Micro Systems Incorporated", 0
db 0x10, 0x38, "AMP Incorporated", 0
db 0x10, 0x39, "Silicon Integrated Systems", 0
db 0x10, 0x3A, "Seiko Epson Corporation", 0
db 0x10, 0x3B, "Tatung Corporation Of America", 0
db 0x10, 0x3C, "Hewlett-Packard", 0
db 0x10, 0x3E, "Solliday Engineering", 0
db 0x10, 0x3F, "Logic Modeling", 0
db 0x10, 0x41, "Computrend", 0
db 0x10, 0x43, "Asustek Computer Incorporated", 0
db 0x10, 0x44, "Distributed Processing Tech", 0
db 0x10, 0x45, "OPTi Incorporated", 0
db 0x10, 0x46, "IPC Corporation LTD", 0
db 0x10, 0x47, "Genoa Systems Corporation", 0
db 0x10, 0x48, "ELSA GmbH", 0
db 0x10, 0x49, "Fountain Technology", 0
db 0x10, 0x4A, "STMicroelectronics", 0
db 0x10, 0x4B, "Mylex / Buslogic", 0
db 0x10, 0x4C, "Texas Instruments", 0
db 0x10, 0x4D, "Sony Corporation", 0
db 0x10, 0x4E, "Oak Technology", 0
db 0x10, 0x4F, "Co-Time Computer Limited", 0
db 0x10, 0x50, "Winbond Electronics Corporation", 0
db 0x10, 0x51, "Anigma Corporation", 0
db 0x10, 0x53, "Young Micro Systems", 0
db 0x10, 0x54, "Hitachi Limited", 0
db 0x10, 0x55, "Standard Microsystems Corporation", 0
db 0x10, 0x56, "ICL", 0
db 0x10, 0x57, "Motorola", 0
db 0x10, 0x58, "Electronics & Telecommunication Res", 0
db 0x10, 0x59, "Kontron Canada", 0
db 0x10, 0x5A, "Promise Technology", 0
db 0x10, 0x5B, "Mobham chip", 0
db 0x10, 0x5C, "Wipro Infotech Limited", 0
db 0x10, 0x5D, "Number Nine Visual Technology", 0
db 0x10, 0x5E, "Vtech Engineering Canada Limited", 0
db 0x10, 0x5F, "Infotronic America Incorporated", 0
db 0x10, 0x60, "United Microelectronics", 0
db 0x10, 0x61, "8x8 Incorporated", 0
db 0x10, 0x62, "Maspar Computer Corporation", 0
db 0x10, 0x63, "Ocean Office Automation", 0
db 0x10, 0x64, "Alcatel Cit", 0
db 0x10, 0x65, "Texas Microsystems", 0
db 0x10, 0x66, "Picopower Technology", 0
db 0x10, 0x67, "Mitsubishi Electronics", 0
db 0x10, 0x68, "Diversified Technology", 0
db 0x10, 0x6A, "Aten Research Incorporated", 0
db 0x10, 0x6B, "Apple Incorporated", 0
db 0x10, 0x6C, "Hyundai Electronics America", 0
db 0x10, 0x6D, "Sequent Computer Systems", 0
db 0x10, 0x6E, "DFI Incorporated", 0
db 0x10, 0x6F, "City Gate Development LTD", 0
db 0x10, 0x70, "Daewoo Telecom Limited", 0
db 0x10, 0x71, "Mitac", 0
db 0x10, 0x72, "GIT Co. Limited", 0
db 0x10, 0x73, "Yamaha Corporation", 0
db 0x10, 0x74, "Nexgen Microsystems", 0
db 0x10, 0x75, "Advanced Integration Research", 0
db 0x10, 0x77, "QLogic Corporation", 0
db 0x10, 0x78, "Cyrix Corporation", 0
db 0x10, 0x79, "I-Bus", 0
db 0x10, 0x7A, "Networth controls", 0
db 0x10, 0x7B, "Gateway 2000", 0
db 0x10, 0x7C, "Goldstar Co. Limited", 0
db 0x10, 0x7D, "Leadtek Research", 0
db 0x10, 0x7E, "Testernec", 0
db 0x10, 0x7F, "Data Technology Corporation", 0
db 0x10, 0x80, "Cypress Semiconductor", 0
db 0x10, 0x81, "Radius Incorporated", 0
db 0x10, 0x82, "EFA Corporation Of America", 0
db 0x10, 0x83, "Forex Computer Corporation", 0
db 0x10, 0x84, "Parador", 0
db 0x10, 0x85, "Tulip Computers Int'l BV", 0
db 0x10, 0x86, "J. Bond Computer Systems", 0
db 0x10, 0x87, "Cache Computer", 0
db 0x10, 0x88, "Microcomputer Systems (M) Son", 0
db 0x10, 0x89, "Data General Corporation", 0
db 0x10, 0x8A, "SBS Operations", 0
db 0x10, 0x8C, "Oakleigh Systems Incorporated", 0
db 0x10, 0x8D, "Olicom", 0
db 0x10, 0x8E, "Sun Microsystems", 0
db 0x10, 0x8F, "Systemsoft Corporation", 0
db 0x10, 0x90, "Encore Computer Corporation", 0
db 0x10, 0x91, "Intergraph Corporation", 0
db 0x10, 0x92, "Diamond Computer Systems", 0
db 0x10, 0x93, "National Instruments", 0
db 0x10, 0x94, "Apostolos", 0
db 0x10, 0x95, "Silicon Image, Incorporated", 0
db 0x10, 0x96, "Alacron", 0
db 0x10, 0x97, "Appian Graphics", 0
db 0x10, 0x98, "Quantum Designs Limited", 0
db 0x10, 0x99, "Samsung Electronics Co. Limited", 0
db 0x10, 0x9A, "Packard Bell", 0
db 0x10, 0x9B, "Gemlight Computer Limited", 0
db 0x10, 0x9C, "Megachips Corporation", 0
db 0x10, 0x9D, "Zida Technologies Limited", 0
db 0x10, 0x9E, "Brooktree Corporation", 0
db 0x10, 0x9F, "Trigem Computer Incorporated", 0
db 0x10, 0xA0, "Meidensha Corporation", 0
db 0x10, 0xA1, "Juko Electronics Incorporated Limited", 0
db 0x10, 0xA2, "Quantum Corporation", 0
db 0x10, 0xA3, "Everex Systems Incorporated", 0
db 0x10, 0xA4, "Globe Manufacturing Sales", 0
db 0x10, 0xA5, "Racal Interlan", 0
db 0x10, 0xA8, "Sierra Semiconductor", 0
db 0x10, 0xA9, "Silicon Graphics", 0
db 0x10, 0xAB, "Digicom", 0
db 0x10, 0xAC, "Honeywell IASD", 0
db 0x10, 0xAD, "Winbond Systems Labs", 0
db 0x10, 0xAE, "Cornerstone Technology", 0
db 0x10, 0xAF, "Micro Computer Systems Incorporated", 0
db 0x10, 0xB0, "Gainward GmbH", 0
db 0x10, 0xB1, "Cabletron Systems Incorporated", 0
db 0x10, 0xB2, "Raytheon Company", 0
db 0x10, 0xB3, "Databook Incorporated", 0
db 0x10, 0xB4, "STB Systems", 0
db 0x10, 0xB5, "PLX Technology Incorporated", 0
db 0x10, 0xB6, "Madge Networks", 0
db 0x10, 0xB7, "3Com Corporation", 0
db 0x10, 0xB8, "Standard Microsystems Corporation", 0
db 0x10, 0xB9, "Ali Corporation", 0
db 0x10, 0xBA, "Mitsubishi Electronics Corporation", 0
db 0x10, 0xBB, "Dapha Electronics Corporation", 0
db 0x10, 0xBC, "Advanced Logic Research Incorporated", 0
db 0x10, 0xBD, "Surecom Technology", 0
db 0x10, 0xBE, "Tsenglabs International Corporation", 0
db 0x10, 0xBF, "MOST Corporation", 0
db 0x10, 0xC0, "Boca Research Incorporated", 0
db 0x10, 0xC1, "ICM Corporation Limited", 0
db 0x10, 0xC2, "Auspex Systems Incorporated", 0
db 0x10, 0xC3, "Samsung Semiconductors", 0
db 0x10, 0xC4, "Award Software Int'l Incorporated", 0
db 0x10, 0xC5, "Xerox Corporation", 0
db 0x10, 0xC6, "Rambus Incorporated", 0
db 0x10, 0xC8, "Neomagic Corporation", 0
db 0x10, 0xC9, "Dataexpert Corporation", 0
db 0x10, 0xCA, "Fujitsu Siemens", 0
db 0x10, 0xCB, "Omron Corporation", 0
db 0x10, 0xCD, "Advanced System Products", 0
db 0x10, 0xCF, "Fujitsu Limited", 0
db 0x10, 0xD1, "Future+ Systems", 0
db 0x10, 0xD2, "Molex Incorporated", 0
db 0x10, 0xD3, "Jabil Circuit Incorporated", 0
db 0x10, 0xD4, "Hualon Microelectronics", 0
db 0x10, 0xD5, "Autologic Incorporated", 0
db 0x10, 0xD6, "Wilson .co .ltd", 0
db 0x10, 0xD7, "BCM Advanced Research", 0
db 0x10, 0xD8, "Advanced Peripherals Labs", 0
db 0x10, 0xD9, "Macronix International Co. Limited", 0
db 0x10, 0xDB, "Rohm Research", 0
db 0x10, 0xDC, "CERN-European Lab. for Particle Physics", 0
db 0x10, 0xDD, "Evans & Sutherland", 0
db 0x10, 0xDE, "NVIDIA", 0
db 0x10, 0xDF, "Emulex Corporation", 0
db 0x10, 0xE1, "Tekram Technology Corporation Limited", 0
db 0x10, 0xE2, "Aptix Corporation", 0
db 0x10, 0xE3, "Tundra Semiconductor Corporation", 0
db 0x10, 0xE4, "Tandem Computers", 0
db 0x10, 0xE5, "Micro Industries Corporation", 0
db 0x10, 0xE6, "Gainbery Computer Products Incorporated", 0
db 0x10, 0xE7, "Vadem", 0
db 0x10, 0xE8, "Applied Micro Circuits Corporation", 0
db 0x10, 0xE9, "Alps Electronic Corporation Limited", 0
db 0x10, 0xEA, "Tvia, Incorporated", 0
db 0x10, 0xEB, "Artist Graphics", 0
db 0x10, 0xEC, "Realtek Semiconductor Corporation", 0
db 0x10, 0xED, "Ascii Corporation", 0
db 0x10, 0xEE, "Xilinx Corporation", 0
db 0x10, 0xEF, "Racore Computer Products", 0
db 0x10, 0xF0, "Curtiss-Wright Controls Embedded Computing", 0
db 0x10, 0xF1, "Tyan Computer", 0
db 0x10, 0xF2, "Achme Computer Incorporated - GONE !!!!", 0
db 0x10, 0xF3, "Alaris Incorporated", 0
db 0x10, 0xF4, "S-Mos Systems", 0
db 0x10, 0xF5, "NKK Corporation", 0
db 0x10, 0xF6, "Creative Electronic Systems SA", 0
db 0x10, 0xF7, "Matsushita Electric Industrial Corporation", 0
db 0x10, 0xF8, "Altos India Limited", 0
db 0x10, 0xF9, "PC Direct", 0
db 0x10, 0xFA, "Truevision", 0
db 0x10, 0xFB, "Thesys Microelectronic's", 0
db 0x10, 0xFC, "I-O Data Device Incorporated", 0
db 0x10, 0xFD, "Soyo Technology Corporation Limited", 0
db 0x10, 0xFE, "Fast Electronic GmbH", 0
db 0x10, 0xFF, "Ncube", 0
db 0x11, 0x00, "Jazz Multimedia", 0
db 0x11, 0x01, "Initio Corporation", 0
db 0x11, 0x02, "Creative Technology LTD.", 0
db 0x11, 0x03, "HighPoint Technologies, Incorporated", 0
db 0x11, 0x04, "Rasterops", 0
db 0x11, 0x05, "Sigma Designs Incorporated", 0
db 0x11, 0x06, "VIA Technologies, Incorporated", 0
db 0x11, 0x07, "Stratus Computer", 0
db 0x11, 0x08, "Proteon Incorporated", 0
db 0x11, 0x09, "Adaptec/Cogent Data Technologies", 0
db 0x11, 0x0A, "Siemens AG", 0
db 0x11, 0x0B, "Chromatic Research Incorporated", 0
db 0x11, 0x0C, "Mini-Max Technology Incorporated", 0
db 0x11, 0x0D, "ZNYX Corporation", 0
db 0x11, 0x0E, "CPU Technology", 0
db 0x11, 0x0F, "Ross Technology", 0
db 0x11, 0x12, "Osicom Technologies Incorporated", 0
db 0x11, 0x13, "Accton Technology Corporation", 0
db 0x11, 0x14, "Atmel Corporation", 0
db 0x11, 0x16, "Data Translation, Incorporated", 0
db 0x11, 0x17, "Datacube Incorporated", 0
db 0x11, 0x18, "Berg Electronics", 0
db 0x11, 0x19, "ICP vortex Computersysteme GmbH", 0
db 0x11, 0x1A, "Efficent Networks", 0
db 0x11, 0x1C, "Tricord Systems Incorporated", 0
db 0x11, 0x1D, "Integrated Device Technology Incorporated", 0
db 0x11, 0x1F, "Precision Digital Images", 0
db 0x11, 0x20, "EMC Corporation", 0
db 0x11, 0x21, "Zilog", 0
db 0x11, 0x23, "Excellent Design Incorporated", 0
db 0x11, 0x24, "Leutron Vision AG", 0
db 0x11, 0x25, "Eurocore/Vigra", 0
db 0x11, 0x27, "FORE Systems", 0
db 0x11, 0x29, "Firmworks", 0
db 0x11, 0x2A, "Hermes Electronics Co. Limited", 0
db 0x11, 0x2C, "Zenith Data Systems", 0
db 0x11, 0x2D, "Ravicad", 0
db 0x11, 0x2E, "Infomedia", 0
db 0x11, 0x30, "Computervision", 0
db 0x11, 0x31, "NXP Semiconductors N.V.", 0
db 0x11, 0x32, "Mitel Corporation", 0
db 0x11, 0x33, "Eicon Networks Corporation", 0
db 0x11, 0x34, "Mercury Computer Systems Incorporated", 0
db 0x11, 0x35, "Fuji Xerox Co Limited", 0
db 0x11, 0x36, "Momentum Data Systems", 0
db 0x11, 0x37, "Cisco Systems Incorporated", 0
db 0x11, 0x38, "Ziatech Corporation", 0
db 0x11, 0x39, "Dynamic Pictures Incorporated", 0
db 0x11, 0x3A, "FWB Incorporated", 0
db 0x11, 0x3B, "Network Computing Devices", 0
db 0x11, 0x3C, "Cyclone Microsystems Incorporated", 0
db 0x11, 0x3D, "Leading Edge Products Incorporated", 0
db 0x11, 0x3E, "Sanyo Electric Co", 0
db 0x11, 0x3F, "Equinox Systems", 0
db 0x11, 0x40, "Intervoice Incorporated", 0
db 0x11, 0x41, "Crest Microsystem Incorporated", 0
db 0x11, 0x42, "Alliance Semiconductor", 0
db 0x11, 0x43, "Netpower Incorporated", 0
db 0x11, 0x44, "Cincinnati Milacron", 0
db 0x11, 0x45, "Workbit Corporation", 0
db 0x11, 0x46, "Force Computers", 0
db 0x11, 0x47, "Interface Corporation", 0
db 0x11, 0x48, "Marvell Semiconductor Germany GmbH", 0
db 0x11, 0x49, "Win System Corporation", 0
db 0x11, 0x4A, "VMIC", 0
db 0x11, 0x4B, "Canopus corporation", 0
db 0x11, 0x4C, "Annabooks", 0
db 0x11, 0x4D, "IC Corporation", 0
db 0x11, 0x4E, "Nikon Systems Incorporated", 0
db 0x11, 0x4F, "Digi International", 0
db 0x11, 0x50, "Thinking Machines Corporation", 0
db 0x11, 0x51, "JAE Electronics Incorporated", 0
db 0x11, 0x53, "Land Win Electronic Corporation", 0
db 0x11, 0x54, "Melco Incorporated", 0
db 0x11, 0x55, "Pine Technology Limited", 0
db 0x11, 0x56, "Periscope Engineering", 0
db 0x11, 0x57, "Avsys Corporation", 0
db 0x11, 0x58, "Voarx R&D Incorporated", 0
db 0x11, 0x59, "Mutech", 0
db 0x11, 0x5A, "Harlequin Limited", 0
db 0x11, 0x5B, "Parallax Graphics", 0
db 0x11, 0x5C, "Photron Limited", 0
db 0x11, 0x5D, "Xircom", 0
db 0x11, 0x5E, "Peer Protocols Incorporated", 0
db 0x11, 0x5F, "Maxtor Corporation", 0
db 0x11, 0x60, "Megasoft Incorporated", 0
db 0x11, 0x61, "PFU Limited", 0
db 0x11, 0x62, "OA Laboratory Co Limited", 0
db 0x11, 0x63, "mohamed alsherif", 0
db 0x11, 0x64, "Advanced Peripherals Tech", 0
db 0x11, 0x65, "Imagraph Corporation", 0
db 0x11, 0x66, "Broadcom / ServerWorks", 0
db 0x11, 0x67, "Mutoh Industries Incorporated", 0
db 0x11, 0x68, "Thine Electronics Incorporated", 0
db 0x11, 0x69, "Centre f/Dev. of Adv. Computing", 0
db 0x11, 0x6A, "Luminex Software, Incorporated", 0
db 0x11, 0x6B, "Connectware Incorporated", 0
db 0x11, 0x6C, "Intelligent Resources", 0
db 0x11, 0x6E, "Electronics for Imaging", 0
db 0x11, 0x70, "Inventec Corporation", 0
db 0x11, 0x72, "Altera Corporation", 0
db 0x11, 0x73, "Adobe Systems", 0
db 0x11, 0x74, "Bridgeport Machines", 0
db 0x11, 0x75, "Mitron Computer Incorporated", 0
db 0x11, 0x76, "SBE", 0
db 0x11, 0x77, "Silicon Engineering", 0
db 0x11, 0x78, "Alfa Incorporated", 0
db 0x11, 0x79, "Toshiba corporation", 0
db 0x11, 0x7A, "A-Trend Technology", 0
db 0x11, 0x7B, "LG (Lucky Goldstar) Electronics Incorporated", 0
db 0x11, 0x7C, "Atto Technology", 0
db 0x11, 0x7D, "Becton & Dickinson", 0
db 0x11, 0x7E, "T/R Systems", 0
db 0x11, 0x7F, "Integrated Circuit Systems", 0
db 0x11, 0x80, "RicohCompany,Limited", 0
db 0x11, 0x83, "Fujikura Limited", 0
db 0x11, 0x84, "Forks Incorporated", 0
db 0x11, 0x85, "Dataworld", 0
db 0x11, 0x86, "D-Link System Incorporated", 0
db 0x11, 0x87, "Philips Healthcare", 0
db 0x11, 0x88, "Shima Seiki Manufacturing Limited", 0
db 0x11, 0x89, "Matsushita Electronics", 0
db 0x11, 0x8A, "Hilevel Technology", 0
db 0x11, 0x8B, "Hypertec Pty Limited", 0
db 0x11, 0x8C, "Corollary Incorporated", 0
db 0x11, 0x8D, "BitFlow Incorporated", 0
db 0x11, 0x8E, "Hermstedt AG", 0
db 0x11, 0x8F, "Green Logic", 0
db 0x11, 0x90, "Tripace", 0
db 0x11, 0x91, "Acard Technology Corporation", 0
db 0x11, 0x92, "Densan Co. Limited", 0
db 0x11, 0x94, "Toucan Technology", 0
db 0x11, 0x95, "Ratoc System Incorporated", 0
db 0x11, 0x96, "Hytec Electronics Limited", 0
db 0x11, 0x97, "Gage Applied Technologies", 0
db 0x11, 0x98, "Lambda Systems Incorporated", 0
db 0x11, 0x99, "Attachmate Corporation", 0
db 0x11, 0x9A, "Mind/Share Incorporated", 0
db 0x11, 0x9B, "Omega Micro Incorporated", 0
db 0x11, 0x9C, "Information Technology Inst.", 0
db 0x11, 0x9D, "Bug Sapporo Japan", 0
db 0x11, 0x9E, "Fujitsu Microelectronics Limited", 0
db 0x11, 0x9F, "Bull Hn Information Systems", 0
db 0x11, 0xA1, "Hamamatsu Photonics K.K.", 0
db 0x11, 0xA2, "Sierra Research and Technology", 0
db 0x11, 0xA3, "Deuretzbacher GmbH & Co. Eng. KG", 0
db 0x11, 0xA4, "Barco", 0
db 0x11, 0xA5, "MicroUnity Systems Engineering Incorporated", 0
db 0x11, 0xA6, "Pure Data", 0
db 0x11, 0xA7, "Power Computing Corporation", 0
db 0x11, 0xA8, "Systech Corporation", 0
db 0x11, 0xA9, "InnoSys Incorporated", 0
db 0x11, 0xAA, "Actel", 0
db 0x11, 0xAB, "Marvell Semiconductor", 0
db 0x11, 0xAC, "Canon Information Systems", 0
db 0x11, 0xAD, "Lite-On Technology Corporation", 0
db 0x11, 0xAE, "Scitex Corporation Limited", 0
db 0x11, 0xAF, "Avid Technology, Incorporated", 0
db 0x11, 0xB0, "Quicklogic Corporation", 0
db 0x11, 0xB1, "Apricot Computers", 0
db 0x11, 0xB2, "Eastman Kodak", 0
db 0x11, 0xB3, "Barr Systems Incorporated", 0
db 0x11, 0xB4, "Leitch Technology International", 0
db 0x11, 0xB5, "Radstone Technology Limited", 0
db 0x11, 0xB6, "United Video Corporation", 0
db 0x11, 0xB7, "Motorola", 0
db 0x11, 0xB8, "Xpoint Technologies Incorporated", 0
db 0x11, 0xB9, "Pathlight Technology Incorporated", 0
db 0x11, 0xBA, "Videotron Corporation", 0
db 0x11, 0xBB, "Pyramid Technology", 0
db 0x11, 0xBC, "Network Peripherals Incorporated", 0
db 0x11, 0xBD, "Pinnacle system", 0
db 0x11, 0xBE, "International Microcircuits Incorporated", 0
db 0x11, 0xBF, "Astrodesign Incorporated", 0
db 0x11, 0xC1, "LSI Corporation", 0
db 0x11, 0xC2, "Sand Microelectronics", 0
db 0x11, 0xC4, "Document Technologies Ind.", 0
db 0x11, 0xC5, "Shiva Corporationoratin", 0
db 0x11, 0xC6, "Dainippon Screen Mfg. Co", 0
db 0x11, 0xC7, "D.C.M. Data Systems", 0
db 0x11, 0xC8, "Dolphin Interconnect Solutions", 0
db 0x11, 0xC9, "MAGMA", 0
db 0x11, 0xCA, "LSI Systems Incorporated", 0
db 0x11, 0xCB, "Specialix International Limited", 0
db 0x11, 0xCC, "Michels & Kleberhoff Computer GmbH", 0
db 0x11, 0xCD, "HAL Computer Systems Incorporated", 0
db 0x11, 0xCE, "Primary Rate Incorporated", 0
db 0x11, 0xCF, "Pioneer Electronic Corporation", 0
db 0x11, 0xD0, "BAE SYSTEMS - Manassas", 0
db 0x11, 0xD1, "AuraVision Corporation", 0
db 0x11, 0xD2, "Intercom Incorporated", 0
db 0x11, 0xD3, "Trancell Systems Incorporated", 0
db 0x11, 0xD4, "Analog Devices, Incorporated", 0
db 0x11, 0xD5, "Tahoma Technology", 0
db 0x11, 0xD6, "Tekelec Technologies", 0
db 0x11, 0xD7, "TRENTON Technology, Incorporated", 0
db 0x11, 0xD8, "Image Technologies Development", 0
db 0x11, 0xD9, "Tec Corporation", 0
db 0x11, 0xDA, "Novell", 0
db 0x11, 0xDB, "Sega Enterprises Limited", 0
db 0x11, 0xDC, "Questra Corporation", 0
db 0x11, 0xDD, "Crosfield Electronics Limited", 0
db 0x11, 0xDE, "Zoran Corporation", 0
db 0x11, 0xE1, "Gec Plessey Semi Incorporated", 0
db 0x11, 0xE2, "Samsung Information Systems America", 0
db 0x11, 0xE3, "Quicklogic Corporation", 0
db 0x11, 0xE4, "Second Wave Incorporated", 0
db 0x11, 0xE5, "IIX Consulting", 0
db 0x11, 0xE6, "Mitsui-Zosen System Research", 0
db 0x11, 0xE8, "Digital Processing Systems Incorporated", 0
db 0x11, 0xE9, "Highwater Designs Limited", 0
db 0x11, 0xEA, "Elsag Bailey", 0
db 0x11, 0xEB, "Formation, Incorporated", 0
db 0x11, 0xEC, "Coreco Incorporated", 0
db 0x11, 0xED, "Mediamatics", 0
db 0x11, 0xEE, "Dome Imaging Systems Incorporated", 0
db 0x11, 0xEF, "Nicolet Technologies BV", 0
db 0x11, 0xF0, "Triya", 0
db 0x11, 0xF2, "Picture Tel Japan KK", 0
db 0x11, 0xF3, "Keithley Instruments, Incorporated", 0
db 0x11, 0xF4, "Kinetic Systems Corporation", 0
db 0x11, 0xF5, "Computing Devices Intl", 0
db 0x11, 0xF6, "Powermatic Data Systems Limited", 0
db 0x11, 0xF7, "Scientific Atlanta", 0
db 0x11, 0xF8, "PMC-Sierra Incorporated", 0
db 0x11, 0xF9, "I-Cube Incorporated", 0
db 0x11, 0xFA, "Kasan Electronics Co Limited", 0
db 0x11, 0xFB, "Datel Incorporated", 0
db 0x11, 0xFD, "High Street Consultants", 0
db 0x11, 0xFE, "Comtrol Corporation", 0
db 0x11, 0xFF, "Scion Corporation", 0
db 0x12, 0x00, "CSS Corporation", 0
db 0x12, 0x01, "Vista Controls Corporation", 0
db 0x12, 0x02, "Network General Corporation", 0
db 0x12, 0x03, "Bayer Corporation Agfa Div", 0
db 0x12, 0x04, "Lattice Semiconductor Corporation", 0
db 0x12, 0x05, "Array Corporation", 0
db 0x12, 0x06, "Amdahl Corporation", 0
db 0x12, 0x08, "Parsytec GmbH", 0
db 0x12, 0x09, "Sci Systems Incorporated", 0
db 0x12, 0x0A, "Synaptel", 0
db 0x12, 0x0B, "Adaptive Solutions", 0
db 0x12, 0x0D, "Compression Labs Incorporated", 0
db 0x12, 0x0E, "Cyclades Corporation", 0
db 0x12, 0x0F, "Essential Communications", 0
db 0x12, 0x10, "Hyperparallel Technologies", 0
db 0x12, 0x11, "Braintech Incorporated", 0
db 0x12, 0x13, "Applied Intelligent Systems Incorporated", 0
db 0x12, 0x14, "Performance Technologies Incorporated", 0
db 0x12, 0x15, "Interware Co Limited", 0
db 0x12, 0x16, "Purup-Eskofot A/S", 0
db 0x12, 0x17, "O2Micro Incorporated", 0
db 0x12, 0x18, "Hybricon Corporation", 0
db 0x12, 0x19, "First Virtual Corporation", 0
db 0x12, 0x1A, "3dfx Interactive Incorporated", 0
db 0x12, 0x1B, "Advanced Telecommunications Modules", 0
db 0x12, 0x1C, "Nippon Texa Co Limited", 0
db 0x12, 0x1D, "LiPPERT Embedded Computers GmbH", 0
db 0x12, 0x1E, "CSPI", 0
db 0x12, 0x1F, "Arcus Technology Incorporated", 0
db 0x12, 0x20, "Ariel Corporation", 0
db 0x12, 0x21, "Contec Microelectronics Europe BV", 0
db 0x12, 0x22, "Ancor Communications Incorporated", 0
db 0x12, 0x23, "Artesyn Embedded Technologies", 0
db 0x12, 0x24, "Interactive Images", 0
db 0x12, 0x25, "Power I/O Incorporated", 0
db 0x12, 0x27, "Tech-Source", 0
db 0x12, 0x28, "Norsk Elektro Optikk A/S", 0
db 0x12, 0x29, "Data Kinesis Incorporated", 0
db 0x12, 0x2A, "Integrated Telecom", 0
db 0x12, 0x2B, "LG Industrial Systems Co. Limited", 0
db 0x12, 0x2C, "sci-worx GmbH", 0
db 0x12, 0x2D, "Aztech System Limited", 0
db 0x12, 0x2E, "Absolute Analysis", 0
db 0x12, 0x2F, "Andrew Corporation", 0
db 0x12, 0x30, "Fishcamp Engineering", 0
db 0x12, 0x31, "Woodward McCoach Incorporated", 0
db 0x12, 0x33, "Bus-Tech Incorporated", 0
db 0x12, 0x34, "Technical Corporation", 0
db 0x12, 0x36, "Sigma Designs Incorporated", 0
db 0x12, 0x37, "Alta Technology Corporation", 0
db 0x12, 0x38, "Adtran", 0
db 0x12, 0x39, "The 3DO Company", 0
db 0x12, 0x3A, "Visicom Laboratories Incorporated", 0
db 0x12, 0x3B, "Seeq Technology Incorporated", 0
db 0x12, 0x3C, "Century Systems Incorporated", 0
db 0x12, 0x3D, "Engineering Design Team Incorporated", 0
db 0x12, 0x3F, "C-Cube Microsystems", 0
db 0x12, 0x40, "Marathon Technologies Corporation", 0
db 0x12, 0x41, "DSC Communications", 0
db 0x12, 0x42, "JNI Corporation", 0
db 0x12, 0x43, "Delphax", 0
db 0x12, 0x44, "AVM AUDIOVISUELLES MKTG & Computer GmbH", 0
db 0x12, 0x45, "APD S.A.", 0
db 0x12, 0x46, "Dipix Technologies Incorporated", 0
db 0x12, 0x47, "Xylon Research Incorporated", 0
db 0x12, 0x48, "Central Data Corporation", 0
db 0x12, 0x49, "Samsung Electronics Co. Limited", 0
db 0x12, 0x4A, "AEG Electrocom GmbH", 0
db 0x12, 0x4C, "Solitron Technologies Incorporated", 0
db 0x12, 0x4D, "Stallion Technologies", 0
db 0x12, 0x4E, "Cylink", 0
db 0x12, 0x4F, "Infortrend Technology Incorporated", 0
db 0x12, 0x50, "Hitachi Microcomputer System Limited", 0
db 0x12, 0x51, "VLSI Solution OY", 0
db 0x12, 0x53, "Guzik Technical Enterprises", 0
db 0x12, 0x54, "Linear Systems Limited", 0
db 0x12, 0x55, "Optibase Limited", 0
db 0x12, 0x56, "Perceptive Solutions Incorporated", 0
db 0x12, 0x57, "Vertex Networks Incorporated", 0
db 0x12, 0x58, "Gilbarco Incorporated", 0
db 0x12, 0x59, "Allied Telesyn International", 0
db 0x12, 0x5A, "ABB Power Systems", 0
db 0x12, 0x5B, "Asix Electronics Corporation", 0
db 0x12, 0x5C, "Aurora Technologies Incorporated", 0
db 0x12, 0x5D, "ESS Technology", 0
db 0x12, 0x5E, "Specialvideo Engineering SRL", 0
db 0x12, 0x5F, "Concurrent Technologies Incorporated", 0
db 0x12, 0x60, "Intersil Corporation", 0
db 0x12, 0x61, "Matsushita-Kotobuki Electronics Indu", 0
db 0x12, 0x62, "ES Computer Co. Limited", 0
db 0x12, 0x63, "Sonic Solutions", 0
db 0x12, 0x64, "Aval Nagasaki Corporation", 0
db 0x12, 0x65, "Casio Computer Co. Limited", 0
db 0x12, 0x66, "Microdyne Corporation", 0
db 0x12, 0x67, "S.A. Telecommunications", 0
db 0x12, 0x68, "Tektronix", 0
db 0x12, 0x69, "Thomson-CSF/TTM", 0
db 0x12, 0x6A, "Lexmark International Incorporated", 0
db 0x12, 0x6B, "Adax Incorporated", 0
db 0x12, 0x6C, "Nortel Networks Corporation", 0
db 0x12, 0x6D, "Splash Technology Incorporated", 0
db 0x12, 0x6E, "Sumitomo Metal Industries Limited", 0
db 0x12, 0x6F, "Silicon Motion", 0
db 0x12, 0x70, "Olympus Optical Co. Limited", 0
db 0x12, 0x71, "GW Instruments", 0
db 0x12, 0x72, "themrtaish", 0
db 0x12, 0x73, "Hughes Network Systems", 0
db 0x12, 0x74, "Ensoniq", 0
db 0x12, 0x75, "Network Appliance", 0
db 0x12, 0x76, "Switched Network Technologies Incorporated", 0
db 0x12, 0x77, "Comstream", 0
db 0x12, 0x78, "Transtech Parallel Systems", 0
db 0x12, 0x79, "Transmeta Corporation", 0
db 0x12, 0x7B, "Pixera Corporation", 0
db 0x12, 0x7C, "Crosspoint Solutions Incorporated", 0
db 0x12, 0x7D, "Vela Research LP", 0
db 0x12, 0x7E, "Winnov L.P.", 0
db 0x12, 0x7F, "Fujifilm", 0
db 0x12, 0x80, "Photoscript Group Limited", 0
db 0x12, 0x81, "Yokogawa Electronic Corporation", 0
db 0x12, 0x82, "Davicom Semiconductor Incorporated", 0
db 0x12, 0x83, "Waldo", 0
db 0x12, 0x85, "Platform Technologies Incorporated", 0
db 0x12, 0x86, "MAZeT GmbH", 0
db 0x12, 0x87, "LuxSonor Incorporated", 0
db 0x12, 0x88, "Timestep Corporation", 0
db 0x12, 0x89, "AVC Technology Incorporated", 0
db 0x12, 0x8A, "Asante Technologies Incorporated", 0
db 0x12, 0x8B, "Transwitch Corporation", 0
db 0x12, 0x8C, "Retix Corporation", 0
db 0x12, 0x8D, "G2 Networks Incorporated", 0
db 0x12, 0x8F, "Tateno Dennou Incorporated", 0
db 0x12, 0x90, "Sord Computer Corporation", 0
db 0x12, 0x91, "NCS Computer Italia", 0
db 0x12, 0x92, "Tritech Microelectronics Intl PTE", 0
db 0x12, 0x93, "Media Reality Technology", 0
db 0x12, 0x94, "Rhetorex Incorporated", 0
db 0x12, 0x95, "Imagenation Corporation", 0
db 0x12, 0x96, "Kofax Image Products", 0
db 0x12, 0x97, "Shuttle Computer", 0
db 0x12, 0x98, "Spellcaster Telecommunications Incorporated", 0
db 0x12, 0x99, "Knowledge Technology Laboratories", 0
db 0x12, 0x9A, "Curtiss Wright Controls Electronic Systems", 0
db 0x12, 0x9B, "Image Access", 0
db 0x12, 0x9D, "CompCore Multimedia Incorporated", 0
db 0x12, 0x9E, "Victor Co. of Japan Limited", 0
db 0x12, 0x9F, "OEC Medical Systems Incorporated", 0
db 0x12, 0xA0, "Allen Bradley Co.", 0
db 0x12, 0xA1, "Simpact Incorporated", 0
db 0x12, 0xA2, "NewGen Systems Corporation", 0
db 0x12, 0xA3, "Lucent Technologies AMR", 0
db 0x12, 0xA4, "NTT Electronics Corporation", 0
db 0x12, 0xA5, "Vision Dynamics Limited", 0
db 0x12, 0xA6, "Scalable Networks Incorporated", 0
db 0x12, 0xA7, "AMO GmbH", 0
db 0x12, 0xA8, "News Datacom", 0
db 0x12, 0xA9, "Xiotech Corporation", 0
db 0x12, 0xAA, "SDL Communications Incorporated", 0
db 0x12, 0xAB, "Yuan Yuan Enterprise Co. Limited", 0
db 0x12, 0xAC, "MeasureX Corporation", 0
db 0x12, 0xAD, "MULTIDATA GmbH", 0
db 0x12, 0xAE, "Alteon Networks Incorporated", 0
db 0x12, 0xAF, "TDK USA Corporation", 0
db 0x12, 0xB0, "Jorge Scientific Corporation", 0
db 0x12, 0xB1, "GammaLink", 0
db 0x12, 0xB2, "General Signal Networks", 0
db 0x12, 0xB3, "Interface Corporation Limited", 0
db 0x12, 0xB4, "Future Tel Incorporated", 0
db 0x12, 0xB5, "Granite Systems Incorporated", 0
db 0x12, 0xB7, "Acumen", 0
db 0x12, 0xB8, "Korg", 0
db 0x12, 0xB9, "3Com Corporation", 0
db 0x12, 0xBA, "Bittware Incorporated", 0
db 0x12, 0xBB, "Nippon Unisoft Corporation", 0
db 0x12, 0xBC, "Array Microsystems", 0
db 0x12, 0xBD, "Computerm Corporation", 0
db 0x12, 0xBF, "Fujifilm Microdevices", 0
db 0x12, 0xC0, "Infimed", 0
db 0x12, 0xC1, "GMM Research Corporation", 0
db 0x12, 0xC2, "Mentec Limited", 0
db 0x12, 0xC3, "Holtek Microelectronics Incorporated", 0
db 0x12, 0xC4, "Connect Tech Incorporated", 0
db 0x12, 0xC5, "Picture Elements Incorporated", 0
db 0x12, 0xC6, "Mitani Corporation", 0
db 0x12, 0xC7, "Dialogic Corporation", 0
db 0x12, 0xC8, "G Force Co. Limited", 0
db 0x12, 0xC9, "Gigi Operations", 0
db 0x12, 0xCA, "Integrated Computing Engines, Incorporated", 0
db 0x12, 0xCB, "Antex Electronics Corporation", 0
db 0x12, 0xCC, "Pluto Technologies International", 0
db 0x12, 0xCD, "Aims Lab", 0
db 0x12, 0xCE, "Netspeed Incorporated", 0
db 0x12, 0xCF, "Prophet Systems Incorporated", 0
db 0x12, 0xD0, "GDE Systems Incorporated", 0
db 0x12, 0xD1, "Huawei Technologies Co., Limited", 0
db 0x12, 0xD3, "Vingmed Sound A/S", 0
db 0x12, 0xD4, "Ulticom, Incorporated", 0
db 0x12, 0xD5, "Equator Technologies", 0
db 0x12, 0xD6, "Analogic Corporation", 0
db 0x12, 0xD7, "Biotronic SRL", 0
db 0x12, 0xD8, "Pericom Semiconductor", 0
db 0x12, 0xD9, "Aculab Plc.", 0
db 0x12, 0xDA, "TrueTime", 0
db 0x12, 0xDB, "Annapolis Micro Systems Incorporated", 0
db 0x12, 0xDC, "Symicron Computer Communication Limited", 0
db 0x12, 0xDD, "Management Graphics Incorporated", 0
db 0x12, 0xDE, "Rainbow Technologies", 0
db 0x12, 0xDF, "SBS Technologies Incorporated", 0
db 0x12, 0xE0, "Chase Research PLC", 0
db 0x12, 0xE1, "Nintendo Co. Limited", 0
db 0x12, 0xE2, "Datum Incorporated Bancomm-Timing Division", 0
db 0x12, 0xE3, "Imation Corporation - Medical Imaging Syst", 0
db 0x12, 0xE4, "Brooktrout Technology Incorporated", 0
db 0x12, 0xE6, "Cirel Systems", 0
db 0x12, 0xE7, "Sebring Systems Incorporated", 0
db 0x12, 0xE8, "CRISC Corporation", 0
db 0x12, 0xE9, "GE Spacenet", 0
db 0x12, 0xEB, "Aureal Semiconductor", 0
db 0x12, 0xEC, "3A International Incorporated", 0
db 0x12, 0xED, "Optivision Incorporated", 0
db 0x12, 0xEE, "Orange Micro, Incorporated", 0
db 0x12, 0xEF, "Vienna Systems", 0
db 0x12, 0xF0, "Pentek", 0
db 0x12, 0xF1, "Sorenson Vision Incorporated", 0
db 0x12, 0xF2, "Gammagraphx Incorporated", 0
db 0x12, 0xF4, "Megatel", 0
db 0x12, 0xF5, "Forks", 0
db 0x12, 0xF7, "Cognex", 0
db 0x12, 0xF8, "Electronic-Design GmbH", 0
db 0x12, 0xF9, "FourFold Technologies", 0
db 0x12, 0xFB, "Spectrum Signal Processing", 0
db 0x12, 0xFC, "Capital Equipment Corporation", 0
db 0x12, 0xFE, "esd Electronic System Design GmbH", 0
db 0x13, 0x03, "Innovative Integration", 0
db 0x13, 0x04, "Juniper Networks Incorporated", 0
db 0x13, 0x07, "ComputerBoards", 0
db 0x13, 0x08, "Jato Technologies Incorporated", 0
db 0x13, 0x0A, "Mitsubishi Electric Microcomputer", 0
db 0x13, 0x0B, "Colorgraphic Communications Corporation", 0
db 0x13, 0x0F, "Advanet Incorporated", 0
db 0x13, 0x10, "Gespac", 0
db 0x13, 0x12, "Microscan Systems Incorporated", 0
db 0x13, 0x13, "Yaskawa Electric Co.", 0
db 0x13, 0x16, "Teradyne Incorporated", 0
db 0x13, 0x17, "ADMtek Incorporated", 0
db 0x13, 0x18, "Packet Engines, Incorporated", 0
db 0x13, 0x19, "Forte Media", 0
db 0x13, 0x1F, "SIIG", 0
db 0x13, 0x25, "austriamicrosystems", 0
db 0x13, 0x26, "Seachange International", 0
db 0x13, 0x28, "CIFELLI SYSTEMS CORPORATION", 0
db 0x13, 0x31, "RadiSys Corporation", 0
db 0x13, 0x32, "Curtiss-Wright Controls Embedded Computing", 0
db 0x13, 0x35, "Videomail Incorporated", 0
db 0x13, 0x3D, "Prisa Networks", 0
db 0x13, 0x3F, "SCM Microsystems", 0
db 0x13, 0x42, "Promax Systems Incorporated", 0
db 0x13, 0x44, "Micron Technology, Incorporated", 0
db 0x13, 0x47, "Spectracom Corporation", 0
db 0x13, 0x4A, "DTC Technology Corporation", 0
db 0x13, 0x4B, "ARK Research Corporation", 0
db 0x13, 0x4C, "Chori Joho System Co. Limited", 0
db 0x13, 0x4D, "PCTEL Incorporated", 0
db 0x13, 0x5A, "Brain Boxes Limited", 0
db 0x13, 0x5B, "Giganet Incorporated", 0
db 0x13, 0x5C, "Quatech Incorporated", 0
db 0x13, 0x5D, "ABB Network Partner AB", 0
db 0x13, 0x5E, "Sealevel Systems Incorporated", 0
db 0x13, 0x5F, "I-Data International A-S", 0
db 0x13, 0x60, "Meinberg Funkuhren GmbH & Co. KG", 0
db 0x13, 0x61, "Soliton Systems K.K.", 0
db 0x13, 0x63, "Phoenix Technologies Limited", 0
db 0x13, 0x65, "Hypercope Corporation", 0
db 0x13, 0x66, "Teijin Seiki Co. Limited", 0
db 0x13, 0x67, "Hitachi Zosen Corporation", 0
db 0x13, 0x68, "Skyware Corporation", 0
db 0x13, 0x69, "Digigram", 0
db 0x13, 0x6B, "Kawasaki Steel Corporation", 0
db 0x13, 0x6C, "Adtek System Science Co Limited", 0
db 0x13, 0x75, "Boeing - Sunnyvale", 0
db 0x13, 0x7A, "Mark Of The Unicorn Incorporated", 0
db 0x13, 0x7B, "PPT Vision", 0
db 0x13, 0x7C, "Iwatsu Electric Co Limited", 0
db 0x13, 0x7D, "Dynachip Corporation", 0
db 0x13, 0x7E, "Patriot Scientific Corporation", 0
db 0x13, 0x80, "Sanritz Automation Co LTC", 0
db 0x13, 0x81, "Brains Co. Limited", 0
db 0x13, 0x82, "Marian - Electronic & Software", 0
db 0x13, 0x84, "Stellar Semiconductor Incorporated", 0
db 0x13, 0x85, "Netgear", 0
db 0x13, 0x87, "Curtiss-Wright Controls Electronic Systems", 0
db 0x13, 0x88, "Hitachi Information Technology Co Limited", 0
db 0x13, 0x89, "Applicom International", 0
db 0x13, 0x8A, "Validity Sensors, Incorporated", 0
db 0x13, 0x8B, "Tokimec Incorporated", 0
db 0x13, 0x8E, "Basler GMBH", 0
db 0x13, 0x8F, "Patapsco Designs Incorporated", 0
db 0x13, 0x90, "Concept Development Incorporated", 0
db 0x13, 0x93, "Moxa Technologies Co Limited", 0
db 0x13, 0x94, "Level One Communications", 0
db 0x13, 0x95, "Ambicom Incorporated", 0
db 0x13, 0x96, "Cipher Systems Incorporated", 0
db 0x13, 0x97, "Cologne Chip Designs GmbH", 0
db 0x13, 0x98, "Clarion Co. Limited", 0
db 0x13, 0x9A, "Alacritech Incorporated", 0
db 0x13, 0x9D, "Xstreams PLC/ EPL Limited", 0
db 0x13, 0x9E, "Echostar Data Networks", 0
db 0x13, 0xA0, "Crystal Group Incorporated", 0
db 0x13, 0xA1, "Kawasaki Heavy Industries Limited", 0
db 0x13, 0xA3, "HI-FN Incorporated", 0
db 0x13, 0xA4, "Rascom Incorporated", 0
db 0x13, 0xA7, "amc330", 0
db 0x13, 0xA8, "Exar Corporation", 0
db 0x13, 0xA9, "Siemens Healthcare", 0
db 0x13, 0xAA, "Nortel Networks - BWA Division", 0
db 0x13, 0xAF, "T.Sqware", 0
db 0x13, 0xB1, "Tamura Corporation", 0
db 0x13, 0xB4, "Wellbean Co Incorporated", 0
db 0x13, 0xB5, "ARM Limited", 0
db 0x13, 0xB6, "DLoG Gesellschaft für elektronische Datentechnik mbH", 0
db 0x13, 0xB8, "Nokia Telecommunications OY", 0
db 0x13, 0xBD, "Sharp Corporation", 0
db 0x13, 0xBF, "Sharewave Incorporated", 0
db 0x13, 0xC0, "Microgate Corporation", 0
db 0x13, 0xC1, "LSI", 0
db 0x13, 0xC2, "Technotrend Systemtechnik GMBH", 0
db 0x13, 0xC3, "Janz Computer AG", 0
db 0x13, 0xC7, "Blue Chip Technology Limited", 0
db 0x13, 0xCC, "Metheus Corporation", 0
db 0x13, 0xCF, "Studio Audio & Video Limited", 0
db 0x13, 0xD0, "B2C2 Incorporated", 0
db 0x13, 0xD1, "AboCom Systems, Incorporated", 0
db 0x13, 0xD4, "Graphics Microsystems Incorporated", 0
db 0x13, 0xD6, "K.I. Technology Co Limited", 0
db 0x13, 0xD7, "Toshiba Engineering Corporation", 0
db 0x13, 0xD8, "Phobos Corporation", 0
db 0x13, 0xD9, "Apex Incorporated", 0
db 0x13, 0xDC, "Netboost Corporation", 0
db 0x13, 0xDE, "ABB Robotics Products AB", 0
db 0x13, 0xDF, "E-Tech Incorporated", 0
db 0x13, 0xE0, "GVC Corporation", 0
db 0x13, 0xE3, "Nest Incorporated", 0
db 0x13, 0xE4, "Calculex Incorporated", 0
db 0x13, 0xE5, "Telesoft Design Limited", 0
db 0x13, 0xE9, "Intraserver Technology Incorporated", 0
db 0x13, 0xEA, "Dallas Semiconductor", 0
db 0x13, 0xF0, "IC Plus Corporation", 0
db 0x13, 0xF1, "OCE - Industries S.A.", 0
db 0x13, 0xF4, "Troika Networks Incorporated", 0
db 0x13, 0xF6, "C-Media Electronics Incorporated", 0
db 0x13, 0xF9, "NTT Advanced Technology Corporation", 0
db 0x13, 0xFA, "Pentland Systems Limited", 0
db 0x13, 0xFB, "Aydin Corporation", 0
db 0x13, 0xFD, "Micro Science Incorporated", 0
db 0x13, 0xFE, "Advantech Co., Limited", 0
db 0x13, 0xFF, "Silicon Spice Incorporated", 0
db 0x14, 0x00, "ArtX Incorporated", 0
db 0x14, 0x02, "Meilhaus Electronic GmbH Germany", 0
db 0x14, 0x04, "Fundamental Software Incorporated", 0
db 0x14, 0x06, "Oce Print Logics Technologies S.A.", 0
db 0x14, 0x07, "Lava Computer MFG Incorporated", 0
db 0x14, 0x08, "Aloka Co. Limited", 0
db 0x14, 0x09, "SUNIX Co., Limited", 0
db 0x14, 0x0A, "DSP Research Incorporated", 0
db 0x14, 0x0B, "Ramix Incorporated", 0
db 0x14, 0x0D, "Matsushita Electric Works Limited", 0
db 0x14, 0x0F, "Salient Systems Corporation", 0
db 0x14, 0x12, "IC Ensemble, Incorporated", 0
db 0x14, 0x13, "Addonics", 0
db 0x14, 0x15, "Oxford Semiconductor Limited- now part of PLX Technology", 0
db 0x14, 0x18, "Kyushu Electronics Systems Incorporated", 0
db 0x14, 0x19, "Excel Switching Corporation", 0
db 0x14, 0x1B, "Zoom Telephonics Incorporated", 0
db 0x14, 0x1E, "Fanuc Co. Limited", 0
db 0x14, 0x1F, "Visiontech Limited", 0
db 0x14, 0x20, "Psion Dacom PLC", 0
db 0x14, 0x25, "Chelsio Communications", 0
db 0x14, 0x28, "Edec Co Limited", 0
db 0x14, 0x29, "Unex Technology Corporation", 0
db 0x14, 0x2A, "Kingmax Technology Incorporated", 0
db 0x14, 0x2B, "Radiolan", 0
db 0x14, 0x2C, "Minton Optic Industry Co Limited", 0
db 0x14, 0x2D, "Pixstream Incorporated", 0
db 0x14, 0x30, "ITT Aerospace/Communications Division", 0
db 0x14, 0x33, "Eltec Elektronik AG", 0
db 0x14, 0x35, "RTD Embedded Technologies, Incorporated", 0
db 0x14, 0x36, "CIS Technology Incorporated", 0
db 0x14, 0x37, "Nissin IncorporatedCo", 0
db 0x14, 0x38, "Atmel-Dream", 0
db 0x14, 0x3F, "Lightwell Co Limited- Zax Division", 0
db 0x14, 0x41, "Agie SA.", 0
db 0x14, 0x43, "Unibrain S.A.", 0
db 0x14, 0x45, "Logical Co Limited", 0
db 0x14, 0x46, "Graphin Co., LTD", 0
db 0x14, 0x47, "Aim GMBH", 0
db 0x14, 0x48, "Alesis Studio", 0
db 0x14, 0x4A, "ADLINK Technology Incorporated", 0
db 0x14, 0x4B, "Loronix Information Systems, Incorporated", 0
db 0x14, 0x4D, "sanyo", 0
db 0x14, 0x50, "Octave Communications Ind.", 0
db 0x14, 0x51, "SP3D Chip Design GMBH", 0
db 0x14, 0x53, "Mycom Incorporated", 0
db 0x14, 0x58, "Giga-Byte Technologies", 0
db 0x14, 0x5C, "Cryptek", 0
db 0x14, 0x5F, "Baldor Electric Company", 0
db 0x14, 0x60, "Dynarc Incorporated", 0
db 0x14, 0x62, "Micro-Star International Co Limited", 0
db 0x14, 0x63, "Fast Corporation", 0
db 0x14, 0x64, "Interactive Circuits & Systems Limited", 0
db 0x14, 0x68, "Ambit Microsystems Corporation", 0
db 0x14, 0x69, "Cleveland Motion Controls", 0
db 0x14, 0x6C, "Ruby Tech Corporation", 0
db 0x14, 0x6D, "Tachyon Incorporated", 0
db 0x14, 0x6E, "WMS Gaming", 0
db 0x14, 0x71, "Integrated Telecom Express Incorporated", 0
db 0x14, 0x73, "Zapex Technologies Incorporated", 0
db 0x14, 0x74, "Doug Carson & Associates", 0
db 0x14, 0x77, "Net Insight", 0
db 0x14, 0x78, "Diatrend Corporation", 0
db 0x14, 0x7B, "Abit Computer Corporation", 0
db 0x14, 0x7F, "Nihon Unisys Limited", 0
db 0x14, 0x82, "Isytec - Integrierte Systemtechnik Gmbh", 0
db 0x14, 0x83, "Labway Coporation", 0
db 0x14, 0x85, "Erma - Electronic GMBH", 0
db 0x14, 0x89, "KYE Systems Corporation", 0
db 0x14, 0x8A, "Opto 22", 0
db 0x14, 0x8B, "Innomedialogic Incorporated", 0
db 0x14, 0x8C, "C.P. Technology Co. Limited", 0
db 0x14, 0x8D, "Digicom Systems Incorporated", 0
db 0x14, 0x8E, "OSI Plus Corporation", 0
db 0x14, 0x8F, "Plant Equipment Incorporated", 0
db 0x14, 0x90, "TC Labs Pty Limited", 0
db 0x14, 0x91, "Futronic", 0
db 0x14, 0x93, "Maker Communications", 0
db 0x14, 0x95, "Tokai Communications Industry Co. Limited", 0
db 0x14, 0x96, "Joytech Computer Co. Limited", 0
db 0x14, 0x97, "SMA Technologie AG", 0
db 0x14, 0x98, "Tews Technologies", 0
db 0x14, 0x99, "Micro-Technology Co Limited", 0
db 0x14, 0x9A, "Andor Technology Limited", 0
db 0x14, 0x9B, "Seiko Instruments Incorporated", 0
db 0x14, 0x9E, "Mapletree Networks Incorporated", 0
db 0x14, 0x9F, "Lectron Co Limited", 0
db 0x14, 0xA0, "Softing AG", 0
db 0x14, 0xA2, "Millennium Engineering Incorporated", 0
db 0x14, 0xA4, "GVC/BCM Advanced Research", 0
db 0x14, 0xA9, "Hivertec Incorporated", 0
db 0x14, 0xAB, "Mentor Graphics Corporation", 0
db 0x14, 0xB1, "Nextcom K.K.", 0
db 0x14, 0xB3, "Xpeed Incorporated", 0
db 0x14, 0xB4, "Philips Business Electronics B.V.", 0
db 0x14, 0xB5, "Creamware GmbH", 0
db 0x14, 0xB6, "Quantum Data Corporation", 0
db 0x14, 0xB7, "Proxim Incorporated", 0
db 0x14, 0xB9, "Aironet Wireless Communication", 0
db 0x14, 0xBA, "Internix Incorporated", 0
db 0x14, 0xBB, "Semtech Corporation", 0
db 0x14, 0xBE, "L3 Communications", 0
db 0x14, 0xC0, "Compal Electronics, Incorporated", 0
db 0x14, 0xC1, "Myricom Incorporated", 0
db 0x14, 0xC2, "DTK Computer", 0
db 0x14, 0xC4, "Iwasaki Information Systems Co Limited", 0
db 0x14, 0xC5, "ABB AB (Sweden)", 0
db 0x14, 0xC6, "Data Race Incorporated", 0
db 0x14, 0xC7, "Modular Technology Limited", 0
db 0x14, 0xC8, "Turbocomm Tech Incorporated", 0
db 0x14, 0xC9, "Odin Telesystems Incorporated", 0
db 0x14, 0xCB, "Billionton Systems Incorporated/Cadmus Micro Incorporated", 0
db 0x14, 0xCD, "Universal Scientific Ind.", 0
db 0x14, 0xCF, "TEK Microsystems Incorporated", 0
db 0x14, 0xD4, "Panacom Technology Corporation", 0
db 0x14, 0xD5, "Nitsuko Corporation", 0
db 0x14, 0xD6, "Accusys Incorporated", 0
db 0x14, 0xD7, "Hirakawa Hewtech Corporation", 0
db 0x14, 0xD8, "Hopf Elektronik GMBH", 0
db 0x14, 0xD9, "Alpha Processor Incorporated", 0
db 0x14, 0xDB, "Avlab Technology Incorporated", 0
db 0x14, 0xDC, "Amplicon Liveline Limited", 0
db 0x14, 0xDD, "Imodl Incorporated", 0
db 0x14, 0xDE, "Applied Integration Corporation", 0
db 0x14, 0xE3, "Amtelco", 0
db 0x14, 0xE4, "Broadcom", 0
db 0x14, 0xEA, "Planex Communications, Incorporated", 0
db 0x14, 0xEB, "Seiko Epson Corporation", 0
db 0x14, 0xEC, "Acqiris", 0
db 0x14, 0xED, "Datakinetics Limited", 0
db 0x14, 0xEF, "Carry Computer Eng. Co Limited", 0
db 0x14, 0xF1, "Conexant", 0
db 0x14, 0xF2, "Mobility Electronics, Incorporated", 0
db 0x14, 0xF4, "Tokyo Electronic Industry Co. Limited", 0
db 0x14, 0xF5, "Sopac Limited", 0
db 0x14, 0xF6, "Coyote Technologies LLC", 0
db 0x14, 0xF7, "Wolf Technology Incorporated", 0
db 0x14, 0xF8, "Audiocodes Incorporated", 0
db 0x14, 0xF9, "AG Communications", 0
db 0x14, 0xFB, "Transas Marine (UK) Limited", 0
db 0x14, 0xFC, "Quadrics Limited", 0
db 0x14, 0xFD, "Silex Technology Incorporated", 0
db 0x14, 0xFE, "Archtek Telecom Corporation", 0
db 0x14, 0xFF, "Twinhead International Corporation", 0
db 0x15, 0x01, "Banksoft Canada Limited", 0
db 0x15, 0x02, "Mitsubishi Electric Logistics Support Co", 0
db 0x15, 0x03, "Kawasaki LSI USA Incorporated", 0
db 0x15, 0x04, "Kaiser Electronics", 0
db 0x15, 0x06, "Chameleon Systems Incorporated", 0
db 0x15, 0x07, "Htec Limited", 0
db 0x15, 0x09, "First International Computer Incorporated", 0
db 0x15, 0x0B, "Yamashita Systems Corporation", 0
db 0x15, 0x0C, "Kyopal Co Limited", 0
db 0x15, 0x0D, "Warpspped Incorporated", 0
db 0x15, 0x0E, "C-Port Corporation", 0
db 0x15, 0x0F, "Intec GMBH", 0
db 0x15, 0x10, "Behavior Tech Computer Corporation", 0
db 0x15, 0x11, "Centillium Technology Corporation", 0
db 0x15, 0x12, "Rosun Technologies Incorporated", 0
db 0x15, 0x13, "Raychem", 0
db 0x15, 0x14, "TFL LAN Incorporated", 0
db 0x15, 0x15, "ICS Advent", 0
db 0x15, 0x16, "Myson Technology Incorporated", 0
db 0x15, 0x17, "Echotek Corporation", 0
db 0x15, 0x18, "Kontron Modular Computers GmbH (PEP Modular Computers GMBH)", 0
db 0x15, 0x19, "Telefon Aktiebolaget LM Ericsson", 0
db 0x15, 0x1A, "Globetek Incorporated", 0
db 0x15, 0x1B, "Combox Limited", 0
db 0x15, 0x1C, "Digital Audio Labs Incorporated", 0
db 0x15, 0x1D, "Fujitsu Computer Products Of America", 0
db 0x15, 0x1E, "Matrix Corporation", 0
db 0x15, 0x1F, "Topic Semiconductor Corporation", 0
db 0x15, 0x20, "Chaplet System Incorporated", 0
db 0x15, 0x21, "Bell Corporation", 0
db 0x15, 0x22, "Mainpine Limited", 0
db 0x15, 0x23, "Music Semiconductors", 0
db 0x15, 0x24, "ENE Technology Incorporated", 0
db 0x15, 0x25, "Impact Technologies", 0
db 0x15, 0x26, "ISS Incorporated", 0
db 0x15, 0x27, "Solectron", 0
db 0x15, 0x28, "Acksys", 0
db 0x15, 0x29, "American Microsystems Incorporated", 0
db 0x15, 0x2A, "Quickturn Design Systems", 0
db 0x15, 0x2B, "Flytech Technology Co Limited", 0
db 0x15, 0x2C, "Macraigor Systems LLC", 0
db 0x15, 0x2D, "Quanta Computer Incorporated", 0
db 0x15, 0x2E, "Melec Incorporated", 0
db 0x15, 0x2F, "Philips - Crypto", 0
db 0x15, 0x32, "Echelon Corporation", 0
db 0x15, 0x33, "Baltimore", 0
db 0x15, 0x34, "Road Corporation", 0
db 0x15, 0x35, "Evergreen Technologies Incorporated", 0
db 0x15, 0x37, "Datalex Communcations", 0
db 0x15, 0x38, "Aralion Incorporated", 0
db 0x15, 0x39, "Atelier Informatiques et Electronique Et", 0
db 0x15, 0x3A, "ONO Sokki", 0
db 0x15, 0x3B, "Terratec Electronic GMBH", 0
db 0x15, 0x3C, "Antal Electronic", 0
db 0x15, 0x3D, "Filanet Corporation", 0
db 0x15, 0x3E, "Techwell Incorporated", 0
db 0x15, 0x3F, "MIPS Technologies Incorporated", 0
db 0x15, 0x40, "Provideo Multimedia Co Limited", 0
db 0x15, 0x41, "Telocity Incorporated", 0
db 0x15, 0x42, "Vivid Technology Incorporated", 0
db 0x15, 0x43, "Silicon Laboratories", 0
db 0x15, 0x44, "DCM Technologies Limited", 0
db 0x15, 0x45, "VisionTek", 0
db 0x15, 0x46, "IOI Technology Corporation", 0
db 0x15, 0x47, "Mitutoyo Corporation", 0
db 0x15, 0x48, "Jet Propulsion Laboratory", 0
db 0x15, 0x49, "Interconnect Systems Solutions", 0
db 0x15, 0x4A, "Max Technologies Incorporated", 0
db 0x15, 0x4B, "Computex Co Limited", 0
db 0x15, 0x4C, "Visual Technology Incorporated", 0
db 0x15, 0x4D, "PAN International Industrial Corporation", 0
db 0x15, 0x4E, "Servotest Limited", 0
db 0x15, 0x4F, "Stratabeam Technology", 0
db 0x15, 0x50, "Open Network Company Limited", 0
db 0x15, 0x51, "Smart Electronic Development GMBH", 0
db 0x15, 0x53, "Chicony Electronics Company Limited", 0
db 0x15, 0x54, "Prolink Microsystems Corporation", 0
db 0x15, 0x55, "Gesytec GmbH", 0
db 0x15, 0x56, "PLDA", 0
db 0x15, 0x57, "Mediastar Co. Limited", 0
db 0x15, 0x58, "Clevo/Kapok Computer", 0
db 0x15, 0x59, "SI Logic Limited", 0
db 0x15, 0x5A, "Innomedia Incorporated", 0
db 0x15, 0x5B, "Protac International Corporation", 0
db 0x15, 0x5C, "s", 0
db 0x15, 0x5D, "MAC System Company Limited", 0
db 0x15, 0x5E, "KUKA Roboter GmbH", 0
db 0x15, 0x5F, "Perle Systems Limited", 0
db 0x15, 0x60, "Terayon Communications Systems", 0
db 0x15, 0x61, "Viewgraphics Incorporated", 0
db 0x15, 0x62, "Symbol Technologies, Incorporated", 0
db 0x15, 0x63, "A-Trend Technology Company Limited", 0
db 0x15, 0x64, "Yamakatsu Electronics Industry Company Limited", 0
db 0x15, 0x65, "Biostar Microtech Intl Corporation", 0
db 0x15, 0x66, "Ardent Technologies Incorporated", 0
db 0x15, 0x67, "Jungsoft", 0
db 0x15, 0x68, "DDK Electronics Incorporated", 0
db 0x15, 0x69, "Palit Microsystems Incorporated", 0
db 0x15, 0x6A, "Avtec Systems Incorporated", 0
db 0x15, 0x6B, "S2io Incorporated", 0
db 0x15, 0x6C, "Vidac Electronics GMBH", 0
db 0x15, 0x6D, "Alpha-Top Corporation", 0
db 0x15, 0x6E, "Alfa Incorporated", 0
db 0x15, 0x6F, "M-Systems Flash Disk Pioneers Limited", 0
db 0x15, 0x70, "Lecroy Corporation", 0
db 0x15, 0x71, "Contemporary Controls", 0
db 0x15, 0x72, "Otis Elevator Company", 0
db 0x15, 0x73, "Lattice - Vantis", 0
db 0x15, 0x74, "Fairchild Semiconductor", 0
db 0x15, 0x75, "Voltaire Advanced Data Security Limited", 0
db 0x15, 0x76, "Viewcast Com", 0
db 0x15, 0x78, "Hitt", 0
db 0x15, 0x79, "Dual Technology Corporation", 0
db 0x15, 0x7A, "Japan Elecronics Ind. Incorporated", 0
db 0x15, 0x7B, "Star Multimedia Corporation", 0
db 0x15, 0x7C, "Eurosoft (UK)", 0
db 0x15, 0x7D, "Gemflex Networks", 0
db 0x15, 0x7E, "Transition Networks", 0
db 0x15, 0x7F, "PX Instruments Technology Limited", 0
db 0x15, 0x80, "Primex Aerospace Co.", 0
db 0x15, 0x81, "SEH Computertechnik GMBH", 0
db 0x15, 0x82, "Cytec Corporation", 0
db 0x15, 0x83, "Inet Technologies Incorporated", 0
db 0x15, 0x84, "Vetronix Corporation Engenharia Limited", 0
db 0x15, 0x85, "Marconi Commerce Systems SRL", 0
db 0x15, 0x86, "Lancast Incorporated", 0
db 0x15, 0x87, "Konica Corporation", 0
db 0x15, 0x88, "Solidum Systems Corporation", 0
db 0x15, 0x89, "Atlantek Microsystems Pty Limited", 0
db 0x15, 0x8A, "Digalog Systems Incorporated", 0
db 0x15, 0x8B, "Allied Data Technologies", 0
db 0x15, 0x8C, "Hitachi Semiconductor & Devices Sales Co", 0
db 0x15, 0x8D, "Point Multimedia Systems", 0
db 0x15, 0x8E, "Lara Technology Incorporated", 0
db 0x15, 0x8F, "Ditect Coop", 0
db 0x15, 0x90, "3pardata Incorporated", 0
db 0x15, 0x91, "ARN", 0
db 0x15, 0x92, "Syba Tech Limited", 0
db 0x15, 0x93, "Bops Incorporated", 0
db 0x15, 0x94, "Netgame Limited", 0
db 0x15, 0x95, "Diva Systems Corporation", 0
db 0x15, 0x96, "Folsom Research Incorporated", 0
db 0x15, 0x97, "Memec Design Services", 0
db 0x15, 0x98, "Granite Microsystems", 0
db 0x15, 0x99, "Delta Electronics Incorporated", 0
db 0x15, 0x9A, "General Instrument", 0
db 0x15, 0x9B, "Faraday Technology Corporation", 0
db 0x15, 0x9C, "Stratus Computer Systems", 0
db 0x15, 0x9D, "Ningbo Harrison Electronics Co Limited", 0
db 0x15, 0x9E, "A-Max Technology Co Limited", 0
db 0x15, 0x9F, "Galea Network Security", 0
db 0x15, 0xA0, "Compumaster SRL", 0
db 0x15, 0xA1, "Geocast Network Systems Incorporated", 0
db 0x15, 0xA2, "Catalyst Enterprises Incorporated", 0
db 0x15, 0xA3, "Italtel", 0
db 0x15, 0xA4, "X-Net OY", 0
db 0x15, 0xA5, "Toyota MACS Incorporated", 0
db 0x15, 0xA6, "Sunlight Ultrasound Technologies Limited", 0
db 0x15, 0xA7, "SSE Telecom Incorporated", 0
db 0x15, 0xA8, "Shanghai Communications Technologies Cen", 0
db 0x15, 0xAA, "Moreton Bay", 0
db 0x15, 0xAB, "Bluesteel Networks Incorporated", 0
db 0x15, 0xAC, "North Atlantic Instruments", 0
db 0x15, 0xAD, "VMware Incorporated", 0
db 0x15, 0xAE, "Amersham Pharmacia Biotech", 0
db 0x15, 0xB0, "Zoltrix International Limited", 0
db 0x15, 0xB1, "Source Technology Incorporated", 0
db 0x15, 0xB2, "Mosaid Technologies Incorporated", 0
db 0x15, 0xB3, "Mellanox Technology", 0
db 0x15, 0xB4, "CCI/Triad", 0
db 0x15, 0xB5, "Cimetrics Incorporated", 0
db 0x15, 0xB6, "Texas Memory Systems Incorporated", 0
db 0x15, 0xB7, "Sandisk Corporation", 0
db 0x15, 0xB8, "Addi-Data GMBH", 0
db 0x15, 0xB9, "Maestro Digital Communications", 0
db 0x15, 0xBA, "Impacct Technology Corporation", 0
db 0x15, 0xBB, "Portwell Incorporated", 0
db 0x15, 0xBC, "Agilent Technologies", 0
db 0x15, 0xBD, "DFI Incorporated", 0
db 0x15, 0xBE, "Sola Electronics", 0
db 0x15, 0xBF, "High Tech Computer Corporation (HTC)", 0
db 0x15, 0xC0, "BVM Limited", 0
db 0x15, 0xC1, "Quantel", 0
db 0x15, 0xC2, "Newer Technology Incorporated", 0
db 0x15, 0xC3, "Taiwan Mycomp Co Limited", 0
db 0x15, 0xC4, "EVSX Incorporated", 0
db 0x15, 0xC5, "Procomp Informatics Limited", 0
db 0x15, 0xC6, "Technical University Of Budapest", 0
db 0x15, 0xC7, "Tateyama System Laboratory Co Limited", 0
db 0x15, 0xC8, "Penta Media Co. Limited", 0
db 0x15, 0xC9, "Serome Technology Incorporated", 0
db 0x15, 0xCA, "Bitboys OY", 0
db 0x15, 0xCB, "AG Electronics Limited", 0
db 0x15, 0xCC, "Hotrail Incorporated", 0
db 0x15, 0xCD, "Dreamtech Co Limited", 0
db 0x15, 0xCE, "Genrad Incorporated", 0
db 0x15, 0xCF, "Hilscher GMBH", 0
db 0x15, 0xD1, "Infineon Technologies AG", 0
db 0x15, 0xD2, "FIC (First International Computer Incorporated", 0
db 0x15, 0xD3, "NDS Technologies Israel Limited", 0
db 0x15, 0xD4, "Iwill Corporation", 0
db 0x15, 0xD5, "Tatung Co.", 0
db 0x15, 0xD6, "Entridia Corporation", 0
db 0x15, 0xD7, "Rockwell-Collins Incorporated", 0
db 0x15, 0xD8, "Cybernetics Technology Co Limited", 0
db 0x15, 0xD9, "Super Micro Computer Incorporated", 0
db 0x15, 0xDA, "Cyberfirm Incorporated", 0
db 0x15, 0xDB, "Applied Computing Systems Incorporated", 0
db 0x15, 0xDC, "Litronic Incorporated", 0
db 0x15, 0xDD, "Sigmatel Incorporated", 0
db 0x15, 0xDE, "Malleable Technologies Incorporated", 0
db 0x15, 0xE0, "Cacheflow Incorporated", 0
db 0x15, 0xE1, "Voice Technologies Group", 0
db 0x15, 0xE2, "Quicknet Technologies Incorporated", 0
db 0x15, 0xE3, "Networth Technologies Incorporated", 0
db 0x15, 0xE4, "VSN Systemen BV", 0
db 0x15, 0xE5, "Valley Technologies Incorporated", 0
db 0x15, 0xE6, "Agere Incorporated", 0
db 0x15, 0xE7, "GET Engineering Corporation", 0
db 0x15, 0xE8, "National Datacomm Corporation", 0
db 0x15, 0xE9, "Pacific Digital Corporation", 0
db 0x15, 0xEA, "Tokyo Denshi Sekei K.K.", 0
db 0x15, 0xEB, "Drsearch GMBH", 0
db 0x15, 0xEC, "Beckhoff Automation GmbH", 0
db 0x15, 0xED, "Macrolink Incorporated", 0
db 0x15, 0xEE, "IN Win Development Incorporated", 0
db 0x15, 0xEF, "Intelligent Paradigm Incorporated", 0
db 0x15, 0xF0, "B-Tree Systems Incorporated", 0
db 0x15, 0xF1, "Times N Systems Incorporated", 0
db 0x15, 0xF2, "SPOT Imaging Solutions a division of Diagnostic Instruments Incorporated", 0
db 0x15, 0xF3, "Digitmedia Corporation", 0
db 0x15, 0xF4, "Valuesoft", 0
db 0x15, 0xF5, "Power Micro Research", 0
db 0x15, 0xF6, "Extreme Packet Device Incorporated", 0
db 0x15, 0xF7, "Banctec", 0
db 0x15, 0xF8, "Koga Electronics Co", 0
db 0x15, 0xF9, "Zenith Electronics Co", 0
db 0x15, 0xFA, "Axzam Corporation", 0
db 0x15, 0xFB, "Zilog Incorporated", 0
db 0x15, 0xFC, "Techsan Electronics Co Limited", 0
db 0x15, 0xFD, "N-Cubed.Net", 0
db 0x15, 0xFE, "Kinpo Electronics Incorporated", 0
db 0x15, 0xFF, "Fastpoint Technologies Incorporated", 0
db 0x16, 0x00, "Northrop Grumman - Canada Limited", 0
db 0x16, 0x01, "Tenta Technology", 0
db 0x16, 0x02, "Prosys-TEC Incorporated", 0
db 0x16, 0x03, "Nokia Wireless Business Communications", 0
db 0x16, 0x04, "Central System Research Co Limited", 0
db 0x16, 0x05, "Pairgain Technologies", 0
db 0x16, 0x06, "Europop AG", 0
db 0x16, 0x07, "Lava Semiconductor Manufacturing Incorporated", 0
db 0x16, 0x08, "Automated Wagering International", 0
db 0x16, 0x09, "Sciemetric Instruments Incorporated", 0
db 0x16, 0x0A, "Kollmorgen Servotronix", 0
db 0x16, 0x0B, "Onkyo Corporation", 0
db 0x16, 0x0C, "Oregon Micro Systems Incorporated", 0
db 0x16, 0x0D, "Aaeon Electronics Incorporated", 0
db 0x16, 0x0E, "CML Emergency Services", 0
db 0x16, 0x0F, "ITEC Co Limited", 0
db 0x16, 0x10, "Tottori Sanyo Electric Co Limited", 0
db 0x16, 0x11, "Bel Fuse Incorporated", 0
db 0x16, 0x12, "Telesynergy Research Incorporated", 0
db 0x16, 0x13, "System Craft Incorporated", 0
db 0x16, 0x14, "Jace Tech Incorporated", 0
db 0x16, 0x15, "Equus Computer Systems Incorporated", 0
db 0x16, 0x16, "Iotech Incorporated", 0
db 0x16, 0x17, "Rapidstream Incorporated", 0
db 0x16, 0x18, "Esec SA", 0
db 0x16, 0x19, "FarSite Communications Limited", 0
db 0x16, 0x1B, "Mobilian Israel Limited", 0
db 0x16, 0x1C, "Berkshire Products", 0
db 0x16, 0x1D, "Gatec", 0
db 0x16, 0x1E, "Kyoei Sangyo Co Limited", 0
db 0x16, 0x1F, "Arima Computer Corporation", 0
db 0x16, 0x20, "Sigmacom Co Limited", 0
db 0x16, 0x21, "Lynx Studio Technology Incorporated", 0
db 0x16, 0x22, "Nokia Home Communications", 0
db 0x16, 0x23, "KRF Tech Limited", 0
db 0x16, 0x24, "CE Infosys GMBH", 0
db 0x16, 0x25, "Warp Nine Engineering", 0
db 0x16, 0x26, "TDK Semiconductor Corporation", 0
db 0x16, 0x27, "BCom Electronics Incorporated", 0
db 0x16, 0x29, "Kongsberg Spacetec a.s.", 0
db 0x16, 0x2A, "Sejin Computerland Company Limited", 0
db 0x16, 0x2B, "Shanghai Bell Company Limited", 0
db 0x16, 0x2C, "C&H Technologies Incorporated", 0
db 0x16, 0x2D, "Reprosoft Company Limited", 0
db 0x16, 0x2E, "Margi Systems Incorporated", 0
db 0x16, 0x2F, "Rohde & Schwarz GMBH & Co KG", 0
db 0x16, 0x30, "Sky Computers Incorporated", 0
db 0x16, 0x31, "NEC Computer International", 0
db 0x16, 0x32, "Verisys Incorporated", 0
db 0x16, 0x33, "Adac Corporation", 0
db 0x16, 0x34, "Visionglobal Network Corporation", 0
db 0x16, 0x35, "Decros / S.ICZ a.s.", 0
db 0x16, 0x36, "Jean Company Limited", 0
db 0x16, 0x37, "NSI", 0
db 0x16, 0x38, "Eumitcom Technology Incorporated", 0
db 0x16, 0x3A, "Air Prime Incorporated", 0
db 0x16, 0x3B, "Glotrex Co Limited", 0
db 0x16, 0x3C, "intel", 0
db 0x16, 0x3D, "Heidelberg Digital LLC", 0
db 0x16, 0x3E, "3dpower", 0
db 0x16, 0x3F, "Renishaw PLC", 0
db 0x16, 0x40, "Intelliworxx Incorporated", 0
db 0x16, 0x41, "MKNet Corporation", 0
db 0x16, 0x42, "Bitland", 0
db 0x16, 0x43, "Hajime Industries Limited", 0
db 0x16, 0x44, "Western Avionics Limited", 0
db 0x16, 0x45, "Quick-Serv. Computer Co. Limited", 0
db 0x16, 0x46, "Nippon Systemware Co Limited", 0
db 0x16, 0x47, "Hertz Systemtechnik GMBH", 0
db 0x16, 0x48, "MeltDown Systems LLC", 0
db 0x16, 0x49, "Jupiter Systems", 0
db 0x16, 0x4A, "Aiwa Co. Limited", 0
db 0x16, 0x4C, "Department Of Defense", 0
db 0x16, 0x4D, "Ishoni Networks", 0
db 0x16, 0x4E, "Micrel Incorporated", 0
db 0x16, 0x4F, "Datavoice (Pty) Limited", 0
db 0x16, 0x50, "Admore Technology Incorporated", 0
db 0x16, 0x51, "Chaparral Network Storage", 0
db 0x16, 0x52, "Spectrum Digital Incorporated", 0
db 0x16, 0x53, "Nature Worldwide Technology Corporation", 0
db 0x16, 0x54, "Sonicwall Incorporated", 0
db 0x16, 0x55, "Dazzle Multimedia Incorporated", 0
db 0x16, 0x56, "Insyde Software Corporation", 0
db 0x16, 0x57, "Brocade Communications Systems", 0
db 0x16, 0x58, "Med Associates Incorporated", 0
db 0x16, 0x59, "Shiba Denshi Systems Incorporated", 0
db 0x16, 0x5A, "Epix Incorporated", 0
db 0x16, 0x5B, "Real-Time Digital Incorporated", 0
db 0x16, 0x5C, "Kondo Kagaku", 0
db 0x16, 0x5D, "Hsing Tech. Enterprise Co. Limited", 0
db 0x16, 0x5E, "Hyunju Computer Co. Limited", 0
db 0x16, 0x5F, "Comartsystem Korea", 0
db 0x16, 0x60, "Network Security Technologies Incorporated (NetSec)", 0
db 0x16, 0x61, "Worldspace Corporation", 0
db 0x16, 0x62, "Int Labs", 0
db 0x16, 0x63, "Elmec Incorporated Limited", 0
db 0x16, 0x64, "Fastfame Technology Co. Limited", 0
db 0x16, 0x65, "Edax Incorporated", 0
db 0x16, 0x66, "Norpak Corporation", 0
db 0x16, 0x67, "CoSystems Incorporated", 0
db 0x16, 0x68, "Actiontec Electronics Incorporated", 0
db 0x16, 0x6A, "Komatsu Limited", 0
db 0x16, 0x6B, "Supernet Incorporated", 0
db 0x16, 0x6C, "Shade Limited", 0
db 0x16, 0x6D, "Sibyte Incorporated", 0
db 0x16, 0x6E, "Schneider Automation Incorporated", 0
db 0x16, 0x6F, "Televox Software Incorporated", 0
db 0x16, 0x70, "Rearden Steel", 0
db 0x16, 0x71, "Atan Technology Incorporated", 0
db 0x16, 0x72, "Unitec Co. Limited", 0
db 0x16, 0x73, "pctel", 0
db 0x16, 0x75, "Square Wave Technology", 0
db 0x16, 0x76, "Emachines Incorporated", 0
db 0x16, 0x77, "Bernecker + Rainer", 0
db 0x16, 0x78, "INH Semiconductor", 0
db 0x16, 0x79, "Tokyo Electron Device Limited", 0
db 0x16, 0x7F, "iba AG", 0
db 0x16, 0x80, "Dunti Corporation", 0
db 0x16, 0x81, "Hercules", 0
db 0x16, 0x82, "PINE Technology, Limited", 0
db 0x16, 0x88, "CastleNet Technology Incorporated", 0
db 0x16, 0x8A, "Utimaco Safeware AG", 0
db 0x16, 0x8B, "Circut Assembly Corporation", 0
db 0x16, 0x8C, "Atheros Communications Incorporated", 0
db 0x16, 0x8D, "NMI Electronics Limited", 0
db 0x16, 0x8E, "Hyundai MultiCAV Computer Co. Limited", 0
db 0x16, 0x8F, "KDS Innotech Corporation", 0
db 0x16, 0x90, "NetContinuum, Incorporated", 0
db 0x16, 0x93, "FERMA", 0
db 0x16, 0x95, "EPoX Computer Company Limited", 0
db 0x16, 0xAE, "SafeNet Incorporated", 0
db 0x16, 0xB3, "CNF Mobile Solutions", 0
db 0x16, 0xB8, "Sonnet Technologies, Incorporated", 0
db 0x16, 0xCA, "Cenatek Incorporated", 0
db 0x16, 0xCB, "Minolta Co. Limited", 0
db 0x16, 0xCC, "Inari Incorporated", 0
db 0x16, 0xD0, "Systemax", 0
db 0x16, 0xE0, "Third Millenium Test Solutions, Incorporated", 0
db 0x16, 0xE5, "Intellon Corporation", 0
db 0x16, 0xEC, "U.S. Robotics", 0
db 0x16, 0xF0, "LaserLinc Incorporated", 0
db 0x16, 0xF1, "Adicti Corporation", 0
db 0x16, 0xF3, "Jetway Information Company Limited", 0
db 0x16, 0xF6, "VideoTele.com Incorporated", 0
db 0x17, 0x00, "Antara LLC", 0
db 0x17, 0x01, "Interactive Computer Products Incorporated", 0
db 0x17, 0x02, "Internet Machines Corporation", 0
db 0x17, 0x03, "Desana Systems", 0
db 0x17, 0x04, "Clearwater Networks", 0
db 0x17, 0x05, "Digital First", 0
db 0x17, 0x06, "Pacific Broadband Communications", 0
db 0x17, 0x07, "Cogency Semiconductor Incorporated", 0
db 0x17, 0x08, "Harris Corporation", 0
db 0x17, 0x09, "Zarlink Semiconductor", 0
db 0x17, 0x0A, "Alpine Electronics Incorporated", 0
db 0x17, 0x0B, "NetOctave Incorporated", 0
db 0x17, 0x0C, "YottaYotta Incorporated", 0
db 0x17, 0x0D, "SensoMotoric Instruments GmbH", 0
db 0x17, 0x0E, "San Valley Systems, Incorporated", 0
db 0x17, 0x0F, "Cyberdyne Incorporated", 0
db 0x17, 0x10, "Pelago Networks", 0
db 0x17, 0x11, "MyName Technologies, Incorporated", 0
db 0x17, 0x12, "NICE Systems Incorporated", 0
db 0x17, 0x13, "TOPCON Corporation", 0
db 0x17, 0x25, "Vitesse Semiconductor", 0
db 0x17, 0x34, "Fujitsu-Siemens Computers GmbH", 0
db 0x17, 0x37, "LinkSys", 0
db 0x17, 0x3B, "Altima Communications Incorporated", 0
db 0x17, 0x43, "Peppercon AG", 0
db 0x17, 0x4B, "PC Partner Limited", 0
db 0x17, 0x52, "Global Brands Manufacture Limited", 0
db 0x17, 0x53, "TeraRecon Incorporated", 0
db 0x17, 0x55, "Alchemy Semiconductor Incorporated", 0
db 0x17, 0x6A, "General Dynamics Canada", 0
db 0x17, 0x75, "General Electric", 0
db 0x17, 0x89, "Ennyah Technologies Corporation", 0
db 0x17, 0x93, "Unitech Electronics Company Limited", 0
db 0x17, 0xA1, "Tascorp", 0
db 0x17, 0xA7, "Start Network Technology Company Limited", 0
db 0x17, 0xAA, "Legend Limited (Beijing)", 0
db 0x17, 0xAB, "Phillips Components", 0
db 0x17, 0xAF, "Hightech Information Systems Limited", 0
db 0x17, 0xBE, "Philips Semiconductors", 0
db 0x17, 0xC0, "Wistron Corporation", 0
db 0x17, 0xC4, "Movita", 0
db 0x17, 0xCC, "NetChip", 0
db 0x17, 0xCD, "Cadence Design Systems", 0
db 0x17, 0xD5, "Neterion Incorporated", 0
db 0x17, 0xDB, "Cray Incorporated", 0
db 0x17, 0xE9, "DH electronics GmbH / Sabrent", 0
db 0x17, 0xEE, "Connect Components Limited", 0
db 0x17, 0xF3, "RDC Semiconductor Company Limited", 0
db 0x17, 0xFE, "INPROCOMM", 0
db 0x18, 0x13, "Ambient Technologies Incorporated", 0
db 0x18, 0x14, "Ralink Technology, Corporation", 0
db 0x18, 0x15, "devolo AG", 0
db 0x18, 0x20, "InfiniCon Systems, Incorporated", 0
db 0x18, 0x24, "Avocent", 0
db 0x18, 0x41, "Panda Platinum", 0
db 0x18, 0x60, "Primagraphics Limited", 0
db 0x18, 0x6C, "Humusoft S.R.O", 0
db 0x18, 0x87, "Elan Digital Systems Limited", 0
db 0x18, 0x88, "Varisys Limited", 0
db 0x18, 0x8D, "Millogic Limited", 0
db 0x18, 0x90, "Egenera, Incorporated", 0
db 0x18, 0xBC, "Info-Tek Corporation", 0
db 0x18, 0xC9, "ARVOO Engineering BV", 0
db 0x18, 0xCA, "XGI Technology Incorporated", 0
db 0x18, 0xF1, "Spectrum Systementwicklung Microelectronic GmbH", 0
db 0x18, 0xF4, "Napatech A/S", 0
db 0x18, 0xF7, "Commtech, Incorporated", 0
db 0x18, 0xFB, "Resilience Corporation", 0
db 0x19, 0x04, "Ritmo", 0
db 0x19, 0x05, "WIS Technology, Incorporated", 0
db 0x19, 0x10, "Seaway Networks", 0
db 0x19, 0x12, "Renesas Electronics", 0
db 0x19, 0x31, "Option NV", 0
db 0x19, 0x41, "Stelar", 0
db 0x19, 0x54, "One Stop Systems, Incorporated", 0
db 0x19, 0x69, "Atheros Communications", 0
db 0x19, 0x71, "AGEIA Technologies, Incorporated", 0
db 0x19, 0x7B, "JMicron Technology Corporation", 0
db 0x19, 0x8A, "Nallatech", 0
db 0x19, 0x91, "Topstar Digital Technologies Co., Limited", 0
db 0x19, 0xA2, "ServerEngines", 0
db 0x19, 0xA8, "DAQDATA GmbH", 0
db 0x19, 0xAC, "Kasten Chase Applied Research", 0
db 0x19, 0xB6, "Mikrotik", 0
db 0x19, 0xE2, "Vector Informatik GmbH", 0
db 0x19, 0xE3, "DDRdrive LLC", 0
db 0x1A, 0x08, "Linux Networx", 0
db 0x1A, 0x41, "Tilera Corporation", 0
db 0x1A, 0x42, "Imaginant", 0
db 0x1B, 0x13, "Jaton Corporation USA", 0
db 0x1B, 0x21, "Asustek - ASMedia Technology Incorporated", 0
db 0x1B, 0x6F, "Etron", 0
db 0x1B, 0x73, "Fresco Logic Incorporated", 0
db 0x1B, 0x91, "Averna", 0
db 0x1B, 0xAD, "ReFLEX CES", 0
db 0x1C, 0x0F, "Monarch Innovative Technologies Private Limited", 0
db 0x1C, 0x32, "Highland Technology Incorporated", 0
db 0x1C, 0x39, "Thomson Video Networks", 0
db 0x1D, 0xE1, "Tekram", 0
db 0x1F, 0xCF, "Miranda Technologies Limited", 0
db 0x20, 0x01, "Temporal Research Limited", 0
db 0x26, 0x46, "Kingston Technology Company", 0
db 0x27, 0x0F, "ChainTek Computer Company Limited", 0
db 0x2E, 0xC1, "Zenic Incorporated", 0
db 0x33, 0x88, "Hint Corporation", 0
db 0x34, 0x11, "Quantum Designs (H.K.) Incorporated", 0
db 0x35, 0x13, "ARCOM Control Systems Limited", 0
db 0x38, 0xEF, "4links", 0
db 0x3D, 0x3D, "3Dlabs, Incorporated Limited", 0
db 0x40, 0x05, "Avance Logic Incorporated", 0
db 0x41, 0x44, "Alpha Data", 0
db 0x41, 0x6C, "Aladdin Knowledge Systems", 0
db 0x43, 0x48, "wch.cn", 0
db 0x46, 0x80, "UMAX Computer Corporation", 0
db 0x48, 0x43, "Hercules Computer Technology", 0
db 0x49, 0x43, "Growth Networks", 0
db 0x49, 0x54, "Integral Technologies", 0
db 0x49, 0x78, "Axil Computer Incorporated", 0
db 0x4C, 0x48, "Lung Hwa Electronics", 0
db 0x4C, 0x53, "SBS-OR Industrial Computers", 0
db 0x4C, 0xA1, "Seanix Technology Incorporated", 0
db 0x4D, 0x51, "Mediaq Incorporated", 0
db 0x4D, 0x54, "Microtechnica Company Limited", 0
db 0x4D, 0xDC, "ILC Data Device Corporation", 0
db 0x4E, 0x80, "Samsung Windows Portable Devices", 0
db 0x50, 0x53, "TBS/Voyetra Technologies", 0
db 0x50, 0x8A, "Samsung T10 MP3 Player", 0
db 0x51, 0x36, "S S Technologies", 0
db 0x51, 0x43, "Qualcomm Incorporated USA", 0
db 0x53, 0x33, "S3 Graphics Company Limited", 0
db 0x54, 0x4C, "Teralogic Incorporated", 0
db 0x55, 0x55, "Genroco Incorporated", 0
db 0x58, 0x53, "Citrix Systems, Incorporated", 0
db 0x64, 0x09, "Logitec Corporation", 0
db 0x66, 0x66, "Decision Computer International Company", 0
db 0x69, 0x45, "ASMedia Technology Incorporated", 0
db 0x76, 0x04, "O.N. Electric Company Limited", 0
db 0x7d, 0x10,	"D-Link Corporation", 0
db 0x80, 0x80, "Xirlink, Incorporated", 0
db 0x80, 0x86, "Intel Corporation", 0
db 0x80, 0xEE, "Oracle Corporation - InnoTek Systemberatung GmbH", 0
db 0x88, 0x66, "T-Square Design Incorporated", 0
db 0x88, 0x88, "Silicon Magic", 0
db 0x8E, 0x0E, "Computone Corporation", 0
db 0x90, 0x04, "Adaptec Incorporated", 0
db 0x90, 0x05, "Adaptec Incorporated", 0
db 0x91, 0x9A, "Gigapixel Corporation", 0
db 0x94, 0x12, "Holtek", 0
db 0x96, 0x99, "Omni Media Technology Incorporated", 0
db 0x97, 0x10, "MosChip Semiconductor Technology", 0
db 0x99, 0x02, "StarGen Incorporated", 0
db 0xA0, 0xA0, "Aopen Incorporated", 0
db 0xA0, 0xF1, "Unisys Corporation", 0
db 0xA2, 0x00, "NEC Corporation", 0
db 0xA2, 0x59, "Hewlett Packard", 0
db 0xA3, 0x04, "Sony", 0
db 0xA7, 0x27, "3com Corporation", 0
db 0xAA, 0x42, "Abekas Incorporated", 0
db 0xAC, 0x1E, "Digital Receiver Technology Incorporated", 0
db 0xB1, 0xB3, "Shiva Europe Limited", 0
db 0xB8, 0x94, "Brown & Sharpe Mfg. Company", 0
db 0xBE, 0xEF, "Mindstream Computing", 0
db 0xC0, 0x01, "TSI Telsys", 0
db 0xC0, 0xA9, "Micron/Crucial Technology", 0
db 0xC0, 0xDE, "Motorola", 0
db 0xC0, 0xFE, "Motion Engineering Inc.", 0
db 0xC6, 0x22, "Hudson Soft Company Limited", 0
db 0xCA, 0x50, "Varian Incorporated", 0
db 0xCA, 0xFE, "Chrysalis-ITS", 0
db 0xCC, 0xCC, "Catapult Communications", 0
db 0xD4, 0xD4, "Curtiss-Wright Controls Embedded Computing", 0
db 0xDC, 0x93, "Dawicontrol", 0
db 0xDE, 0xAD, "Indigita Corporation", 0
db 0xDE, 0xAF, "Middle Digital, Inc", 0
db 0xE1, 0x59, "Tiger Jet Network Inc", 0
db 0xE4, 0xBF, "EKF Elektronik GMBH", 0
db 0xEA, 0x01, "Eagle Technology", 0
db 0xEA, 0xBB, "Aashima Technology B.V.", 0
db 0xEA, 0xCE, "Endace Measurement Systems Limited", 0
db 0xEC, 0xC0, "Echo Digital Audio Corporation", 0
db 0xED, 0xD8, "ARK Logic Incorporated", 0
db 0xF5, 0xF5, "F5 Networks Incorporated", 0
db 0xFA, 0x57, "Interagon AS", 0
db 0xFF, 0xFF, "-Unknown or Invalid Vendor ID-", 0