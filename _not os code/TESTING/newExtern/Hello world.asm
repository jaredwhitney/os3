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
dd main

main :
	mov ebx, hello_text
	mov ah, 0xFF
	mov word [System.function], Console.println
		int 0x30
	mov word [System.function], System.exit
		int 0x30
		
%include "shlib_standard.asm"

hello_text :
	db "Hello World!", 0

fileEnd :

