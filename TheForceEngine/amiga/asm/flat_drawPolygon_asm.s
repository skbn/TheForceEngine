;
; TheForceEngine - Amiga port
;
; 68020+
;

    section .text,code

    XDEF _flat_drawPolygonScanline_asm
    XDEF flat_drawPolygonScanline_asm

    XREF _g_rcfState_ptr
    XREF _g_asm_display
    XREF _g_asm_windowMinX_Pixels
    XREF _g_asm_windowMaxX_Pixels
    XREF _g_asm_screenYMidBase
    XREF _g_asm_screenYMidFix
    XREF _g_asm_screenXMid
    XREF _g_asm_scanlineWidth
    XREF _g_asm_scanlineX0
    XREF _g_asm_scanlineOut
    XREF _g_asm_scanlineU0
    XREF _g_asm_scanlineV0
    XREF _g_asm_scanline_dUdX
    XREF _g_asm_scanline_dVdX
    XREF _g_asm_scanlineLight
    XREF _g_asm_s_poly_offsetX
    XREF _g_asm_s_poly_offsetZ
    XREF _g_asm_s_poly_scaledHOffset
    XREF _g_asm_s_poly_sinYawHOffset
    XREF _g_asm_s_poly_cosYawHOffset
    XREF _g_asm_s_poly_cosYawScaledHOffset
    XREF _g_asm_s_poly_sinYawScaledHOffset
    XREF _g_asm_computeLighting
    XREF _clipScanline_asm
    XREF _drawScanline_Lit_asm
    XREF _drawScanline_Fullbright_asm
    XREF _drawScanline_Trans_asm
    XREF _drawScanline_Fullbright_Trans_asm

RCF_RCPY = 160

HEIGHT_X2 = 400

FP_X0 = 0
FP_X1 = 4
FRAMESZ = 8

_flat_drawPolygonScanline_asm:
flat_drawPolygonScanline_asm:
    movem.l d2-d7/a2-a6,-(sp)
    lea -FRAMESZ(sp),sp

    and.l #1,d3
    move.l d0,FP_X0(sp)
    move.l d1,FP_X1(sp)
    move.l d3,a2

    move.l _g_asm_windowMinX_Pixels,a0
    cmp.l (a0),d0
    bge .x0_ok
    move.l (a0),d0
    move.l d0,FP_X0(sp)

.x0_ok:
    move.l _g_asm_windowMaxX_Pixels,a0
    cmp.l (a0),d1
    ble .x1_ok
    move.l (a0),d1
    move.l d1,FP_X1(sp)

.x1_ok:
    move.l d2,-(sp)
    pea (FP_X1+4,sp)
    pea (FP_X0+8,sp)
    jsr _clipScanline_asm
    lea 12(sp),sp

    move.l FP_X1(sp),d1
    move.l FP_X0(sp),d0
    sub.l d0,d1
    addq.l #1,d1
    ble .done

    move.l _g_asm_scanlineWidth,a0
    move.l d1,(a0)
    move.l _g_asm_scanlineX0,a0
    move.l d0,(a0)

    move.l d2,d3
    move.l d2,d4
    lsl.l #6,d2
    lsl.l #8,d4
    add.l d4,d2
    add.l d0,d2
    move.l _g_asm_display,a0
    move.l (a0),a1
    lea (a1,d2.l),a1
    move.l _g_asm_scanlineOut,a0
    move.l a1,(a0)

    move.l _g_asm_screenYMidBase,a0
    move.l (a0),d2
    move.l _g_asm_screenYMidFix,a0
    sub.l (a0),d2
    add.l d3,d2
    add.l #HEIGHT_X2,d2
    move.l _g_rcfState_ptr,a6
    move.l RCF_RCPY(a6),a0
    move.l (a0,d2.l*4),d2

    move.l _g_asm_s_poly_scaledHOffset,a0
    move.l (a0),d0
    muls.l d2,d1:d0
    move.w d1,d0
    swap d0
    move.l d0,d4

    move.l FP_X1(sp),d3
    subq.l #1,d3
    move.l _g_asm_screenXMid,a0
    sub.l (a0),d3

    move.l _g_asm_s_poly_cosYawHOffset,a0
    move.l (a0),d6
    move.l _g_asm_s_poly_sinYawHOffset,a0
    move.l (a0),d7

    move.l _g_asm_s_poly_sinYawScaledHOffset,a0
    move.l (a0),d5
    move.l d6,d0
    muls.l d3,d0
    sub.l d0,d5
    move.l d5,d0
    muls.l d2,d1:d0
    move.w d1,d0
    swap d0
    move.l _g_asm_s_poly_offsetX,a0
    sub.l (a0),d0
    asl.l #3,d0
    move.l _g_asm_scanlineU0,a0
    move.l d0,(a0)

    move.l _g_asm_s_poly_cosYawScaledHOffset,a0
    move.l (a0),d5
    move.l d7,d0
    muls.l d3,d0
    add.l d0,d5
    move.l d5,d0
    muls.l d2,d1:d0
    move.w d1,d0
    swap d0
    move.l _g_asm_s_poly_offsetZ,a0
    sub.l (a0),d0
    asl.l #3,d0
    move.l _g_asm_scanlineV0,a0
    move.l d0,(a0)

    move.l d7,d0
    muls.l d2,d1:d0
    move.w d1,d0
    swap d0
    neg.l d0
    asl.l #3,d0
    move.l _g_asm_scanline_dVdX,a0
    move.l d0,(a0)

    move.l d6,d0
    muls.l d2,d1:d0
    move.w d1,d0
    swap d0
    asl.l #3,d0
    move.l _g_asm_scanline_dUdX,a0
    move.l d0,(a0)

    clr.l -(sp)
    move.l d4,-(sp)
    jsr _g_asm_computeLighting
    lea 8(sp),sp
    move.l _g_asm_scanlineLight,a0
    move.l d0,(a0)

    seq d0
    and.l #1,d0
    move.l a2,d1
    lsl.l #1,d1
    add.l d1,d0

    lea .dispatch,a0
    move.l (a0,d0.l*4),a0
    jsr (a0)

.done:
    lea FRAMESZ(sp),sp
    movem.l (sp)+,d2-d7/a2-a6
    rts

.dispatch:
    dc.l _drawScanline_Lit_asm
    dc.l _drawScanline_Fullbright_asm
    dc.l _drawScanline_Trans_asm
    dc.l _drawScanline_Fullbright_Trans_asm