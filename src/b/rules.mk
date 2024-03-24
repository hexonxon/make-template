objs-b := \
	b.o

$(objdir-b)/b.o: $(srcdir-b)/b.asm
	nasm -f elf -o $@ $<

$(objdir-b)/b.d: $(srcdir-b)/b.asm
	touch $(objdir-b)/b.d
