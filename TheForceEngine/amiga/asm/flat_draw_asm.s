;
; TheForceEngine - Amiga port
;
; 68020+
;

    section .text,code

    XDEF _flat_drawCeiling_asm
    XDEF flat_drawCeiling_asm
    XDEF _flat_drawFloor_asm
    XDEF flat_drawFloor_asm

    XREF _g_rcfState_ptr
    XREF _g_asm_scanlineU0
    XREF _g_asm_scanlineV0
    XREF _g_asm_scanline_dUdX
    XREF _g_asm_scanline_dVdX
    XREF _g_asm_scanlineWidth
    XREF _g_asm_scanlineLight
    XREF _g_asm_scanlineOut
    XREF _g_asm_scanlineX0
    XREF _g_asm_display
    XREF _g_asm_windowMinY
    XREF _g_asm_windowMaxY
    XREF _g_asm_wallMaxCeilY
    XREF _g_asm_wallMinFloorY
    XREF _g_asm_windowMinX_Pixels
    XREF _g_asm_screenYMidBase
    XREF _g_asm_screenYMidFix
    XREF _g_asm_screenXMid
    XREF _g_asm_flat_setTexture
    XREF _flat_buildScanlineCeiling_asm
    XREF _flat_buildScanlineFloor_asm
    XREF _g_asm_computeLighting
    XREF _drawScanline_Lit_asm
    XREF _drawScanline_Fullbright_asm

RS_FLOORHTX = 40
RS_CEILHTX = 44
RS_FLOORTEX = 76
RS_CEILTEX = 80
RS_FLOOROFF_X = 84
RS_FLOOROFF_Z = 88
RS_CEILOFF_X = 92
RS_CEILOFF_Z = 96

RCF_FOCALLENASPECT = 28
RCF_EYEHEIGHT = 32
RCF_CAMPOS_X = 44
RCF_CAMPOS_Z = 52
RCF_COSYAW = 64
RCF_SINYAW = 68
RCF_RCPY = 160

FRAMESZ = 48
F_RELCEIL = 0
F_Y = 4
F_YOFFSET = 8
F_YRCP = 12
F_Z = 16
F_X = 20
F_I = 24
F_LEFT = 28
F_RIGHT = 32
F_RIGHTCLIP = 36
F_BOUND1 = 40
F_BOUND2 = 44

HEIGHT_X2 = 400

_flat_drawCeiling_asm:
flat_drawCeiling_asm:
    movem.l d2-d7/a2-a6,-(sp)
    lea -FRAMESZ(sp),sp

    move.l a1,a3
    move.l d0,a4
    move.l _g_rcfState_ptr,a6

    move.l RCF_CAMPOS_X(a6),d2
    move.l RS_CEILOFF_X(a0),d0
    sub.l d0,d2

    move.l RS_CEILOFF_Z(a0),d3
    move.l RCF_CAMPOS_Z(a6),d0
    sub.l d0,d3

    move.l RS_CEILHTX(a0),d0
    sub.l RCF_EYEHEIGHT(a6),d0
    move.l d0,F_RELCEIL(sp)

    move.l d0,d4
    muls.l RCF_FOCALLENASPECT(a6),d4

    move.l d4,d0
    muls.l RCF_COSYAW(a6),d1:d0
    move.w d1,d0
    swap d0
    move.l d0,d5

    move.l F_RELCEIL(sp),d0
    muls.l RCF_SINYAW(a6),d1:d0
    move.w d1,d0
    swap d0
    neg.l d0
    move.l d0,d6

    move.l d4,d0
    muls.l RCF_SINYAW(a6),d1:d0
    move.w d1,d0
    swap d0
    move.l d0,d7

    move.l F_RELCEIL(sp),d0
    muls.l RCF_COSYAW(a6),d1:d0
    move.w d1,d0
    swap d0
    neg.l d0
    move.l d0,a2

    move.l a2,F_RELCEIL(sp)

    move.l RS_CEILTEX(a0),a0
    move.l (a0),d0
    move.l d0,-(sp)
    jsr _g_asm_flat_setTexture
    addq.l #4,sp
    tst.b d0
    beq .ceil_done

    move.l _g_asm_screenYMidBase,a0
    move.l (a0),d0
    move.l _g_asm_screenYMidFix,a1
    move.l (a1),d1
    sub.l d1,d0
    add.l #HEIGHT_X2,d0
    move.l d0,a5

    move.l _g_asm_wallMaxCeilY,a0
    move.l (a0),F_BOUND1(sp)
    move.l _g_asm_windowMaxY,a0
    move.l (a0),F_BOUND2(sp)

    move.l _g_asm_windowMinY,a0
    move.l (a0),F_Y(sp)

