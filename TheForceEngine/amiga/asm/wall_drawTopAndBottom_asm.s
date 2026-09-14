;
; TheForceEngine - Amiga port
;
; 68020+
;

    section .text,code

    XDEF _wall_drawTopAndBottom_asm
    XDEF wall_drawTopAndBottom_asm

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
X0 = 8
LEN = 12
XOFF = 16
RCPLRAW = 20
TOPTEX = 24
TOPTEXW = 28
TOPTEXH = 32
TOPX = 36
TOPZ = 40
TOPLOGY = 44
TOPIMG = 48
TOPMASK = 52
BOTTEX = 56
BOTTEXW = 60
BOTTEXH = 64
BOTX = 68
BOTZ = 72
BOTLOGY = 76
BOTIMG = 80
BOTMASK = 84
DISP = 88
DEPTH = 92
COLTOP = 96
COLBOT = 100
WINTOP = 104
WINBOT = 108
WLIGHT = 112
FLIP = 116
DYDC = 120
DYDNC = 124
DYDF = 128
DYDNF = 132
CPROJ0 = 136
CPROJ1 = 140
FPROJ0 = 144
FPROJ1 = 148
NCPROJ0 = 152
NCPROJ1 = 156
NFPROJ0 = 160
NFPROJ1 = 164
YC0 = 168
YC1 = 172
YF0 = 176
YF1 = 180
DXV = 184
ZVAL = 188
TOP = 192
BOT = 196
VCS = 200
TEXU = 204
SU0 = 208
SU1 = 212
SFB = 216
SLIT = 220
SYT = 224
SIGNTEX = 228
NEXTSEC = 232
FRAMESZ = 236

_wall_drawTopAndBottom_asm:
wall_drawTopAndBottom_asm:
    movem.l d2-d7/a2-a6,-(sp)
    lea -FRAMESZ(sp),sp

    move.l a0,a2
    move.l (a2),a3
    move.l _g_rcfState_ptr,a6

    move.l 16(a3),a0
    move.l a0,NEXTSEC(sp)

    move.l 24(a2),d0
    move.l d0,Z0(sp)
    move.l 12(a2),d0
    move.l d0,X0(sp)
    move.l 16(a2),d0
    sub.l 12(a2),d0
    addq.l #1,d0
    move.l d0,LEN(sp)

    move.l 12(a2),d0
    move.l 4(a2),d1
    sub.l d1,d0
    move.l d0,XOFF(sp)

    move.l 8(a2),d0
    move.l 4(a2),d1
    sub.l d1,d0
    move.l d0,d2
    beq .rcp_done
    move.l #$10000,d1
    divs.l d0,d1
    move.l d1,RCPLRAW(sp)
    bra .proj_ceil

.rcp_done:
    clr.l RCPLRAW(sp)

.proj_ceil:
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
    move.l d4,CPROJ0(sp)

    move.l d0,d4
    swap d4
    move.w d4,d5
    clr.w d4
    ext.l d5
    move.l 28(a2),d1
    divs.l d1,d5:d4
    add.l 12(a6),d4
    move.l d4,CPROJ1(sp)

    move.l CPROJ0(sp),d0
    add.l #$8000,d0
    swap d0
    ext.l d0
    move.l d0,d2
    move.l CPROJ1(sp),d0
    add.l #$8000,d0
    swap d0
    ext.l d0
    move.l d0,d3

    move.l _g_asm_windowMaxY,a0
    move.l (a0),d0
    cmp.l d0,d2
    ble .ceil_in
    cmp.l d0,d3
    ble .ceil_in

    clr.l 8(a3)

    move.l d0,d4
    move.l _g_asm_columnTop,a1
    move.l (a1),a1
    move.l X0(sp),d2
    move.l LEN(sp),d3

