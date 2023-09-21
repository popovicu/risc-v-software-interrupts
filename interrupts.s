        .global _start
        .section .text.kernel

	# Print Hello World to begin with, through OpenSBI.
	#
	# If unfamiliar with RISC-V SBI, read the following:
	# https://popovicu.com/posts/risc-v-sbi-and-full-boot-process/
_start: li a7, 0x4442434E
        li a6, 0x00
        li a0, 12
        lla a1, debug_string
        li a2, 0
        ecall

	# Load the pointer to the interrupt routine into the STVEC CSR.
	# Since this value ends with zeroes, by RISC-V design, it means
	# it will be the centralized routine, i.e. the access to all the
	# interrupts goes through this one routine (and it should internally
	# route to the correct logic, in a real world case). The other approach
	# is vectorized, but that is not what is done here.
	lla t0, handle
	csrw stvec, t0

	li t1, 2
	csrs sstatus, t1 # Set the S-level interrupt enable flag (SIE)
	csrs sie, t1     # Set the software interrupt enable flag (SSIE)
	csrs sip, t1     # Set the software interrupt pending flag (SSIP)

	# After the software interrupt, we return here and keep going into the
	# infinite loop.
loop:   j loop

        .section .rodata
debug_string:
        .string "Hello world\n"

	.section .text.handle
	# At the beginning of the interrupt handling processing routine, we
	# print a debug message. Same logic as the above (copy/paste).
handle:	li a7, 0x4442434E
        li a6, 0x00
        li a0, 12
        lla a1, handler_string
        li a2, 0
        ecall

	# The bit is cleared on the pending register. This signifies that the
	# interrupt has been taken care of.
	li t2, 2
	csrc sip, t2

	# Return from the interrupt, unwind
	sret

	.section .handle.rodata
handler_string:
	.string "Handler called\n"
