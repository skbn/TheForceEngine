;
; TheForceEngine - Amiga port
;
; 68020+
;

    section .text,code

    XDEF _wall_drawTop_asm
    XDEF wall_drawTop_asm

    XREF _g_rcfState_ptr
    XREF _g_asm_texHeightMask
    XREF _g_asm_yPixelCount
    XREF _g_asm_vCoordStep
    XREF _g_asm_vCoordFixed
    XREF _g_asm_columnLight
    XREF _g_asm_texImage
    XREF _g_asm_columnOut
    XREF _g_asm_columnTop
    XREF _g_asm_columnBot
    XREF _g_asm_windowTop
    XREF _g_asm_windowBot
    XREF _g_asm_display
    XREF _g_asm_windowMinY
    XREF _g_asm_windowMaxY
    XREF _g_asm_solveForZ_Numerator
    XREF _g_asm_drawColumn_Lit
    XREF _g_asm_drawColumn_Fullbright
    XREF _g_asm_computeLighting
    XREF _g_asm_flat_addEdges
    XREF _g_asm_wall_addAdjoinSegment
    XREF _g_asm_setupSignTexture
    XREF _solveForZ_asm

SW = 320

Z0 = 0
NUM = 4
TEXW = 8
FLIP = 12
USCL = 16
UC0 = 20
TOPX = 24
TOPZ = 28
TOPTEXH = 32
DISP = 36
DEPTH = 40
COLTOP = 44
COLBOT = 48
WINTOP = 52
WINBOT = 56
DYDT = 60
DYDB = 64
DYDN = 68
DXV = 72
ZVAL = 76
TOP = 80
BOT = 84
VCS = 88
TEXU = 92
SU0 = 96
SU1 = 100
SFB = 104
SLIT = 108
SYT = 112
YC = 116
YNEXT = 120
YBOT = 124
NEXTSEC = 128
WLIGHT = 132
TEXMASK = 136
MTEXH = 140
MOFFZ = 144
LOGY = 148
TEXIMG = 152
FRAMESZ = 156

_wall_drawTop_asm:
wall_drawTop_asm:
    movem.l d2-d7/a2-a6,-(sp)
    lea -FRAMESZ(sp),sp

    move.l a0,a2
    move.l (a2),a3
    move.l _g_rcfState_ptr,a6

    move.l 16(a3),a0
    move.l a0,NEXTSEC(sp)

    move.l 48(a3),a0
    tst.l a0
    beq .return
    move.l (a0),a4
    tst.l a4
    beq .return

    move.l 24(a2),d0
    move.l d0,Z0(sp)

    move.l a2,-(sp)
    jsr _g_asm_solveForZ_Numerator
    addq.l #4,sp
    move.l d0,NUM(sp)

    move.l 12(a2),d2
    move.l 16(a2),d3
    sub.l d2,d3
    addq.l #1,d3

    move.l 12(a3),a5

    move.l 44(a5),d0
    move.l 32(a6),d1
    sub.l d1,d0
    muls.l 28(a6),d0

    move.l d0,d4
    swap d4
    move.w d4,d5
    clr.w d4
    ext.l d5
    move.l Z0(sp),d1
    divs.l d1,d5:d4
    add.l 12(a6),d4
    move.l d4,DXV(sp)

    move.l d0,d4
    swap d4
    move.w d4,d5
    clr.w d4
    ext.l d5
    move.l 28(a2),d1
    divs.l d1,d5:d4
    add.l 12(a6),d4
    move.l d4,ZVAL(sp)

    move.l DXV(sp),d5
    add.l #$8000,d5
    swap d5
    ext.l d5
    move.l ZVAL(sp),d6
    add.l #$8000,d6
    swap d6
    ext.l d6

    move.l _g_asm_windowMaxY,a0
    move.l (a0),d7
    cmp.l d7,d5
    ble .floor_setup
    cmp.l d7,d6
    ble .floor_setup

    moveq #0,d0
    move.l d0,8(a3)

    addq.l #1,d7
    swap d7
    clr.w d7
    move.l d7,-(sp)
    pea 0.w
    move.l d7,-(sp)
    pea 0.w
    move.l d2,-(sp)
    move.l d3,-(sp)
    jsr _g_asm_flat_addEdges
    lea 24(sp),sp

    move.l _g_rcfState_ptr,a6
    move.l 40(a6),a0
    move.l _g_asm_columnTop,a1
    move.l (a1),a1
    move.l _g_asm_windowMaxY,a4
    move.l (a4),a4

