;
; TheForceEngine - Amiga port
;
; 68020+
;

    section .text,code

    XDEF _robj3d_transformVertices_asm
    XDEF robj3d_transformVertices_asm
    XDEF _robj3d_projectVertices_asm
    XDEF robj3d_projectVertices_asm
    XDEF _robj3d_dotProduct_asm
    XDEF robj3d_dotProduct_asm

    XREF _g_rcfState_ptr

; void robj3d_transformVertices_asm
; d0=count a0=vtxIn a1=xform a2=offset a3=vtxOut
; xform is a 3x3 row-major matrix, 32-bit fixed16:16
; offsets: e00=0 e01=12 e02=24 e10=4 e11=16 e12=28 e20=8 e21=20 e22=32
_robj3d_transformVertices_asm:
robj3d_transformVertices_asm:
    movem.l d2-d7/a3-a5,-(sp)

    move.l (a2),d5
    move.l 4(a2),a4
    move.l 8(a2),a5

    subq.l #1,d0
    blt .done

.loop:
    movem.l (a0),d1-d3

    ; x' = offset.x + x*e00 + y*e01 + z*e02
    move.l d5,d4
    move.l (a1),d6
    muls.l d1,d7:d6
    swap d7
    swap d6
    move.w d6,d7
    add.l d7,d4
    move.l 12(a1),d6
    muls.l d2,d7:d6
    swap d7
    swap d6
    move.w d6,d7
    add.l d7,d4
    move.l 24(a1),d6
    muls.l d3,d7:d6
    swap d7
    swap d6
    move.w d6,d7
    add.l d7,d4
    move.l d4,(a3)

    ; y' = offset.y + x*e10 + y*e11 + z*e12
    move.l a4,d4
    move.l 4(a1),d6
    muls.l d1,d7:d6
    swap d7
    swap d6
    move.w d6,d7
    add.l d7,d4
    move.l 16(a1),d6
    muls.l d2,d7:d6
    swap d7
    swap d6
    move.w d6,d7
    add.l d7,d4
    move.l 28(a1),d6
    muls.l d3,d7:d6
    swap d7
    swap d6
    move.w d6,d7
    add.l d7,d4
    move.l d4,4(a3)

    ; z' = offset.z + x*e20 + y*e21 + z*e22
    move.l a5,d4
    move.l 8(a1),d6
    muls.l d1,d7:d6
    swap d7
    swap d6
    move.w d6,d7
    add.l d7,d4
    move.l 20(a1),d6
    muls.l d2,d7:d6
    swap d7
    swap d6
    move.w d6,d7
    add.l d7,d4
    move.l 32(a1),d6
    muls.l d3,d7:d6
    swap d7
    swap d6
    move.w d6,d7
    add.l d7,d4
    move.l d4,8(a3)

    lea 12(a0),a0
    lea 12(a3),a3
    subq.l #1,d0
    bpl .loop

.done:
    movem.l (sp)+,d2-d7/a3-a5
    rts

; void robj3d_projectVertices_asm
; d0=count a0=pos a1=out
_robj3d_projectVertices_asm:
robj3d_projectVertices_asm:
    movem.l d2-d7/a2-a4,-(sp)

    move.l _g_rcfState_ptr,a2
    move.l 24(a2),d6
    move.l 28(a2),d7
    move.l 8(a2),a3
    move.l 12(a2),a4

    moveq #0,d1
    move.w #$8000,d1
    add.l d1,a3
    add.l d1,a4

    subq.l #1,d0
    blt .proj_done

.proj_loop:
    movem.l (a0),d1-d3

    ; rcpZ = 2^32 / z
    moveq #1,d4
    moveq #0,d5
    divs.l d3,d4:d5

    ; x = round16( x * focalLength * rcpZ ) + projOffsetX
    muls.l d6,d1
    muls.l d5,d4:d1
    swap d4
    swap d1
    move.w d1,d4
    add.l a3,d4
    swap d4
    ext.l d4
    move.l d4,(a1)

    ; y = round16( y * focalLenAspect * rcpZ ) + projOffsetY
    muls.l d7,d2
    muls.l d5,d4:d2
    swap d4
    swap d2
    move.w d2,d4
    add.l a4,d4
    swap d4
    ext.l d4
    move.l d4,4(a1)

    move.l d3,8(a1)

    lea 12(a0),a0
    lea 12(a1),a1
    subq.l #1,d0
    bpl .proj_loop

.proj_done:
    movem.l (sp)+,d2-d7/a2-a4
    rts

; fixed16_16 robj3d_dotProduct_asm
; a0=pos a1=normal a2=dir, return d0
; result = (normal-pos) . (dir-pos), with mul16 scaling
_robj3d_dotProduct_asm:
robj3d_dotProduct_asm:
    movem.l d2-d4,-(sp)

    move.l (a0),d3
    move.l (a1),d1
    sub.l d3,d1
    move.l (a2),d2
    sub.l d3,d2
    muls.l d2,d4:d1
    swap d4
    swap d1
    move.w d1,d4
    move.l d4,d0

    move.l 4(a0),d3
    move.l 4(a1),d1
    sub.l d3,d1
    move.l 4(a2),d2
    sub.l d3,d2
    muls.l d2,d4:d1
    swap d4
    swap d1
    move.w d1,d4
    add.l d4,d0

    move.l 8(a0),d3
    move.l 8(a1),d1
    sub.l d3,d1
    move.l 8(a2),d2
    sub.l d3,d2
    muls.l d2,d4:d1
    swap d4
    swap d1
    move.w d1,d4
    add.l d4,d0

    movem.l (sp)+,d2-d4
    rts
