objs-b := \
	b.o

$(objdir-b)/b.o: $(srcdir-b)/b.asm
	$(Q) nasm -f elf -o $@ $<

$(objdir-b)/b.d: $(srcdir-b)/b.asm
	$(Q) touch $(objdir-b)/b.d