.ceil_y_loop:
    move.l F_Y(sp),d0
    move.l F_BOUND1(sp),d1
    cmp.l d0,d1
    blt .ceil_done

    move.l F_BOUND2(sp),d1
    cmp.l d0,d1
    ble .ceil_done

    move.l d0,d1
    lsl.l #6,d0
    lsl.l #8,d1
    add.l d1,d0
    move.l d0,F_YOFFSET(sp)

    move.l a5,d0
    add.l F_Y(sp),d0
    move.l RCF_RCPY(a6),a0
    move.l (a0,d0.l*4),d0
    move.l d0,F_YRCP(sp)

    move.l F_YRCP(sp),d0
    muls.l d4,d1:d0
    move.w d1,d0
    swap d0
    move.l d0,F_Z(sp)

    move.l _g_asm_windowMinX_Pixels,a0
    move.l (a0),F_X(sp)

    clr.l F_I(sp)

.ceil_inner_loop:
    move.l F_I(sp),d0
    cmp.l a4,d0
    bge .ceil_y_next

    move.l a3,-(sp)
    move.l _g_asm_scanlineWidth,a0
    pea (a0)
    pea (F_RIGHT+8,sp)
    pea (F_LEFT+12,sp)
    move.l (F_Y+16,sp),-(sp)
    pea (F_X+20,sp)
    move.l a4,-(sp)
    pea (F_I+28,sp)
    jsr _flat_buildScanlineCeiling_asm
    lea 32(sp),sp

    tst.l d0
    beq .ceil_y_next

    move.l _g_asm_scanlineWidth,a0
    move.l (a0),d0
    tst.l d0
    ble .ceil_inner_loop

    move.l F_LEFT(sp),d0
    move.l _g_asm_scanlineX0,a0
    move.l d0,(a0)
    add.l F_YOFFSET(sp),d0
    move.l _g_asm_display,a0
    move.l (a0),a0
    lea (a0,d0.l),a0
    move.l _g_asm_scanlineOut,a1
    move.l a0,(a1)

    move.l F_RIGHT(sp),d0
    move.l _g_asm_screenXMid,a0
    move.l (a0),d1
    sub.l d1,d0
    move.l d0,F_RIGHTCLIP(sp)

    move.l F_RIGHTCLIP(sp),d0
    muls.l d6,d0
    move.l d5,d1
    sub.l d0,d1
    move.l d1,d0
    muls.l (F_YRCP,sp),d1:d0
    move.w d1,d0
    swap d0
    sub.l d3,d0
    asl.l #3,d0
    move.l _g_asm_scanlineV0,a0
    move.l d0,(a0)

    move.l F_RIGHTCLIP(sp),d0
    muls.l (F_RELCEIL,sp),d0
    move.l d7,d1
    add.l d0,d1
    move.l d1,d0
    muls.l (F_YRCP,sp),d1:d0
    move.w d1,d0
    swap d0
    sub.l d2,d0
    asl.l #3,d0
    move.l _g_asm_scanlineU0,a0
    move.l d0,(a0)

    move.l F_YRCP(sp),d0
    muls.l d6,d1:d0
    move.w d1,d0
    swap d0
    asl.l #3,d0
    move.l _g_asm_scanline_dVdX,a0
    move.l d0,(a0)

    move.l F_YRCP(sp),d0
    muls.l (F_RELCEIL,sp),d1:d0
    move.w d1,d0
    swap d0
    neg.l d0
    asl.l #3,d0
    move.l _g_asm_scanline_dUdX,a0
    move.l d0,(a0)

    clr.l -(sp)
    move.l F_Z+4(sp),d0
    move.l d0,-(sp)
    jsr _g_asm_computeLighting
    lea 8(sp),sp
    move.l _g_asm_scanlineLight,a0
    move.l d0,(a0)

    tst.l d0
    beq .ceil_fullbright
    jsr _drawScanline_Lit_asm
    bra .ceil_inner_loop

