section .data
    space       db " ", 0
    newline     db 0xA

section .bss
    buffer      resb 16
    out_str     resb 16
    x_val       resd 1

section .text
    global _start

_start:
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 16
    int 0x80
    call atoi
    mov [x_val], eax

    mov ebp, eax        
    mov ecx, 32        
.bin_lp:
    rol ebp, 1       
    mov al, '0'
    test ebp, 1        
    jz .pr_bit
    inc al             
.pr_bit:
    mov [buffer], al
    push ecx
    mov eax, 4
    mov ebx, 1
    mov ecx, buffer
    mov edx, 1
    int 0x80
    pop ecx

    ; Пробіл кожні 4 біти
    test cl, 3
    jnz .next_bit
    cmp cl, 1
    je .next_bit
    push ecx
    mov eax, 4
    mov ecx, space
    int 0x80
    pop ecx
.next_bit:
    loop .bin_lp
    call pr_nl

  
    mov eax, [x_val]
    xor edx, edx
    mov ecx, 32
.pop_lp:
    test eax, 1
    jz .no_bit
    inc edx
.no_bit:
    shr eax, 1
    loop .pop_lp
    mov eax, edx
    call itoa

    mov eax, [x_val]
    or eax, 3           ; set bit 0, 1
    and eax, -5         ; clear bit 2 (маска 111...1011)
    call itoa

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
    call pr_nl
    popa
    ret

pr_nl:
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    ret