.ceil_fill:
    move.l d4,(a1,d2.l*4)
    addq.l #1,d2
    subq.l #1,d3
    bgt .ceil_fill

    move.l X0(sp),d2
    move.l LEN(sp),d3
    addq.l #1,d0
    swap d0
    clr.w d0
    move.l d0,-(sp)
    pea 0.w
    move.l d0,-(sp)
    pea 0.w
    move.l d2,-(sp)
    move.l d3,-(sp)
    jsr _g_asm_flat_addEdges
    lea 24(sp),sp

    move.l a2,-(sp)
    jsr _g_asm_solveForZ_Numerator
    addq.l #4,sp
    move.l d0,d7

    move.l _g_rcfState_ptr,a6
    move.l 40(a6),a0
    move.l _g_asm_columnTop,a1
    move.l (a1),a1
    move.l _g_asm_windowMaxY,a4
    move.l (a4),a4
    move.l X0(sp),d2
    move.l LEN(sp),d3

.ceil_eloop:
    move.l a0,-(sp)
    move.l a1,-(sp)
    move.l a2,a0
    move.l d2,d0
    move.l d7,d1
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

.ceil_in:
    move.l 40(a5),d0
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
    move.l d4,FPROJ0(sp)

    move.l d0,d4
    swap d4
    move.w d4,d5
    clr.w d4
    ext.l d5
    move.l 28(a2),d1
    divs.l d1,d5:d4
    add.l 12(a6),d4
    move.l d4,FPROJ1(sp)

    move.l FPROJ0(sp),d0
    add.l #$8000,d0
    swap d0
    ext.l d0
    move.l d0,d2
    move.l FPROJ1(sp),d0
    add.l #$8000,d0
    swap d0
    ext.l d0
    move.l d0,d3

    move.l _g_asm_windowMinY,a0
    move.l (a0),d0
    cmp.l d0,d2
    bge .floor_in
    cmp.l d0,d3
    bge .floor_in

    clr.l 8(a3)

    move.l d0,d4
    move.l _g_asm_columnBot,a1
    move.l (a1),a1
    move.l X0(sp),d2
    move.l LEN(sp),d3

.floor_fill:
    move.l d4,(a1,d2.l*4)
    addq.l #1,d2
    subq.l #1,d3
    bgt .floor_fill

    move.l X0(sp),d2
    move.l LEN(sp),d3
    subq.l #1,d0
    swap d0
    clr.w d0
    move.l d0,-(sp)
    pea 0.w
    move.l d0,-(sp)
    pea 0.w
    move.l d2,-(sp)
    move.l d3,-(sp)
    jsr _g_asm_flat_addEdges
    lea 24(sp),sp

    move.l a2,-(sp)
    jsr _g_asm_solveForZ_Numerator
    addq.l #4,sp
    move.l d0,d7

    move.l _g_rcfState_ptr,a6
    move.l 40(a6),a0
    move.l _g_asm_columnBot,a1
    move.l (a1),a1
    move.l _g_asm_windowMinY,a4
    move.l (a4),a4
    move.l X0(sp),d2
    move.l LEN(sp),d3

.floor_eloop:
    move.l a0,-(sp)
    move.l a1,-(sp)
    move.l a2,a0
    move.l d2,d0
    move.l d7,d1
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

.floor_in:
    move.l NEXTSEC(sp),a0
    move.l 44(a0),d0
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
    move.l d4,NCPROJ0(sp)

    move.l d0,d4
    swap d4
    move.w d4,d5
    clr.w d4
    ext.l d5
    move.l 28(a2),d1
    divs.l d1,d5:d4
    add.l 12(a6),d4
    move.l d4,NCPROJ1(sp)

    clr.l DYDC(sp)
    clr.l DYDNC(sp)
    move.l RCPLRAW(sp),d0
    tst.l d0
    beq .ceil_sdone

    move.l CPROJ1(sp),d1
    sub.l CPROJ0(sp),d1
    muls.l d0,d4:d1
    swap d4
    swap d1
    move.w d1,d4
    move.l d4,DYDC(sp)

    move.l NCPROJ1(sp),d1
    sub.l NCPROJ0(sp),d1
    muls.l d0,d4:d1
    swap d4
    swap d1
    move.w d1,d4
    move.l d4,DYDNC(sp)

.ceil_sdone:
    move.l XOFF(sp),d0
    tst.l d0
    beq .ceil_xdone

    move.l DYDC(sp),d1
    muls.l d0,d1
    add.l d1,CPROJ0(sp)

    move.l DYDNC(sp),d1
    muls.l d0,d1
    add.l d1,NCPROJ0(sp)

