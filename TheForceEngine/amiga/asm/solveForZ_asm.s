;
; TheForceEngine - Amiga port
;
; 68020+
;

    section .text,code

    XDEF _solveForZ_asm
    XDEF solveForZ_asm

    XREF _g_rcfState_ptr

_solveForZ_asm:
solveForZ_asm:
    movem.l d3/d5-d6/a2,-(sp)

    move.l _g_rcfState_ptr,a2

    move.l 40(a0),d3

    move.l d1,d5
    swap d5
    move.w d5,d6
    clr.w d5
    ext.l d6

    tst.b 20(a0)
    bne .dx_dz

    move.l 152(a2),a2
    move.l (a2,d0.l*4),d0
    sub.l d3,d0
    bne .dz_ok
    moveq #1,d0

.dz_ok:
    divs.l d0,d6:d5

    sub.l 36(a0),d5

    tst.l a1
    beq .dz_skip
    move.l d5,(a1)

.dz_skip:
    muls.l d3,d6:d5
    swap d6
    swap d5
    move.w d5,d6

    add.l 24(a0),d6
    move.l d6,d0
    bra .done

.dx_dz:
    move.l 156(a2),a2
    move.l (a2,d0.l*4),d0
    sub.l d3,d0
    bne .xz_ok
    moveq #1,d0

.xz_ok:
    divs.l d0,d6:d5
    move.l d5,d0

.done:
    movem.l (sp)+,d3/d5-d6/a2
    rts
