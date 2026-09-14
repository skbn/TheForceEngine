;
; TheForceEngine - Amiga port
;
; 68020+
;

    section .text,code

    XDEF _wall_drawTransparent_asm
    XDEF wall_drawTransparent_asm

    XREF _g_rcfState_ptr
    XREF _g_asm_texHeightMask
    XREF _g_asm_yPixelCount
    XREF _g_asm_vCoordStep
    XREF _g_asm_vCoordFixed
    XREF _g_asm_columnLight
    XREF _g_asm_texImage
    XREF _g_asm_columnOut
    XREF _g_asm_windowTop
    XREF _g_asm_windowBot
    XREF _g_asm_display
    XREF _g_asm_solveForZ_Numerator
    XREF _g_asm_drawColumn_Lit_Trans
    XREF _g_asm_drawColumn_Fullbright_Trans
    XREF _g_asm_computeLighting
    XREF _solveForZ_asm

SW = 320

Z0 = 0
NUM = 4
TEXW = 8
FLIP = 12
USCL = 16
UC0 = 20
DISP = 24
DEPTH = 28
WINTOP = 32
WINBOT = 36
Y0C = 40
Y0F = 44
DYDT = 48
DYDB = 52
DXV = 56
ZVAL = 60
TOP = 64
BOT = 68
VCS = 72
TEXU = 76
WLIGHT = 80
TEXMASK = 84
MTEXH = 88
MOFFZ = 92
LOGY = 96
TEXIMG = 100
FRAMESZ = 104

_wall_drawTransparent_asm:
wall_drawTransparent_asm:
    movem.l d2-d7/a2-a6,-(sp)
    lea -FRAMESZ(sp),sp

    move.l a0,a2
    move.l a1,a5
    move.l _g_rcfState_ptr,a6

    move.l (a2),a3
    move.l 52(a3),a0
    move.l (a0),a4
    tst.l a4
    beq .return

    move.l 24(a2),d0
    move.l d0,Z0(sp)

    move.l (a5),d0
    move.l d0,Y0C(sp)
    move.l 12(a5),d0
    move.l d0,Y0F(sp)
    move.l 8(a5),d0
    move.l d0,DYDT(sp)
    move.l 20(a5),d0
    move.l d0,DYDB(sp)

    move.l 44(a2),d0
    move.l d0,USCL(sp)
    move.l 32(a2),d0
    add.l 88(a3),d0
    move.l d0,UC0(sp)

    move.l 40(a5),d3
    move.l 44(a5),d2

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

    move.l 72(a3),d0
    move.l d0,MTEXH(sp)
    move.l 92(a3),d0
    move.l d0,MOFFZ(sp)
    moveq #0,d0
    move.b 12(a4),d0
    move.l d0,LOGY(sp)
    move.l 16(a4),d0
    move.l d0,TEXIMG(sp)

    move.l a2,-(sp)
    jsr _g_asm_solveForZ_Numerator
    addq.l #4,sp
    move.l d0,NUM(sp)

    move.l _g_asm_display,a0
    move.l (a0),d0
    move.l d0,DISP(sp)
    move.l 40(a6),d0
    move.l d0,DEPTH(sp)
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

    move.l WINTOP(sp),a0
    move.l WINBOT(sp),a1
    move.l (a0,d2.l*4),d0
    cmp.l d0,d4
    bge .dx_ct
    move.l d0,d4

.dx_ct:
    move.l (a1,d2.l*4),d0
    cmp.l d0,d5
    ble .dx_cb
    move.l d0,d5

.dx_cb:
    move.l d4,TOP(sp)
    move.l d5,BOT(sp)

    move.l d5,d0
    sub.l d4,d0
    addq.l #1,d0
    move.l _g_asm_yPixelCount,a1
    move.l d0,(a1)
    ble .next_dx

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

    move.l WINTOP(sp),a0
    move.l WINBOT(sp),a1
    move.l (a0,d2.l*4),d0
    cmp.l d0,d4
    bge .dz_ct
    move.l d0,d4

.dz_ct:
    move.l (a1,d2.l*4),d0
    cmp.l d0,d5
    ble .dz_cb
    move.l d0,d5

.dz_cb:
    move.l d4,TOP(sp)
    move.l d5,BOT(sp)

    move.l d5,d0
    sub.l d4,d0
    addq.l #1,d0
    move.l _g_asm_yPixelCount,a1
    move.l d0,(a1)
    ble .next_dz

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
    jsr _g_asm_drawColumn_Lit_Trans
    bra .next_check

.cb_fb:
    jsr _g_asm_drawColumn_Fullbright_Trans

.next_check:
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
.return:
    lea FRAMESZ(sp),sp
    movem.l (sp)+,d2-d7/a2-a6
    rts
