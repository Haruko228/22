section .data
    msg_a       db "Enter a: ", 0
    msg_b       db "Enter b: ", 0
    txt_s       db "SIGNED: ", 0
    txt_u       db "UNSIGNED: ", 0
    txt_max_s   db "Max Signed: ", 0
    txt_max_u   db "Max Unsigned: ", 0
    res_lt      db "a < b", 0xA, 0
    res_eq      db "a = b", 0xA, 0
    res_gt      db "a > b", 0xA, 0
    newline     db 0xA

section .bss
    buf_a       resb 32
    buf_b       resb 32
    num_a       resd 1
    num_b       resd 1
    out_str     resb 32

section .text
    global _start

_start:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_a
    mov edx, 9
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, buf_a
    mov edx, 32
    int 0x80
    call atoi
    mov [num_a], eax

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_b
    mov edx, 9
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, buf_b
    mov edx, 32
    int 0x80
    call atoi
    mov [num_b], eax

    mov eax, 4
    mov ebx, 1
    mov ecx, txt_s
    mov edx, 8
    int 0x80

    mov eax, [num_a]
    mov ebx, [num_b]
    cmp eax, ebx
    jl .s_lt
    jg .s_gt
    mov ecx, res_eq
    mov edx, 6
    jmp .s_print
.s_lt:
    mov ecx, res_lt
    mov edx, 6
    jmp .s_print
.s_gt:
    mov ecx, res_gt
    mov edx, 6
.s_print:
    mov eax, 4
    mov ebx, 1
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, txt_u
    mov edx, 10
    int 0x80

    mov eax, [num_a]
    mov ebx, [num_b]
    cmp eax, ebx
    jb .u_lt
    ja .u_gt
    mov ecx, res_eq
    mov edx, 6
    jmp .u_print
.u_lt:
    mov ecx, res_lt
    mov edx, 6
    jmp .u_print
.u_gt:
    mov ecx, res_gt
    mov edx, 6
.u_print:
    mov eax, 4
    mov ebx, 1
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, txt_max_s
    mov edx, 12
    int 0x80

    mov eax, [num_a]
    mov ebx, [num_b]
    cmp eax, ebx
    jg .p_max_s
    mov eax, ebx
.p_max_s:
    call itoa

    mov eax, 4
    mov ebx, 1
    mov ecx, txt_max_u
    mov edx, 14
    int 0x80

    mov eax, [num_a]
    mov ebx, [num_b]
    cmp eax, ebx
    ja .p_max_u
    mov eax, ebx
.p_max_u:
    call itoa

    mov eax, 1
    xor ebx, ebx
    int 0x80

atoi:
    push ebx
    push esi
    mov esi, ecx
    xor eax, eax
    xor ebx, ebx
    movzx edx, byte [esi]
    cmp dl, '-'
    jne .a_loop
    inc esi
    push 1
    jmp .a_start
.a_loop:
    push 0
.a_start:
    movzx edx, byte [esi]
    cmp dl, 0xA
    je .a_done
    sub dl, '0'
    imul eax, 10
    add eax, edx
    inc esi
    jmp .a_start
.a_done:
    pop ebx
    test ebx, ebx
    jz .a_exit
    neg eax
.a_exit:
    pop esi
    pop ebx
    ret

itoa:
    push eax
    push ebx
    push ecx
    push edx
    mov edi, out_str
    add edi, 31
    mov byte [edi], 0
    mov ebx, 10
    test eax, eax
    jns .i_pos
    neg eax
    push 1
    jmp .i_conv
.i_pos:
    push 0
.i_conv:
    xor edx, edx
    div ebx
    add dl, '0'
    dec edi
    mov [edi], dl
    test eax, eax
    jnz .i_conv
    pop eax
    test eax, eax
    jz .i_print
    dec edi
    mov byte [edi], '-'
.i_print:
    mov ecx, edi
    mov edx, out_str
    add edx, 31
    sub edx, ecx
    mov eax, 4
    mov ebx, 1
    int 0x80
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret