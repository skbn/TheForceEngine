;
; TheForceEngine - Amiga port
;
; 68020+
;

    section .text,code

    XDEF _drawColumnS_Fullbright_asm
    XDEF drawColumnS_Fullbright_asm
    XDEF _drawColumnS_Lit_asm
    XDEF drawColumnS_Lit_asm
    XDEF _drawColumnS_Fullbright_Trans_asm
    XDEF drawColumnS_Fullbright_Trans_asm
    XDEF _drawColumnS_Lit_Trans_asm
    XDEF drawColumnS_Lit_Trans_asm

    XREF _g_asm_yPixelCount
    XREF _g_asm_columnOut
    XREF _g_asm_vCoordStep
    XREF _g_asm_vCoordFixed
    XREF _g_asm_texImage
    XREF _g_asm_columnLight
    XREF _g_asm_xPixelCount

SW = 320

; drawColumnS_Fullbright_asm()
_drawColumnS_Fullbright_asm:
drawColumnS_Fullbright_asm:
    movem.l d3/d5,-(sp)

    move.l _g_asm_yPixelCount,a0
    move.l (a0),d3
    subq.l #1,d3
    blt .sfb_done

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

    move.l d0,d1
    swap d1

    move.l _g_asm_texImage,a0
    move.l (a0),a0

.sfb_loop:
    move.b (a0,d1.w),(a1)
    add.l d5,d0
    move.l d0,d1
    swap d1
    lea -SW(a1),a1
    dbra d3,.sfb_loop

.sfb_done:
    movem.l (sp)+,d3/d5
    rts

; drawColumnS_Lit_asm()
_drawColumnS_Lit_asm:
drawColumnS_Lit_asm:
    movem.l d3-d5/a2,-(sp)

    move.l _g_asm_yPixelCount,a0
    move.l (a0),d3
    subq.l #1,d3
    blt .slt_done

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

    move.l d0,d1
    swap d1

    move.l _g_asm_texImage,a0
    move.l (a0),a0
    move.l _g_asm_columnLight,a2
    move.l (a2),a2

    moveq #0,d4

.slt_loop:
    move.b (a0,d1.w),d4
    move.b (a2,d4.l),(a1)
    add.l d5,d0
    move.l d0,d1
    swap d1
    lea -SW(a1),a1
    dbra d3,.slt_loop

.slt_done:
    movem.l (sp)+,d3-d5/a2
    rts

;drawColumnS_Fullbright_Trans_asm()
_drawColumnS_Fullbright_Trans_asm:
drawColumnS_Fullbright_Trans_asm:
    movem.l d2-d7,-(sp)

    move.l _g_asm_yPixelCount,a0
    move.l (a0),d3
    subq.l #1,d3
    blt .sft_done

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

    move.l d0,d1
    swap d1

    move.l _g_asm_xPixelCount,a0
    move.l (a0),d6

    cmp.l #7,d6
    bhi .sft_done

    lea .sft_jt(pc),a0
    move.l (a0,d6.l*4),d2
    move.l _g_asm_texImage,a0
    move.l (a0),a0
    jmp (d2)

.sft_jt:
    dc.l .sft_w1,.sft_w2,.sft_w3,.sft_w4
    dc.l .sft_w5,.sft_w6,.sft_w7,.sft_w8

.sft_w1:
    move.b (a0,d1.w),d4
    beq .sft_s1
    move.b d4,(a1)

.sft_s1:
    add.l d5,d0
    move.l d0,d1
    swap d1
    lea -SW(a1),a1
    dbra d3,.sft_w1
    bra .sft_done

.sft_w2:
    move.b (a0,d1.w),d4
    beq .sft_s2
    move.b d4,d7
    lsl.w #8,d7
    move.b d4,d7
    move.w d7,(a1)

.sft_s2:
    add.l d5,d0
    move.l d0,d1
    swap d1
    lea -SW(a1),a1
    dbra d3,.sft_w2
    bra .sft_done

