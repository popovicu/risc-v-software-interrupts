# risc-v-software-interrupts

Software interrupts example for RISC-V. To build, simply run `make interrupts`, though on your machine, you may also have to override the `CROSS_COMPILE` flag for `Makefile`.

To run this example, execute with QEMU (for 64-bit RISC-V):

```
qemu-system-riscv64 -machine virt -kernel interrupts -bios PATH_TO_YOUR_OPENSBI_DIRECTORY/build/platform/generic/firmware/fw_dynamic.bin
```

The reason why OpenSBI is called out explicitly above is because your QEMU may ship with an older version of OpenSBI which does not support the debug console features. If this does not make sense to you, please read https://popovicu.com/posts/risc-v-sbi-and-full-boot-process/ This article should explain what OpenSBI is, what SBI layer on RISC-V does, what the `-bios` flag for QEMU does, etc. OpenSBI is used in this example to send some message through UART. It should take 3-4 terminal commands to build your OpenSBI image.

As for the exact functionality of this example, it sits on top of OpenSBI, executes in S-mode of a RISC-V machine and runs a software interrupt. This is **not** the same as `ecall`, and the details of `ecall` are in the article linked above. The code here is for the interrupts within the S-mode, and software interrupts are just one example. Other interrupts in the same mode can be achieved similarly.

The code is heavily commented, but please let me know if something is unclear. I hope this helps, as I felt there was not a consolidated example to learn all these things quickly. Instead, this one is a quick and dirty example.

**Note: This example follows no particular register convention. The registers are used more or less randomly and the goal was just to illustrate a concept. Please be careful about this if you need to do something regarding interrupts in production code.**