section .data
    newline     db 0xA

section .bss
    buffer      resb 16
    line_buf    resb 128   
    h_val       resd 1

section .text
    global _start

_start:

    mov eax, 3          ; sys_read
    mov ebx, 0          ; stdin
    mov ecx, buffer
    mov edx, 16
    int 0x80
    call atoi
    mov [h_val], eax

  
    xor esi, esi       
.main_loop:
    cmp esi, [h_val]
    je .exit

    mov edi, line_buf  

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
    mov ecx, esi
    shl ecx, 1          ; ecx = 2 * i
    inc ecx             ; ecx = 2 * i + 1
.stars_lp:
    mov byte [edi], '*'
    inc edi
    loop .stars_lp

    mov byte [edi], 0xA
    inc edi

    mov eax, edi
    sub eax, line_buf 
    mov ecx, line_buf   
    call print_line

    inc esi
    jmp .main_loop

.exit:
    mov eax, 1          ; sys_exit
    xor ebx, ebx
    int 0x80

print_line:
    pusha
    mov edx, eax        ; edx = len
    mov eax, 4          ; sys_write
    mov ebx, 1          ; stdout
    int 0x80
    popa
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