.sft_w3:
    move.b (a0,d1.w),d4
    beq .sft_s3
    move.b d4,d7
    lsl.w #8,d7
    move.b d4,d7
    move.w d7,(a1)
    move.b d7,2(a1)
    
.sft_s3:
    add.l d5,d0
    move.l d0,d1
    swap d1
    lea -SW(a1),a1
    dbra d3,.sft_w3
    bra .sft_done

.sft_w4:
    move.b (a0,d1.w),d4
    beq .sft_s4
    moveq #0,d7
    move.b d4,d7
    lsl.l #8,d7
    or.b d4,d7
    move.l d7,d6
    swap d6
    or.l d6,d7
    move.l d7,(a1)

.sft_s4:
    add.l d5,d0
    move.l d0,d1
    swap d1
    lea -SW(a1),a1
    dbra d3,.sft_w4
    bra .sft_done

.sft_w5:
    move.b (a0,d1.w),d4
    beq .sft_s5
    moveq #0,d7
    move.b d4,d7
    lsl.l #8,d7
    or.b d4,d7
    move.l d7,d6
    swap d6
    or.l d6,d7
    move.l d7,(a1)
    move.b d7,4(a1)

.sft_s5:
    add.l d5,d0
    move.l d0,d1
    swap d1
    lea -SW(a1),a1
    dbra d3,.sft_w5
    bra .sft_done

.sft_w6:
    move.b (a0,d1.w),d4
    beq .sft_s6
    moveq #0,d7
    move.b d4,d7
    lsl.l #8,d7
    or.b d4,d7
    move.l d7,d6
    swap d6
    or.l d6,d7
    move.l d7,(a1)
    move.w d7,4(a1)

.sft_s6:
    add.l d5,d0
    move.l d0,d1
    swap d1
    lea -SW(a1),a1
    dbra d3,.sft_w6
    bra .sft_done

.sft_w7:
    move.b (a0,d1.w),d4
    beq .sft_s7
    moveq #0,d7
    move.b d4,d7
    lsl.l #8,d7
    or.b d4,d7
    move.l d7,d6
    swap d6
    or.l d6,d7
    move.l d7,(a1)
    move.w d7,4(a1)
    move.b d7,6(a1)

.sft_s7:
    add.l d5,d0
    move.l d0,d1
    swap d1
    lea -SW(a1),a1
    dbra d3,.sft_w7
    bra .sft_done

.sft_w8:
    move.b (a0,d1.w),d4
    beq .sft_s8
    moveq #0,d7
    move.b d4,d7
    lsl.l #8,d7
    or.b d4,d7
    move.l d7,d6
    swap d6
    or.l d6,d7
    move.l d7,(a1)
    move.l d7,4(a1)

.sft_s8:
    add.l d5,d0
    move.l d0,d1
    swap d1
    lea -SW(a1),a1
    dbra d3,.sft_w8

.sft_done:
    movem.l (sp)+,d2-d7
    rts

; drawColumnS_Lit_Trans_asm()
_drawColumnS_Lit_Trans_asm:
drawColumnS_Lit_Trans_asm:
    movem.l d2-d7/a2,-(sp)

    move.l _g_asm_yPixelCount,a0
    move.l (a0),d3
    subq.l #1,d3
    blt .slt2_done

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

    move.l d0,d1
    swap d1

    move.l _g_asm_columnLight,a2
    move.l (a2),a2

    move.l _g_asm_xPixelCount,a0
    move.l (a0),d6

    cmp.l #7,d6
    bhi .slt2_done

    moveq #0,d4

    lea .slt2_jt(pc),a0
    move.l (a0,d6.l*4),d2
    move.l _g_asm_texImage,a0
    move.l (a0),a0
    jmp (d2)

.slt2_jt:
    dc.l .slt2_w1,.slt2_w2,.slt2_w3,.slt2_w4
    dc.l .slt2_w5,.slt2_w6,.slt2_w7,.slt2_w8

