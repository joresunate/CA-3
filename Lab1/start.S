.syntax unified              // Use unified ARM/Thumb assembly syntax
.cpu cortex-m4               // Target CPU: Cortex-M4
.thumb                       // Generate Thumb instructions

/* Export symbols for linker */
.global vtable
.global reset_handler

/* Define the interrupt vector table */
.type vtable, %object
vtable:
    .word __stack_start
    .word __hard_reset__ + 1
.size vtable, . - vtable

/* Define the reset handler function */
__hard_reset__:
    ldr    r0, =__stack_start  // Load stack start address into r0
    mov    sp, r0              // Initialize stack pointer
    b      __hard_reset__      // Infinite loop to prevent fall-through
