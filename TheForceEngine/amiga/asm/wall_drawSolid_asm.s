;
; TheForceEngine - Amiga port
;
; 68020+
;

    section .text,code

    XDEF _wall_drawSolid_asm
    XDEF wall_drawSolid_asm

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
    XREF _g_asm_windowMaxY
    XREF _g_asm_solveForZ_Numerator
    XREF _g_asm_drawColumn_Lit
    XREF _g_asm_drawColumn_Fullbright
    XREF _g_asm_computeLighting
    XREF _g_asm_flat_addEdges
    XREF _g_asm_setupSignTexture
    XREF _solveForZ_asm

SW = 320

Z0 = 0
NUM = 4
TEXW = 8
FLIP = 12
SU0 = 16
SU1 = 20
SFB = 24
SLIT = 28
DISP = 32
USCL = 36
UC0 = 40
DYDT = 44
DYDB = 48
Y0C = 52
Y0F = 56
DXV = 60
ZVAL = 64
TOP = 68
BOT = 72
VCS = 76
TEXU = 80
SYT = 84
DEPTH = 88
COLBOT = 92
COLTOP = 96
WINTOP = 100
WINBOT = 104
WLIGHT = 108
TEXMASK = 112
MTEXH = 116
MOFFZ = 120
LOGY = 124
TEXIMG = 128
FRAMESZ = 132

_wall_drawSolid_asm:
wall_drawSolid_asm:
    movem.l d2-d7/a2-a6,-(sp)
    lea -FRAMESZ(sp),sp

    move.l a0,a2
    move.l _g_rcfState_ptr,a6

    move.l (a2),a3
    move.l 12(a3),a0
    move.l 44(a0),d0
    move.l 40(a0),d1
    move.l 32(a6),d2
    sub.l d2,d0
    sub.l d2,d1

    move.l 24(a2),d2
    move.l 28(a2),d3
    move.l d2,Z0(sp)

    move.l 52(a3),a0
    tst.l a0
    beq .return
    move.l (a0),a4
    tst.l a4
    beq .return

    move.l 28(a6),d4
    muls.l d4,d0
    muls.l d4,d1

    moveq #1,d4
    moveq #0,d5
    divs.l d2,d4:d5

    moveq #1,d4
    moveq #0,d6
    divs.l d3,d4:d6

    move.l 12(a6),d3

    move.l d0,d2
    muls.l d5,d4:d0
    swap d4
    swap d0
    move.w d0,d4
    add.l d3,d4
    move.l d4,Y0C(sp)

    muls.l d6,d4:d2
    swap d4
    swap d2
    move.w d2,d4
    add.l d3,d4
    move.l d4,DXV(sp)

    move.l d1,d2
    muls.l d5,d4:d1
    swap d4
    swap d1
    move.w d1,d4
    add.l d3,d4
    move.l d4,Y0F(sp)

    muls.l d6,d4:d2
    swap d4
    swap d2
    move.w d2,d4
    add.l d3,d4
    move.l d4,ZVAL(sp)

    move.l Y0C(sp),d0
    add.l #$8000,d0
    swap d0
    ext.l d0
    move.l d0,TOP(sp)

    move.l DXV(sp),d0
    add.l #$8000,d0
    swap d0
    ext.l d0
    move.l d0,BOT(sp)

    move.l 12(a2),d2
    move.l 16(a2),d3
    sub.l d2,d3
    addq.l #1,d3

    move.l a2,-(sp)
    jsr _g_asm_solveForZ_Numerator
    addq.l #4,sp
    move.l d0,NUM(sp)

    move.l _g_asm_windowMaxY,a0
    move.l (a0),d0
    move.l TOP(sp),d4
    cmp.l d0,d4
    ble .no_early
    move.l BOT(sp),d4
    cmp.l d0,d4
    ble .no_early

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

    move.l 40(a6),a0
    move.l _g_asm_columnTop,a1
    move.l (a1),a1
    move.l _g_asm_windowMaxY,a4
    move.l (a4),a4

.early_loop:
    move.l a0,d4
    move.l a1,d5
    move.l a2,a0
    move.l d2,d0
    move.l NUM(sp),d1
    suba.l a1,a1
    jsr _solveForZ_asm
    move.l d4,a0
    move.l d5,a1
    move.l d0,(a0,d2.l*4)
    move.l a4,(a1,d2.l*4)
    addq.l #1,d2
    subq.l #1,d3
    bgt .early_loop

    moveq #0,d0
    move.l d0,8(a3)
    bra .return

