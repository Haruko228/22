section .data
    newline     db 0xA
    minus_one   db "-1", 0xA

section .bss
    text_buf    resb 256
    pat_buf     resb 64
    out_str     resb 16
    text_len    resd 1
    pat_len     resd 1
    buffer_char resb 1

section .text
    global _start

_start:
    mov eax, 3
    mov ebx, 0
    mov ecx, text_buf
    mov edx, 250
    int 0x80
    call strip_nl
    mov [text_len], eax

    mov eax, 3
    mov ecx, pat_buf
    mov edx, 60
    int 0x80
    call strip_nl
    mov [pat_len], eax

    cmp eax, 0
    je .not_found

    mov ebx, [text_len]
    cmp eax, ebx
    jg .not_found

    mov dword [out_str], -1
    xor ebp, ebp
    xor esi, esi

.search_lp:
    mov eax, [text_len]
    sub eax, [pat_len]
    cmp esi, eax
    jg .search_dn

    xor edi, edi
.match_lp:
    mov ecx, [pat_len]
    cmp edi, ecx
    je .matched

    mov al, [text_buf + esi + edi]
    mov bl, [pat_buf + edi]
    cmp al, bl
    jne .no_match

    inc edi
    jmp .match_lp

.matched:
    inc ebp
    cmp dword [out_str], -1
    jne .skip_first
    mov [out_str], esi
.skip_first:
    add esi, [pat_len]
    jmp .search_lp

.no_match:
    inc esi
    jmp .search_lp

.search_dn:
    mov eax, [out_str]
    cmp eax, -1
    je .not_found

    call itoa
    mov eax, ebp
    call itoa
    jmp .exit

.not_found:
    mov eax, 4
    mov ebx, 1
    mov ecx, minus_one
    mov edx, 3
    int 0x80

    mov eax, '0'
    mov [buffer_char], al
    mov eax, 4
    mov ecx, buffer_char
    mov edx, 1
    int 0x80
    call pr_nl

.exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80

strip_nl:
    xor edx, edx
.s_lp:
    mov al, [ecx + edx]
    cmp al, 0xA
    je .s_done
    cmp al, 0
    je .s_done
    inc edx
    jmp .s_lp
.s_done:
    mov byte [ecx + edx], 0
    mov eax, edx
    ret

itoa:
    pusha
    mov edi, out_str + 12
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
    mov edx, out_str + 12
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