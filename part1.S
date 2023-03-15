/*
 * File: fpu_example.S
 * Description: Example of how to enable the FPU.
 */

        .text
# Text segment



        .globl _start;
_start: # entry point

        # .align 4
        # enable FPU
        li      t0, (3 << 13);
        csrs    mstatus, t0;

        la      t0, WORD_F0;
        flw     f0, 0(t0);
        la      t0, WORD_F1;
        flw     f1, 0(t0);
      
        flw     f3, 0(t3);
        flw     f4, 0(t4);
        
        mul     t4, t2, t1;
        add     t3, t2, t1;    
           
        
        flw     f5, 0(t5);
        flw     f6, 0(t6);
        
        fadd.s  f3, f0, f1;
        fsqrt.s  f4, f0;
        fadd.s  f5, f0, f1;
        fmul.s  f6, f0, f1;

OoO:
        div     t1, t0, t1;
        # fdiv.s  f5, f0, f1;
        # Out of order 
        fmul.s  f3, f0, f1;
        sw      t5, 0(t0); # Wait on t1 to stall, RAW?
        # bne     t4, t3, continue; # if t4 != t3 then target
        fadd.s  f5, f3, f1;

RAW:
        div     t1, t0, t1;
        # fdiv.s  f5, f0, f1;
        # Out of order 
        fmul.s  f3, f0, f1;
        sw      t1, 0(t0); # Waiting on t1. stall RAW
        # bne     t4, t3, continue; # if t4 != t3 then target
        fadd.s  f5, f3, f1;

WAW:
        la      t0, msg1;
        div     t4, t0, t1;
        # fdiv.s  f5, f0, f1;
        # Out of order 
        fmul.s  f3, f0, f1;
        lw      t4, 0(t0); # t4, WAW waiting on div, will not run out of order
        # bne     t4, t3, continue; # if t4 != t3 then target
        fadd.s  f5, f3, f1;

WAR:
        la      t0, msg1;
        div     t4, t0, t1;
        # fdiv.s  f5, f0, f1;
        # Out of order 
        fmul.s  f3, f0, f1;
        lw      t1, 0(t0); # t4, WAR waiting on div, will not run out of order
        # bne     t4, t3, continue; # if t4 != t3 then target
        fadd.s  f5, f3, f1;

BRANCH_MISS:

FILL_ISSUE:

continue:    
        li      a0, 0;  # set exit value to 0
        li      a7, 93; # set syscall to `exit`
        ecall;


.section .data
# Data segment
        # .align 10
WORD_F0: .word 0x6c47c14a # 154.0
WORD_F1: .word 0x41700000 #  15.0
WORD_F2: .word 0x41700000 #  15.0


.section .rodata
msg1:     .string "Hello World\n"
msg2:     .string "Hello Worl\n"
msg3:     .string "Hello Wor\n"
# msg:     .string "Hello World\n"
# msg:     .string "Hello World\n"
# msg:     .string "Hello World\n"
# msg:     .string "Hello World\n"
# msg:     .string "Hello World\n"
# msg:     .string "Hello World\n"


        .section ".tohost","aw",@progbits
        .globl tohost
        .globl fromhost

        .align 6
tohost: .dword 0
        .align 6
fromhost: .dword 0


.section .data
        .align 8
WORD_F3:  .word 0x41700000 #  15.0
        .align 10
WORD_F4: .word 0x41700000 #  15.0
        .align 12
WORD_F5: .word 0x41700000 #  15.0
        .align 14
WORD_F6: .word 0x41700000 #  15.0