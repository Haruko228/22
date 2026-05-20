section .data
    newline     db 0xA

section .bss
    buffer      resb 16
    line_buf    resb 128    ; Буфер для формування рядка
    h_val       resd 1

section .text
    global _start

_start:
    ; --- I/O: Читання висоти h ---
    mov eax, 3          ; sys_read
    mov ebx, 0          ; stdin
    mov ecx, buffer
    mov edx, 16
    int 0x80
    call atoi
    mov [h_val], eax

    ; --- loops: Вкладені цикли для ялинки ---
    xor esi, esi        ; esi = i (поточний рядок від 0 до h-1)
.main_loop:
    cmp esi, [h_val]
    je .exit

    mov edi, line_buf   ; edi вказує на початок буфера рядка

    ; 1. Цикл пробілів: кількість = h - i - 1
    mov ecx, [h_val]
    sub ecx, esi
    dec ecx
.spaces_lp:
    cmp ecx, 0
    jle .stars_prep
    mov byte [edi], ' '
    inc edi
    loop .spaces_lp

.stars_prep:
    ; 2. Цикл зірочок: кількість = 2 * i + 1
    mov ecx, esi
    shl ecx, 1          ; ecx = 2 * i
    inc ecx             ; ecx = 2 * i + 1
.stars_lp:
    mov byte [edi], '*'
    inc edi
    loop .stars_lp

    ; 3. Додаємо символ нового рядка в кінець буфера
    mov byte [edi], 0xA
    inc edi

    ; --- logic: Один вивід на рядок через підпрограму ---
    mov eax, edi
    sub eax, line_buf   ; eax = довжина сформованого рядка (len)
    mov ecx, line_buf   ; ecx = адреса буфера (buf)
    call print_line

    inc esi
    jmp .main_loop

.exit:
    ; --- memory: Вихід з програми ---
    mov eax, 1          ; sys_exit
    xor ebx, ebx
    int 0x80

; --- Підпрограма друку рядка print_line(buf, len) ---
print_line:
    pusha
    mov edx, eax        ; edx = len
    mov eax, 4          ; sys_write
    mov ebx, 1          ; stdout
    int 0x80
    popa
    ret

; --- Допоміжна підпрограма atoi ---
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