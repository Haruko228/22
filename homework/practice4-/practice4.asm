section .data
    msg_input  db "Enter a number: ", 0
    len_input  equ $ - msg_input
    newline    db 0xA

section .bss
    buffer      resb 16
    out_str     resb 16

section .text
    global _start

_start:
    ; I/O: Запит
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_input
    mov edx, len_input
    int 0x80

    ; I/O: Читання
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 16
    int 0x80

    ; parse: рядок -> AX
    xor eax, eax
    xor ebx, ebx
    mov esi, buffer
.parse_loop:
    movzx edx, byte [esi + ebx]
    cmp dl, 0xA
    je .parse_done
    cmp dl, 0x0
    je .parse_done
    sub dl, '0'
    imul eax, 10
    add eax, edx
    inc ebx
    jmp .parse_loop
.parse_done:

    ; math/logic: AX -> рядок
    mov edi, out_str
    add edi, 15
    mov byte [edi], 0
    movzx eax, ax
    mov ebx, 10
    xor ecx, ecx
.convert_loop:
    xor edx, edx
    div ebx
    add dl, '0'
    dec edi
    mov [edi], dl
    inc ecx
    test eax, eax
    jnz .convert_loop

    ; I/O: Вивід
    mov eax, 4
    mov ebx, 1
    mov edx, ecx
    mov ecx, edi
    int 0x80

    ; Newline
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; Exit
    mov eax, 1
    xor ebx, ebx
    int 0x80