.ceil_eloop:
    move.l a0,-(sp)
    move.l a1,-(sp)
    move.l a2,a0
    move.l d2,d0
    move.l NUM(sp),d1
    suba.l a1,a1
    jsr _solveForZ_asm
    move.l (sp)+,a1
    move.l (sp)+,a0
    move.l d0,(a0,d2.l*4)
    move.l a4,(a1,d2.l*4)
    addq.l #1,d2
    subq.l #1,d3
    bgt .ceil_eloop

    moveq #-1,d0
    move.l d0,4(a3)
    bra .return

.floor_setup:
    move.l NEXTSEC(sp),a0
    move.l 124(a5),d4
    move.l 124(a0),d5
    btst #7,d4
    beq .floor_proj
    btst #8,d5
    beq .floor_proj

    move.l _g_asm_windowMaxY,a0
    move.l (a0),d0
    swap d0
    clr.w d0
    move.l d0,TOP(sp)
    move.l d0,BOT(sp)
    bra .floor_round

.floor_proj:
    move.l 40(a5),d4
    move.l 32(a6),d1
    sub.l d1,d4
    muls.l 28(a6),d4

    move.l d4,d5
    swap d5
    move.w d5,d6
    clr.w d5
    ext.l d6
    move.l Z0(sp),d0
    divs.l d0,d6:d5
    add.l 12(a6),d5
    move.l d5,TOP(sp)

    move.l d4,d5
    swap d5
    move.w d5,d6
    clr.w d5
    ext.l d6
    move.l 28(a2),d0
    divs.l d0,d6:d5
    add.l 12(a6),d5
    move.l d5,BOT(sp)

.floor_round:
    move.l TOP(sp),d5
    add.l #$8000,d5
    swap d5
    ext.l d5
    move.l BOT(sp),d6
    add.l #$8000,d6
    swap d6
    ext.l d6

    move.l _g_asm_windowMinY,a0
    move.l (a0),d7
    cmp.l d7,d5
    bge .nextCeil_setup
    cmp.l d7,d6
    bge .nextCeil_setup

    moveq #0,d0
    move.l d0,8(a3)

    subq.l #1,d7
    swap d7
    clr.w d7
    move.l d7,-(sp)
    pea 0.w
    move.l d7,-(sp)
    pea 0.w
    move.l d2,-(sp)
    move.l d3,-(sp)
    jsr _g_asm_flat_addEdges
    lea 24(sp),sp

    move.l _g_rcfState_ptr,a6
    move.l 40(a6),a0
    move.l _g_asm_columnBot,a1
    move.l (a1),a1
    move.l _g_asm_windowMinY,a4
    move.l (a4),a4

.floor_eloop:
    move.l a0,-(sp)
    move.l a1,-(sp)
    move.l a2,a0
    move.l d2,d0
    move.l NUM(sp),d1
    suba.l a1,a1
    jsr _solveForZ_asm
    move.l (sp)+,a1
    move.l (sp)+,a0
    move.l d0,(a0,d2.l*4)
    move.l a4,(a1,d2.l*4)
    addq.l #1,d2
    subq.l #1,d3
    bgt .floor_eloop

    moveq #-1,d0
    move.l d0,4(a3)
    bra .return

