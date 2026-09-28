.global _start

.section .data
msg:
    .ascii "OmaTools v0.1.0 - Assembly x86_64 Core inicializado com sucesso!\n"
len = . - msg

.section .text
_start:
    # sys_write(stdout, msg, len)
    mov $1, %rax        # syscall 1: sys_write
    mov $1, %rdi        # fd: 1 (stdout)
    lea msg(%rip), %rsi # buffer
    mov $len, %rdx      # length
    syscall

    # sys_exit(0)
    mov $60, %rax       # syscall 60: sys_exit
    xor %rdi, %rdi      # exit code 0
    syscall
