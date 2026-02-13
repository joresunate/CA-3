SHELL := /bin/bash

# -------------------------------
# Toolchain settings
# -------------------------------
SDK_PREFIX ?= arm-none-eabi-
CC         = $(SDK_PREFIX)gcc
LD         = $(SDK_PREFIX)ld
SIZE       = $(SDK_PREFIX)size
OBJCOPY    = $(SDK_PREFIX)objcopy

# -------------------------------
# QEMU settings
# -------------------------------
QEMU     = qemu-system-gnuarmeclipse
BOARD    ?= STM32F4-Discovery
MCU      = STM32F407VG
TCP_ADDR = 1234

# -------------------------------
# Build configuration
# -------------------------------
TARGET = firmware
CPU_CC = cortex-m4

# -------------------------------
# Sources
# -------------------------------
deps = start.S lscript.ld

# -------------------------------
# Default target
# -------------------------------
all: $(TARGET).bin

# -------------------------------
# Build steps
# -------------------------------
start.o: start.S
	$(CC) -x assembler-with-cpp -c -O0 -g3 -mcpu=$(CPU_CC) -Wall start.S -o start.o

$(TARGET).elf: start.o lscript.ld
	$(CC) start.o -mcpu=$(CPU_CC) -Wall --specs=nosys.specs -nostdlib -lgcc -T./lscript.ld -o $(TARGET).elf

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary -F elf32-littlearm $(TARGET).elf $(TARGET).bin

# -------------------------------
# QEMU run target
# -------------------------------
qemu: $(TARGET).bin
	$(QEMU) --verbose --board $(BOARD) --mcu $(MCU) \
		-d unimp,guest_errors \
		--image $(TARGET).bin \
		--semihosting-config enable=on,target=native \
		-gdb tcp::$(TCP_ADDR) -nographic -S


# -------------------------------
# Clean build artifacts
# -------------------------------
clean:
	-rm -f *.o *.elf *.bin
