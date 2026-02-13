/* STM32F1 linker script */

MEMORY
{
    FLASH (rx)  : ORIGIN = 0x08000000, LENGTH = 1M    /* Flash memory region: code storage */
    RAM   (rwx) : ORIGIN = 0x20000000, LENGTH = 128K  /* SRAM region: data, stack, heap */
}

__stack_start = ORIGIN(RAM) + LENGTH(RAM);  /* Define initial stack pointer */
