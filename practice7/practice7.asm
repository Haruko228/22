section .data
    msg_n      db "Enter n (5-50): ", 0
    msg_arr    db "Array: ", 0
    msg_min    db 10, "Min: ", 0
    msg_max    db 10, "Max: ", 0
    msg_idx    db " Index: ", 0
    space      db " ", 0
    newline    db 10, 0

section .bss
    buffer     resb 16
    array      resd 50      ; масив на 50 елементів
    n_size     resd 1
    v_min      resd 1
    v_max      resd 1
    i_min      resd 1
    i_max      resd 1

section .text
    global _start

_start:
    ; --- Ввід n ---
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_n
    mov edx, 17
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 16
    int 0x80

    ; ASCII to Int
    xor eax, eax
    mov esi, buffer
.lp_n:
    movzx ecx, byte [esi]
    cmp cl, 10
    je .done_n
    sub cl, '0'
    imul eax, 10
    add eax, ecx
    inc esi
    jmp .lp_n
.done_n:
    mov [n_size], eax

    ; --- Заповнення: array[i] = i*i + 5 ---
    xor ecx, ecx
fill:
    cmp ecx, [n_size]
    je find
    mov eax, ecx
    mul eax
    add eax, 5
    mov [array + ecx*4], eax
    inc ecx
    jmp fill

    ; --- Пошук Min/Max ---
find:
    mov eax, [array]
    mov [v_min], eax
    mov [v_max], eax
    mov dword [i_min], 0
    mov dword [i_max], 0
    mov ecx, 1
search:
    cmp ecx, [n_size]
    je show
    mov eax, [array + ecx*4]
    cmp eax, [v_min]
    jge .ch_max
    mov [v_min], eax
    mov [i_min], ecx
.ch_max:
    cmp eax, [v_max]
    jle .next
    mov [v_max], eax
    mov [i_max], ecx
.next:
    inc ecx
    jmp search

    ; --- Вивід результатів ---
show:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_arr
    mov edx, 7
    int 0x80
    xor ecx, ecx
.p_arr:
    cmp ecx, [n_size]
    je .p_res
    push ecx
    mov eax, [array + ecx*4]
    call print_num
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80
    pop ecx
    inc ecx
    jmp .p_arr

.p_res:
    ; Вивід Min
    mov eax, 4
    mov ecx, msg_min
    mov edx, 6
    int 0x80
    mov eax, [v_min]
    call print_num
    ; Вивід Max
    mov eax, 4
    mov ecx, msg_max
    mov edx, 6
    int 0x80
    mov eax, [v_max]
    call print_num

    ; Вихід
    mov eax, 4
    mov ecx, newline
    mov edx, 1
    int 0x80
    mov eax, 1
    xor ebx, ebx
    int 0x80

print_num:
    pushad
    mov ebx, 10
    mov ecx, buffer + 15
    mov byte [ecx], 0
.c:
    dec ecx
    xor edx, edx
    div ebx
    add dl, '0'
    mov [ecx], dl
    test eax, eax
    jnz .c
    mov eax, 4
    mov ebx, 1
    mov edx, buffer + 15
    sub edx, ecx
    int 0x80
    popad
    ret
