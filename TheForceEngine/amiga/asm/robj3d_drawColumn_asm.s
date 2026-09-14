;
; TheForceEngine - Amiga port
;
; 68020+
;

    section .text,code

    XDEF _robj3d_drawColumnFlatColor_asm
    XDEF robj3d_drawColumnFlatColor_asm
    XDEF _robj3d_drawColumnShadedColor_asm
    XDEF robj3d_drawColumnShadedColor_asm
    XDEF _robj3d_drawColumnFlatTexture_asm
    XDEF robj3d_drawColumnFlatTexture_asm
    XDEF _robj3d_drawColumnShadedTexture_asm
    XDEF robj3d_drawColumnShadedTexture_asm

    XREF _g_asm_s_columnHeight
    XREF _g_asm_s_pcolumnOut
    XREF _g_asm_s_polyColorIndex
    XREF _g_asm_s_polyColorMap
    XREF _g_asm_s_polyTexture
    XREF _g_asm_s_col_I0
    XREF _g_asm_s_col_dIdY
    XREF _g_asm_s_col_Uv0
    XREF _g_asm_s_col_dUVdY
    XREF _g_asm_s_dither
    XREF _g_asm_s_ditherOffset

SW = 320

; robj3d_drawColumnFlatColor_asm()
_robj3d_drawColumnFlatColor_asm:
robj3d_drawColumnFlatColor_asm:
    move.l d3,-(sp)

    move.l _g_asm_s_columnHeight,a0
    move.l (a0),d3
    subq.l #1,d3
    blt .fc_done

    move.l _g_asm_s_pcolumnOut,a1
    move.l (a1),a1
    move.l d3,d0
    move.l d3,d1
    lsl.l #8,d0
    lsl.l #6,d1
    add.l d1,d0
    add.l d0,a1

    move.l _g_asm_s_polyColorIndex,a0
    moveq #0,d0
    move.b (a0),d0

.fc_loop:
    move.b d0,(a1)
    lea -SW(a1),a1
    dbra d3,.fc_loop

.fc_done:
    move.l (sp)+,d3
    rts

; robj3d_drawColumnShadedColor_asm()
_robj3d_drawColumnShadedColor_asm:
robj3d_drawColumnShadedColor_asm:
    movem.l d2-d7/a2,-(sp)

    move.l _g_asm_s_columnHeight,a0
    move.l (a0),d3
    subq.l #1,d3
    blt .sc_done

    move.l _g_asm_s_pcolumnOut,a1
    move.l (a1),a1
    move.l d3,d0
    move.l d3,d1
    lsl.l #8,d0
    lsl.l #6,d1
    add.l d1,d0
    add.l d0,a1

    move.l _g_asm_s_polyColorMap,a2
    move.l (a2),a2

    move.l _g_asm_s_col_I0,a0
    move.l (a0),d4

    move.l _g_asm_s_col_dIdY,a0
    move.l (a0),d5

    ; s_dither is 0 or -1
    move.l _g_asm_s_dither,a0
    move.l (a0),d6
    neg.l d6

    move.l _g_asm_s_ditherOffset,a0
    move.l (a0),d7

    move.l _g_asm_s_polyColorIndex,a0
    moveq #0,d2
    move.b (a0),d2

.sc_loop:
    move.l d4,d0
    swap d0

    tst.l d6
    beq .sc_nodither
    move.l d4,d1
    sub.l d7,d1
    blt .sc_nodither
    move.l d1,d0
    swap d0

.sc_nodither:
    and.w #31,d0
    lsl.w #8,d0
    or.b d2,d0
    move.b (a2,d0.w),(a1)

    add.l d5,d4
    eor #1,d6
    lea -SW(a1),a1
    dbra d3,.sc_loop

.sc_done:
    movem.l (sp)+,d2-d7/a2
    rts

