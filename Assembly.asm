;========================================================================================================================
; Create a file based on user input
; Add content to the file based on user input
; If the file already exists, give an error message
;========================================================================================================================

section .bss
	msg_in resb 128
    filename resb 128

section .data
    msg0 db 'Please enter file content for test.txt: ', 0xa
    len0 equ $ - msg0

    msg1 db 'File already exists, please enter a different name.', 0xa
    len1 equ $ - msg1

    msg2 db 'Please enter a filename to create: ', 0xa
    len2 equ $ - msg2

	;filename db "test.txt", 0
	mode equ 0o644 ; rw-r--r-- ; 0o = Octal ; 644 in Octal

section .text
	global _start

file_not_found:
    mov rax, 1
	mov rdi, 1
	mov rsi, msg0
	mov rdx, len0
	syscall ; sys_write

	mov rax, 0
	mov rdi, 0
	mov rsi, msg_in
	mov rdx, 128
	syscall ; sys_read

    mov r13, rax ; store number of bytes read

	mov rax, 2
    mov rdi, filename
	mov rsi, 0x241 ; flags: O_WRONLY(1) | O_CREAT(64) | O_TRUNC(512)
	mov rdx, mode
	syscall ; sys_open

    mov r12, rax ; store file descriptor

    mov rax, 1
    mov rdi, r12
    mov rsi, msg_in
    mov rdx, r13
    syscall ; sys_write

    mov rax, 3
    mov rdi, r12
    syscall ; sys_close

	mov rax, 60
    xor rdi, rdi ; exit code 0
	syscall ; sys_exit

file_exists:
    mov rax, 1
	mov rdi, 1
	mov rsi, msg1
	mov rdx, len1
	syscall ; sys_write

    mov rax, 60
    xor rdi, rdi ; exit code 0
	syscall ; sys_exit

_start:
    ; Prompt user for filename
    mov rax, 1
	mov rdi, 1
	mov rsi, msg2
	mov rdx, len2
	syscall ; sys_write

    ; Read user input for filename
	mov rax, 0
	mov rdi, 0
	mov rsi, filename
	mov rdx, 128
	syscall ; sys_read

    mov r13, rax ; store number of bytes read

    ; Remove newline character from the end of the input
    dec r13 ; adjust for zero-based index to get last character (decrement by 1)
    mov byte [filename + r13], 0 ; overwrite last character with null terminator (removing newline)

    ; Check if file already exists
    mov rax, 2
    mov rdi, filename
    mov rsi, 0 ; O_RDONLY
    syscall ; sys_open
    test rax, rax
    js  file_not_found ; file does NOT exist → ask for input
    jmp file_exists    ; file exists → show "File already exists"

    ; Cleanup and exit
    mov rdi, rax   ; file descriptor returned by sys_open
    mov rax, 3
    syscall ; sys_close

    mov rax, 60
    xor rdi, rdi ; exit code 0
    syscall ; sys_exit