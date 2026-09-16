;
; TheForceEngine - Amiga port
;
; 68020+
;

    section .text,code

    XDEF _dotFixed_asm
    XDEF dotFixed_asm
    XDEF _dot_asm
    XDEF dot_asm

_dotFixed_asm:
dotFixed_asm:
_dot_asm:
dot_asm:
    move.l d2,-(sp)

    move.l (a0)+,d0
    muls.l (a1)+,d2:d0
    move.w d2,d0
    swap d0

    move.l (a0)+,d1
    muls.l (a1)+,d2:d1
    move.w d2,d1
    swap d1
    add.l d1,d0

    move.l (a0),d1
    muls.l (a1),d2:d1
    move.w d2,d1
    swap d1
    add.l d1,d0

    move.l (sp)+,d2
    rts