.no_early:
    moveq #0,d0
    move.w 2(a4),d0
    subq.l #1,d0
    move.l _g_asm_texHeightMask,a0
    move.l d0,(a0)

    pea SLIT(sp)
    pea SFB+4(sp)
    pea SU1+8(sp)
    pea SU0+12(sp)
    move.l a3,-(sp)
    jsr _g_asm_setupSignTexture
    lea 20(sp),sp
    move.l d0,a5

    move.l 8(a2),d0
    move.l 4(a2),d1
    sub.l d1,d0
    beq .slopes_zero

    move.l #$10000,d1
    divs.l d0,d1

    move.l DXV(sp),d0
    sub.l Y0C(sp),d0
    muls.l d1,d4:d0
    swap d4
    swap d0
    move.w d0,d4
    move.l d4,DYDT(sp)

    move.l ZVAL(sp),d0
    sub.l Y0F(sp),d0
    muls.l d1,d4:d0
    swap d4
    swap d0
    move.w d0,d4
    move.l d4,DYDB(sp)
    bra .slopes_done

.slopes_zero:
    moveq #0,d0
    move.l d0,DYDT(sp)
    move.l d0,DYDB(sp)

.slopes_done:
    move.l 12(a2),d0
    move.l 4(a2),d1
    sub.l d1,d0
    beq .no_clip

    move.l DYDT(sp),d1
    muls.l d0,d1
    add.l d1,Y0C(sp)
    move.l DYDB(sp),d1
    muls.l d0,d1
    add.l d1,Y0F(sp)

.no_clip:
    move.l Y0C(sp),d0
    move.l Y0F(sp),d1
    move.l DYDT(sp),d4
    move.l DYDB(sp),d5
    move.l d0,-(sp)
    move.l d4,-(sp)
    move.l d1,-(sp)
    move.l d5,-(sp)
    move.l 12(a2),-(sp)
    move.l d3,-(sp)
    jsr _g_asm_flat_addEdges
    lea 24(sp),sp

    moveq #0,d0
    move.w (a4),d0
    move.l d0,TEXW(sp)
    subq.l #1,d0
    move.l d0,TEXMASK(sp)

    move.l 136(a3),d0
    and.l #4,d0
    move.l d0,FLIP(sp)

    move.l 44(a2),d0
    move.l d0,USCL(sp)
    move.l 32(a2),d0
    add.l 88(a3),d0
    move.l d0,UC0(sp)

    move.l _g_asm_display,a0
    move.l (a0),d0
    move.l d0,DISP(sp)

    move.l 40(a6),d0
    move.l d0,DEPTH(sp)
    move.l _g_asm_columnBot,a0
    move.l (a0),d0
    move.l d0,COLBOT(sp)
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

    move.l 72(a3),d0
    move.l d0,MTEXH(sp)
    move.l 92(a3),d0
    move.l d0,MOFFZ(sp)
    moveq #0,d0
    move.b 12(a4),d0
    move.l d0,LOGY(sp)
    move.l 16(a4),d0
    move.l d0,TEXIMG(sp)

    move.l _g_asm_columnLight,a6

    move.l Y0C(sp),d6
    move.l Y0F(sp),d7

    tst.b 20(a2)
    beq .loop_dz

.loop_dx:
    move.l d6,d4
    add.l #$8000,d4
    swap d4
    ext.l d4
    move.l d7,d5
    add.l #$8000,d5
    swap d5
    ext.l d5
    move.l d4,TOP(sp)
    move.l d5,BOT(sp)

    move.l COLBOT(sp),a0
    move.l COLTOP(sp),a1
    addq.l #1,d5
    move.l d5,(a0,d2.l*4)
    subq.l #1,d4
    move.l d4,(a1,d2.l*4)

    move.l WINTOP(sp),a0
    move.l WINBOT(sp),a1
    move.l (a0,d2.l*4),d1
    move.l TOP(sp),d4
    cmp.l d1,d4
    bge .dx_ct
    move.l d1,d4

.dx_ct:
    move.l (a1,d2.l*4),d1
    move.l BOT(sp),d5
    cmp.l d1,d5
    ble .dx_cb
    move.l d1,d5

.dx_cb:
    move.l d4,TOP(sp)
    move.l d5,BOT(sp)

    move.l d5,d0
    sub.l d4,d0
    addq.l #1,d0
    move.l _g_asm_yPixelCount,a1
    move.l d0,(a1)
    move.l d0,d5

    move.l a2,a0
    move.l d2,d0
    move.l NUM(sp),d1
    lea DXV(sp),a1
    jsr _solveForZ_asm
    move.l d0,ZVAL(sp)

    move.l DEPTH(sp),a0
    move.l d0,(a0,d2.l*4)

    sub.l Z0(sp),d0
    move.l USCL(sp),d1
    muls.l d1,d4:d0
    swap d4
    swap d0
    move.w d0,d4
    add.l UC0(sp),d4
    move.l d4,DXV(sp)

    move.l d5,d0
    ble .next_dx
    bra .col_body

.loop_dz:
    move.l d6,d4
    add.l #$8000,d4
    swap d4
    ext.l d4
    move.l d7,d5
    add.l #$8000,d5
    swap d5
    ext.l d5
    move.l d4,TOP(sp)
    move.l d5,BOT(sp)

    move.l COLBOT(sp),a0
    move.l COLTOP(sp),a1
    addq.l #1,d5
    move.l d5,(a0,d2.l*4)
    subq.l #1,d4
    move.l d4,(a1,d2.l*4)

    move.l WINTOP(sp),a0
    move.l WINBOT(sp),a1
    move.l (a0,d2.l*4),d1
    move.l TOP(sp),d4
    cmp.l d1,d4
    bge .dz_ct
    move.l d1,d4

