;
; TheForceEngine - Amiga port
;
; 68020+
;

    section .text,code

    XDEF _drawScanline_Lit_asm
    XDEF drawScanline_Lit_asm
    XDEF _drawScanline_Fullbright_asm
    XDEF drawScanline_Fullbright_asm
    XDEF _drawScanline_Trans_asm
    XDEF drawScanline_Trans_asm
    XDEF _drawScanline_Fullbright_Trans_asm
    XDEF drawScanline_Fullbright_Trans_asm

    XREF _g_asm_scanlineU0
    XREF _g_asm_scanlineV0
    XREF _g_asm_scanline_dUdX
    XREF _g_asm_scanline_dVdX
    XREF _g_asm_scanlineWidth
    XREF _g_asm_scanlineLight
    XREF _g_asm_scanlineOut
    XREF _g_asm_ftexImage

; drawScanline_Lit_asm()
_drawScanline_Lit_asm:
drawScanline_Lit_asm:
    movem.l d2-d7/a2,-(sp)

    moveq #10,d7

    move.l _g_asm_scanlineV0,a0
    move.l (a0),d1
    lsl.l d7,d1

    move.l _g_asm_scanlineU0,a0
    move.l (a0),d0
    lsl.l d7,d0

    move.l _g_asm_scanline_dVdX,a0
    move.l (a0),d3
    lsl.l d7,d3

    move.l _g_asm_scanline_dUdX,a0
    move.l (a0),d2
    lsl.l d7,d2

    move.l _g_asm_scanlineWidth,a0
    move.l (a0),d6
    subq.l #1,d6
    blt .lt_done

    move.l _g_asm_ftexImage,a0
    move.l (a0),a0
    move.l _g_asm_scanlineOut,a1
    move.l (a1),a1
    move.l _g_asm_scanlineLight,a2
    move.l (a2),a2

    move.l d0,d4
    swap d4
    lsr.w d7,d4
    lsl.w #6,d4
    move.l d1,d5
    swap d5
    lsr.w d7,d5
    add.w d5,d4

    add.l d2,d0
    add.l d3,d1

.lt_loop:
    moveq #0,d5
    move.b (a0,d4.w),d5
    move.b (a2,d5.w),d5
    move.b d5,(a1,d6.w)

    move.l d0,d4
    swap d4
    lsr.w d7,d4
    lsl.w #6,d4
    move.l d1,d5
    swap d5
    lsr.w d7,d5
    add.w d5,d4

    add.l d2,d0
    add.l d3,d1

    dbra d6,.lt_loop

.lt_done:
    movem.l (sp)+,d2-d7/a2
    rts

; drawScanline_Fullbright_asm()
_drawScanline_Fullbright_asm:
drawScanline_Fullbright_asm:
    movem.l d2-d7,-(sp)

    moveq #10,d7

    move.l _g_asm_scanlineV0,a0
    move.l (a0),d1
    lsl.l d7,d1

    move.l _g_asm_scanlineU0,a0
    move.l (a0),d0
    lsl.l d7,d0

    move.l _g_asm_scanline_dVdX,a0
    move.l (a0),d3
    lsl.l d7,d3

    move.l _g_asm_scanline_dUdX,a0
    move.l (a0),d2
    lsl.l d7,d2

    move.l _g_asm_scanlineWidth,a0
    move.l (a0),d6
    subq.l #1,d6
    blt .fb_done

    move.l _g_asm_ftexImage,a0
    move.l (a0),a0
    move.l _g_asm_scanlineOut,a1
    move.l (a1),a1

    move.l d0,d4
    swap d4
    lsr.w d7,d4
    lsl.w #6,d4
    move.l d1,d5
    swap d5
    lsr.w d7,d5
    add.w d5,d4

    add.l d2,d0
    add.l d3,d1