.ceil_xdone:
    move.l CPROJ0(sp),d0
    move.l d0,YC0(sp)
    move.l NCPROJ0(sp),d0
    move.l d0,YC1(sp)

    move.l 48(a3),a0
    tst.l a0
    beq .no_toptex
    move.l (a0),a4
    tst.l a4
    beq .no_toptex
    move.l a4,TOPTEX(sp)

    move.l NCPROJ0(sp),d0
    add.l #$8000,d0
    swap d0
    ext.l d0
    move.l _g_asm_windowMinY,a1
    move.l (a1),d1
    cmp.l d1,d0
    bge .do_top

    move.l NCPROJ1(sp),d0
    add.l #$8000,d0
    swap d0
    ext.l d0
    cmp.l d1,d0
    blt .no_toptex

.do_top:
    move.l a2,-(sp)
    jsr _g_asm_solveForZ_Numerator
    addq.l #4,sp
    move.l d0,NUM(sp)

    moveq #0,d0
    move.w 2(a4),d0
    subq.l #1,d0
    move.l _g_asm_texHeightMask,a0
    move.l d0,(a0)

    moveq #0,d0
    move.w (a4),d0
    move.l d0,TOPTEXW(sp)
    subq.l #1,d0
    move.l d0,TOPMASK(sp)

    move.l 136(a3),d0
    and.l #4,d0
    move.l d0,FLIP(sp)

    move.l 80(a3),d0
    move.l d0,TOPX(sp)
    move.l 84(a3),d0
    move.l d0,TOPZ(sp)
    move.l 68(a3),d0
    move.l d0,TOPTEXH(sp)

    moveq #0,d0
    move.b 12(a4),d0
    move.l d0,TOPLOGY(sp)
    move.l 16(a4),d0
    move.l d0,TOPIMG(sp)

    move.l _g_asm_display,a0
    move.l (a0),d0
    move.l d0,DISP(sp)
    move.l _g_rcfState_ptr,a0
    move.l 40(a0),d0
    move.l d0,DEPTH(sp)
    move.l _g_asm_columnTop,a0
    move.l (a0),d0
    move.l d0,COLTOP(sp)
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

    move.l DEPTH(sp),a4
    move.l NUM(sp),d5
    move.l WINTOP(sp),a5

    move.l X0(sp),d2
    move.l LEN(sp),d3
    tst.l d3
    ble .top_done

.top_loop:
    move.l YC0(sp),d0
    add.l #$8000,d0
    swap d0
    ext.l d0
    move.l d0,d6
    move.l d0,TOP(sp)

    move.l YC1(sp),d0
    add.l #$8000,d0
    swap d0
    ext.l d0
    move.l d0,BOT(sp)

    move.l COLTOP(sp),a0
    subq.l #1,d6
    move.l d6,(a0,d2.l*4)

    move.l (a5,d2.l*4),d0
    move.l TOP(sp),d7
    cmp.l d0,d7
    bge .top_ct
    move.l d0,d7

.top_ct:
    move.l WINBOT(sp),a1
    move.l (a1,d2.l*4),d0
    move.l BOT(sp),d1
    cmp.l d0,d1
    ble .top_cb
    move.l d0,d1

.top_cb:
    move.l d7,TOP(sp)
    move.l d1,BOT(sp)

    move.l d1,d0
    sub.l d7,d0
    addq.l #1,d0
    move.l _g_asm_yPixelCount,a1
    move.l d0,(a1)

    move.l a2,a0
    move.l d2,d0
    move.l d5,d1
    lea DXV(sp),a1
    jsr _solveForZ_asm
    move.l d0,ZVAL(sp)

    move.l d0,(a4,d2.l*4)

    tst.b 20(a2)
    beq .top_u_dzdx

.top_u_dxdz:
    sub.l Z0(sp),d0
    move.l 44(a2),d1
    muls.l d1,d4:d0
    swap d4
    swap d0
    move.w d0,d4
    add.l 32(a2),d4
    add.l TOPX(sp),d4
    move.l d4,DXV(sp)
    bra .top_u_done

