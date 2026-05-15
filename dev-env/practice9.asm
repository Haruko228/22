section .data
    msg_n       db "Enter n (100-1000): ", 0
    dot_sep     db ": ", 0
    hash        db "#", 0
    newline     db 0xA
    seed        dd 12345

section .bss
    buffer      resb 16
    freq        resd 10
    n_val       resd 1
    out_str     resb 16

section .text
    global _start

_start:
    ; --- I/O: Input n ---
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_n
    mov edx, 20
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 16
    int 0x80
    call atoi
    mov [n_val], eax

    ; --- math: Generate and count ---
    xor esi, esi
.gen_lp:
    cmp esi, [n_val]
    je .gen_dn

    ; LCG: x = (1103515245 * x + 12345) & 0x7FFFFFFF
    mov eax, [seed]
    mov ebx, 1103515245
    mul ebx
    add eax, 12345
    and eax, 0x7FFFFFFF
    mov [seed], eax

    ; mod 10 to get digit 0-9
    xor edx, edx
    mov ebx, 10
    div ebx
    inc dword [freq + edx*4]

    inc esi
    jmp .gen_lp
.gen_dn:

    ; --- logic: Print Histogram ---
    xor esi, esi
.hist_lp:
    cmp esi, 10
    je .exit

    ; Print index
    mov eax, esi
    call itoa_no_nl

    mov eax, 4
    mov ebx, 1
    mov ecx, dot_sep
    mov edx, 2
    int 0x80

    ; Print hashes (count / 5 for scaling)
    mov ecx, [freq + esi*4]
    push ecx
    shr ecx, 2 ; simple scale: divide by 4
.hash_lp:
    cmp ecx, 0
    je .hash_dn
    push ecx
    mov eax, 4
    mov ebx, 1
    mov ecx, hash
    mov edx, 1
    int 0x80
    pop ecx
    loop .hash_lp
.hash_dn:

    ; Print count in brackets
    mov eax, 4
    mov ebx, 1
    mov ecx, dot_sep
    mov edx, 1
    int 0x80
    pop eax
    call itoa_no_nl

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    inc esi
    jmp .hist_lp

.exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80

; --- Helper: atoi ---
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

; --- Helper: itoa (no newline) ---
itoa_no_nl:
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