.nextCeil_setup:
    move.l NEXTSEC(sp),a0
    move.l 44(a0),d4
    move.l 32(a6),d1
    sub.l d1,d4
    muls.l 28(a6),d4

    move.l d4,d5
    swap d5
    move.w d5,d6
    clr.w d5
    ext.l d6
    move.l Z0(sp),d0
    divs.l d0,d6:d5
    add.l 12(a6),d5
    move.l d5,VCS(sp)

    move.l d4,d5
    swap d5
    move.w d5,d6
    clr.w d5
    ext.l d6
    move.l 28(a2),d0
    divs.l d0,d6:d5
    add.l 12(a6),d5
    move.l d5,TEXU(sp)

    move.l 4(a2),d2
    move.l 12(a2),d7
    move.l d7,d0
    sub.l d2,d0
    move.l d0,d2
    move.l 16(a2),d3
    move.l 12(a2),d0
    sub.l d0,d3
    addq.l #1,d3
    move.l 8(a2),d0
    move.l 4(a2),d1
    sub.l d1,d0

    moveq #0,d1
    move.l d1,DYDT(sp)
    move.l d1,DYDB(sp)
    move.l d1,DYDN(sp)
    tst.l d0
    beq .slopes_done

    move.l #$10000,d1
    divs.l d0,d1

    move.l ZVAL(sp),d0
    sub.l DXV(sp),d0
    muls.l d1,d4:d0
    swap d4
    swap d0
    move.w d0,d4
    move.l d4,DYDT(sp)

    move.l TEXU(sp),d0
    sub.l VCS(sp),d0
    muls.l d1,d4:d0
    swap d4
    swap d0
    move.w d0,d4
    move.l d4,DYDN(sp)

    move.l BOT(sp),d0
    sub.l TOP(sp),d0
    muls.l d1,d4:d0
    swap d4
    swap d0
    move.w d0,d4
    move.l d4,DYDB(sp)

.slopes_done:
    tst.l d2
    beq .no_xoff

    move.l DYDT(sp),d0
    muls.l d2,d0
    add.l d0,DXV(sp)

    move.l DYDN(sp),d0
    muls.l d2,d0
    add.l d0,VCS(sp)

    move.l DYDB(sp),d0
    muls.l d2,d0
    add.l d0,TOP(sp)

.no_xoff:
    move.l DXV(sp),d0
    move.l d0,YC(sp)
    move.l VCS(sp),d0
    move.l d0,YNEXT(sp)
    move.l TOP(sp),d0
    move.l d0,YBOT(sp)

    move.l YC(sp),d0
    move.l DYDT(sp),d1
    move.l YBOT(sp),d4
    move.l DYDB(sp),d5
    move.l d0,-(sp)
    move.l d1,-(sp)
    move.l d4,-(sp)
    move.l d5,-(sp)
    move.l d7,-(sp)
    move.l d3,-(sp)
    jsr _g_asm_flat_addEdges
    lea 24(sp),sp

    move.l YNEXT(sp),d0
    add.l #$8000,d0
    swap d0
    ext.l d0
    move.l d0,d4
    move.l TEXU(sp),d0
    add.l #$8000,d0
    swap d0
    ext.l d0
    move.l d0,d5

    move.l _g_asm_windowMaxY,a0
    move.l (a0),d0
    cmp.l d0,d4
    blt .adjoin_check
    cmp.l d0,d5
    bge .no_adjoin

.adjoin_check:
    move.l 40(a5),d0
    move.l NEXTSEC(sp),a0
    move.l 44(a0),d1
    cmp.l d1,d0
    ble .no_adjoin

    move.l YNEXT(sp),d0
    move.l DYDN(sp),d1
    move.l YBOT(sp),d4
    move.l DYDB(sp),d5
    move.l a2,-(sp)
    move.l d0,-(sp)
    move.l d1,-(sp)
    move.l d4,-(sp)
    move.l d5,-(sp)
    move.l d7,-(sp)
    move.l d3,-(sp)
    jsr _g_asm_wall_addAdjoinSegment
    lea 28(sp),sp

