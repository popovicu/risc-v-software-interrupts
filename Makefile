CROSS_COMPILE=riscv64-linux-gnu-

interrupts: interrupts.o interrupts.ld
	${CROSS_COMPILE}ld -T interrupts.ld --no-dynamic-linker -m elf64lriscv -static -notstdlib -s -o interrupts interrupts.o

interrupts.o: interrupts.s
	${CROSS_COMPILE}as -march=rv64i -mabi=lp64 -o interrupts.o -c interrupts.s
