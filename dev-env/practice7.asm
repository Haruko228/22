section .data
    msg_n       db "Enter n (5-50): ", 0
    msg_min     db "Min: ", 0
    msg_max     db "Max: ", 0
    msg_idx     db " Index: ", 0
    space       db " ", 0
    newline     db 0xA

section .bss
    array       resd 50
    buffer      resb 16
    out_str     resb 16
    n_val       resd 1

section .text
    global _start

_start:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_n
    mov edx, 15
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 16
    int 0x80
    call atoi
    mov [n_val], eax

    xor esi, esi
.fill_loop:
    cmp esi, [n_val]
    je .fill_done
    mov eax, esi
    imul eax, eax
    add eax, 5
    mov [array + esi*4], eax
    inc esi
    jmp .fill_loop
.fill_done:

    xor esi, esi
.print_arr:
    cmp esi, [n_val]
    je .print_done
    mov eax, [array + esi*4]
    call itoa
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80
    inc esi
    jmp .print_arr
.print_done:
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    mov eax, [array]
    xor ebx, ebx
    mov ecx, [array]
    xor edx, edx
    mov esi, 1
.min_max_loop:
    cmp esi, [n_val]
    je .min_max_done
    mov edi, [array + esi*4]
    cmp edi, eax
    jge .not_min
    mov eax, edi
    mov ebx, esi
.not_min:
    cmp edi, ecx
    jle .not_max
    mov ecx, edi
    mov edx, esi
.not_max:
    inc esi
    jmp .min_max_loop
.min_max_done:
    push edx
    push ecx
    push ebx
    push eax

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_min
    mov edx, 5
    int 0x80
    pop eax
    call itoa
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_idx
    mov edx, 8
    int 0x80
    pop eax
    call itoa
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_max
    mov edx, 5
    int 0x80
    pop eax
    call itoa
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_idx
    mov edx, 8
    int 0x80
    pop eax
    call itoa
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    mov eax, 1
    xor ebx, ebx
    int 0x80

atoi:
    xor eax, eax
    mov esi, ecx
.a_lp:
    movzx edx, byte [esi]
    cmp dl, 0xA
    je .a_dn
    sub dl, '0'
    imul eax, 10
    add eax, edx
    inc esi
    jmp .a_lp
.a_dn:
    ret

itoa:
    pusha
    mov edi, out_str
    add edi, 15
    mov byte [edi], 0
    mov ebx, 10
.i_lp:
    xor edx, edx
    div ebx
    add dl, '0'
    dec edi
    mov [edi], dl
    test eax, eax
    jnz .i_lp
    mov ecx, edi
    mov edx, out_str
    add edx, 15
    sub edx, ecx
    mov eax, 4
    mov ebx, 1
    int 0x80
    popa
    retЛ