.ceil_fullbright:
    jsr _drawScanline_Fullbright_asm
    bra .ceil_inner_loop

.ceil_y_next:
    addq.l #1,F_Y(sp)
    bra .ceil_y_loop

.ceil_done:
    lea FRAMESZ(sp),sp
    movem.l (sp)+,d2-d7/a2-a6
    rts

_flat_drawFloor_asm:
flat_drawFloor_asm:
    movem.l d2-d7/a2-a6,-(sp)
    lea -FRAMESZ(sp),sp

    move.l a1,a3
    move.l d0,a4
    move.l _g_rcfState_ptr,a6

    move.l RCF_CAMPOS_X(a6),d2
    move.l RS_FLOOROFF_X(a0),d0
    sub.l d0,d2

    move.l RS_FLOOROFF_Z(a0),d3
    move.l RCF_CAMPOS_Z(a6),d0
    sub.l d0,d3

    move.l RS_FLOORHTX(a0),d0
    sub.l RCF_EYEHEIGHT(a6),d0
    move.l d0,F_RELCEIL(sp)

    move.l d0,d4
    muls.l RCF_FOCALLENASPECT(a6),d4

    move.l d4,d0
    muls.l RCF_COSYAW(a6),d1:d0
    move.w d1,d0
    swap d0
    move.l d0,d5

    move.l F_RELCEIL(sp),d0
    muls.l RCF_SINYAW(a6),d1:d0
    move.w d1,d0
    swap d0
    neg.l d0
    move.l d0,d6

    move.l d4,d0
    muls.l RCF_SINYAW(a6),d1:d0
    move.w d1,d0
    swap d0
    move.l d0,d7

    move.l F_RELCEIL(sp),d0
    muls.l RCF_COSYAW(a6),d1:d0
    move.w d1,d0
    swap d0
    neg.l d0
    move.l d0,a2
    
    move.l a2,F_RELCEIL(sp)

    move.l RS_FLOORTEX(a0),a0
    move.l (a0),d0
    move.l d0,-(sp)
    jsr _g_asm_flat_setTexture
    addq.l #4,sp
    tst.b d0
    beq .floor_done

    move.l _g_asm_screenYMidBase,a0
    move.l (a0),d0
    move.l _g_asm_screenYMidFix,a1
    move.l (a1),d1
    sub.l d1,d0
    add.l #HEIGHT_X2,d0
    move.l d0,a5

    move.l _g_asm_windowMaxY,a0
    move.l (a0),F_BOUND1(sp)

    move.l _g_asm_wallMinFloorY,a0
    move.l (a0),d0
    move.l _g_asm_windowMinY,a1
    move.l (a1),d1
    cmp.l d1,d0
    bge .floor_use_wallmin
    move.l d1,F_Y(sp)
    bra .floor_y_loop

.floor_use_wallmin:
    move.l d0,F_Y(sp)