.dz_ct:
    move.l (a1,d2.l*4),d1
    move.l BOT(sp),d5
    cmp.l d1,d5
    ble .dz_cb
    move.l d1,d5

.dz_cb:
    move.l d4,TOP(sp)
    move.l d5,BOT(sp)

    move.l d5,d0
    sub.l d4,d0
    addq.l #1,d0
    move.l _g_asm_yPixelCount,a1
    move.l d0,(a1)
    move.l d0,d5

    move.l a2,a0
    move.l d2,d0
    move.l NUM(sp),d1
    lea DXV(sp),a1
    jsr _solveForZ_asm
    move.l d0,ZVAL(sp)

    move.l DEPTH(sp),a0
    move.l d0,(a0,d2.l*4)

    move.l DXV(sp),d0
    move.l USCL(sp),d1
    muls.l d1,d4:d0
    swap d4
    swap d0
    move.w d0,d4
    add.l UC0(sp),d4
    move.l d4,DXV(sp)

    move.l d5,d0
    ble .next_dz
    bra .col_body

.col_body:
    move.l DXV(sp),d0
    swap d0
    and.l TEXMASK(sp),d0
    move.l FLIP(sp),d1
    tst.l d1
    beq .cb_nf
    move.l TEXW(sp),d1
    sub.l d0,d1
    subq.l #1,d1
    move.l d1,d0

.cb_nf:
    move.l d0,TEXU(sp)

    move.l d7,d1
    sub.l d6,d1
    add.l #$10000,d1
    move.l MTEXH(sp),d0
    move.l d0,d4
    swap d0
    clr.w d0
    swap d4
    ext.l d4
    divs.l d1,d4:d0
    move.l d0,VCS(sp)
    move.l _g_asm_vCoordStep,a0
    move.l d0,(a0)

    move.l BOT(sp),d0
    swap d0
    clr.w d0
    move.l d7,d1
    sub.l d0,d1
    add.l #$8000,d1
    move.l VCS(sp),d0
    muls.l d1,d4:d0
    swap d4
    swap d0
    move.w d0,d4

    add.l MOFFZ(sp),d4
    move.l _g_asm_vCoordFixed,a0
    move.l d4,(a0)

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
    move.l d1,d4
    lsl.l #8,d1
    lsl.l #6,d4
    add.l d4,d1
    add.l d2,d1
    move.l DISP(sp),a0
    add.l d1,a0
    move.l _g_asm_columnOut,a1
    move.l a0,(a1)

    tst.l d0
    beq .cb_fb
    jsr _g_asm_drawColumn_Lit
    bra .cb_sign

.cb_fb:
    jsr _g_asm_drawColumn_Fullbright

.cb_sign:
    tst.l a5
    beq .cb_done

    move.l DXV(sp),d0
    move.l SU0(sp),d1
    cmp.l d1,d0
    blt .cb_done
    move.l SU1(sp),d1
    cmp.l d1,d0
    bgt .cb_done

    move.l VCS(sp),d1
    moveq #1,d4
    moveq #0,d5
    divs.l d1,d4:d5

    move.l 108(a3),d0
    muls.l d5,d4:d0
    swap d4
    swap d0
    move.w d0,d4
    move.l d7,d0
    add.l d0,d4
    move.l d4,ZVAL(sp)

    move.w 2(a5),d0
    swap d0
    clr.w d0
    muls.l d5,d4:d0
    swap d4
    swap d0
    move.w d0,d4
    move.l ZVAL(sp),d0
    sub.l d4,d0
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
    move.l _g_asm_yPixelCount,a0
    move.l d0,(a0)
    ble .cb_done

    move.l BOT(sp),d0
    swap d0
    clr.w d0
    move.l ZVAL(sp),d1
    sub.l d0,d1
    add.l #$8000,d1
    move.l VCS(sp),d0
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
    sub.l SU0(sp),d0
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

.cb_done:
    tst.b 20(a2)
    beq .next_dz

.next_dx:
    move.l DYDT(sp),d0
    add.l d0,d6
    move.l DYDB(sp),d0
    add.l d0,d7
    addq.l #1,d2
    subq.l #1,d3
    ble .done
    bra .loop_dx

.next_dz:
    move.l DYDT(sp),d0
    add.l d0,d6
    move.l DYDB(sp),d0
    add.l d0,d7
    addq.l #1,d2
    subq.l #1,d3
    ble .done
    bra .loop_dz

.done:
    moveq #-1,d0
    move.l d0,4(a3)

.return:
    lea FRAMESZ(sp),sp
    movem.l (sp)+,d2-d7/a2-a6
    rts
