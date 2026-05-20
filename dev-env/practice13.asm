section .data
    space       db " ", 0
    newline     db 0xA
    msg_yes     db "PALINDROME: YES", 0xA
    msg_no      db "PALINDROME: NO", 0xA

section .bss
    array_orig  resd 200
    array_rev   resd 200
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
    mov [array_orig + esi*4], eax
    inc esi
    jmp .in_lp
.in_dn:

    mov ecx, [n_val]
    mov esi, array_orig
    mov edi, array_rev
    cld
    rep movsd

    mov ecx, [n_val]
    xor esi, esi
    mov edi, ecx
    dec edi
.rev_lp:
    cmp esi, edi
    jge .rev_dn
    mov eax, [array_rev + esi*4]
    mov ebx, [array_rev + edi*4]
    mov [array_rev + esi*4], ebx
    mov [array_rev + edi*4], eax
    inc esi
    dec edi
    jmp .rev_lp
.rev_dn:

    xor esi, esi
.pr_orig:
    cmp esi, [n_val]
    je .pr_orig_dn
    mov eax, [array_orig + esi*4]
    call itoa
    inc esi
    jmp .pr_orig
.pr_orig_dn:
    call pr_nl

    xor esi, esi
.pr_rev:
    cmp esi, [n_val]
    je .pr_rev_dn
    mov eax, [array_rev + esi*4]
    call itoa
    inc esi
    jmp .pr_rev
.pr_rev_dn:
    call pr_nl

    xor esi, esi
    mov edi, [n_val]
    dec edi
    mov ebp, 1
.pal_lp:
    cmp esi, edi
    jge .pal_dn
    mov eax, [array_orig + esi*4]
    mov ebx, [array_orig + edi*4]
    cmp eax, ebx
    je .pal_next
    xor ebp, ebp
    jmp .pal_dn
.pal_next:
    inc esi
    dec edi
    jmp .pal_lp
.pal_dn:

    cmp ebp, 1
    je .is_pal
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_no
    mov edx, 15
    int 0x80
    jmp .exit
.is_pal:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_yes
    mov edx, 16
    int 0x80

.exit:
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