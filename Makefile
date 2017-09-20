LD ?= ld
LDFLAGS ?=
AS ?= as
ASFLAGS ?= -gwarf-2 --64
OBJCOPY ?= objcopy
OBJDUMP ?= objdump

asmcalc: main.o
	$(LD) $(LDFLAGS) -o $@ main.o
	$(OBJCOPY) --dump-section .text=$@.bin main.o 

main.o: src/main.asm 
	$(AS) $(ASFLAGS) -a=$(basename $(notdir $<)).lst -o $@ $<

.PHONY: disassemble
disassemble: asmcalc
	$(OBJDUMP) -d asmcalc 
	$(OBJDUMP) -s -j .data asmcalc
	$(OBJDUMP) -s -j .rodata asmcalc

.PHONY: clean
clean: 
	rm -f *.lst *.o *.bin asmcalc asmcalc.bin

