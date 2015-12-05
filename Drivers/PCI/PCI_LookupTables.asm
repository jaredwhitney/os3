PCI_TABLES.lookupVendorString :
push eax
push ebx
push edx
	mov ebx, PCI_VENDOR_LOOPKUP_TABLE
	
	PCI_TABLES.lookupVendorString.loop :
	cmp [ebx], ecx
		je PCI_TABLES.lookupVendorString.ret
	cmp word [ebx], 0xFFFF
		je PCI_TABLES.lookupVendorString.ret
	add ebx, 1
	call String.getLength
	add ebx, edx
	jmp PCI_TABLES.lookupVendorString.loop
	PCI_TABLES.lookupVendorString.ret :
	mov ecx, ebx
pop edx
pop ebx
pop eax
ret

PCI_TABLES.lookupHardwareType :	; ecx contains obj
push eax
push ebx
push edx

pop edx
pop ebx
pop eax

; The following is a modified and formatted derivitive of the list found at http://pcidatabase.com/vendors.php
PCI_VENDOR_LOOPKUP_TABLE :
db 0x0033, "Paradyne Corporation", 0
db 0x003d, "Master", 0
db 0x0070, "Hauppauge Computer Works Incorporated", 0
db 0x0100, "USBPDO-8", 0
db 0x0123, "General Dynamics", 0
db 0x0315, "SK Electronics Corporation Limited", 0
db 0x0402, "Acer Aspire One", 0
db 0x046D, "Logitech Incorporated", 0
db 0x0483, "UPEK", 0
db 0x04A9, "Canon", 0
db 0x04B3, "IBM", 0
db 0x04D9, "Filco", 0
db 0x04F2, "Chicony Electronics Co.", 0
db 0x051D, "ACPI\VEN_INT&DEV_33A0", 0
db 0x0529, "Aladdin E-Token", 0
db 0x0553, "Aiptek USA", 0
db 0x058f, "Alcor Micro Corporation", 0
db 0x0590, "Omron Corporation", 0
db 0x05ac, "Apple Incorporated", 0
db 0x05E1, "D-MAX", 0
db 0x064e, "SUYIN Corporation", 0
db 0x067B, "Prolific Technology Incorporated", 0
db 0x06FE, "Acresso Software Incorporated", 0
db 0x0711, "SIIG, Incorporated", 0
db 0x093a, "KYE Systems Corporation / Pixart Imaging", 0
db 0x096E, "USB Rockey dongle from Feitain", 0
db 0x0A5C, "Broadcom Corporation", 0
db 0x0A89, "BREA Technologies Incorporated", 0
db 0x0A92, "Egosys, Incorporated", 0
db 0x0AC8, "ASUS", 0
db 0x0b05, "Toshiba Bluetooth RFBUS, RFCOM, RFHID", 0
db 0x0c45, "Microdia Limited", 0
db 0x0cf3, "TP-Link", 0
db 0x0D2E, "Feedback Instruments Limited", 0
db 0x0D8C, "C-Media Electronics, Incorporated", 0
db 0x0DF6, "Sitecom", 0
db 0x0E11, "Compaq Computer Corporation", 0
db 0x0E8D, "MediaTek Incorporated", 0
db 0x1000, "LSI Logic", 0
db 0x1001, "Kolter Electronic - Germany", 0
db 0x1002, "Advanced Micro Devices, Incorporated", 0
db 0x1003, "ULSI", 0
db 0x1004, "VLSI Technology", 0
db 0x1006, "Reply Group", 0
db 0x1007, "Netframe Systems Incorporated", 0
db 0x1008, "Epson", 0
db 0x100A, "Ã‚as Limited de Phoenix del Âƒ de TecnologÃƒ", 0
db 0x100B, "National Semiconductors", 0
db 0x100C, "Tseng Labs", 0
db 0x100D, "AST Research", 0
db 0x100E, "Weitek", 0
db 0x1010, "Video Logic Limited", 0
db 0x1011, "Digital Equipment Corporation", 0
db 0x1012, "Micronics Computers Incorporated", 0
db 0x1013, "Cirrus Logic", 0
db 0x1014, "International Business Machines Corporation", 0
db 0x1016, "Fujitsu ICL Computers", 0
db 0x1017, "Spea Software AG", 0
db 0x1018, "Unisys Systems", 0
db 0x1019, "Elitegroup Computer System", 0
db 0x101A, "NCR Corporation", 0
db 0x101B, "Vitesse Semiconductor", 0
db 0x101E, "American Megatrends Incorporated", 0
db 0x101F, "PictureTel Corporation", 0
db 0x1020, "Hitachi Computer Electronics", 0
db 0x1021, "Oki Electric Industry", 0
db 0x1022, "Advanced Micro Devices", 0
db 0x1023, "Trident Mirco", 0
db 0x1025, "Acer Incorporated", 0
db 0x1028, "Dell Incorporated", 0
db 0x102A, "LSI Logic Headland Division", 0
db 0x102B, "Matrox Electronic Systems Limited", 0
db 0x102C, "Asiliant (Chips And Technologies)", 0
db 0x102D, "Wyse Technology", 0
db 0x102E, "Olivetti Advanced Technology", 0
db 0x102F, "Toshiba America", 0
db 0x1030, "TMC Research", 0
db 0x1031, "Miro Computer Products AG", 0
db 0x1033, "NEC Electronics", 0
db 0x1034, "Burndy Corporation", 0
db 0x1036, "Future Domain", 0
db 0x1037, "Hitachi Micro Systems Incorporated", 0
db 0x1038, "AMP Incorporated", 0
db 0x1039, "Silicon Integrated Systems", 0
db 0x103A, "Seiko Epson Corporation", 0
db 0x103B, "Tatung Corporation Of America", 0
db 0x103C, "Hewlett-Packard", 0
db 0x103E, "Solliday Engineering", 0
db 0x103F, "Logic Modeling", 0
db 0x1041, "Computrend", 0
db 0x1043, "Asustek Computer Incorporated", 0
db 0x1044, "Distributed Processing Tech", 0
db 0x1045, "OPTi Incorporated", 0
db 0x1046, "IPC Corporation LTD", 0
db 0x1047, "Genoa Systems Corporation", 0
db 0x1048, "ELSA GmbH", 0
db 0x1049, "Fountain Technology", 0
db 0x104A, "STMicroelectronics", 0
db 0x104B, "Mylex / Buslogic", 0
db 0x104C, "Texas Instruments", 0
db 0x104D, "Sony Corporation", 0
db 0x104E, "Oak Technology", 0
db 0x104F, "Co-Time Computer Limited", 0
db 0x1050, "Winbond Electronics Corporation", 0
db 0x1051, "Anigma Corporation", 0
db 0x1053, "Young Micro Systems", 0
db 0x1054, "Hitachi Limited", 0
db 0x1055, "Standard Microsystems Corporation", 0
db 0x1056, "ICL", 0
db 0x1057, "Motorola", 0
db 0x1058, "Electronics & Telecommunication Res", 0
db 0x1059, "Kontron Canada", 0
db 0x105A, "Promise Technology", 0
db 0x105B, "Mobham chip", 0
db 0x105C, "Wipro Infotech Limited", 0
db 0x105D, "Number Nine Visual Technology", 0
db 0x105E, "Vtech Engineering Canada Limited", 0
db 0x105F, "Infotronic America Incorporated", 0
db 0x1060, "United Microelectronics", 0
db 0x1061, "8x8 Incorporated", 0
db 0x1062, "Maspar Computer Corporation", 0
db 0x1063, "Ocean Office Automation", 0
db 0x1064, "Alcatel Cit", 0
db 0x1065, "Texas Microsystems", 0
db 0x1066, "Picopower Technology", 0
db 0x1067, "Mitsubishi Electronics", 0
db 0x1068, "Diversified Technology", 0
db 0x106A, "Aten Research Incorporated", 0
db 0x106B, "Apple Incorporated", 0
db 0x106C, "Hyundai Electronics America", 0
db 0x106D, "Sequent Computer Systems", 0
db 0x106E, "DFI Incorporated", 0
db 0x106F, "City Gate Development LTD", 0
db 0x1070, "Daewoo Telecom Limited", 0
db 0x1071, "Mitac", 0
db 0x1072, "GIT Co. Limited", 0
db 0x1073, "Yamaha Corporation", 0
db 0x1074, "Nexgen Microsystems", 0
db 0x1075, "Advanced Integration Research", 0
db 0x1077, "QLogic Corporation", 0
db 0x1078, "Cyrix Corporation", 0
db 0x1079, "I-Bus", 0
db 0x107A, "Networth controls", 0
db 0x107B, "Gateway 2000", 0
db 0x107C, "Goldstar Co. Limited", 0
db 0x107D, "Leadtek Research", 0
db 0x107E, "Testernec", 0
db 0x107F, "Data Technology Corporation", 0
db 0x1080, "Cypress Semiconductor", 0
db 0x1081, "Radius Incorporated", 0
db 0x1082, "EFA Corporation Of America", 0
db 0x1083, "Forex Computer Corporation", 0
db 0x1084, "Parador", 0
db 0x1085, "Tulip Computers Int'l BV", 0
db 0x1086, "J. Bond Computer Systems", 0
db 0x1087, "Cache Computer", 0
db 0x1088, "Microcomputer Systems (M) Son", 0
db 0x1089, "Data General Corporation", 0
db 0x108A, "SBS Operations", 0
db 0x108C, "Oakleigh Systems Incorporated", 0
db 0x108D, "Olicom", 0
db 0x108E, "Sun Microsystems", 0
db 0x108F, "Systemsoft Corporation", 0
db 0x1090, "Encore Computer Corporation", 0
db 0x1091, "Intergraph Corporation", 0
db 0x1092, "Diamond Computer Systems", 0
db 0x1093, "National Instruments", 0
db 0x1094, "Apostolos", 0
db 0x1095, "Silicon Image, Incorporated", 0
db 0x1096, "Alacron", 0
db 0x1097, "Appian Graphics", 0
db 0x1098, "Quantum Designs Limited", 0
db 0x1099, "Samsung Electronics Co. Limited", 0
db 0x109A, "Packard Bell", 0
db 0x109B, "Gemlight Computer Limited", 0
db 0x109C, "Megachips Corporation", 0
db 0x109D, "Zida Technologies Limited", 0
db 0x109E, "Brooktree Corporation", 0
db 0x109F, "Trigem Computer Incorporated", 0
db 0x10A0, "Meidensha Corporation", 0
db 0x10A1, "Juko Electronics Incorporated Limited", 0
db 0x10A2, "Quantum Corporation", 0
db 0x10A3, "Everex Systems Incorporated", 0
db 0x10A4, "Globe Manufacturing Sales", 0
db 0x10A5, "Racal Interlan", 0
db 0x10A8, "Sierra Semiconductor", 0
db 0x10A9, "Silicon Graphics", 0
db 0x10AB, "Digicom", 0
db 0x10AC, "Honeywell IASD", 0
db 0x10AD, "Winbond Systems Labs", 0
db 0x10AE, "Cornerstone Technology", 0
db 0x10AF, "Micro Computer Systems Incorporated", 0
db 0x10B0, "Gainward GmbH", 0
db 0x10B1, "Cabletron Systems Incorporated", 0
db 0x10B2, "Raytheon Company", 0
db 0x10B3, "Databook Incorporated", 0
db 0x10B4, "STB Systems", 0
db 0x10B5, "PLX Technology Incorporated", 0
db 0x10B6, "Madge Networks", 0
db 0x10B7, "3Com Corporation", 0
db 0x10B8, "Standard Microsystems Corporation", 0
db 0x10B9, "Ali Corporation", 0
db 0x10BA, "Mitsubishi Electronics Corporation", 0
db 0x10BB, "Dapha Electronics Corporation", 0
db 0x10BC, "Advanced Logic Research Incorporated", 0
db 0x10BD, "Surecom Technology", 0
db 0x10BE, "Tsenglabs International Corporation", 0
db 0x10BF, "MOST Corporation", 0
db 0x10C0, "Boca Research Incorporated", 0
db 0x10C1, "ICM Corporation Limited", 0
db 0x10C2, "Auspex Systems Incorporated", 0
db 0x10C3, "Samsung Semiconductors", 0
db 0x10C4, "Award Software Int'l Incorporated", 0
db 0x10C5, "Xerox Corporation", 0
db 0x10C6, "Rambus Incorporated", 0
db 0x10C8, "Neomagic Corporation", 0
db 0x10C9, "Dataexpert Corporation", 0
db 0x10CA, "Fujitsu Siemens", 0
db 0x10CB, "Omron Corporation", 0
db 0x10CD, "Advanced System Products", 0
db 0x10CF, "Fujitsu Limited", 0
db 0x10D1, "Future+ Systems", 0
db 0x10D2, "Molex Incorporated", 0
db 0x10D3, "Jabil Circuit Incorporated", 0
db 0x10D4, "Hualon Microelectronics", 0
db 0x10D5, "Autologic Incorporated", 0
db 0x10D6, "Wilson .co .ltd", 0
db 0x10D7, "BCM Advanced Research", 0
db 0x10D8, "Advanced Peripherals Labs", 0
db 0x10D9, "Macronix International Co. Limited", 0
db 0x10DB, "Rohm Research", 0
db 0x10DC, "CERN-European Lab. for Particle Physics", 0
db 0x10DD, "Evans & Sutherland", 0
db 0x10DE, "NVIDIA", 0
db 0x10DF, "Emulex Corporation", 0
db 0x10E1, "Tekram Technology Corporation Limited", 0
db 0x10E2, "Aptix Corporation", 0
db 0x10E3, "Tundra Semiconductor Corporation", 0
db 0x10E4, "Tandem Computers", 0
db 0x10E5, "Micro Industries Corporation", 0
db 0x10E6, "Gainbery Computer Products Incorporated", 0
db 0x10E7, "Vadem", 0
db 0x10E8, "Applied Micro Circuits Corporation", 0
db 0x10E9, "Alps Electronic Corporation Limited", 0
db 0x10EA, "Tvia, Incorporated", 0
db 0x10EB, "Artist Graphics", 0
db 0x10EC, "Realtek Semiconductor Corporation", 0
db 0x10ED, "Ascii Corporation", 0
db 0x10EE, "Xilinx Corporation", 0
db 0x10EF, "Racore Computer Products", 0
db 0x10F0, "Curtiss-Wright Controls Embedded Computing", 0
db 0x10F1, "Tyan Computer", 0
db 0x10F2, "Achme Computer Incorporated - GONE !!!!", 0
db 0x10F3, "Alaris Incorporated", 0
db 0x10F4, "S-Mos Systems", 0
db 0x10F5, "NKK Corporation", 0
db 0x10F6, "Creative Electronic Systems SA", 0
db 0x10F7, "Matsushita Electric Industrial Corporation", 0
db 0x10F8, "Altos India Limited", 0
db 0x10F9, "PC Direct", 0
db 0x10FA, "Truevision", 0
db 0x10FB, "Thesys Microelectronic's", 0
db 0x10FC, "I-O Data Device Incorporated", 0
db 0x10FD, "Soyo Technology Corporation Limited", 0
db 0x10FE, "Fast Electronic GmbH", 0
db 0x10FF, "Ncube", 0
db 0x1100, "Jazz Multimedia", 0
db 0x1101, "Initio Corporation", 0
db 0x1102, "Creative Technology LTD.", 0
db 0x1103, "HighPoint Technologies, Incorporated", 0
db 0x1104, "Rasterops", 0
db 0x1105, "Sigma Designs Incorporated", 0
db 0x1106, "VIA Technologies, Incorporated", 0
db 0x1107, "Stratus Computer", 0
db 0x1108, "Proteon Incorporated", 0
db 0x1109, "Adaptec/Cogent Data Technologies", 0
db 0x110A, "Siemens AG", 0
db 0x110B, "Chromatic Research Incorporated", 0
db 0x110C, "Mini-Max Technology Incorporated", 0
db 0x110D, "ZNYX Corporation", 0
db 0x110E, "CPU Technology", 0
db 0x110F, "Ross Technology", 0
db 0x1112, "Osicom Technologies Incorporated", 0
db 0x1113, "Accton Technology Corporation", 0
db 0x1114, "Atmel Corporation", 0
db 0x1116, "Data Translation, Incorporated", 0
db 0x1117, "Datacube Incorporated", 0
db 0x1118, "Berg Electronics", 0
db 0x1119, "ICP vortex Computersysteme GmbH", 0
db 0x111A, "Efficent Networks", 0
db 0x111C, "Tricord Systems Incorporated", 0
db 0x111D, "Integrated Device Technology Incorporated", 0
db 0x111F, "Precision Digital Images", 0
db 0x1120, "EMC Corporation", 0
db 0x1121, "Zilog", 0
db 0x1123, "Excellent Design Incorporated", 0
db 0x1124, "Leutron Vision AG", 0
db 0x1125, "Eurocore/Vigra", 0
db 0x1127, "FORE Systems", 0
db 0x1129, "Firmworks", 0
db 0x112A, "Hermes Electronics Co. Limited", 0
db 0x112C, "Zenith Data Systems", 0
db 0x112D, "Ravicad", 0
db 0x112E, "Infomedia", 0
db 0x1130, "Computervision", 0
db 0x1131, "NXP Semiconductors N.V.", 0
db 0x1132, "Mitel Corporation", 0
db 0x1133, "Eicon Networks Corporation", 0
db 0x1134, "Mercury Computer Systems Incorporated", 0
db 0x1135, "Fuji Xerox Co Limited", 0
db 0x1136, "Momentum Data Systems", 0
db 0x1137, "Cisco Systems Incorporated", 0
db 0x1138, "Ziatech Corporation", 0
db 0x1139, "Dynamic Pictures Incorporated", 0
db 0x113A, "FWB Incorporated", 0
db 0x113B, "Network Computing Devices", 0
db 0x113C, "Cyclone Microsystems Incorporated", 0
db 0x113D, "Leading Edge Products Incorporated", 0
db 0x113E, "Sanyo Electric Co", 0
db 0x113F, "Equinox Systems", 0
db 0x1140, "Intervoice Incorporated", 0
db 0x1141, "Crest Microsystem Incorporated", 0
db 0x1142, "Alliance Semiconductor", 0
db 0x1143, "Netpower Incorporated", 0
db 0x1144, "Cincinnati Milacron", 0
db 0x1145, "Workbit Corporation", 0
db 0x1146, "Force Computers", 0
db 0x1147, "Interface Corporation", 0
db 0x1148, "Marvell Semiconductor Germany GmbH", 0
db 0x1149, "Win System Corporation", 0
db 0x114A, "VMIC", 0
db 0x114B, "Canopus corporation", 0
db 0x114C, "Annabooks", 0
db 0x114D, "IC Corporation", 0
db 0x114E, "Nikon Systems Incorporated", 0
db 0x114F, "Digi International", 0
db 0x1150, "Thinking Machines Corporation", 0
db 0x1151, "JAE Electronics Incorporated", 0
db 0x1153, "Land Win Electronic Corporation", 0
db 0x1154, "Melco Incorporated", 0
db 0x1155, "Pine Technology Limited", 0
db 0x1156, "Periscope Engineering", 0
db 0x1157, "Avsys Corporation", 0
db 0x1158, "Voarx R&D Incorporated", 0
db 0x1159, "Mutech", 0
db 0x115A, "Harlequin Limited", 0
db 0x115B, "Parallax Graphics", 0
db 0x115C, "Photron Limited", 0
db 0x115D, "Xircom", 0
db 0x115E, "Peer Protocols Incorporated", 0
db 0x115F, "Maxtor Corporation", 0
db 0x1160, "Megasoft Incorporated", 0
db 0x1161, "PFU Limited", 0
db 0x1162, "OA Laboratory Co Limited", 0
db 0x1163, "mohamed alsherif", 0
db 0x1164, "Advanced Peripherals Tech", 0
db 0x1165, "Imagraph Corporation", 0
db 0x1166, "Broadcom / ServerWorks", 0
db 0x1167, "Mutoh Industries Incorporated", 0
db 0x1168, "Thine Electronics Incorporated", 0
db 0x1169, "Centre f/Dev. of Adv. Computing", 0
db 0x116A, "Luminex Software, Incorporated", 0
db 0x116B, "Connectware Incorporated", 0
db 0x116C, "Intelligent Resources", 0
db 0x116E, "Electronics for Imaging", 0
db 0x1170, "Inventec Corporation", 0
db 0x1172, "Altera Corporation", 0
db 0x1173, "Adobe Systems", 0
db 0x1174, "Bridgeport Machines", 0
db 0x1175, "Mitron Computer Incorporated", 0
db 0x1176, "SBE", 0
db 0x1177, "Silicon Engineering", 0
db 0x1178, "Alfa Incorporated", 0
db 0x1179, "Toshiba corporation", 0
db 0x117A, "A-Trend Technology", 0
db 0x117B, "LG (Lucky Goldstar) Electronics Incorporated", 0
db 0x117C, "Atto Technology", 0
db 0x117D, "Becton & Dickinson", 0
db 0x117E, "T/R Systems", 0
db 0x117F, "Integrated Circuit Systems", 0
db 0x1180, "RicohCompany,Limited", 0
db 0x1183, "Fujikura Limited", 0
db 0x1184, "Forks Incorporated", 0
db 0x1185, "Dataworld", 0
db 0x1186, "D-Link System Incorporated", 0
db 0x1187, "Philips Healthcare", 0
db 0x1188, "Shima Seiki Manufacturing Limited", 0
db 0x1189, "Matsushita Electronics", 0
db 0x118A, "Hilevel Technology", 0
db 0x118B, "Hypertec Pty Limited", 0
db 0x118C, "Corollary Incorporated", 0
db 0x118D, "BitFlow Incorporated", 0
db 0x118E, "Hermstedt AG", 0
db 0x118F, "Green Logic", 0
db 0x1190, "Tripace", 0
db 0x1191, "Acard Technology Corporation", 0
db 0x1192, "Densan Co. Limited", 0
db 0x1194, "Toucan Technology", 0
db 0x1195, "Ratoc System Incorporated", 0
db 0x1196, "Hytec Electronics Limited", 0
db 0x1197, "Gage Applied Technologies", 0
db 0x1198, "Lambda Systems Incorporated", 0
db 0x1199, "Attachmate Corporation", 0
db 0x119A, "Mind/Share Incorporated", 0
db 0x119B, "Omega Micro Incorporated", 0
db 0x119C, "Information Technology Inst.", 0
db 0x119D, "Bug Sapporo Japan", 0
db 0x119E, "Fujitsu Microelectronics Limited", 0
db 0x119F, "Bull Hn Information Systems", 0
db 0x11A1, "Hamamatsu Photonics K.K.", 0
db 0x11A2, "Sierra Research and Technology", 0
db 0x11A3, "Deuretzbacher GmbH & Co. Eng. KG", 0
db 0x11A4, "Barco", 0
db 0x11A5, "MicroUnity Systems Engineering Incorporated", 0
db 0x11A6, "Pure Data", 0
db 0x11A7, "Power Computing Corporation", 0
db 0x11A8, "Systech Corporation", 0
db 0x11A9, "InnoSys Incorporated", 0
db 0x11AA, "Actel", 0
db 0x11AB, "Marvell Semiconductor", 0
db 0x11AC, "Canon Information Systems", 0
db 0x11AD, "Lite-On Technology Corporation", 0
db 0x11AE, "Scitex Corporation Limited", 0
db 0x11AF, "Avid Technology, Incorporated", 0
db 0x11B0, "Quicklogic Corporation", 0
db 0x11B1, "Apricot Computers", 0
db 0x11B2, "Eastman Kodak", 0
db 0x11B3, "Barr Systems Incorporated", 0
db 0x11B4, "Leitch Technology International", 0
db 0x11B5, "Radstone Technology Limited", 0
db 0x11B6, "United Video Corporation", 0
db 0x11B7, "Motorola", 0
db 0x11B8, "Xpoint Technologies Incorporated", 0
db 0x11B9, "Pathlight Technology Incorporated", 0
db 0x11BA, "Videotron Corporation", 0
db 0x11BB, "Pyramid Technology", 0
db 0x11BC, "Network Peripherals Incorporated", 0
db 0x11BD, "Pinnacle system", 0
db 0x11BE, "International Microcircuits Incorporated", 0
db 0x11BF, "Astrodesign Incorporated", 0
db 0x11C1, "LSI Corporation", 0
db 0x11C2, "Sand Microelectronics", 0
db 0x11C4, "Document Technologies Ind.", 0
db 0x11C5, "Shiva Corporationoratin", 0
db 0x11C6, "Dainippon Screen Mfg. Co", 0
db 0x11C7, "D.C.M. Data Systems", 0
db 0x11C8, "Dolphin Interconnect Solutions", 0
db 0x11C9, "MAGMA", 0
db 0x11CA, "LSI Systems Incorporated", 0
db 0x11CB, "Specialix International Limited", 0
db 0x11CC, "Michels & Kleberhoff Computer GmbH", 0
db 0x11CD, "HAL Computer Systems Incorporated", 0
db 0x11CE, "Primary Rate Incorporated", 0
db 0x11CF, "Pioneer Electronic Corporation", 0
db 0x11D0, "BAE SYSTEMS - Manassas", 0
db 0x11D1, "AuraVision Corporation", 0
db 0x11D2, "Intercom Incorporated", 0
db 0x11D3, "Trancell Systems Incorporated", 0
db 0x11D4, "Analog Devices, Incorporated", 0
db 0x11D5, "Tahoma Technology", 0
db 0x11D6, "Tekelec Technologies", 0
db 0x11D7, "TRENTON Technology, Incorporated", 0
db 0x11D8, "Image Technologies Development", 0
db 0x11D9, "Tec Corporation", 0
db 0x11DA, "Novell", 0
db 0x11DB, "Sega Enterprises Limited", 0
db 0x11DC, "Questra Corporation", 0
db 0x11DD, "Crosfield Electronics Limited", 0
db 0x11DE, "Zoran Corporation", 0
db 0x11E1, "Gec Plessey Semi Incorporated", 0
db 0x11E2, "Samsung Information Systems America", 0
db 0x11E3, "Quicklogic Corporation", 0
db 0x11E4, "Second Wave Incorporated", 0
db 0x11E5, "IIX Consulting", 0
db 0x11E6, "Mitsui-Zosen System Research", 0
db 0x11E8, "Digital Processing Systems Incorporated", 0
db 0x11E9, "Highwater Designs Limited", 0
db 0x11EA, "Elsag Bailey", 0
db 0x11EB, "Formation, Incorporated", 0
db 0x11EC, "Coreco Incorporated", 0
db 0x11ED, "Mediamatics", 0
db 0x11EE, "Dome Imaging Systems Incorporated", 0
db 0x11EF, "Nicolet Technologies BV", 0
db 0x11F0, "Triya", 0
db 0x11F2, "Picture Tel Japan KK", 0
db 0x11F3, "Keithley Instruments, Incorporated", 0
db 0x11F4, "Kinetic Systems Corporation", 0
db 0x11F5, "Computing Devices Intl", 0
db 0x11F6, "Powermatic Data Systems Limited", 0
db 0x11F7, "Scientific Atlanta", 0
db 0x11F8, "PMC-Sierra Incorporated", 0
db 0x11F9, "I-Cube Incorporated", 0
db 0x11FA, "Kasan Electronics Co Limited", 0
db 0x11FB, "Datel Incorporated", 0
db 0x11FD, "High Street Consultants", 0
db 0x11FE, "Comtrol Corporation", 0
db 0x11FF, "Scion Corporation", 0
db 0x1200, "CSS Corporation", 0
db 0x1201, "Vista Controls Corporation", 0
db 0x1202, "Network General Corporation", 0
db 0x1203, "Bayer Corporation Agfa Div", 0
db 0x1204, "Lattice Semiconductor Corporation", 0
db 0x1205, "Array Corporation", 0
db 0x1206, "Amdahl Corporation", 0
db 0x1208, "Parsytec GmbH", 0
db 0x1209, "Sci Systems Incorporated", 0
db 0x120A, "Synaptel", 0
db 0x120B, "Adaptive Solutions", 0
db 0x120D, "Compression Labs Incorporated", 0
db 0x120E, "Cyclades Corporation", 0
db 0x120F, "Essential Communications", 0
db 0x1210, "Hyperparallel Technologies", 0
db 0x1211, "Braintech Incorporated", 0
db 0x1213, "Applied Intelligent Systems Incorporated", 0
db 0x1214, "Performance Technologies Incorporated", 0
db 0x1215, "Interware Co Limited", 0
db 0x1216, "Purup-Eskofot A/S", 0
db 0x1217, "O2Micro Incorporated", 0
db 0x1218, "Hybricon Corporation", 0
db 0x1219, "First Virtual Corporation", 0
db 0x121A, "3dfx Interactive Incorporated", 0
db 0x121B, "Advanced Telecommunications Modules", 0
db 0x121C, "Nippon Texa Co Limited", 0
db 0x121D, "LiPPERT Embedded Computers GmbH", 0
db 0x121E, "CSPI", 0
db 0x121F, "Arcus Technology Incorporated", 0
db 0x1220, "Ariel Corporation", 0
db 0x1221, "Contec Microelectronics Europe BV", 0
db 0x1222, "Ancor Communications Incorporated", 0
db 0x1223, "Artesyn Embedded Technologies", 0
db 0x1224, "Interactive Images", 0
db 0x1225, "Power I/O Incorporated", 0
db 0x1227, "Tech-Source", 0
db 0x1228, "Norsk Elektro Optikk A/S", 0
db 0x1229, "Data Kinesis Incorporated", 0
db 0x122A, "Integrated Telecom", 0
db 0x122B, "LG Industrial Systems Co. Limited", 0
db 0x122C, "sci-worx GmbH", 0
db 0x122D, "Aztech System Limited", 0
db 0x122E, "Absolute Analysis", 0
db 0x122F, "Andrew Corporation", 0
db 0x1230, "Fishcamp Engineering", 0
db 0x1231, "Woodward McCoach Incorporated", 0
db 0x1233, "Bus-Tech Incorporated", 0
db 0x1234, "Technical Corporation", 0
db 0x1236, "Sigma Designs Incorporated", 0
db 0x1237, "Alta Technology Corporation", 0
db 0x1238, "Adtran", 0
db 0x1239, "The 3DO Company", 0
db 0x123A, "Visicom Laboratories Incorporated", 0
db 0x123B, "Seeq Technology Incorporated", 0
db 0x123C, "Century Systems Incorporated", 0
db 0x123D, "Engineering Design Team Incorporated", 0
db 0x123F, "C-Cube Microsystems", 0
db 0x1240, "Marathon Technologies Corporation", 0
db 0x1241, "DSC Communications", 0
db 0x1242, "JNI Corporation", 0
db 0x1243, "Delphax", 0
db 0x1244, "AVM AUDIOVISUELLES MKTG & Computer GmbH", 0
db 0x1245, "APD S.A.", 0
db 0x1246, "Dipix Technologies Incorporated", 0
db 0x1247, "Xylon Research Incorporated", 0
db 0x1248, "Central Data Corporation", 0
db 0x1249, "Samsung Electronics Co. Limited", 0
db 0x124A, "AEG Electrocom GmbH", 0
db 0x124C, "Solitron Technologies Incorporated", 0
db 0x124D, "Stallion Technologies", 0
db 0x124E, "Cylink", 0
db 0x124F, "Infortrend Technology Incorporated", 0
db 0x1250, "Hitachi Microcomputer System Limited", 0
db 0x1251, "VLSI Solution OY", 0
db 0x1253, "Guzik Technical Enterprises", 0
db 0x1254, "Linear Systems Limited", 0
db 0x1255, "Optibase Limited", 0
db 0x1256, "Perceptive Solutions Incorporated", 0
db 0x1257, "Vertex Networks Incorporated", 0
db 0x1258, "Gilbarco Incorporated", 0
db 0x1259, "Allied Telesyn International", 0
db 0x125A, "ABB Power Systems", 0
db 0x125B, "Asix Electronics Corporation", 0
db 0x125C, "Aurora Technologies Incorporated", 0
db 0x125D, "ESS Technology", 0
db 0x125E, "Specialvideo Engineering SRL", 0
db 0x125F, "Concurrent Technologies Incorporated", 0
db 0x1260, "Intersil Corporation", 0
db 0x1261, "Matsushita-Kotobuki Electronics Indu", 0
db 0x1262, "ES Computer Co. Limited", 0
db 0x1263, "Sonic Solutions", 0
db 0x1264, "Aval Nagasaki Corporation", 0
db 0x1265, "Casio Computer Co. Limited", 0
db 0x1266, "Microdyne Corporation", 0
db 0x1267, "S.A. Telecommunications", 0
db 0x1268, "Tektronix", 0
db 0x1269, "Thomson-CSF/TTM", 0
db 0x126A, "Lexmark International Incorporated", 0
db 0x126B, "Adax Incorporated", 0
db 0x126C, "Nortel Networks Corporation", 0
db 0x126D, "Splash Technology Incorporated", 0
db 0x126E, "Sumitomo Metal Industries Limited", 0
db 0x126F, "Silicon Motion", 0
db 0x1270, "Olympus Optical Co. Limited", 0
db 0x1271, "GW Instruments", 0
db 0x1272, "themrtaish", 0
db 0x1273, "Hughes Network Systems", 0
db 0x1274, "Ensoniq", 0
db 0x1275, "Network Appliance", 0
db 0x1276, "Switched Network Technologies Incorporated", 0
db 0x1277, "Comstream", 0
db 0x1278, "Transtech Parallel Systems", 0
db 0x1279, "Transmeta Corporation", 0
db 0x127B, "Pixera Corporation", 0
db 0x127C, "Crosspoint Solutions Incorporated", 0
db 0x127D, "Vela Research LP", 0
db 0x127E, "Winnov L.P.", 0
db 0x127F, "Fujifilm", 0
db 0x1280, "Photoscript Group Limited", 0
db 0x1281, "Yokogawa Electronic Corporation", 0
db 0x1282, "Davicom Semiconductor Incorporated", 0
db 0x1283, "Waldo", 0
db 0x1285, "Platform Technologies Incorporated", 0
db 0x1286, "MAZeT GmbH", 0
db 0x1287, "LuxSonor Incorporated", 0
db 0x1288, "Timestep Corporation", 0
db 0x1289, "AVC Technology Incorporated", 0
db 0x128A, "Asante Technologies Incorporated", 0
db 0x128B, "Transwitch Corporation", 0
db 0x128C, "Retix Corporation", 0
db 0x128D, "G2 Networks Incorporated", 0
db 0x128F, "Tateno Dennou Incorporated", 0
db 0x1290, "Sord Computer Corporation", 0
db 0x1291, "NCS Computer Italia", 0
db 0x1292, "Tritech Microelectronics Intl PTE", 0
db 0x1293, "Media Reality Technology", 0
db 0x1294, "Rhetorex Incorporated", 0
db 0x1295, "Imagenation Corporation", 0
db 0x1296, "Kofax Image Products", 0
db 0x1297, "Shuttle Computer", 0
db 0x1298, "Spellcaster Telecommunications Incorporated", 0
db 0x1299, "Knowledge Technology Laboratories", 0
db 0x129A, "Curtiss Wright Controls Electronic Systems", 0
db 0x129B, "Image Access", 0
db 0x129D, "CompCore Multimedia Incorporated", 0
db 0x129E, "Victor Co. of Japan Limited", 0
db 0x129F, "OEC Medical Systems Incorporated", 0
db 0x12A0, "Allen Bradley Co.", 0
db 0x12A1, "Simpact Incorporated", 0
db 0x12A2, "NewGen Systems Corporation", 0
db 0x12A3, "Lucent Technologies AMR", 0
db 0x12A4, "NTT Electronics Corporation", 0
db 0x12A5, "Vision Dynamics Limited", 0
db 0x12A6, "Scalable Networks Incorporated", 0
db 0x12A7, "AMO GmbH", 0
db 0x12A8, "News Datacom", 0
db 0x12A9, "Xiotech Corporation", 0
db 0x12AA, "SDL Communications Incorporated", 0
db 0x12AB, "Yuan Yuan Enterprise Co. Limited", 0
db 0x12AC, "MeasureX Corporation", 0
db 0x12AD, "MULTIDATA GmbH", 0
db 0x12AE, "Alteon Networks Incorporated", 0
db 0x12AF, "TDK USA Corporation", 0
db 0x12B0, "Jorge Scientific Corporation", 0
db 0x12B1, "GammaLink", 0
db 0x12B2, "General Signal Networks", 0
db 0x12B3, "Interface Corporation Limited", 0
db 0x12B4, "Future Tel Incorporated", 0
db 0x12B5, "Granite Systems Incorporated", 0
db 0x12B7, "Acumen", 0
db 0x12B8, "Korg", 0
db 0x12B9, "3Com Corporation", 0
db 0x12BA, "Bittware Incorporated", 0
db 0x12BB, "Nippon Unisoft Corporation", 0
db 0x12BC, "Array Microsystems", 0
db 0x12BD, "Computerm Corporation", 0
db 0x12BF, "Fujifilm Microdevices", 0
db 0x12C0, "Infimed", 0
db 0x12C1, "GMM Research Corporation", 0
db 0x12C2, "Mentec Limited", 0
db 0x12C3, "Holtek Microelectronics Incorporated", 0
db 0x12C4, "Connect Tech Incorporated", 0
db 0x12C5, "Picture Elements Incorporated", 0
db 0x12C6, "Mitani Corporation", 0
db 0x12C7, "Dialogic Corporation", 0
db 0x12C8, "G Force Co. Limited", 0
db 0x12C9, "Gigi Operations", 0
db 0x12CA, "Integrated Computing Engines, Incorporated", 0
db 0x12CB, "Antex Electronics Corporation", 0
db 0x12CC, "Pluto Technologies International", 0
db 0x12CD, "Aims Lab", 0
db 0x12CE, "Netspeed Incorporated", 0
db 0x12CF, "Prophet Systems Incorporated", 0
db 0x12D0, "GDE Systems Incorporated", 0
db 0x12D1, "Huawei Technologies Co., Limited", 0
db 0x12D3, "Vingmed Sound A/S", 0
db 0x12D4, "Ulticom, Incorporated", 0
db 0x12D5, "Equator Technologies", 0
db 0x12D6, "Analogic Corporation", 0
db 0x12D7, "Biotronic SRL", 0
db 0x12D8, "Pericom Semiconductor", 0
db 0x12D9, "Aculab Plc.", 0
db 0x12DA, "TrueTime", 0
db 0x12DB, "Annapolis Micro Systems Incorporated", 0
db 0x12DC, "Symicron Computer Communication Limited", 0
db 0x12DD, "Management Graphics Incorporated", 0
db 0x12DE, "Rainbow Technologies", 0
db 0x12DF, "SBS Technologies Incorporated", 0
db 0x12E0, "Chase Research PLC", 0
db 0x12E1, "Nintendo Co. Limited", 0
db 0x12E2, "Datum Incorporated Bancomm-Timing Division", 0
db 0x12E3, "Imation Corporation - Medical Imaging Syst", 0
db 0x12E4, "Brooktrout Technology Incorporated", 0
db 0x12E6, "Cirel Systems", 0
db 0x12E7, "Sebring Systems Incorporated", 0
db 0x12E8, "CRISC Corporation", 0
db 0x12E9, "GE Spacenet", 0
db 0x12EB, "Aureal Semiconductor", 0
db 0x12EC, "3A International Incorporated", 0
db 0x12ED, "Optivision Incorporated", 0
db 0x12EE, "Orange Micro, Incorporated", 0
db 0x12EF, "Vienna Systems", 0
db 0x12F0, "Pentek", 0
db 0x12F1, "Sorenson Vision Incorporated", 0
db 0x12F2, "Gammagraphx Incorporated", 0
db 0x12F4, "Megatel", 0
db 0x12F5, "Forks", 0
db 0x12F7, "Cognex", 0
db 0x12F8, "Electronic-Design GmbH", 0
db 0x12F9, "FourFold Technologies", 0
db 0x12FB, "Spectrum Signal Processing", 0
db 0x12FC, "Capital Equipment Corporation", 0
db 0x12FE, "esd Electronic System Design GmbH", 0
db 0x1303, "Innovative Integration", 0
db 0x1304, "Juniper Networks Incorporated", 0
db 0x1307, "ComputerBoards", 0
db 0x1308, "Jato Technologies Incorporated", 0
db 0x130A, "Mitsubishi Electric Microcomputer", 0
db 0x130B, "Colorgraphic Communications Corporation", 0
db 0x130F, "Advanet Incorporated", 0
db 0x1310, "Gespac", 0
db 0x1312, "Microscan Systems Incorporated", 0
db 0x1313, "Yaskawa Electric Co.", 0
db 0x1316, "Teradyne Incorporated", 0
db 0x1317, "ADMtek Incorporated", 0
db 0x1318, "Packet Engines, Incorporated", 0
db 0x1319, "Forte Media", 0
db 0x131F, "SIIG", 0
db 0x1325, "austriamicrosystems", 0
db 0x1326, "Seachange International", 0
db 0x1328, "CIFELLI SYSTEMS CORPORATION", 0
db 0x1331, "RadiSys Corporation", 0
db 0x1332, "Curtiss-Wright Controls Embedded Computing", 0
db 0x1335, "Videomail Incorporated", 0
db 0x133D, "Prisa Networks", 0
db 0x133F, "SCM Microsystems", 0
db 0x1342, "Promax Systems Incorporated", 0
db 0x1344, "Micron Technology, Incorporated", 0
db 0x1347, "Spectracom Corporation", 0
db 0x134A, "DTC Technology Corporation", 0
db 0x134B, "ARK Research Corporation", 0
db 0x134C, "Chori Joho System Co. Limited", 0
db 0x134D, "PCTEL Incorporated", 0
db 0x135A, "Brain Boxes Limited", 0
db 0x135B, "Giganet Incorporated", 0
db 0x135C, "Quatech Incorporated", 0
db 0x135D, "ABB Network Partner AB", 0
db 0x135E, "Sealevel Systems Incorporated", 0
db 0x135F, "I-Data International A-S", 0
db 0x1360, "Meinberg Funkuhren GmbH & Co. KG", 0
db 0x1361, "Soliton Systems K.K.", 0
db 0x1363, "Phoenix Technologies Limited", 0
db 0x1365, "Hypercope Corporation", 0
db 0x1366, "Teijin Seiki Co. Limited", 0
db 0x1367, "Hitachi Zosen Corporation", 0
db 0x1368, "Skyware Corporation", 0
db 0x1369, "Digigram", 0
db 0x136B, "Kawasaki Steel Corporation", 0
db 0x136C, "Adtek System Science Co Limited", 0
db 0x1375, "Boeing - Sunnyvale", 0
db 0x137A, "Mark Of The Unicorn Incorporated", 0
db 0x137B, "PPT Vision", 0
db 0x137C, "Iwatsu Electric Co Limited", 0
db 0x137D, "Dynachip Corporation", 0
db 0x137E, "Patriot Scientific Corporation", 0
db 0x1380, "Sanritz Automation Co LTC", 0
db 0x1381, "Brains Co. Limited", 0
db 0x1382, "Marian - Electronic & Software", 0
db 0x1384, "Stellar Semiconductor Incorporated", 0
db 0x1385, "Netgear", 0
db 0x1387, "Curtiss-Wright Controls Electronic Systems", 0
db 0x1388, "Hitachi Information Technology Co Limited", 0
db 0x1389, "Applicom International", 0
db 0x138A, "Validity Sensors, Incorporated", 0
db 0x138B, "Tokimec Incorporated", 0
db 0x138E, "Basler GMBH", 0
db 0x138F, "Patapsco Designs Incorporated", 0
db 0x1390, "Concept Development Incorporated", 0
db 0x1393, "Moxa Technologies Co Limited", 0
db 0x1394, "Level One Communications", 0
db 0x1395, "Ambicom Incorporated", 0
db 0x1396, "Cipher Systems Incorporated", 0
db 0x1397, "Cologne Chip Designs GmbH", 0
db 0x1398, "Clarion Co. Limited", 0
db 0x139A, "Alacritech Incorporated", 0
db 0x139D, "Xstreams PLC/ EPL Limited", 0
db 0x139E, "Echostar Data Networks", 0
db 0x13A0, "Crystal Group Incorporated", 0
db 0x13A1, "Kawasaki Heavy Industries Limited", 0
db 0x13A3, "HI-FN Incorporated", 0
db 0x13A4, "Rascom Incorporated", 0
db 0x13A7, "amc330", 0
db 0x13A8, "Exar Corporation", 0
db 0x13A9, "Siemens Healthcare", 0
db 0x13AA, "Nortel Networks - BWA Division", 0
db 0x13AF, "T.Sqware", 0
db 0x13B1, "Tamura Corporation", 0
db 0x13B4, "Wellbean Co Incorporated", 0
db 0x13B5, "ARM Limited", 0
db 0x13B6, "DLoG Gesellschaft für elektronische Datentechnik mbH", 0
db 0x13B8, "Nokia Telecommunications OY", 0
db 0x13BD, "Sharp Corporation", 0
db 0x13BF, "Sharewave Incorporated", 0
db 0x13C0, "Microgate Corporation", 0
db 0x13C1, "LSI", 0
db 0x13C2, "Technotrend Systemtechnik GMBH", 0
db 0x13C3, "Janz Computer AG", 0
db 0x13C7, "Blue Chip Technology Limited", 0
db 0x13CC, "Metheus Corporation", 0
db 0x13CF, "Studio Audio & Video Limited", 0
db 0x13D0, "B2C2 Incorporated", 0
db 0x13D1, "AboCom Systems, Incorporated", 0
db 0x13D4, "Graphics Microsystems Incorporated", 0
db 0x13D6, "K.I. Technology Co Limited", 0
db 0x13D7, "Toshiba Engineering Corporation", 0
db 0x13D8, "Phobos Corporation", 0
db 0x13D9, "Apex Incorporated", 0
db 0x13DC, "Netboost Corporation", 0
db 0x13DE, "ABB Robotics Products AB", 0
db 0x13DF, "E-Tech Incorporated", 0
db 0x13E0, "GVC Corporation", 0
db 0x13E3, "Nest Incorporated", 0
db 0x13E4, "Calculex Incorporated", 0
db 0x13E5, "Telesoft Design Limited", 0
db 0x13E9, "Intraserver Technology Incorporated", 0
db 0x13EA, "Dallas Semiconductor", 0
db 0x13F0, "IC Plus Corporation", 0
db 0x13F1, "OCE - Industries S.A.", 0
db 0x13F4, "Troika Networks Incorporated", 0
db 0x13F6, "C-Media Electronics Incorporated", 0
db 0x13F9, "NTT Advanced Technology Corporation", 0
db 0x13FA, "Pentland Systems Limited", 0
db 0x13FB, "Aydin Corporation", 0
db 0x13FD, "Micro Science Incorporated", 0
db 0x13FE, "Advantech Co., Limited", 0
db 0x13FF, "Silicon Spice Incorporated", 0
db 0x1400, "ArtX Incorporated", 0
db 0x1402, "Meilhaus Electronic GmbH Germany", 0
db 0x1404, "Fundamental Software Incorporated", 0
db 0x1406, "Oce Print Logics Technologies S.A.", 0
db 0x1407, "Lava Computer MFG Incorporated", 0
db 0x1408, "Aloka Co. Limited", 0
db 0x1409, "SUNIX Co., Limited", 0
db 0x140A, "DSP Research Incorporated", 0
db 0x140B, "Ramix Incorporated", 0
db 0x140D, "Matsushita Electric Works Limited", 0
db 0x140F, "Salient Systems Corporation", 0
db 0x1412, "IC Ensemble, Incorporated", 0
db 0x1413, "Addonics", 0
db 0x1415, "Oxford Semiconductor Limited- now part of PLX Technology", 0
db 0x1418, "Kyushu Electronics Systems Incorporated", 0
db 0x1419, "Excel Switching Corporation", 0
db 0x141B, "Zoom Telephonics Incorporated", 0
db 0x141E, "Fanuc Co. Limited", 0
db 0x141F, "Visiontech Limited", 0
db 0x1420, "Psion Dacom PLC", 0
db 0x1425, "Chelsio Communications", 0
db 0x1428, "Edec Co Limited", 0
db 0x1429, "Unex Technology Corporation", 0
db 0x142A, "Kingmax Technology Incorporated", 0
db 0x142B, "Radiolan", 0
db 0x142C, "Minton Optic Industry Co Limited", 0
db 0x142D, "Pixstream Incorporated", 0
db 0x1430, "ITT Aerospace/Communications Division", 0
db 0x1433, "Eltec Elektronik AG", 0
db 0x1435, "RTD Embedded Technologies, Incorporated", 0
db 0x1436, "CIS Technology Incorporated", 0
db 0x1437, "Nissin IncorporatedCo", 0
db 0x1438, "Atmel-Dream", 0
db 0x143F, "Lightwell Co Limited- Zax Division", 0
db 0x1441, "Agie SA.", 0
db 0x1443, "Unibrain S.A.", 0
db 0x1445, "Logical Co Limited", 0
db 0x1446, "Graphin Co., LTD", 0
db 0x1447, "Aim GMBH", 0
db 0x1448, "Alesis Studio", 0
db 0x144A, "ADLINK Technology Incorporated", 0
db 0x144B, "Loronix Information Systems, Incorporated", 0
db 0x144D, "sanyo", 0
db 0x1450, "Octave Communications Ind.", 0
db 0x1451, "SP3D Chip Design GMBH", 0
db 0x1453, "Mycom Incorporated", 0
db 0x1458, "Giga-Byte Technologies", 0
db 0x145C, "Cryptek", 0
db 0x145F, "Baldor Electric Company", 0
db 0x1460, "Dynarc Incorporated", 0
db 0x1462, "Micro-Star International Co Limited", 0
db 0x1463, "Fast Corporation", 0
db 0x1464, "Interactive Circuits & Systems Limited", 0
db 0x1468, "Ambit Microsystems Corporation", 0
db 0x1469, "Cleveland Motion Controls", 0
db 0x146C, "Ruby Tech Corporation", 0
db 0x146D, "Tachyon Incorporated", 0
db 0x146E, "WMS Gaming", 0
db 0x1471, "Integrated Telecom Express Incorporated", 0
db 0x1473, "Zapex Technologies Incorporated", 0
db 0x1474, "Doug Carson & Associates", 0
db 0x1477, "Net Insight", 0
db 0x1478, "Diatrend Corporation", 0
db 0x147B, "Abit Computer Corporation", 0
db 0x147F, "Nihon Unisys Limited", 0
db 0x1482, "Isytec - Integrierte Systemtechnik Gmbh", 0
db 0x1483, "Labway Coporation", 0
db 0x1485, "Erma - Electronic GMBH", 0
db 0x1489, "KYE Systems Corporation", 0
db 0x148A, "Opto 22", 0
db 0x148B, "Innomedialogic Incorporated", 0
db 0x148C, "C.P. Technology Co. Limited", 0
db 0x148D, "Digicom Systems Incorporated", 0
db 0x148E, "OSI Plus Corporation", 0
db 0x148F, "Plant Equipment Incorporated", 0
db 0x1490, "TC Labs Pty Limited", 0
db 0x1491, "Futronic", 0
db 0x1493, "Maker Communications", 0
db 0x1495, "Tokai Communications Industry Co. Limited", 0
db 0x1496, "Joytech Computer Co. Limited", 0
db 0x1497, "SMA Technologie AG", 0
db 0x1498, "Tews Technologies", 0
db 0x1499, "Micro-Technology Co Limited", 0
db 0x149A, "Andor Technology Limited", 0
db 0x149B, "Seiko Instruments Incorporated", 0
db 0x149E, "Mapletree Networks Incorporated", 0
db 0x149F, "Lectron Co Limited", 0
db 0x14A0, "Softing AG", 0
db 0x14A2, "Millennium Engineering Incorporated", 0
db 0x14A4, "GVC/BCM Advanced Research", 0
db 0x14A9, "Hivertec Incorporated", 0
db 0x14AB, "Mentor Graphics Corporation", 0
db 0x14B1, "Nextcom K.K.", 0
db 0x14B3, "Xpeed Incorporated", 0
db 0x14B4, "Philips Business Electronics B.V.", 0
db 0x14B5, "Creamware GmbH", 0
db 0x14B6, "Quantum Data Corporation", 0
db 0x14B7, "Proxim Incorporated", 0
db 0x14B9, "Aironet Wireless Communication", 0
db 0x14BA, "Internix Incorporated", 0
db 0x14BB, "Semtech Corporation", 0
db 0x14BE, "L3 Communications", 0
db 0x14C0, "Compal Electronics, Incorporated", 0
db 0x14C1, "Myricom Incorporated", 0
db 0x14C2, "DTK Computer", 0
db 0x14C4, "Iwasaki Information Systems Co Limited", 0
db 0x14C5, "ABB AB (Sweden)", 0
db 0x14C6, "Data Race Incorporated", 0
db 0x14C7, "Modular Technology Limited", 0
db 0x14C8, "Turbocomm Tech Incorporated", 0
db 0x14C9, "Odin Telesystems Incorporated", 0
db 0x14CB, "Billionton Systems Incorporated/Cadmus Micro Incorporated", 0
db 0x14CD, "Universal Scientific Ind.", 0
db 0x14CF, "TEK Microsystems Incorporated", 0
db 0x14D4, "Panacom Technology Corporation", 0
db 0x14D5, "Nitsuko Corporation", 0
db 0x14D6, "Accusys Incorporated", 0
db 0x14D7, "Hirakawa Hewtech Corporation", 0
db 0x14D8, "Hopf Elektronik GMBH", 0
db 0x14D9, "Alpha Processor Incorporated", 0
db 0x14DB, "Avlab Technology Incorporated", 0
db 0x14DC, "Amplicon Liveline Limited", 0
db 0x14DD, "Imodl Incorporated", 0
db 0x14DE, "Applied Integration Corporation", 0
db 0x14E3, "Amtelco", 0
db 0x14E4, "Broadcom", 0
db 0x14EA, "Planex Communications, Incorporated", 0
db 0x14EB, "Seiko Epson Corporation", 0
db 0x14EC, "Acqiris", 0
db 0x14ED, "Datakinetics Limited", 0
db 0x14EF, "Carry Computer Eng. Co Limited", 0
db 0x14F1, "Conexant", 0
db 0x14F2, "Mobility Electronics, Incorporated", 0
db 0x14F4, "Tokyo Electronic Industry Co. Limited", 0
db 0x14F5, "Sopac Limited", 0
db 0x14F6, "Coyote Technologies LLC", 0
db 0x14F7, "Wolf Technology Incorporated", 0
db 0x14F8, "Audiocodes Incorporated", 0
db 0x14F9, "AG Communications", 0
db 0x14FB, "Transas Marine (UK) Limited", 0
db 0x14FC, "Quadrics Limited", 0
db 0x14FD, "Silex Technology Incorporated", 0
db 0x14FE, "Archtek Telecom Corporation", 0
db 0x14FF, "Twinhead International Corporation", 0
db 0x1501, "Banksoft Canada Limited", 0
db 0x1502, "Mitsubishi Electric Logistics Support Co", 0
db 0x1503, "Kawasaki LSI USA Incorporated", 0
db 0x1504, "Kaiser Electronics", 0
db 0x1506, "Chameleon Systems Incorporated", 0
db 0x1507, "Htec Limited", 0
db 0x1509, "First International Computer Incorporated", 0
db 0x150B, "Yamashita Systems Corporation", 0
db 0x150C, "Kyopal Co Limited", 0
db 0x150D, "Warpspped Incorporated", 0
db 0x150E, "C-Port Corporation", 0
db 0x150F, "Intec GMBH", 0
db 0x1510, "Behavior Tech Computer Corporation", 0
db 0x1511, "Centillium Technology Corporation", 0
db 0x1512, "Rosun Technologies Incorporated", 0
db 0x1513, "Raychem", 0
db 0x1514, "TFL LAN Incorporated", 0
db 0x1515, "ICS Advent", 0
db 0x1516, "Myson Technology Incorporated", 0
db 0x1517, "Echotek Corporation", 0
db 0x1518, "Kontron Modular Computers GmbH (PEP Modular Computers GMBH)", 0
db 0x1519, "Telefon Aktiebolaget LM Ericsson", 0
db 0x151A, "Globetek Incorporated", 0
db 0x151B, "Combox Limited", 0
db 0x151C, "Digital Audio Labs Incorporated", 0
db 0x151D, "Fujitsu Computer Products Of America", 0
db 0x151E, "Matrix Corporation", 0
db 0x151F, "Topic Semiconductor Corporation", 0
db 0x1520, "Chaplet System Incorporated", 0
db 0x1521, "Bell Corporation", 0
db 0x1522, "Mainpine Limited", 0
db 0x1523, "Music Semiconductors", 0
db 0x1524, "ENE Technology Incorporated", 0
db 0x1525, "Impact Technologies", 0
db 0x1526, "ISS Incorporated", 0
db 0x1527, "Solectron", 0
db 0x1528, "Acksys", 0
db 0x1529, "American Microsystems Incorporated", 0
db 0x152A, "Quickturn Design Systems", 0
db 0x152B, "Flytech Technology Co Limited", 0
db 0x152C, "Macraigor Systems LLC", 0
db 0x152D, "Quanta Computer Incorporated", 0
db 0x152E, "Melec Incorporated", 0
db 0x152F, "Philips - Crypto", 0
db 0x1532, "Echelon Corporation", 0
db 0x1533, "Baltimore", 0
db 0x1534, "Road Corporation", 0
db 0x1535, "Evergreen Technologies Incorporated", 0
db 0x1537, "Datalex Communcations", 0
db 0x1538, "Aralion Incorporated", 0
db 0x1539, "Atelier Informatiques et Electronique Et", 0
db 0x153A, "ONO Sokki", 0
db 0x153B, "Terratec Electronic GMBH", 0
db 0x153C, "Antal Electronic", 0
db 0x153D, "Filanet Corporation", 0
db 0x153E, "Techwell Incorporated", 0
db 0x153F, "MIPS Technologies Incorporated", 0
db 0x1540, "Provideo Multimedia Co Limited", 0
db 0x1541, "Telocity Incorporated", 0
db 0x1542, "Vivid Technology Incorporated", 0
db 0x1543, "Silicon Laboratories", 0
db 0x1544, "DCM Technologies Limited", 0
db 0x1545, "VisionTek", 0
db 0x1546, "IOI Technology Corporation", 0
db 0x1547, "Mitutoyo Corporation", 0
db 0x1548, "Jet Propulsion Laboratory", 0
db 0x1549, "Interconnect Systems Solutions", 0
db 0x154A, "Max Technologies Incorporated", 0
db 0x154B, "Computex Co Limited", 0
db 0x154C, "Visual Technology Incorporated", 0
db 0x154D, "PAN International Industrial Corporation", 0
db 0x154E, "Servotest Limited", 0
db 0x154F, "Stratabeam Technology", 0
db 0x1550, "Open Network Company Limited", 0
db 0x1551, "Smart Electronic Development GMBH", 0
db 0x1553, "Chicony Electronics Company Limited", 0
db 0x1554, "Prolink Microsystems Corporation", 0
db 0x1555, "Gesytec GmbH", 0
db 0x1556, "PLDA", 0
db 0x1557, "Mediastar Co. Limited", 0
db 0x1558, "Clevo/Kapok Computer", 0
db 0x1559, "SI Logic Limited", 0
db 0x155A, "Innomedia Incorporated", 0
db 0x155B, "Protac International Corporation", 0
db 0x155C, "s", 0
db 0x155D, "MAC System Company Limited", 0
db 0x155E, "KUKA Roboter GmbH", 0
db 0x155F, "Perle Systems Limited", 0
db 0x1560, "Terayon Communications Systems", 0
db 0x1561, "Viewgraphics Incorporated", 0
db 0x1562, "Symbol Technologies, Incorporated", 0
db 0x1563, "A-Trend Technology Company Limited", 0
db 0x1564, "Yamakatsu Electronics Industry Company Limited", 0
db 0x1565, "Biostar Microtech Intl Corporation", 0
db 0x1566, "Ardent Technologies Incorporated", 0
db 0x1567, "Jungsoft", 0
db 0x1568, "DDK Electronics Incorporated", 0
db 0x1569, "Palit Microsystems Incorporated", 0
db 0x156A, "Avtec Systems Incorporated", 0
db 0x156B, "S2io Incorporated", 0
db 0x156C, "Vidac Electronics GMBH", 0
db 0x156D, "Alpha-Top Corporation", 0
db 0x156E, "Alfa Incorporated", 0
db 0x156F, "M-Systems Flash Disk Pioneers Limited", 0
db 0x1570, "Lecroy Corporation", 0
db 0x1571, "Contemporary Controls", 0
db 0x1572, "Otis Elevator Company", 0
db 0x1573, "Lattice - Vantis", 0
db 0x1574, "Fairchild Semiconductor", 0
db 0x1575, "Voltaire Advanced Data Security Limited", 0
db 0x1576, "Viewcast Com", 0
db 0x1578, "Hitt", 0
db 0x1579, "Dual Technology Corporation", 0
db 0x157A, "Japan Elecronics Ind. Incorporated", 0
db 0x157B, "Star Multimedia Corporation", 0
db 0x157C, "Eurosoft (UK)", 0
db 0x157D, "Gemflex Networks", 0
db 0x157E, "Transition Networks", 0
db 0x157F, "PX Instruments Technology Limited", 0
db 0x1580, "Primex Aerospace Co.", 0
db 0x1581, "SEH Computertechnik GMBH", 0
db 0x1582, "Cytec Corporation", 0
db 0x1583, "Inet Technologies Incorporated", 0
db 0x1584, "Vetronix Corporation Engenharia Limited", 0
db 0x1585, "Marconi Commerce Systems SRL", 0
db 0x1586, "Lancast Incorporated", 0
db 0x1587, "Konica Corporation", 0
db 0x1588, "Solidum Systems Corporation", 0
db 0x1589, "Atlantek Microsystems Pty Limited", 0
db 0x158A, "Digalog Systems Incorporated", 0
db 0x158B, "Allied Data Technologies", 0
db 0x158C, "Hitachi Semiconductor & Devices Sales Co", 0
db 0x158D, "Point Multimedia Systems", 0
db 0x158E, "Lara Technology Incorporated", 0
db 0x158F, "Ditect Coop", 0
db 0x1590, "3pardata Incorporated", 0
db 0x1591, "ARN", 0
db 0x1592, "Syba Tech Limited", 0
db 0x1593, "Bops Incorporated", 0
db 0x1594, "Netgame Limited", 0
db 0x1595, "Diva Systems Corporation", 0
db 0x1596, "Folsom Research Incorporated", 0
db 0x1597, "Memec Design Services", 0
db 0x1598, "Granite Microsystems", 0
db 0x1599, "Delta Electronics Incorporated", 0
db 0x159A, "General Instrument", 0
db 0x159B, "Faraday Technology Corporation", 0
db 0x159C, "Stratus Computer Systems", 0
db 0x159D, "Ningbo Harrison Electronics Co Limited", 0
db 0x159E, "A-Max Technology Co Limited", 0
db 0x159F, "Galea Network Security", 0
db 0x15A0, "Compumaster SRL", 0
db 0x15A1, "Geocast Network Systems Incorporated", 0
db 0x15A2, "Catalyst Enterprises Incorporated", 0
db 0x15A3, "Italtel", 0
db 0x15A4, "X-Net OY", 0
db 0x15A5, "Toyota MACS Incorporated", 0
db 0x15A6, "Sunlight Ultrasound Technologies Limited", 0
db 0x15A7, "SSE Telecom Incorporated", 0
db 0x15A8, "Shanghai Communications Technologies Cen", 0
db 0x15AA, "Moreton Bay", 0
db 0x15AB, "Bluesteel Networks Incorporated", 0
db 0x15AC, "North Atlantic Instruments", 0
db 0x15AD, "VMware Incorporated", 0
db 0x15AE, "Amersham Pharmacia Biotech", 0
db 0x15B0, "Zoltrix International Limited", 0
db 0x15B1, "Source Technology Incorporated", 0
db 0x15B2, "Mosaid Technologies Incorporated", 0
db 0x15B3, "Mellanox Technology", 0
db 0x15B4, "CCI/Triad", 0
db 0x15B5, "Cimetrics Incorporated", 0
db 0x15B6, "Texas Memory Systems Incorporated", 0
db 0x15B7, "Sandisk Corporation", 0
db 0x15B8, "Addi-Data GMBH", 0
db 0x15B9, "Maestro Digital Communications", 0
db 0x15BA, "Impacct Technology Corporation", 0
db 0x15BB, "Portwell Incorporated", 0
db 0x15BC, "Agilent Technologies", 0
db 0x15BD, "DFI Incorporated", 0
db 0x15BE, "Sola Electronics", 0
db 0x15BF, "High Tech Computer Corporation (HTC)", 0
db 0x15C0, "BVM Limited", 0
db 0x15C1, "Quantel", 0
db 0x15C2, "Newer Technology Incorporated", 0
db 0x15C3, "Taiwan Mycomp Co Limited", 0
db 0x15C4, "EVSX Incorporated", 0
db 0x15C5, "Procomp Informatics Limited", 0
db 0x15C6, "Technical University Of Budapest", 0
db 0x15C7, "Tateyama System Laboratory Co Limited", 0
db 0x15C8, "Penta Media Co. Limited", 0
db 0x15C9, "Serome Technology Incorporated", 0
db 0x15CA, "Bitboys OY", 0
db 0x15CB, "AG Electronics Limited", 0
db 0x15CC, "Hotrail Incorporated", 0
db 0x15CD, "Dreamtech Co Limited", 0
db 0x15CE, "Genrad Incorporated", 0
db 0x15CF, "Hilscher GMBH", 0
db 0x15D1, "Infineon Technologies AG", 0
db 0x15D2, "FIC (First International Computer Incorporated", 0
db 0x15D3, "NDS Technologies Israel Limited", 0
db 0x15D4, "Iwill Corporation", 0
db 0x15D5, "Tatung Co.", 0
db 0x15D6, "Entridia Corporation", 0
db 0x15D7, "Rockwell-Collins Incorporated", 0
db 0x15D8, "Cybernetics Technology Co Limited", 0
db 0x15D9, "Super Micro Computer Incorporated", 0
db 0x15DA, "Cyberfirm Incorporated", 0
db 0x15DB, "Applied Computing Systems Incorporated", 0
db 0x15DC, "Litronic Incorporated", 0
db 0x15DD, "Sigmatel Incorporated", 0
db 0x15DE, "Malleable Technologies Incorporated", 0
db 0x15E0, "Cacheflow Incorporated", 0
db 0x15E1, "Voice Technologies Group", 0
db 0x15E2, "Quicknet Technologies Incorporated", 0
db 0x15E3, "Networth Technologies Incorporated", 0
db 0x15E4, "VSN Systemen BV", 0
db 0x15E5, "Valley Technologies Incorporated", 0
db 0x15E6, "Agere Incorporated", 0
db 0x15E7, "GET Engineering Corporation", 0
db 0x15E8, "National Datacomm Corporation", 0
db 0x15E9, "Pacific Digital Corporation", 0
db 0x15EA, "Tokyo Denshi Sekei K.K.", 0
db 0x15EB, "Drsearch GMBH", 0
db 0x15EC, "Beckhoff Automation GmbH", 0
db 0x15ED, "Macrolink Incorporated", 0
db 0x15EE, "IN Win Development Incorporated", 0
db 0x15EF, "Intelligent Paradigm Incorporated", 0
db 0x15F0, "B-Tree Systems Incorporated", 0
db 0x15F1, "Times N Systems Incorporated", 0
db 0x15F2, "SPOT Imaging Solutions a division of Diagnostic Instruments Incorporated", 0
db 0x15F3, "Digitmedia Corporation", 0
db 0x15F4, "Valuesoft", 0
db 0x15F5, "Power Micro Research", 0
db 0x15F6, "Extreme Packet Device Incorporated", 0
db 0x15F7, "Banctec", 0
db 0x15F8, "Koga Electronics Co", 0
db 0x15F9, "Zenith Electronics Co", 0
db 0x15FA, "Axzam Corporation", 0
db 0x15FB, "Zilog Incorporated", 0
db 0x15FC, "Techsan Electronics Co Limited", 0
db 0x15FD, "N-Cubed.Net", 0
db 0x15FE, "Kinpo Electronics Incorporated", 0
db 0x15FF, "Fastpoint Technologies Incorporated", 0
db 0x1600, "Northrop Grumman - Canada Limited", 0
db 0x1601, "Tenta Technology", 0
db 0x1602, "Prosys-TEC Incorporated", 0
db 0x1603, "Nokia Wireless Business Communications", 0
db 0x1604, "Central System Research Co Limited", 0
db 0x1605, "Pairgain Technologies", 0
db 0x1606, "Europop AG", 0
db 0x1607, "Lava Semiconductor Manufacturing Incorporated", 0
db 0x1608, "Automated Wagering International", 0
db 0x1609, "Sciemetric Instruments Incorporated", 0
db 0x160A, "Kollmorgen Servotronix", 0
db 0x160B, "Onkyo Corporation", 0
db 0x160C, "Oregon Micro Systems Incorporated", 0
db 0x160D, "Aaeon Electronics Incorporated", 0
db 0x160E, "CML Emergency Services", 0
db 0x160F, "ITEC Co Limited", 0
db 0x1610, "Tottori Sanyo Electric Co Limited", 0
db 0x1611, "Bel Fuse Incorporated", 0
db 0x1612, "Telesynergy Research Incorporated", 0
db 0x1613, "System Craft Incorporated", 0
db 0x1614, "Jace Tech Incorporated", 0
db 0x1615, "Equus Computer Systems Incorporated", 0
db 0x1616, "Iotech Incorporated", 0
db 0x1617, "Rapidstream Incorporated", 0
db 0x1618, "Esec SA", 0
db 0x1619, "FarSite Communications Limited", 0
db 0x161B, "Mobilian Israel Limited", 0
db 0x161C, "Berkshire Products", 0
db 0x161D, "Gatec", 0
db 0x161E, "Kyoei Sangyo Co Limited", 0
db 0x161F, "Arima Computer Corporation", 0
db 0x1620, "Sigmacom Co Limited", 0
db 0x1621, "Lynx Studio Technology Incorporated", 0
db 0x1622, "Nokia Home Communications", 0
db 0x1623, "KRF Tech Limited", 0
db 0x1624, "CE Infosys GMBH", 0
db 0x1625, "Warp Nine Engineering", 0
db 0x1626, "TDK Semiconductor Corporation", 0
db 0x1627, "BCom Electronics Incorporated", 0
db 0x1629, "Kongsberg Spacetec a.s.", 0
db 0x162A, "Sejin Computerland Company Limited", 0
db 0x162B, "Shanghai Bell Company Limited", 0
db 0x162C, "C&H Technologies Incorporated", 0
db 0x162D, "Reprosoft Company Limited", 0
db 0x162E, "Margi Systems Incorporated", 0
db 0x162F, "Rohde & Schwarz GMBH & Co KG", 0
db 0x1630, "Sky Computers Incorporated", 0
db 0x1631, "NEC Computer International", 0
db 0x1632, "Verisys Incorporated", 0
db 0x1633, "Adac Corporation", 0
db 0x1634, "Visionglobal Network Corporation", 0
db 0x1635, "Decros / S.ICZ a.s.", 0
db 0x1636, "Jean Company Limited", 0
db 0x1637, "NSI", 0
db 0x1638, "Eumitcom Technology Incorporated", 0
db 0x163A, "Air Prime Incorporated", 0
db 0x163B, "Glotrex Co Limited", 0
db 0x163C, "intel", 0
db 0x163D, "Heidelberg Digital LLC", 0
db 0x163E, "3dpower", 0
db 0x163F, "Renishaw PLC", 0
db 0x1640, "Intelliworxx Incorporated", 0
db 0x1641, "MKNet Corporation", 0
db 0x1642, "Bitland", 0
db 0x1643, "Hajime Industries Limited", 0
db 0x1644, "Western Avionics Limited", 0
db 0x1645, "Quick-Serv. Computer Co. Limited", 0
db 0x1646, "Nippon Systemware Co Limited", 0
db 0x1647, "Hertz Systemtechnik GMBH", 0
db 0x1648, "MeltDown Systems LLC", 0
db 0x1649, "Jupiter Systems", 0
db 0x164A, "Aiwa Co. Limited", 0
db 0x164C, "Department Of Defense", 0
db 0x164D, "Ishoni Networks", 0
db 0x164E, "Micrel Incorporated", 0
db 0x164F, "Datavoice (Pty) Limited", 0
db 0x1650, "Admore Technology Incorporated", 0
db 0x1651, "Chaparral Network Storage", 0
db 0x1652, "Spectrum Digital Incorporated", 0
db 0x1653, "Nature Worldwide Technology Corporation", 0
db 0x1654, "Sonicwall Incorporated", 0
db 0x1655, "Dazzle Multimedia Incorporated", 0
db 0x1656, "Insyde Software Corporation", 0
db 0x1657, "Brocade Communications Systems", 0
db 0x1658, "Med Associates Incorporated", 0
db 0x1659, "Shiba Denshi Systems Incorporated", 0
db 0x165A, "Epix Incorporated", 0
db 0x165B, "Real-Time Digital Incorporated", 0
db 0x165C, "Kondo Kagaku", 0
db 0x165D, "Hsing Tech. Enterprise Co. Limited", 0
db 0x165E, "Hyunju Computer Co. Limited", 0
db 0x165F, "Comartsystem Korea", 0
db 0x1660, "Network Security Technologies Incorporated (NetSec)", 0
db 0x1661, "Worldspace Corporation", 0
db 0x1662, "Int Labs", 0
db 0x1663, "Elmec Incorporated Limited", 0
db 0x1664, "Fastfame Technology Co. Limited", 0
db 0x1665, "Edax Incorporated", 0
db 0x1666, "Norpak Corporation", 0
db 0x1667, "CoSystems Incorporated", 0
db 0x1668, "Actiontec Electronics Incorporated", 0
db 0x166A, "Komatsu Limited", 0
db 0x166B, "Supernet Incorporated", 0
db 0x166C, "Shade Limited", 0
db 0x166D, "Sibyte Incorporated", 0
db 0x166E, "Schneider Automation Incorporated", 0
db 0x166F, "Televox Software Incorporated", 0
db 0x1670, "Rearden Steel", 0
db 0x1671, "Atan Technology Incorporated", 0
db 0x1672, "Unitec Co. Limited", 0
db 0x1673, "pctel", 0
db 0x1675, "Square Wave Technology", 0
db 0x1676, "Emachines Incorporated", 0
db 0x1677, "Bernecker + Rainer", 0
db 0x1678, "INH Semiconductor", 0
db 0x1679, "Tokyo Electron Device Limited", 0
db 0x167F, "iba AG", 0
db 0x1680, "Dunti Corporation", 0
db 0x1681, "Hercules", 0
db 0x1682, "PINE Technology, Limited", 0
db 0x1688, "CastleNet Technology Incorporated", 0
db 0x168A, "Utimaco Safeware AG", 0
db 0x168B, "Circut Assembly Corporation", 0
db 0x168C, "Atheros Communications Incorporated", 0
db 0x168D, "NMI Electronics Limited", 0
db 0x168E, "Hyundai MultiCAV Computer Co. Limited", 0
db 0x168F, "KDS Innotech Corporation", 0
db 0x1690, "NetContinuum, Incorporated", 0
db 0x1693, "FERMA", 0
db 0x1695, "EPoX Computer Company Limited", 0
db 0x16AE, "SafeNet Incorporated", 0
db 0x16B3, "CNF Mobile Solutions", 0
db 0x16B8, "Sonnet Technologies, Incorporated", 0
db 0x16CA, "Cenatek Incorporated", 0
db 0x16CB, "Minolta Co. Limited", 0
db 0x16CC, "Inari Incorporated", 0
db 0x16D0, "Systemax", 0
db 0x16E0, "Third Millenium Test Solutions, Incorporated", 0
db 0x16E5, "Intellon Corporation", 0
db 0x16EC, "U.S. Robotics", 0
db 0x16F0, "LaserLinc Incorporated", 0
db 0x16F1, "Adicti Corporation", 0
db 0x16F3, "Jetway Information Company Limited", 0
db 0x16F6, "VideoTele.com Incorporated", 0
db 0x1700, "Antara LLC", 0
db 0x1701, "Interactive Computer Products Incorporated", 0
db 0x1702, "Internet Machines Corporation", 0
db 0x1703, "Desana Systems", 0
db 0x1704, "Clearwater Networks", 0
db 0x1705, "Digital First", 0
db 0x1706, "Pacific Broadband Communications", 0
db 0x1707, "Cogency Semiconductor Incorporated", 0
db 0x1708, "Harris Corporation", 0
db 0x1709, "Zarlink Semiconductor", 0
db 0x170A, "Alpine Electronics Incorporated", 0
db 0x170B, "NetOctave Incorporated", 0
db 0x170C, "YottaYotta Incorporated", 0
db 0x170D, "SensoMotoric Instruments GmbH", 0
db 0x170E, "San Valley Systems, Incorporated", 0
db 0x170F, "Cyberdyne Incorporated", 0
db 0x1710, "Pelago Networks", 0
db 0x1711, "MyName Technologies, Incorporated", 0
db 0x1712, "NICE Systems Incorporated", 0
db 0x1713, "TOPCON Corporation", 0
db 0x1725, "Vitesse Semiconductor", 0
db 0x1734, "Fujitsu-Siemens Computers GmbH", 0
db 0x1737, "LinkSys", 0
db 0x173B, "Altima Communications Incorporated", 0
db 0x1743, "Peppercon AG", 0
db 0x174B, "PC Partner Limited", 0
db 0x1752, "Global Brands Manufacture Limited", 0
db 0x1753, "TeraRecon Incorporated", 0
db 0x1755, "Alchemy Semiconductor Incorporated", 0
db 0x176A, "General Dynamics Canada", 0
db 0x1775, "General Electric", 0
db 0x1789, "Ennyah Technologies Corporation", 0
db 0x1793, "Unitech Electronics Company Limited", 0
db 0x17A1, "Tascorp", 0
db 0x17A7, "Start Network Technology Company Limited", 0
db 0x17AA, "Legend Limited (Beijing)", 0
db 0x17AB, "Phillips Components", 0
db 0x17AF, "Hightech Information Systems Limited", 0
db 0x17BE, "Philips Semiconductors", 0
db 0x17C0, "Wistron Corporation", 0
db 0x17C4, "Movita", 0
db 0x17CC, "NetChip", 0
db 0x17cd, "Cadence Design Systems", 0
db 0x17D5, "Neterion Incorporated", 0
db 0x17db, "Cray Incorporated", 0
db 0x17E9, "DH electronics GmbH / Sabrent", 0
db 0x17EE, "Connect Components Limited", 0
db 0x17F3, "RDC Semiconductor Company Limited", 0
db 0x17FE, "INPROCOMM", 0
db 0x1813, "Ambient Technologies Incorporated", 0
db 0x1814, "Ralink Technology, Corporation", 0
db 0x1815, "devolo AG", 0
db 0x1820, "InfiniCon Systems, Incorporated", 0
db 0x1824, "Avocent", 0
db 0x1841, "Panda Platinum", 0
db 0x1860, "Primagraphics Limited", 0
db 0x186C, "Humusoft S.R.O", 0
db 0x1887, "Elan Digital Systems Limited", 0
db 0x1888, "Varisys Limited", 0
db 0x188D, "Millogic Limited", 0
db 0x1890, "Egenera, Incorporated", 0
db 0x18BC, "Info-Tek Corporation", 0
db 0x18C9, "ARVOO Engineering BV", 0
db 0x18CA, "XGI Technology Incorporated", 0
db 0x18F1, "Spectrum Systementwicklung Microelectronic GmbH", 0
db 0x18F4, "Napatech A/S", 0
db 0x18F7, "Commtech, Incorporated", 0
db 0x18FB, "Resilience Corporation", 0
db 0x1904, "Ritmo", 0
db 0x1905, "WIS Technology, Incorporated", 0
db 0x1910, "Seaway Networks", 0
db 0x1912, "Renesas Electronics", 0
db 0x1931, "Option NV", 0
db 0x1941, "Stelar", 0
db 0x1954, "One Stop Systems, Incorporated", 0
db 0x1969, "Atheros Communications", 0
db 0x1971, "AGEIA Technologies, Incorporated", 0
db 0x197B, "JMicron Technology Corporation", 0
db 0x198a, "Nallatech", 0
db 0x1991, "Topstar Digital Technologies Co., Limited", 0
db 0x19a2, "ServerEngines", 0
db 0x19A8, "DAQDATA GmbH", 0
db 0x19AC, "Kasten Chase Applied Research", 0
db 0x19B6, "Mikrotik", 0
db 0x19E2, "Vector Informatik GmbH", 0
db 0x19E3, "DDRdrive LLC", 0
db 0x1A08, "Linux Networx", 0
db 0x1a41, "Tilera Corporation", 0
db 0x1A42, "Imaginant", 0
db 0x1B13, "Jaton Corporation USA", 0
db 0x1B21, "Asustek - ASMedia Technology Incorporated", 0
db 0x1B6F, "Etron", 0
db 0x1B73, "Fresco Logic Incorporated", 0
db 0x1B91, "Averna", 0
db 0x1BAD, "ReFLEX CES", 0
db 0x1C0F, "Monarch Innovative Technologies Private Limited", 0
db 0x1C32, "Highland Technology Incorporated", 0
db 0x1c39, "Thomson Video Networks", 0
db 0x1DE1, "Tekram", 0
db 0x1FCF, "Miranda Technologies Limited", 0
db 0x2001, "Temporal Research Limited", 0
db 0x2646, "Kingston Technology Company", 0
db 0x270F, "ChainTek Computer Company Limited", 0
db 0x2EC1, "Zenic Incorporated", 0
db 0x3388, "Hint Corporation", 0
db 0x3411, "Quantum Designs (H.K.) Incorporated", 0
db 0x3513, "ARCOM Control Systems Limited", 0
db 0x38EF, "4links", 0
db 0x3D3D, "3Dlabs, Incorporated Limited", 0
db 0x4005, "Avance Logic Incorporated", 0
db 0x4144, "Alpha Data", 0
db 0x416C, "Aladdin Knowledge Systems", 0
db 0x4348, "wch.cn", 0
db 0x4680, "UMAX Computer Corporation", 0
db 0x4843, "Hercules Computer Technology", 0
db 0x4943, "Growth Networks", 0
db 0x4954, "Integral Technologies", 0
db 0x4978, "Axil Computer Incorporated", 0
db 0x4C48, "Lung Hwa Electronics", 0
db 0x4C53, "SBS-OR Industrial Computers", 0
db 0x4CA1, "Seanix Technology Incorporated", 0
db 0x4D51, "Mediaq Incorporated", 0
db 0x4D54, "Microtechnica Company Limited", 0
db 0x4DDC, "ILC Data Device Corporation", 0
db 0x4E80, "Samsung Windows Portable Devices", 0
db 0x5053, "TBS/Voyetra Technologies", 0
db 0x508A, "Samsung T10 MP3 Player", 0
db 0x5136, "S S Technologies", 0
db 0x5143, "Qualcomm Incorporated USA", 0
db 0x5333, "S3 Graphics Company Limited", 0
db 0x544C, "Teralogic Incorporated", 0
db 0x5555, "Genroco Incorporated", 0
db 0x5853, "Citrix Systems, Incorporated", 0
db 0x6409, "Logitec Corporation", 0
db 0x6666, "Decision Computer International Company", 0
db 0x6945, "ASMedia Technology Incorporated", 0
db 0x7604, "O.N. Electric Company Limited", 0
db 0x7d10,	"D-Link Corporation", 0
db 0x8080, "Xirlink, Incorporated", 0
db 0x8086, "Intel Corporation", 0
db 0x80EE, "Oracle Corporation - InnoTek Systemberatung GmbH", 0
db 0x8866, "T-Square Design Incorporated", 0
db 0x8888, "Silicon Magic", 0
db 0x8E0E, "Computone Corporation", 0
db 0x9004, "Adaptec Incorporated", 0
db 0x9005, "Adaptec Incorporated", 0
db 0x919A, "Gigapixel Corporation", 0
db 0x9412, "Holtek", 0
db 0x9699, "Omni Media Technology Incorporated", 0
db 0x9710, "MosChip Semiconductor Technology", 0
db 0x9902, "StarGen Incorporated", 0
db 0xA0A0, "Aopen Incorporated", 0
db 0xA0F1, "Unisys Corporation", 0
db 0xA200, "NEC Corporation", 0
db 0xA259, "Hewlett Packard", 0
db 0xA304, "Sony", 0
db 0xA727, "3com Corporation", 0
db 0xAA42, "Abekas Incorporated", 0
db 0xAC1E, "Digital Receiver Technology Incorporated", 0
db 0xB1B3, "Shiva Europe Limited", 0
db 0xB894, "Brown & Sharpe Mfg. Company", 0
db 0xBEEF, "Mindstream Computing", 0
db 0xC001, "TSI Telsys", 0
db 0xC0A9, "Micron/Crucial Technology", 0
db 0xC0DE, "Motorola", 0
db 0xC0FE, "Motion Engineering Inc.", 0
db 0xC622, "Hudson Soft Company Limited", 0
db 0xCA50, "Varian Incorporated", 0
db 0xCAFE, "Chrysalis-ITS", 0
db 0xCCCC, "Catapult Communications", 0
db 0xD4D4, "Curtiss-Wright Controls Embedded Computing", 0
db 0xDC93, "Dawicontrol", 0
db 0xDEAD, "Indigita Corporation", 0
db 0xDEAF, "Middle Digital, Inc", 0
db 0xE159, "Tiger Jet Network Inc", 0
db 0xE4BF, "EKF Elektronik GMBH", 0
db 0xEA01, "Eagle Technology", 0
db 0xEABB, "Aashima Technology B.V.", 0
db 0xEACE, "Endace Measurement Systems Limited", 0
db 0xECC0, "Echo Digital Audio Corporation", 0
db 0xEDD8, "ARK Logic Incorporated", 0
db 0xF5F5, "F5 Networks Incorporated", 0
db 0xFA57, "Interagon AS", 0
db 0xFFFF, "-Unknown or Invalid Vendor ID-", 0