.top_u_dzdx:
    move.l DXV(sp),d0
    move.l 44(a2),d1
    muls.l d1,d4:d0
    swap d4
    swap d0
    move.w d0,d4
    add.l 32(a2),d4
    add.l TOPX(sp),d4
    move.l d4,DXV(sp)

.top_u_done:
    move.l _g_asm_yPixelCount,a0
    move.l (a0),d0
    ble .top_next

    move.l DXV(sp),d0
    swap d0
    and.l TOPMASK(sp),d0
    move.l FLIP(sp),d1
    tst.l d1
    beq .top_nf
    move.l TOPTEXW(sp),d1
    sub.l d0,d1
    subq.l #1,d1
    move.l d1,d0

.top_nf:
    move.l d0,TEXU(sp)

    move.l YC1(sp),d1
    move.l YC0(sp),d0
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
    move.l YC1(sp),d1
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
    move.l TOPLOGY(sp),d1
    lsl.l d1,d0
    move.l TOPIMG(sp),a0
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
    beq .top_fb
    jsr _g_asm_drawColumn_Lit
    bra .top_next

.top_fb:
    jsr _g_asm_drawColumn_Fullbright

.top_next:
    move.l DYDC(sp),d0
    add.l d0,YC0(sp)
    move.l DYDNC(sp),d0
    add.l d0,YC1(sp)
    addq.l #1,d2
    subq.l #1,d3
    bgt .top_loop

.top_done:
    bra .bot_setup

.no_toptex:
    move.l _g_asm_windowMinY,a0
    move.l (a0),d0
    subq.l #1,d0
    move.l _g_asm_columnTop,a1
    move.l (a1),a1
    move.l X0(sp),d2
    move.l LEN(sp),d3

.notop_fill:
    move.l d0,(a1,d2.l*4)
    addq.l #1,d2
    subq.l #1,d3
    bgt .notop_fill

.bot_setup:
    move.l _g_rcfState_ptr,a6
    move.l NEXTSEC(sp),a0
    move.l 40(a0),d0
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
    move.l d4,NFPROJ0(sp)

    move.l d0,d4
    swap d4
    move.w d4,d5
    clr.w d4
    ext.l d5
    move.l 28(a2),d1
    divs.l d1,d5:d4
    add.l 12(a6),d4
    move.l d4,NFPROJ1(sp)

    clr.l DYDNF(sp)
    clr.l DYDF(sp)
    move.l RCPLRAW(sp),d0
    tst.l d0
    ble .floor_sdone

    move.l NFPROJ1(sp),d1
    sub.l NFPROJ0(sp),d1
    muls.l d0,d4:d1
    swap d4
    swap d1
    move.w d1,d4
    move.l d4,DYDNF(sp)

    move.l FPROJ1(sp),d1
    sub.l FPROJ0(sp),d1
    muls.l d0,d4:d1
    swap d4
    swap d1
    move.w d1,d4
    move.l d4,DYDF(sp)

.floor_sdone:
    move.l XOFF(sp),d0
    tst.l d0
    beq .floor_xdone

    move.l DYDNF(sp),d1
    muls.l d0,d1
    add.l d1,NFPROJ0(sp)

    move.l DYDF(sp),d1
    muls.l d0,d1
    add.l d1,FPROJ0(sp)

.floor_xdone:
    move.l NFPROJ0(sp),d0
    move.l d0,YF0(sp)
    move.l FPROJ0(sp),d0
    move.l d0,YF1(sp)

    move.l 56(a3),a0
    tst.l a0
    beq .no_bottex
    move.l (a0),a4
    tst.l a4
    beq .no_bottex
    move.l a4,BOTTEX(sp)

    move.l NFPROJ0(sp),d0
    add.l #$8000,d0
    swap d0
    ext.l d0
    move.l _g_asm_windowMaxY,a1
    move.l (a1),d1
    cmp.l d1,d0
    ble .do_bot

    move.l NFPROJ1(sp),d0
    add.l #$8000,d0
    swap d0
    ext.l d0
    cmp.l d1,d0
    bgt .no_bottex