.no_adjoin:
    move.l _g_asm_windowMinY,a0
    move.l (a0),d0
    cmp.l d0,d4
    bge .main_setup
    cmp.l d0,d5
    bge .main_setup

    subq.l #1,d0
    move.l _g_asm_columnTop,a1
    move.l (a1),a1

    move.l 12(a2),d2

    move.l NUM(sp),d1

    move.l _g_rcfState_ptr,a6
    move.l 40(a6),a0
    move.l _g_asm_columnBot,a4
    move.l (a4),a4
    move.l _g_asm_windowBot,a5
    move.l (a5),a5

.minY_eloop:
    move.l d0,(a1,d2.l*4)

    move.l YBOT(sp),d6
    move.l d6,d7
    add.l #$8000,d7
    swap d7
    ext.l d7

    move.l (a5,d2.l*4),d6
    cmp.l d6,d7
    ble .mye_clamp
    move.l d6,d7

.mye_clamp:
    addq.l #1,d7
    move.l d7,(a4,d2.l*4)

    move.l a0,-(sp)
    move.l a1,-(sp)
    move.l a2,a0
    move.l d2,d0
    suba.l a1,a1
    jsr _solveForZ_asm
    move.l (sp)+,a1
    move.l (sp)+,a0
    move.l d0,(a0,d2.l*4)

    move.l DYDB(sp),d4
    add.l d4,YBOT(sp)
    addq.l #1,d2
    subq.l #1,d3
    bgt .minY_eloop

    moveq #-1,d0
    move.l d0,4(a3)
    bra .return

.main_setup:
    move.l 32(a2),d0
    move.l d0,UC0(sp)
    move.l 44(a2),d0
    move.l d0,USCL(sp)

    move.l 80(a3),d0
    move.l d0,TOPX(sp)
    move.l 84(a3),d0
    move.l d0,TOPZ(sp)
    move.l 68(a3),d0
    move.l d0,TOPTEXH(sp)

    moveq #0,d0
    move.w 2(a4),d0
    subq.l #1,d0
    move.l _g_asm_texHeightMask,a0
    move.l d0,(a0)

    moveq #0,d0
    move.w (a4),d0
    move.l d0,TEXW(sp)
    subq.l #1,d0
    move.l d0,TEXMASK(sp)

    move.l 136(a3),d0
    and.l #4,d0
    move.l d0,FLIP(sp)

    move.l 108(a3),d0
    move.l d0,MOFFZ(sp)
    moveq #0,d0
    move.b 12(a4),d0
    move.l d0,LOGY(sp)
    move.l 16(a4),d0
    move.l d0,TEXIMG(sp)

    pea SLIT(sp)
    pea SFB+4(sp)
    pea SU1+8(sp)
    pea SU0+12(sp)
    move.l a3,-(sp)
    jsr _g_asm_setupSignTexture
    lea 20(sp),sp
    move.l d0,a5

    move.l _g_asm_display,a0
    move.l (a0),d0
    move.l d0,DISP(sp)
    move.l _g_rcfState_ptr,a0
    move.l 40(a0),d0
    move.l d0,DEPTH(sp)
    move.l _g_asm_columnTop,a0
    move.l (a0),d0
    move.l d0,COLTOP(sp)
    move.l _g_asm_columnBot,a0
    move.l (a0),d0
    move.l d0,COLBOT(sp)
    move.l _g_asm_windowTop,a0
    move.l (a0),d0
    move.l d0,WINTOP(sp)
    move.l _g_asm_windowBot,a0
    move.l (a0),d0
    move.l d0,WINBOT(sp)

    move.l 156(a3),d0
    swap d0
    ext.l d0
    move.l d0,WLIGHT(sp)

    move.l _g_asm_columnLight,a6

    tst.l d3
    ble .done

    move.l d7,d2

.loop:
    move.l YC(sp),d0
    add.l #$8000,d0
    swap d0
    ext.l d0
    move.l d0,d6
    move.l d0,TOP(sp)

    move.l YNEXT(sp),d0
    add.l #$8000,d0
    swap d0
    ext.l d0
    move.l d0,BOT(sp)

    move.l YBOT(sp),d0
    add.l #$8000,d0
    swap d0
    ext.l d0
    move.l d0,d7

    move.l COLTOP(sp),a0
    move.l COLBOT(sp),a1
    subq.l #1,d6
    move.l d6,(a0,d2.l*4)

    addq.l #1,d7
    move.l d7,(a1,d2.l*4)

    move.l WINTOP(sp),a0
    move.l WINBOT(sp),a1
    move.l (a0,d2.l*4),d0
    move.l TOP(sp),d7
    cmp.l d0,d7
    bge .ct_clamp
    move.l d0,d7

