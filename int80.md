sys_exit	1	ebx (код виходу)	Завершує програму. 0 — успіх.
sys_read	3	ebx (fd), ecx (buf), edx (count)	Читання з файлу або введення (fd=0 для stdin).
sys_write	4	ebx (fd), ecx (buf), edx (count)	Запис у файл або виведення (fd=1 для stdout).
sys_open	5	ebx (filename), ecx (flags), edx (mode)	Відкриття файлу. Повертає дескриптор у eax.
sys_close	6	ebx (fd)	Закриття файлу за його дескриптором.