.do_bot:
    move.l a2,-(sp)
    jsr _g_asm_solveForZ_Numerator
    addq.l #4,sp
    move.l d0,NUM(sp)

    moveq #0,d0
    move.w 2(a4),d0
    subq.l #1,d0
    move.l _g_asm_texHeightMask,a0
    move.l d0,(a0)

    moveq #0,d0
    move.w (a4),d0
    move.l d0,BOTTEXW(sp)
    subq.l #1,d0
    move.l d0,BOTMASK(sp)

    move.l 136(a3),d0
    and.l #4,d0
    move.l d0,FLIP(sp)

    move.l 96(a3),d0
    move.l d0,BOTX(sp)
    move.l 100(a3),d0
    move.l d0,BOTZ(sp)
    move.l 76(a3),d0
    move.l d0,BOTTEXH(sp)

    moveq #0,d0
    move.b 12(a4),d0
    move.l d0,BOTLOGY(sp)
    move.l 16(a4),d0
    move.l d0,BOTIMG(sp)

    pea SLIT(sp)
    pea SFB+4(sp)
    pea SU1+8(sp)
    pea SU0+12(sp)
    move.l a3,-(sp)
    jsr _g_asm_setupSignTexture
    lea 20(sp),sp
    move.l d0,SIGNTEX(sp)

    move.l _g_asm_display,a0
    move.l (a0),d0
    move.l d0,DISP(sp)
    move.l _g_rcfState_ptr,a0
    move.l 40(a0),d0
    move.l d0,DEPTH(sp)
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

    move.l DEPTH(sp),a4

    move.l X0(sp),d2
    move.l LEN(sp),d3
    tst.l d3
    ble .bot_done

.bot_loop:
    move.l YF0(sp),d0
    add.l #$8000,d0
    swap d0
    ext.l d0
    move.l d0,TOP(sp)

    move.l YF1(sp),d0
    add.l #$8000,d0
    swap d0
    ext.l d0
    move.l d0,BOT(sp)

    move.l COLBOT(sp),a0
    move.l BOT(sp),d7
    addq.l #1,d7
    move.l d7,(a0,d2.l*4)

    move.l WINTOP(sp),a0
    move.l WINBOT(sp),a1
    move.l (a0,d2.l*4),d0
    move.l TOP(sp),d7
    cmp.l d0,d7
    bge .bot_ct
    move.l d0,d7

.bot_ct:
    move.l (a1,d2.l*4),d0
    move.l BOT(sp),d1
    cmp.l d0,d1
    ble .bot_cb
    move.l d0,d1

.bot_cb:
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

    move.l d0,(a4,d2.l*4)

    tst.b 20(a2)
    beq .bot_u_dzdx

.bot_u_dxdz:
    sub.l Z0(sp),d0
    move.l 44(a2),d1
    muls.l d1,d4:d0
    swap d4
    swap d0
    move.w d0,d4
    add.l 32(a2),d4
    add.l BOTX(sp),d4
    move.l d4,DXV(sp)
    bra .bot_u_done

.bot_u_dzdx:
    move.l DXV(sp),d0
    move.l 44(a2),d1
    muls.l d1,d4:d0
    swap d4
    swap d0
    move.w d0,d4
    add.l 32(a2),d4
    add.l BOTX(sp),d4
    move.l d4,DXV(sp)

.bot_u_done:
    move.l _g_asm_yPixelCount,a0
    move.l (a0),d0
    ble .bot_next

    move.l DXV(sp),d0
    swap d0
    and.l BOTMASK(sp),d0
    move.l FLIP(sp),d1
    tst.l d1
    beq .bot_nf
    move.l BOTTEXW(sp),d1
    sub.l d0,d1
    subq.l #1,d1
    move.l d1,d0

.bot_nf:
    move.l d0,TEXU(sp)

    move.l YF1(sp),d1
    move.l YF0(sp),d0
    sub.l d0,d1
    add.l #$10000,d1
    move.l BOTTEXH(sp),d0
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
    move.l YF1(sp),d1
    sub.l d0,d1
    add.l #$8000,d1
    move.l VCS(sp),d0
    muls.l d1,d6:d0
    swap d6
    swap d0
    move.w d0,d6
    add.l BOTZ(sp),d6
    move.l _g_asm_vCoordFixed,a0
    move.l d6,(a0)

    move.l TEXU(sp),d0
    move.l BOTLOGY(sp),d1
    lsl.l d1,d0
    move.l BOTIMG(sp),a0
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
    beq .bot_fb
    jsr _g_asm_drawColumn_Lit
    bra .bot_sign