.ct_clamp:
    move.l (a1,d2.l*4),d0
    move.l BOT(sp),d1
    cmp.l d0,d1
    ble .cb_clamp
    move.l d0,d1

.cb_clamp:
    move.l d7,TOP(sp)
    move.l d1,BOT(sp)

    move.l d1,d0
    sub.l d7,d0
    addq.l #1,d0
    move.l _g_asm_yPixelCount,a1
    move.l d0,(a1)

    move.l a2,a0
    move.l d2,d0
    move.l NUM(sp),d1
    lea DXV(sp),a1
    jsr _solveForZ_asm
    move.l d0,ZVAL(sp)

    move.l DEPTH(sp),a0
    move.l d0,(a0,d2.l*4)

    tst.b 20(a2)
    beq .u_dzdx

.u_dx_dz:
    move.l ZVAL(sp),d0
    sub.l Z0(sp),d0
    move.l USCL(sp),d1
    muls.l d1,d4:d0
    swap d4
    swap d0
    move.w d0,d4
    add.l UC0(sp),d4
    add.l TOPX(sp),d4
    move.l d4,DXV(sp)
    bra .u_done

.u_dzdx:
    move.l DXV(sp),d0
    move.l USCL(sp),d1
    muls.l d1,d4:d0
    swap d4
    swap d0
    move.w d0,d4
    add.l UC0(sp),d4
    add.l TOPX(sp),d4
    move.l d4,DXV(sp)

.u_done:
    move.l _g_asm_yPixelCount,a0
    move.l (a0),d0
    ble .next

    move.l DXV(sp),d0
    swap d0
    and.l TEXMASK(sp),d0
    move.l FLIP(sp),d1
    tst.l d1
    beq .nf
    move.l TEXW(sp),d1
    sub.l d0,d1
    subq.l #1,d1
    move.l d1,d0

.nf:
    move.l d0,TEXU(sp)

    move.l YNEXT(sp),d1
    move.l YC(sp),d0
    sub.l d0,d1
    add.l #$10000,d1
    move.l TOPTEXH(sp),d0
    move.l d0,d6
    swap d0
    clr.w d0
    swap d6
    ext.l d6
    divs.l d1,d6:d0
    move.l d0,VCS(sp)
    move.l _g_asm_vCoordStep,a0
    move.l d0,(a0)

    move.l BOT(sp),d0
    swap d0
    clr.w d0
    move.l YNEXT(sp),d1
    sub.l d0,d1
    add.l #$8000,d1
    move.l VCS(sp),d0
    muls.l d1,d6:d0
    swap d6
    swap d0
    move.w d0,d6
    add.l TOPZ(sp),d6
    move.l _g_asm_vCoordFixed,a0
    move.l d6,(a0)

    move.l TEXU(sp),d0
    move.l LOGY(sp),d1
    lsl.l d1,d0
    move.l TEXIMG(sp),a0
    add.l d0,a0
    move.l _g_asm_texImage,a1
    move.l a0,(a1)

    move.l ZVAL(sp),d0
    move.l WLIGHT(sp),d1
    move.l d1,-(sp)
    move.l d0,-(sp)
    jsr _g_asm_computeLighting
    addq.l #8,sp
    move.l d0,(a6)

    move.l TOP(sp),d1
    move.l d1,d7
    lsl.l #8,d1
    lsl.l #6,d7
    add.l d7,d1
    add.l d2,d1
    move.l DISP(sp),a0
    add.l d1,a0
    move.l _g_asm_columnOut,a1
    move.l a0,(a1)

    tst.l d0
    beq .fb
    jsr _g_asm_drawColumn_Lit
    bra .sign