.floor_y_loop:
    move.l F_Y(sp),d0
    move.l F_BOUND1(sp),d1
    cmp.l d0,d1
    blt .floor_done

    move.l d0,d1
    lsl.l #6,d0
    lsl.l #8,d1
    add.l d1,d0
    move.l d0,F_YOFFSET(sp)

    move.l a5,d0
    add.l F_Y(sp),d0
    move.l RCF_RCPY(a6),a0
    move.l (a0,d0.l*4),d0
    move.l d0,F_YRCP(sp)

    move.l F_YRCP(sp),d0
    muls.l d4,d1:d0
    move.w d1,d0
    swap d0
    move.l d0,F_Z(sp)

    move.l _g_asm_windowMinX_Pixels,a0
    move.l (a0),F_X(sp)

    clr.l F_I(sp)

.floor_inner_loop:
    move.l F_I(sp),d0
    cmp.l a4,d0
    bge .floor_y_next

    move.l a3,-(sp)
    move.l _g_asm_scanlineWidth,a0
    pea (a0)
    pea (F_RIGHT+8,sp)
    pea (F_LEFT+12,sp)
    move.l (F_Y+16,sp),-(sp)
    pea (F_X+20,sp)
    move.l a4,-(sp)
    pea (F_I+28,sp)
    jsr _flat_buildScanlineFloor_asm
    lea 32(sp),sp

    tst.l d0
    beq .floor_y_next

    move.l _g_asm_scanlineWidth,a0
    move.l (a0),d0
    tst.l d0
    ble .floor_inner_loop

    move.l F_LEFT(sp),d0
    move.l _g_asm_scanlineX0,a0
    move.l d0,(a0)
    add.l F_YOFFSET(sp),d0
    move.l _g_asm_display,a0
    move.l (a0),a0
    lea (a0,d0.l),a0
    move.l _g_asm_scanlineOut,a1
    move.l a0,(a1)

    move.l F_RIGHT(sp),d0
    move.l _g_asm_screenXMid,a0
    move.l (a0),d1
    sub.l d1,d0
    move.l d0,F_RIGHTCLIP(sp)

    move.l F_RIGHTCLIP(sp),d0
    muls.l d6,d0
    move.l d5,d1
    sub.l d0,d1
    move.l d1,d0
    muls.l (F_YRCP,sp),d1:d0
    move.w d1,d0
    swap d0
    sub.l d3,d0
    asl.l #3,d0
    move.l _g_asm_scanlineV0,a0
    move.l d0,(a0)

    move.l F_RIGHTCLIP(sp),d0
    muls.l (F_RELCEIL,sp),d0
    move.l d7,d1
    add.l d0,d1
    move.l d1,d0
    muls.l (F_YRCP,sp),d1:d0
    move.w d1,d0
    swap d0
    sub.l d2,d0
    asl.l #3,d0
    move.l _g_asm_scanlineU0,a0
    move.l d0,(a0)

    move.l F_YRCP(sp),d0
    muls.l d6,d1:d0
    move.w d1,d0
    swap d0
    asl.l #3,d0
    move.l _g_asm_scanline_dVdX,a0
    move.l d0,(a0)

    move.l F_YRCP(sp),d0
    muls.l (F_RELCEIL,sp),d1:d0
    move.w d1,d0
    swap d0
    neg.l d0
    asl.l #3,d0
    move.l _g_asm_scanline_dUdX,a0
    move.l d0,(a0)

    clr.l -(sp)
    move.l F_Z+4(sp),d0
    move.l d0,-(sp)
    jsr _g_asm_computeLighting
    lea 8(sp),sp
    move.l _g_asm_scanlineLight,a0
    move.l d0,(a0)

    tst.l d0
    beq .floor_fullbright
    jsr _drawScanline_Lit_asm
    bra .floor_inner_loop
    
.floor_fullbright:
    jsr _drawScanline_Fullbright_asm
    bra .floor_inner_loop

.floor_y_next:
    addq.l #1,F_Y(sp)
    bra .floor_y_loop

.floor_done:
    lea FRAMESZ(sp),sp
    movem.l (sp)+,d2-d7/a2-a6
    rts
