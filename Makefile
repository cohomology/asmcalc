LD ?= ld
LDFLAGS ?=
AS ?= as
ASFLAGS ?= -gwarf-2 --64

asmcalc: main.o
	$(LD) $(LDFLAGS) -o $@ main.o

main.o: src/main.asm 
	$(AS) $(ASFLAGS) -a=$(basename $(notdir $<)).lst -o $@ $<

.PHONY: clean
clean: 
	rm -f *.lst *.o asmcalc

