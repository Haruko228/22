section .data
    msg_prompt  db "Enter x: ", 0
    len_prompt  equ $ - msg_prompt
    newline     db 0xA

section .bss
    buffer      resb 32    ; Буфер для вводу рядка
    out_str     resb 32    ; Буфер для конвертації числа в рядок

section .text
    global _start

_start:

    mov eax, 4          ; sys_write
    mov ebx, 1          ; stdout
    mov ecx, msg_prompt
    mov edx, len_prompt
    int 0x80


    mov eax, 3          ; sys_read
    mov ebx, 0          ; stdin
    mov ecx, buffer
    mov edx, 32
    int 0x80


    xor eax, eax        ; Тут буде результат (наше число x)
    mov esi, buffer
.atoi_loop:
    movzx edx, byte [esi]
    cmp dl, 0xA         ; Перевірка на Enter
    je .atoi_done
    cmp dl, '0'
    jb .atoi_done
    cmp dl, '9'
    ja .atoi_done

    sub dl, '0'
    imul eax, 10
    add eax, edx
    inc esi
    jmp .atoi_loop
.atoi_done:
    ; Число x тепер в EAX


    xor ebx, ebx        ; EBX = сума цифр (sumDigits)
    xor ecx, ecx        ; ECX = кількість цифр (len)
    mov edi, 10         ; Дільник

.math_loop:
    test eax, eax       ; Перевірка while x > 0
    jz .math_done

    xor edx, edx        ; КРИТИЧНО: обнуляємо EDX перед div
    div edi             ; EDX:EAX / 10 -> залишок в EDX (цифра), частка в EAX

    add ebx, edx        ; Додаємо цифру до суми
    inc ecx             ; Збільшуємо лічильник цифр
    jmp .math_loop

.math_done:
    push ecx            ; Зберігаємо кількість цифр у стеку
    push ebx            ; Зберігаємо суму цифр у стеку

    pop eax             ; Беремо суму цифр
    call print_number

    pop eax             ; Беремо кількість цифр
    call print_number

    mov eax, 1          ; sys_exit
    xor ebx, ebx
    int 0x80

print_number:
    mov esi, out_str
    add esi, 31
    mov byte [esi], 0
    mov ebx, 10
    mov edi, esi

.print_loop:
    xor edx, edx
    div ebx
    add dl, '0'
    dec esi
    mov [esi], dl
    test eax, eax
    jnz .print_loop

    push edi
    sub edi, esi
    mov edx, edi
    mov eax, 4
    mov ebx, 1
    mov ecx, esi
    int 0x80
    pop edi

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    ret