/* vim: ft=gas : 
*/ 
# Mini calculator and parser written in x86_64 assembly for Linux with SSE instructions
# (c) by Cohomology@github, 2017

.section .rodata
.align 16
exit_string: .ascii "exit\n"
.fill 11, 1, 0
help_string: .asciz "This is asmcalc. Type \"exit\" to quit.\n"

.data
.align 16
.fill 15, 1, 0
line_counter_string: .byte '[ 
.align 16
line_counter_content: .byte '0, '], ':, 0x20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

.bss

.lcomm input_line, 256

.text
.global _start

_start:
                movl $1, %eax                           # 1 = write syscall
                movl $1, %edi                           # 1 = stdout
                movq $help_string, %rsi                 # string to write
                movl $38, %edx                          # length of string 
                syscall                                 # write(stdout, $help_string, 38);

        	movq $line_counter_string, %rbx  	# $rbx = $line_counter_string
        	xorl %r10d, %r10d                	# $r10 = 0;
                movdqa exit_string, %xmm15              # strcpy($xmm15, $exit_string, 16); 

# In the main loop, a line counter is shown to the user and an input is expected. The line counter is not counted in a numeric way internally,
# but is directly increased as a character string. For this, the "inc" command is rewritten in assembly for decimal numbers. If the length of the
# number must be increased (e.g. 99 => 100), a move is made via some SSE instructions.
 
main_loop:
        	movl $1, %eax                    	# 1 = write syscall
        	movl $1, %edi                    	# 1 = stdout
         	movq $line_counter_string, %rsi  	# string to write
		movl $16, %edx                   	# length of string  
        	syscall                          	# write(stdout, $line_counter_string, 16);

        	movl $0, %eax                    	# 0 = read syscall
       	 	movl $0, %edi                    	# 0 = stdin
        	movq $input_line, %rsi           	# string into read
        	movl $256, %edx                     	# length of string
        	syscall                             	# read(stdin, $input_line, 256);

                call parse_and_compute                  # parse and compute	

	        movl %r10d, %ecx                        # $rcx = $r10d;
inc_loop:       incb 1(%rbx, %rcx)                      # ++*($rbx + $rcx + 1);
		cmpb $'9, 1(%rbx, %rcx)                 # if (*($rbx + $rcx + 1) <= '9')
		jbe main_loop                           #   goto main_loop;
		movb $'0, 1(%rbx, %rcx)                 # *($rbx + $rcx + 1) = '0'
		test %ecx, %ecx                         # if ($rcx == 0)
		je move                                 #   goto move;
                decl %ecx                               # --$rcx; 
		jmp inc_loop                            # goto inc_loop;

move:   	movdqa 1(%rbx), %xmm0              	# memcpy($xmm0, $rbx + 1, 16);
        	pslldq $1, %xmm0                   	# $xmm0 >>= 16;                           	# shift left in register yields shift right in memory
        	movdqa %xmm0, 1(%rbx)              	# memcpy($rbx + 1, $xmm0, 16); 
        	movb $'1, 1(%rbx)                  	# *($rbx + 1) = '1';
        	incl %r10d                         	# ++r10; 
                jmp main_loop                           # goto main_loop

parse_and_compute:
                pcmpistri $0b011000, input_line, %xmm15 # $ecx = first_different_char_of($input_line, $exit_string) 
                cmp $4, %ecx                            # if ($ecx > 4)
                ja exit                                 #   goto exit;
                ret                                     # return;

exit:           movl $60, %eax                          # exit syscall
                xor %edi, %edi                          # return code 0  
                syscall                                 # exit(0)
