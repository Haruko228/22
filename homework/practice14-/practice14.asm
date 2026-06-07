section .data
    space       db " ", 0
    newline     db 0xA

section .bss
    array       resd 100
    buffer      resb 16
    out_str     resb 16
    n_val       resd 1

section .text
    global _start

_start:
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 16
    int 0x80
    call atoi
    mov [n_val], eax

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

    xor esi, esi
.pr_before:
    cmp esi, [n_val]
    je .pr_before_dn
    mov eax, [array + esi*4]
    call itoa
    inc esi
    jmp .pr_before
.pr_before_dn:
    call pr_nl

    xor esi, esi
.sort_i:
    mov eax, [n_val]
    dec eax
    cmp esi, eax
    jge .sort_dn

    mov edi, esi
    mov ebx, esi
    inc ebx
.sort_j:
    cmp ebx, [n_val]
    jge .sort_j_dn

    mov ecx, [array + ebx*4]
    mov edx, [array + edi*4]
    cmp ecx, edx
    jge .not_min
    mov edi, ebx
.not_min:
    inc ebx
    jmp .sort_j
.sort_j_dn:

    cmp edi, esi
    je .no_swap
    mov eax, [array + esi*4]
    mov ecx, [array + edi*4]
    mov [array + esi*4], ecx
    mov [array + edi*4], eax
.no_swap:
    inc esi
    jmp .sort_i
.sort_dn:

    xor esi, esi
.pr_after:
    cmp esi, [n_val]
    je .pr_after_dn
    mov eax, [array + esi*4]
    call itoa
    inc esi
    jmp .pr_after
.pr_after_dn:
    call pr_nl

    mov eax, [n_val]
    test eax, 1
    jnz .med_odd

    shr eax, 1
    dec eax
    jmp .med_pr
.med_odd:
    shr eax, 1
.med_pr:
    mov eax, [array + eax*4]
    call itoa
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

    mov eax, 4
    mov ecx, space
    mov edx, 1
    int 0x80
    popa
    ret

pr_nl:
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    ret