; robj3d_drawColumnFlatTexture_asm()
_robj3d_drawColumnFlatTexture_asm:
robj3d_drawColumnFlatTexture_asm:
    movem.l d2-d7/a2-a6,-(sp)

    move.l _g_asm_s_columnHeight,a0
    move.l (a0),d3
    subq.l #1,d3
    blt .ft_done

    move.l _g_asm_s_pcolumnOut,a1
    move.l (a1),a1
    move.l d3,d0
    move.l d3,d1
    lsl.l #8,d0
    lsl.l #6,d1
    add.l d1,d0
    add.l d0,a1

    move.l _g_asm_s_polyColorIndex,a0
    moveq #0,d2
    move.b (a0),d2
    lsl.l #8,d2

    move.l _g_asm_s_polyColorMap,a2
    move.l (a2),a2
    add.l d2,a2

    move.l _g_asm_s_polyTexture,a0
    move.l (a0),a0
    move.w (a0),d0
    subq.w #1,d0
    move.w d0,a5
    move.w 2(a0),d1
    subq.w #1,d1
    move.w d1,a6
    move.w 2(a0),a4
    move.l 16(a0),a3

    move.l _g_asm_s_col_Uv0,a0
    move.l (a0),d4
    move.l 4(a0),d5

    move.l _g_asm_s_col_dUVdY,a0
    move.l (a0),d6
    move.l 4(a0),d7

.ft_loop:
    move.l d4,d0
    swap d0
    move.w a5,d2
    and.w d2,d0
    move.w a4,d2
    mulu.w d2,d0

    move.l d5,d1
    swap d1
    move.w a6,d2
    and.w d2,d1
    and.l #$FFFF,d1
    add.l d1,d0

    moveq #0,d2
    move.b (a3,d0.l),d2
    move.b (a2,d2.l),(a1)

    add.l d6,d4
    add.l d7,d5
    lea -SW(a1),a1
    dbra d3,.ft_loop

.ft_done:
    movem.l (sp)+,d2-d7/a2-a6
    rts

; robj3d_drawColumnShadedTexture_asm()
; 0(sp)=I 4(sp)=dIdY
_robj3d_drawColumnShadedTexture_asm:
robj3d_drawColumnShadedTexture_asm:
    movem.l d2-d7/a2-a6,-(sp)
    lea -8(sp),sp

    move.l _g_asm_s_columnHeight,a0
    move.l (a0),d3
    subq.l #1,d3
    blt .st_done

    move.l _g_asm_s_pcolumnOut,a1
    move.l (a1),a1
    move.l d3,d0
    move.l d3,d1
    lsl.l #8,d0
    lsl.l #6,d1
    add.l d1,d0
    add.l d0,a1

    move.l _g_asm_s_polyColorMap,a2
    move.l (a2),a2

    move.l _g_asm_s_polyTexture,a0
    move.l (a0),a0
    move.w (a0),d0
    subq.w #1,d0
    move.w d0,a5
    move.w 2(a0),d1
    subq.w #1,d1
    move.w d1,a6
    move.w 2(a0),a4
    move.l 16(a0),a3

    move.l _g_asm_s_col_Uv0,a0
    move.l (a0),d4
    move.l 4(a0),d5

    move.l _g_asm_s_col_dUVdY,a0
    move.l (a0),d6
    move.l 4(a0),d7

    move.l _g_asm_s_col_I0,a0
    move.l (a0),(sp)

    move.l _g_asm_s_col_dIdY,a0
    move.l (a0),4(sp)

.st_loop:
    move.l d4,d0
    swap d0
    move.w a5,d2
    and.w d2,d0
    move.w a4,d2
    mulu.w d2,d0

    move.l d5,d1
    swap d1
    move.w a6,d2
    and.w d2,d1
    and.l #$FFFF,d1
    add.l d1,d0

    moveq #0,d2
    move.b (a3,d0.l),d2

    move.l (sp),d1
    swap d1
    and.w #31,d1
    lsl.w #8,d1
    or.b d2,d1
    move.b (a2,d1.w),(a1)

    move.l 4(sp),d0
    add.l d0,(sp)

    add.l d6,d4
    add.l d7,d5
    lea -SW(a1),a1
    dbra d3,.st_loop

.st_done:
    lea 8(sp),sp
    movem.l (sp)+,d2-d7/a2-a6
    rts
