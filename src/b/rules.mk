objs-m := \
	b.o

$(objdir-m)/b.o: $(srcdir-m)/b.asm
	$(Q) nasm -f elf -o $@ $<

$(objdir-m)/b.d: $(srcdir-m)/b.asm
	$(Q) touch $@
