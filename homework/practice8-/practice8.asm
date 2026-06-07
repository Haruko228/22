section .data
    space       db " ", 0
    newline     db 0xA
    minus_one   db "-1", 0xA

section .bss
    array       resd 100
    buffer      resb 16
    out_str     resb 16
    n_val       resd 1
    target      resd 1

section .text
    global _start

_start:
    ; Читаємо N
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 16
    int 0x80
    call atoi
    mov [n_val], eax

    ; Ввід масиву
    xor esi, esi
.in_lp:
    cmp esi, [n_val]
    je .in_dn
    push esi
    mov eax, 3
    mov ecx, buffer
    int 0x80
    call atoi
    pop esi
    mov [array + esi*4], eax
    inc esi
    jmp .in_lp
.in_dn:

    ; Читаємо Target
    mov eax, 3
    mov ecx, buffer
    int 0x80
    call atoi
    mov [target], eax

    ; Пошук (ebx = first index, edx = count)
    mov ebx, -1
    xor edx, edx
    xor esi, esi
.sh_lp:
    cmp esi, [n_val]
    je .sh_dn
    mov eax, [array + esi*4]
    cmp eax, [target]
    jne .next
    inc edx
    cmp ebx, -1
    jne .next
    mov ebx, esi
.next:
    inc esi
    jmp .sh_lp
.sh_dn:

    ; Вивід першого індексу
    cmp ebx, -1
    je .not_fnd
    mov eax, ebx
    call itoa
    call pr_nl

    ; Вивід кількості
    mov eax, edx
    call itoa
    call pr_nl

    ; Вивід усіх індексів
    xor esi, esi
.pr_idx:
    cmp esi, [n_val]
    je .exit
    mov eax, [array + esi*4]
    cmp eax, [target]
    jne .skp
    mov eax, esi
    call itoa
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80
.skp:
    inc esi
    jmp .pr_idx
    jmp .exit

.not_fnd:
    mov eax, 4
    mov ebx, 1
    mov ecx, minus_one
    mov edx, 3
    int 0x80

.exit:
    call pr_nl
    mov eax, 1
    xor ebx, ebx
    int 0x80

atoi:
    xor eax, eax
    mov edi, ecx
.a_lp:
    movzx edx, byte [edi]
    cmp dl, '0'
    jb .a_dn
    cmp dl, '9'
    ja .a_dn
    sub dl, '0'
    imul eax, 10
    add eax, edx
    inc edi
    jmp .a_lp
.a_dn: ret

itoa:
    pusha
    mov edi, out_str
    add edi, 15
    mov byte [edi], 0
    mov ebx, 10
    test eax, eax
    jnz .i_lp
    dec edi
    mov byte [edi], '0'
    jmp .i_pr
.i_lp:
    xor edx, edx
    div ebx
    add dl, '0'
    dec edi
    mov [edi], dl
    test eax, eax
    jnz .i_lp
.i_pr:
    mov ecx, edi
    mov edx, out_str
    add edx, 15
    sub edx, ecx
    mov eax, 4
    mov ebx, 1
    int 0x80
    popa
    ret

pr_nl:
    pusha
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    popa
    ret