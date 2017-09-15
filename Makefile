LD ?= ld
LDFLAGS ?=
AS ?= as
ASFLAGS ?= -gwarf-2 --64
OBJCOPY ?= objcopy

asmcalc: main.o
	$(LD) $(LDFLAGS) -o $@ main.o
	$(OBJCOPY) -O binary main.o asmcalc.bin

main.o: src/main.asm 
	$(AS) $(ASFLAGS) -a=$(basename $(notdir $<)).lst -o $@ $<

.PHONY: clean
clean: 
	rm -f *.lst *.o *.bin asmcalc asmcalc.bin