.slt2_w1:
    move.b (a0,d1.w),d4
    beq .slt2_s1
    move.b (a2,d4.l),(a1)

.slt2_s1:
    add.l d5,d0
    move.l d0,d1
    swap d1
    lea -SW(a1),a1
    dbra d3,.slt2_w1
    bra .slt2_done

.slt2_w2:
    move.b (a0,d1.w),d4
    beq .slt2_s2
    move.b (a2,d4.l),d7
    lsl.w #8,d7
    move.b (a2,d4.l),d7
    move.w d7,(a1)

.slt2_s2:
    add.l d5,d0
    move.l d0,d1
    swap d1
    lea -SW(a1),a1
    dbra d3,.slt2_w2
    bra .slt2_done

.slt2_w3:
    move.b (a0,d1.w),d4
    beq .slt2_s3
    move.b (a2,d4.l),d7
    lsl.w #8,d7
    move.b (a2,d4.l),d7
    move.w d7,(a1)
    move.b d7,2(a1)

.slt2_s3:
    add.l d5,d0
    move.l d0,d1
    swap d1
    lea -SW(a1),a1
    dbra d3,.slt2_w3
    bra .slt2_done

.slt2_w4:
    move.b (a0,d1.w),d4
    beq .slt2_s4
    moveq #0,d7
    move.b (a2,d4.l),d7
    move.l d7,d6
    lsl.l #8,d7
    or.l d6,d7
    move.l d7,d6
    swap d6
    or.l d6,d7
    move.l d7,(a1)

.slt2_s4:
    add.l d5,d0
    move.l d0,d1
    swap d1
    lea -SW(a1),a1
    dbra d3,.slt2_w4
    bra .slt2_done

.slt2_w5:
    move.b (a0,d1.w),d4
    beq .slt2_s5
    moveq #0,d7
    move.b (a2,d4.l),d7
    move.l d7,d6
    lsl.l #8,d7
    or.l d6,d7
    move.l d7,d6
    swap d6
    or.l d6,d7
    move.l d7,(a1)
    move.b d7,4(a1)

.slt2_s5:
    add.l d5,d0
    move.l d0,d1
    swap d1
    lea -SW(a1),a1
    dbra d3,.slt2_w5
    bra .slt2_done

.slt2_w6:
    move.b (a0,d1.w),d4
    beq .slt2_s6
    moveq #0,d7
    move.b (a2,d4.l),d7
    move.l d7,d6
    lsl.l #8,d7
    or.l d6,d7
    move.l d7,d6
    swap d6
    or.l d6,d7
    move.l d7,(a1)
    move.w d7,4(a1)

.slt2_s6:
    add.l d5,d0
    move.l d0,d1
    swap d1
    lea -SW(a1),a1
    dbra d3,.slt2_w6
    bra .slt2_done

.slt2_w7:
    move.b (a0,d1.w),d4
    beq .slt2_s7
    moveq #0,d7
    move.b (a2,d4.l),d7
    move.l d7,d6
    lsl.l #8,d7
    or.l d6,d7
    move.l d7,d6
    swap d6
    or.l d6,d7
    move.l d7,(a1)
    move.w d7,4(a1)
    move.b d7,6(a1)

.slt2_s7:
    add.l d5,d0
    move.l d0,d1
    swap d1
    lea -SW(a1),a1
    dbra d3,.slt2_w7
    bra .slt2_done

.slt2_w8:
    move.b (a0,d1.w),d4
    beq .slt2_s8
    moveq #0,d7
    move.b (a2,d4.l),d7
    move.l d7,d6
    lsl.l #8,d7
    or.l d6,d7
    move.l d7,d6
    swap d6
    or.l d6,d7
    move.l d7,(a1)
    move.l d7,4(a1)
    
.slt2_s8:
    add.l d5,d0
    move.l d0,d1
    swap d1
    lea -SW(a1),a1
    dbra d3,.slt2_w8

.slt2_done:
    movem.l (sp)+,d2-d7/a2
    rts