.fb_loop:
    move.b (a0,d4.w),d5
    move.b d5,(a1,d6.w)

    move.l d0,d4
    swap d4
    lsr.w d7,d4
    lsl.w #6,d4
    move.l d1,d5
    swap d5
    lsr.w d7,d5
    add.w d5,d4

    add.l d2,d0
    add.l d3,d1

    dbra d6,.fb_loop

.fb_done:
    movem.l (sp)+,d2-d7
    rts

; drawScanline_Trans_asm()
_drawScanline_Trans_asm:
drawScanline_Trans_asm:
    movem.l d2-d7/a2,-(sp)

    moveq #10,d7

    move.l _g_asm_scanlineV0,a0
    move.l (a0),d1
    lsl.l d7,d1

    move.l _g_asm_scanlineU0,a0
    move.l (a0),d0
    lsl.l d7,d0

    move.l _g_asm_scanline_dVdX,a0
    move.l (a0),d3
    lsl.l d7,d3

    move.l _g_asm_scanline_dUdX,a0
    move.l (a0),d2
    lsl.l d7,d2

    move.l _g_asm_scanlineWidth,a0
    move.l (a0),d6
    subq.l #1,d6
    blt .tr_done

    move.l _g_asm_ftexImage,a0
    move.l (a0),a0
    move.l _g_asm_scanlineOut,a1
    move.l (a1),a1
    move.l _g_asm_scanlineLight,a2
    move.l (a2),a2

    move.l d0,d4
    swap d4
    lsr.w d7,d4
    lsl.w #6,d4
    move.l d1,d5
    swap d5
    lsr.w d7,d5
    add.w d5,d4

    add.l d2,d0
    add.l d3,d1

.tr_loop:
    moveq #0,d5
    move.b (a0,d4.w),d5
    beq .tr_skip
    move.b (a2,d5.w),d5
    move.b d5,(a1,d6.w)

.tr_skip:
    move.l d0,d4
    swap d4
    lsr.w d7,d4
    lsl.w #6,d4
    move.l d1,d5
    swap d5
    lsr.w d7,d5
    add.w d5,d4

    add.l d2,d0
    add.l d3,d1

    dbra d6,.tr_loop

.tr_done:
    movem.l (sp)+,d2-d7/a2
    rts

; drawScanline_Fullbright_Trans_asm()
_drawScanline_Fullbright_Trans_asm:
drawScanline_Fullbright_Trans_asm:
    movem.l d2-d7,-(sp)

    moveq #10,d7

    move.l _g_asm_scanlineV0,a0
    move.l (a0),d1
    lsl.l d7,d1

    move.l _g_asm_scanlineU0,a0
    move.l (a0),d0
    lsl.l d7,d0

    move.l _g_asm_scanline_dVdX,a0
    move.l (a0),d3
    lsl.l d7,d3

    move.l _g_asm_scanline_dUdX,a0
    move.l (a0),d2
    lsl.l d7,d2

    move.l _g_asm_scanlineWidth,a0
    move.l (a0),d6
    subq.l #1,d6
    blt .ft_done

    move.l _g_asm_ftexImage,a0
    move.l (a0),a0
    move.l _g_asm_scanlineOut,a1
    move.l (a1),a1

    move.l d0,d4
    swap d4
    lsr.w d7,d4
    lsl.w #6,d4
    move.l d1,d5
    swap d5
    lsr.w d7,d5
    add.w d5,d4

    add.l d2,d0
    add.l d3,d1

.ft_loop:
    move.b (a0,d4.w),d5
    beq .ft_skip
    move.b d5,(a1,d6.w)

.ft_skip:
    move.l d0,d4
    swap d4
    lsr.w d7,d4
    lsl.w #6,d4
    move.l d1,d5
    swap d5
    lsr.w d7,d5
    add.w d5,d4

    add.l d2,d0
    add.l d3,d1

    dbra d6,.ft_loop

.ft_done:
    movem.l (sp)+,d2-d7
    rts
