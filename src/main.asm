.bss

.text
.global _start

_start:
	movl $60, %eax    # 60 = exit syscall
	xorl %edi, %edi   # returncode 0
	syscall         
