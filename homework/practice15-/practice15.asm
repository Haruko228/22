section .data
    space       db " ", 0
    newline     db 0xA

section .bss
    buffer      resb 16
    out_str     resb 16
    calls_cnt   resd 1

section .text
    global _start

_start:
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 16
    int 0x80
    call atoi

    mov dword [calls_cnt], 0
    call fact

    push dword [calls_cnt]
    call itoa
    call pr_nl
    pop eax
    call itoa
    call pr_nl

    mov eax, 1
    xor ebx, ebx
    int 0x80

fact:
    push ebp
    mov ebp, esp

    inc dword [calls_cnt]

    cmp eax, 1
    jbe .fact_base

    push eax
    dec eax
    call fact
    pop ebx
    mul ebx
    jmp .fact_done

.fact_base:
    mov eax, 1

.fact_done:
    mov esp, ebp
    pop ebp
    ret

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
    popa
    ret

pr_nl:
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    ret