main :
	call findStart
	main_loop :
		mov dword [draw], 1
		mov dword [dr], 1
		mov dword [rdl], 1
		mov dword [dn], 1
		mov eax, [dirrection]
		cmp eax, 1
		jne not1
			mov ebx, map
			mov eax, [ypos]
			sub eax, 1
				mov word [System.function], Array.atIndex	; overwrites ebx with return
				int 0x30
			mov eax, [xpos]
				mov word [System.function], Array.atIndex
				int 0x30
			mov [draw], ebx
			
		not1 :
		
	
	
map :
	dd "ARRd", map_0, map_1, map_2, map_3, map_4, map_5, "~OBJ"
map_0 :
	db "ARRb", 1,1,1,1,1,1,1,1,1,1, "~OBJ"
map_1 :
	db "ARRb", 1,1,1,1,0,0,0,1,5,1, "~OBJ"
map_2 :
	db "ARRb", 1,1,1,1,2,1,0,1,0,1, "~OBJ"
map_3 :
	db "ARRb", 1,1,1,1,3,1,2,1,2,1, "~OBJ"
map_4 :
	db "ARRb". 1,1,1,1,1,1,0,0,0,1, "~OBJ"
map_5 :
	db "ARRb", 1,1,1,1,1,1,1,1,1,1, "~OBJ" 

map2 :
	dd "ARRd", map2_0, map2_1, map2_2, map2_3, map2_4, map2_5, map2_6, "~OBJ"
map2_0 :
	db "ARRb". 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, "~OBJ"
map2_1 :
	db "ARRb", 1, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 3, 1, 1, 1, 0, 0, 0, 1, "~OBJ"
map2_2 :
	db "ARRb", 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 3, 1, 2, 1, "~OBJ"
map2_3 :
	db "ARRb", 1, 0, 1, 1, 5, 2, 0, 2, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 0, 1, "~OBJ"
map2_4 :
	db "ARRb", 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 0, 1, "~OBJ"
map2_5 :
	db "ARRb", 1, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, "~OBJ"
map2_6 :
	db "ARRb", 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, "~OBJ"

maps :
	dd "ARRd", map, map2, "~OBJ"