.fb:
    jsr _g_asm_drawColumn_Fullbright

.sign:
    tst.l a5
    beq .next

    move.l DXV(sp),d0
    move.l SU0(sp),d1
    cmp.l d1,d0
    blt .next
    move.l SU1(sp),d1
    cmp.l d1,d0
    bgt .next

    move.l VCS(sp),d1
    moveq #1,d4
    moveq #0,d5
    divs.l d1,d4:d5

    move.l MOFFZ(sp),d0
    muls.l d5,d4:d0
    swap d4
    swap d0
    move.w d0,d4
    move.l YNEXT(sp),d0
    add.l d0,d4
    move.l d4,ZVAL(sp)

    move.w 2(a5),d0
    swap d0
    clr.w d0
    muls.l d5,d6:d0
    swap d6
    swap d0
    move.w d0,d6
    move.l ZVAL(sp),d0
    sub.l d6,d0
    add.l #$10000,d0
    move.l d0,SYT(sp)

    move.l SYT(sp),d0
    add.l #$8000,d0
    swap d0
    ext.l d0
    move.l TOP(sp),d1
    cmp.l d1,d0
    bge .sg_y0
    move.l d1,d0

.sg_y0:
    move.l d0,TEXU(sp)

    move.l ZVAL(sp),d0
    add.l #$8000,d0
    swap d0
    ext.l d0
    move.l BOT(sp),d1
    cmp.l d1,d0
    ble .sg_y1
    move.l d1,d0

.sg_y1:
    move.l d0,BOT(sp)

    move.l BOT(sp),d0
    sub.l TEXU(sp),d0
    addq.l #1,d0
    move.l _g_asm_yPixelCount,a1
    move.l d0,(a1)
    ble .sg_done

    move.l ZVAL(sp),d0
    move.l BOT(sp),d1
    swap d1
    clr.w d1
    sub.l d1,d0
    add.l #$8000,d0
    move.l VCS(sp),d1
    muls.l d1,d4:d0
    swap d4
    swap d0
    move.w d0,d4
    move.l _g_asm_vCoordFixed,a0
    move.l d4,(a0)

    move.l TEXU(sp),d0
    move.l d0,d4
    lsl.l #8,d0
    lsl.l #6,d4
    add.l d4,d0
    add.l d2,d0
    move.l DISP(sp),a0
    add.l d0,a0
    move.l _g_asm_columnOut,a1
    move.l a0,(a1)

    move.l DXV(sp),d0
    move.l SU0(sp),d1
    sub.l d1,d0
    swap d0
    ext.l d0
    move.l d0,TEXU(sp)

    move.l TEXU(sp),d0
    moveq #0,d1
    move.b 12(a5),d1
    lsl.l d1,d0
    move.l 16(a5),a0
    add.l d0,a0
    move.l _g_asm_texImage,a1
    move.l a0,(a1)

    move.l _g_asm_texHeightMask,a0
    move.l (a0),d0
    move.l d0,SYT(sp)
    moveq #0,d0
    move.w 2(a5),d0
    subq.l #1,d0
    move.l d0,(a0)

    move.l (a6),d0
    tst.l d0
    beq .sg_fb
    move.l SLIT(sp),a0
    jsr (a0)
    bra .sg_rest

.sg_fb:
    move.l SFB(sp),a0
    jsr (a0)

.sg_rest:
    move.l _g_asm_texHeightMask,a0
    move.l SYT(sp),d0
    move.l d0,(a0)

.sg_done:

.next:
    move.l DYDT(sp),d0
    add.l d0,YC(sp)
    move.l DYDN(sp),d0
    add.l d0,YNEXT(sp)
    move.l DYDB(sp),d0
    add.l d0,YBOT(sp)
    addq.l #1,d2
    subq.l #1,d3
    bgt .loop

.done:
    moveq #-1,d0
    move.l d0,4(a3)

.return:
    lea FRAMESZ(sp),sp
    movem.l (sp)+,d2-d7/a2-a6
    rts
