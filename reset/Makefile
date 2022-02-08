export	PATH	:=	$(DEVKITARM)/bin:$(PATH)

TARGET	:=	reset
	
$(TARGET).bin: $(TARGET).elf
	arm-eabi-objcopy -O binary $< $@
	cat $(TARGET).bin ../../r32/bootlib/bootloader/boot.bin > woodreset.bin
	binreplace woodreset.bin /xee/xa5/x8d/xbf /xed/xa5/x8d/xbf

$(TARGET).elf: $(TARGET).s Makefile	
	arm-eabi-gcc -Ttext=0 -x assembler-with-cpp -nostartfiles -nostdlib $(TARGET).s -o $@

clean:
	rm -f $(TARGET).elf $(TARGET).bin
