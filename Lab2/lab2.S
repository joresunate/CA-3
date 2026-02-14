.syntax unified
.cpu cortex-m4
.thumb

/* Input constant values */
#define A_VAL   8
#define B_VAL   2
#define C_VAL   5

/* --------------------------------------------------
 * lab2:
 * Initializes input constants A, B, and C.
 * If C is negative, the function returns an error code.
 * If A is even, the computation is delegated to even_case.
 * If A is odd, the computation is delegated to odd_case.
 * -------------------------------------------------- */
.global lab2
.type lab2, %function
lab2:
    mov     r0, #A_VAL        /* Load constant A into r0 */
    mov     r1, #B_VAL        /* Load constant B into r1 */
    mov     r2, #C_VAL        /* Load constant C into r2 */

    cmp     r2, #0            /* Check if C is negative */
    blt     invalid_c         /* If C < 0, branch to invalid_c handler */

    tst     r0, #1            /* Check if A is even (LSB of A) */
    beq     even_case         /* If A is even, branch to even_case */
    b       odd_case          /* If A is odd, branch to odd_case */

/* --------------------------------------------------
 * even_case:
 * Computes the expression: (A - B)^2 / 2 + C!
 * Overflow is checked after each operation.
 * -------------------------------------------------- */
.type even_case, %function
even_case:
    push    {r4, lr}          /* Save callee-saved register and link register */

    subs    r3, r0, r1        /* Compute A - B, result stored in r3 */
    bvs     overflow          /* If overflow occurs, branch to overflow handler */

    mov     r12, r3
    smull   r3, r4, r12, r12  /* Compute (A - B)^2, result stored in r3:r4 */
    cmp     r4, r3, asr #31   /* Check for overflow (upper 32-bits comparison) */
    bne     overflow          /* If overflow detected, branch to overflow handler */

    mov     r4, #2
    sdiv    r3, r3, r4        /* Divide the result by 2 */

    mov     r4, r3            /* Save the result for later addition */

    mov     r0, r2
    bl      factorial         /* Compute C! and store result in r0 */

    adds    r0, r0, r4        /* Add C! to the previous result */
    bvs     overflow          /* Check for overflow in the addition */

    pop     {r4, pc}          /* Restore registers and return */

/* --------------------------------------------------
 * odd_case:
 * Computes the expression: 2 * (A + B)^C + (C! / 4)
 * Overflow is checked after each operation.
 * -------------------------------------------------- */
.type odd_case, %function
odd_case:
    push    {r4, lr}

    adds    r3, r0, r1        /* Compute A + B, result stored in r3 */
    bvs     overflow          /* If overflow occurs, branch to overflow handler */

    mov     r0, r3            /* Set base as A + B */
    mov     r1, r2            /* Set exponent as C */
    bl      power             /* Compute (A + B)^C, result stored in r0 */

    adds    r0, r0, r0        /* Multiply the result by 2 (2 * (A + B)^C) */
    bvs     overflow          /* Check for overflow */

    mov     r4, r0            /* Save the result for later addition */

    mov     r0, r2
    bl      factorial         /* Compute C! and store result in r0 */

    asr     r0, r0, #2        /* Divide C! by 4 */

    adds    r0, r0, r4        /* Add the results: (A + B)^C * 2 + (C! / 4) */
    bvs     overflow          /* Check for overflow */

    pop     {r4, pc}

/* --------------------------------------------------
 * factorial:
 * Computes the factorial of the input value n.
 * Uses 64-bit multiplication to detect overflow.
 * -------------------------------------------------- */
.type factorial, %function
factorial:
    push    {r4, r5, r6, lr}

    cmp     r0, #0            /* Check if n == 0 */
    bne     factorial_start   /* If n != 0, proceed to factorial computation */

    mov     r0, #1            /* 0! = 1 */
    pop     {r4, r5, r6, pc}  /* Return to caller with result 1 */

factorial_start:
    mov     r4, r0            /* Set the loop limit to n */
    mov     r5, #1            /* Initialize result accumulator */
    mov     r0, #1            /* Initialize loop counter */

factorial_loop:
    mov     r12, r5
    smull   r5, r6, r12, r0   /* Multiply the accumulator by the current counter */
    cmp     r6, r5, asr #31   /* Check for overflow */
    bne     overflow          /* If overflow occurs, branch to overflow handler */

    add     r0, r0, #1        /* Increment loop counter */
    cmp     r0, r4
    ble     factorial_loop    /* Continue looping until counter exceeds n */

    mov     r0, r5            /* Return the result */
    pop     {r4, r5, r6, pc}

/* --------------------------------------------------
 * power:
 * Computes the power of the base raised to the exponent.
 * Uses 64-bit multiplication to detect overflow.
 * -------------------------------------------------- */
.type power, %function
power:
    push    {r4, r5, r6, r7, lr}

    mov     r4, r0            /* Set the base */
    mov     r5, r1            /* Set the exponent */
    mov     r6, #1            /* Initialize result to 1 */

    cmp     r5, #0            /* If exponent is 0, return 1 */
    beq     power_end         /* Return early if exponent is 0 */

power_loop:
    mov     r12, r6
    smull   r6, r7, r12, r4   /* Multiply the result by the base */
    cmp     r7, r6, asr #31   /* Check for overflow */
    bne     overflow          /* If overflow occurs, branch to overflow handler */

    sub     r5, r5, #1        /* Decrement exponent */
    cmp     r5, #0
    bgt     power_loop        /* Continue looping until exponent reaches 0 */

power_end:
    mov     r0, r6            /* Return the result */
    pop     {r4, r5, r6, r7, lr}
    bx      lr

/* --------------------------------------------------
 * overflow:
 * This handler is triggered when an overflow is detected.
 * It loads the maximum signed 32-bit integer value and enters an infinite loop.
 * -------------------------------------------------- */
overflow:
    ldr     r0, =0x7FFFFFFF   /* Load the maximum signed 32-bit value (INT32_MAX) */
    b       overflow          /* Enter an infinite loop to indicate overflow */

/* --------------------------------------------------
 * invalid_c:
 * This handler is triggered when C is negative.
 * It loads the minimum signed 32-bit integer value and exits the function.
 * -------------------------------------------------- */
invalid_c:
    ldr     r0, =0x80000000   /* Load the minimum signed 32-bit value (INT32_MIN) */
    bx      lr                /* Return from the function */

.size lab2, . - lab2
