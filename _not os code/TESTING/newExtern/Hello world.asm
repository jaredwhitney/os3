; THIS FILE IS TO BE UPDATED OR DELETED BY 10-26-15

;	First program written 3.5 years ago in java.
;
;	class HelloWorld {
;	public static void main(String[] args) {
;	System.out.println("Hello World!");
;	}
;	}

;	Time to rewrite it as the first external program in os3!

;	First the file header	;
fileStart :
dd fileEnd - headerStart
db "PROGRAM", 0
db "Hello world", 0

;	Then the program header		;
db 0x01
dd main
db "Hello World", 0

main :
	mov ebx, hello_text
	mov ah, 0xFF
	mov word [System.function], Console.println
		int 0x30
	mov word [System.function], System.exit
		int 0x30
	jmp $
		
%include "shlib_standard.asm"

hello_text :
	db "Hello World!", 0

fileEnd :

