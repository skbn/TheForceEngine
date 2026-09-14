;
; TheForceEngine - Amiga port
;
; 68020+
;

    section .text,code

    XDEF _drawColumn_Fullbright_asm
    XDEF drawColumn_Fullbright_asm
    XDEF _drawColumn_Lit_asm
    XDEF drawColumn_Lit_asm
    XDEF _drawColumn_Fullbright_Trans_asm
    XDEF drawColumn_Fullbright_Trans_asm
    XDEF _drawColumn_Lit_Trans_asm
    XDEF drawColumn_Lit_Trans_asm

    XREF _g_asm_vCoordFixed
    XREF _g_asm_texImage
    XREF _g_asm_texHeightMask
    XREF _g_asm_yPixelCount
    XREF _g_asm_columnOut
    XREF _g_asm_vCoordStep
    XREF _g_asm_columnLight

SW = 320

; drawColumn_Fullbright_asm()
_drawColumn_Fullbright_asm:
drawColumn_Fullbright_asm:
    movem.l d3/d5-d6,-(sp)

    move.l _g_asm_yPixelCount,a0
    move.l (a0),d3
    subq.l #1,d3
    blt .fb_done

    move.l _g_asm_columnOut,a1
    move.l (a1),a1
    move.l d3,d0
    move.l d3,d1
    lsl.l #8,d0
    lsl.l #6,d1
    add.l d1,d0
    add.l d0,a1

    move.l _g_asm_vCoordStep,a0
    move.l (a0),d5
    move.l _g_asm_vCoordFixed,a0
    move.l (a0),d0
    move.l _g_asm_texHeightMask,a0
    move.l (a0),d6

    move.l d0,d1
    swap d1
    and.l d6,d1

    move.l _g_asm_texImage,a0
    move.l (a0),a0

.fb_loop:
    move.b (a0,d1.l),(a1)
    add.l d5,d0
    move.l d0,d1
    swap d1
    and.l d6,d1
    lea -SW(a1),a1
    dbra d3,.fb_loop

.fb_done:
    movem.l (sp)+,d3/d5-d6
    rts

; drawColumn_Lit_asm()
_drawColumn_Lit_asm:
drawColumn_Lit_asm:
    movem.l d3-d6/a2,-(sp)

    move.l _g_asm_yPixelCount,a0
    move.l (a0),d3
    subq.l #1,d3
    blt .lt_done

    move.l _g_asm_columnOut,a1
    move.l (a1),a1
    move.l d3,d0
    move.l d3,d1
    lsl.l #8,d0
    lsl.l #6,d1
    add.l d1,d0
    add.l d0,a1

    move.l _g_asm_vCoordStep,a0
    move.l (a0),d5
    move.l _g_asm_vCoordFixed,a0
    move.l (a0),d0
    move.l _g_asm_texHeightMask,a0
    move.l (a0),d6

    move.l d0,d1
    swap d1
    and.l d6,d1

    move.l _g_asm_texImage,a0
    move.l (a0),a0
    move.l _g_asm_columnLight,a2
    move.l (a2),a2

    moveq #0,d4

.lt_loop:
    move.b (a0,d1.l),d4
    move.b (a2,d4.l),(a1)
    add.l d5,d0
    move.l d0,d1
    swap d1
    and.l d6,d1
    lea -SW(a1),a1
    dbra d3,.lt_loop

.lt_done:
    movem.l (sp)+,d3-d6/a2
    rts

; drawColumn_Fullbright_Trans_asm()
_drawColumn_Fullbright_Trans_asm:
drawColumn_Fullbright_Trans_asm:
    movem.l d3-d6,-(sp)

    move.l _g_asm_yPixelCount,a0
    move.l (a0),d3
    subq.l #1,d3
    blt .ftb_done

    move.l _g_asm_columnOut,a1
    move.l (a1),a1
    move.l d3,d0
    move.l d3,d1
    lsl.l #8,d0
    lsl.l #6,d1
    add.l d1,d0
    add.l d0,a1

    move.l _g_asm_vCoordStep,a0
    move.l (a0),d5
    move.l _g_asm_vCoordFixed,a0
    move.l (a0),d0
    move.l _g_asm_texHeightMask,a0
    move.l (a0),d6

    move.l d0,d1
    swap d1
    and.l d6,d1

    move.l _g_asm_texImage,a0
    move.l (a0),a0

.ftb_loop:
    move.b (a0,d1.l),d4
    beq .ftb_skip
    move.b d4,(a1)

.ftb_skip:
    add.l d5,d0
    move.l d0,d1
    swap d1
    and.l d6,d1
    lea -SW(a1),a1
    dbra d3,.ftb_loop

.ftb_done:
    movem.l (sp)+,d3-d6
    rts

; drawColumn_Lit_Trans_asm()
_drawColumn_Lit_Trans_asm:
drawColumn_Lit_Trans_asm:
    movem.l d3-d6/a2,-(sp)

    move.l _g_asm_yPixelCount,a0
    move.l (a0),d3
    subq.l #1,d3
    blt .ltt_done

    move.l _g_asm_columnOut,a1
    move.l (a1),a1
    move.l d3,d0
    move.l d3,d1
    lsl.l #8,d0
    lsl.l #6,d1
    add.l d1,d0
    add.l d0,a1

    move.l _g_asm_vCoordStep,a0
    move.l (a0),d5
    move.l _g_asm_vCoordFixed,a0
    move.l (a0),d0
    move.l _g_asm_texHeightMask,a0
    move.l (a0),d6

    move.l d0,d1
    swap d1
    and.l d6,d1

    move.l _g_asm_texImage,a0
    move.l (a0),a0
    move.l _g_asm_columnLight,a2
    move.l (a2),a2

    moveq #0,d4

.ltt_loop:
    move.b (a0,d1.l),d4
    beq .ltt_skip
    move.b (a2,d4.l),(a1)

.ltt_skip:
    add.l d5,d0
    move.l d0,d1
    swap d1
    and.l d6,d1
    lea -SW(a1),a1
    dbra d3,.ltt_loop

.ltt_done:
    movem.l (sp)+,d3-d6/a2
    rts