.bot_fb:
    jsr _g_asm_drawColumn_Fullbright

.bot_sign:
    move.l SIGNTEX(sp),a5
    tst.l a5
    beq .bot_next

    move.l DXV(sp),d0
    move.l SU0(sp),d1
    cmp.l d1,d0
    blt .bot_next
    move.l SU1(sp),d1
    cmp.l d1,d0
    bgt .bot_next

    move.l VCS(sp),d1
    moveq #1,d4
    moveq #0,d5
    divs.l d1,d4:d5

    move.l 108(a3),d0
    muls.l d5,d4:d0
    swap d4
    swap d0
    move.w d0,d4
    move.l YF1(sp),d0
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
    ble .bot_next

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

.bot_next:
    move.l DYDF(sp),d0
    add.l d0,YF1(sp)
    move.l DYDNF(sp),d0
    add.l d0,YF0(sp)
    addq.l #1,d2
    subq.l #1,d3
    bgt .bot_loop

.bot_done:
    bra .flat_edges

.no_bottex:
    move.l _g_asm_windowMaxY,a0
    move.l (a0),d0
    addq.l #1,d0
    move.l _g_asm_columnBot,a1
    move.l (a1),a1
    move.l X0(sp),d2
    move.l LEN(sp),d3

.nobot_fill:
    move.l d0,(a1,d2.l*4)
    addq.l #1,d2
    subq.l #1,d3
    bgt .nobot_fill

.flat_edges:
    move.l X0(sp),d2
    move.l LEN(sp),d3
    move.l CPROJ0(sp),d0
    move.l DYDC(sp),d1
    move.l FPROJ0(sp),d4
    move.l DYDF(sp),d5
    move.l d0,-(sp)
    move.l d1,-(sp)
    move.l d4,-(sp)
    move.l d5,-(sp)
    move.l d2,-(sp)
    move.l d3,-(sp)
    jsr _g_asm_flat_addEdges
    lea 24(sp),sp

    move.l _g_rcfState_ptr,a6

    move.l NFPROJ0(sp),d0
    add.l #$8000,d0
    swap d0
    ext.l d0
    move.l _g_asm_windowMinY,a1
    move.l (a1),d1
    cmp.l d1,d0
    bgt .adj_ceil_check
    move.l NFPROJ1(sp),d0
    add.l #$8000,d0
    swap d0
    ext.l d0
    cmp.l d1,d0
    ble .adj_skip

.adj_ceil_check:
    move.l NCPROJ0(sp),d0
    add.l #$8000,d0
    swap d0
    ext.l d0
    move.l _g_asm_windowMaxY,a1
    move.l (a1),d1
    cmp.l d1,d0
    blt .adj_floor_check
    move.l NCPROJ1(sp),d0
    add.l #$8000,d0
    swap d0
    ext.l d0
    cmp.l d1,d0
    bge .adj_skip

.adj_floor_check:
    move.l NEXTSEC(sp),a0
    move.l 40(a0),d0
    move.l 44(a0),d1
    cmp.l d1,d0
    ble .adj_skip

    move.l X0(sp),d2
    move.l LEN(sp),d3
    move.l DYDNF(sp),d0
    move.l NFPROJ0(sp),d1
    sub.l #$10000,d1
    move.l DYDNC(sp),d4
    move.l NCPROJ0(sp),d5
    add.l #$10000,d5
    move.l a2,-(sp)
    move.l d5,-(sp)
    move.l d4,-(sp)
    move.l d1,-(sp)
    move.l d0,-(sp)
    move.l d2,-(sp)
    move.l d3,-(sp)
    jsr _g_asm_wall_addAdjoinSegment
    lea 28(sp),sp

.adj_skip:
    moveq #-1,d0
    move.l d0,4(a3)

.return:
    lea FRAMESZ(sp),sp
    movem.l (sp)+,d2-d7/a2-a6
    rts
