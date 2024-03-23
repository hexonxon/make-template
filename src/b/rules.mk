objs-b := \
	b.o

$(objdir-b)/b.o: $(srcdir-b)/b.asm
	nasm -f elf -o $@ $<
