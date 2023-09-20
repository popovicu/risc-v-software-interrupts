        .global _start
        .section .text.kernel

	# Print Hello World to begin with, through OpenSBI.
	#
	# If unfamiliar with RISC-V SBI, read the following:
	# https://popovicu.com/posts/risc-v-sbi-and-full-boot-process/
_start: li a7, 0x4442434E
        li a6, 0x00
1:      auipc a3, %pcrel_hi(debug_string)
        addi a3, a3, %pcrel_lo(1b)
        li a4, 0x00000000FFFFFFFF
        li a5, 0xFFFFFFFF00000000
        li a0, 12
        and a1, a3, a4
        and a2, a3, a5
        ecall

	# Load the pointer to the interrupt routine into the STVEC CSR.
	# Since this value ends with zeroes, by RISC-V design, it means
	# it will be the centralized routine, i.e. the access to all the
	# interrupts goes through this one routine (and it should internally
	# route to the correct logic, in a real world case). The other approach
	# is vectorized, but that is not what is done here.
1:	auipc t0, %pcrel_hi(handle)
        addi t0, t0, %pcrel_lo(1b)
	csrw stvec, t0

	# This flips the S-mode global interrupt flags. Without this, the
	# interrupts in the S-mode are globally disabled, i.e. the other
	# flags don't matter.
	csrr t1, sstatus
	ori t1, t1, 2 # Set the S-level interrupt enable flag (SIE)
	csrw sstatus, t1

	# This flips the correct flag in the S-mode interrupt level register.
	# It's there specifically for the software interrupts.
	csrr t1, sie
	ori t1, t1, 2 # Set the software interrupt enable flag (SSIE)
	csrw sie, t1

	# Writing to the SIP register in this portion of the code will actually
	# trigger the interrupt.
	csrr t1, sip
	ori t1, t1, 2 # Set the software interrupt pending flag (SSIP)
	csrw sip, t1

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
1:      auipc a3, %pcrel_hi(handler_string)
        addi a3, a3, %pcrel_lo(1b)
        li a4, 0x00000000FFFFFFFF
        li a5, 0xFFFFFFFF00000000
        li a0, 12
        and a1, a3, a4
        and a2, a3, a5
        ecall

	# The bit is cleared on the pending register. This signifies that the
	# interrupt has been taken care of.
	csrr t1, sip
	li t2, 0xFFFFFFFFFFFFFFFD
	and t1, t1, t2 # Clear the software interrupt pending flag (SSIP)
	csrw sip, t1

	# sret is not the correct instruction here to get out of the interrupt.
	# sret would imply going down to the U-mode, but we didn't have that to
	# begin with, as the entrance into the interrupt handler wasn't through
	# the ecall instruction.
	#
	# Instead, we look at the CSR flag which has the instruction of where
	# we stopped before handling the interrupt.
	csrr t1, sepc
	jr t1

	.section .handle.rodata
handler_string:
	.string "Handler called\n"
