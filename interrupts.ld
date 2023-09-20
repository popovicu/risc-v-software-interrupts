MEMORY {
  kernel_space (rwx) : ORIGIN = 0x80200000, LENGTH = 512
}

SECTIONS {
  .text : {
    interrupts.o(.text.kernel)
    interrupts.o(.rodata)
  } > kernel_space

  .text.handle : ALIGN(4) {
    /* You have to ensure that the instructions are on 4-byte alignment.
    In other words, the last two bits of the address have to be 00. */
    interrupts.o(.text.handle)
    interrupts.o(.handle.rodata)
  } > kernel_space
}
