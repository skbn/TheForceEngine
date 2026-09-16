;
; TheForceEngine - Amiga port
; 68020+
;

    section .text,code

    XDEF _wall_process_asm
    XDEF wall_process_asm

    XREF _g_rcfState_ptr
    XREF __ZN8TFE_Jedi19s_minScreenX_PixelsE
    XREF __ZN8TFE_Jedi19s_maxScreenX_PixelsE
    XREF __ZN8TFE_Jedi10s_nextWallE

W_VISIBLE = 8
W_V0 = 40
W_V1 = 44
W_TEXLEN = 64

WS_SRCW = 0
WS_X0RAW = 4
WS_X1RAW = 8
WS_X0 = 12
WS_X1 = 16
WS_ORIENT = 20
WS_Z0 = 24
WS_Z1 = 28
WS_UCOORD = 32
WS_X0VIEW = 36
WS_SLOPE = 40
WS_USCALE = 44

RS_HALFH = 4
RS_PROJX = 8
RS_FOCAL = 24
RS_WALLSEG = 304812

ONE_16 = $10000
HALF_16 = $8000
MAX_SEG = 384

F_CURU = 0
F_TEXLEN = 4
F_TEXREM = 8
F_CLIPL = 12
F_CLIPR = 16
F_CLIPX0N = 20
F_CLIPX1N = 24
F_X0PIX = 28
F_X1PIX = 32
F_T1 = 36
F_T2 = 40
F_T3 = 44
F_T4 = 48
F_T5 = 52
F_T6 = 56
FRAMESZ = 60

_wall_process_asm:
wall_process_asm:
    movem.l d2-d7/a2-a6,-(sp)
    lea -FRAMESZ(sp),sp

    move.l a0,a2
    move.l _g_rcfState_ptr,a3

    move.l W_V0(a2),a0
    move.l W_V1(a2),a1
    move.l (a0),d2
    move.l 4(a0),d3
    move.l (a1),d4
    move.l 4(a1),d5

    tst.l d3
    bge .z0ok
    tst.l d5
    bge .z0ok
    bra .cull

.z0ok:
    move.l d3,d0
    neg.l d0
    cmp.l d0,d2
    bge .chk_right
    move.l d5,d0
    neg.l d0
    cmp.l d0,d4
    bge .chk_right
    bra .cull

.chk_right:
    cmp.l d3,d2
    ble .view_ok
    cmp.l d5,d4
    ble .view_ok
    bra .cull

.view_ok:
    move.l d4,d6
    sub.l d2,d6
    move.l d5,d7
    sub.l d3,d7

    move.l d3,d0
    muls.l d6,d1:d0
    move.w d1,d0
    swap d0
    move.l d0,a5
    move.l d2,d0
    muls.l d7,d1:d0
    move.w d1,d0
    swap d0
    sub.l d0,a5
    tst.l a5
    bmi .cull

    moveq #0,d0
    move.l d0,F_CURU(sp)
    move.l d0,F_CLIPL(sp)
    move.l d0,F_CLIPR(sp)
    move.l d0,F_CLIPX0N(sp)
    move.l d0,F_CLIPX1N(sp)

    move.l W_TEXLEN(a2),d0
    move.l d0,F_TEXLEN(sp)
    move.l d0,F_TEXREM(sp)

    move.l d3,d0
    neg.l d0
    cmp.l d0,d2
    bge .clip_left_done

    move.l d2,d0
    muls.l d5,d1:d0
    move.w d1,d0
    swap d0
    move.l d0,a5
    move.l d3,d0
    muls.l d4,d1:d0
    move.w d1,d0
    swap d0
    sub.l d0,a5

    move.l d7,d0
    neg.l d0
    sub.l d6,d0
    beq .left_xz_done
    move.l d0,F_T1(sp)
    move.l a5,d0
    swap d0
    move.w d0,d1
    clr.w d0
    ext.l d1
    divs.l (F_T1,sp),d1:d0
    move.l d0,a5

.left_xz_done:
    suba.l a6,a6
    tst.l d7
    beq .left_s_chkdx
    move.l d7,d0
    tst.l d0
    bpl .left_abs_dz
    neg.l d0

.left_abs_dz:
    move.l d6,d1
    tst.l d1
    bpl .left_abs_dx
    neg.l d1

.left_abs_dx:
    cmp.l d1,d0
    ble .left_s_chkdx
    move.l a5,d0
    sub.l d3,d0
    swap d0
    move.w d0,d1
    clr.w d0
    ext.l d1
    divs.l d7,d1:d0
    move.l d0,a6
    bra .left_s_done

.left_s_chkdx:
    tst.l d6
    beq .left_s_done
    move.l a5,d0
    neg.l d0
    sub.l d2,d0
    swap d0
    move.w d0,d1
    clr.w d0
    ext.l d1
    divs.l d6,d1:d0
    move.l d0,a6

.left_s_done:
    move.l a5,d0
    neg.l d0
    move.l d0,d2
    move.l a5,d3

    tst.l a6
    beq .left_no_u
    move.l a6,d1
    move.l F_TEXREM(sp),d0
    muls.l d1,d1:d0
    move.w d1,d0
    swap d0
    add.l d0,F_CURU(sp)
    move.l F_TEXLEN(sp),d0
    sub.l F_CURU(sp),d0
    move.l d0,F_TEXREM(sp)

.left_no_u:
    moveq #-1,d0
    move.l d0,F_CLIPL(sp)
    move.l d4,d6
    sub.l d2,d6
    move.l d5,d7
    sub.l d3,d7

.clip_left_done:
    cmp.l d5,d4
    ble .clip_right_done

    move.l d2,d0
    muls.l d5,d1:d0
    move.w d1,d0
    swap d0
    move.l d0,a5
    move.l d3,d0
    muls.l d4,d1:d0
    move.w d1,d0
    swap d0
    sub.l d0,a5
    move.l d7,d0
    sub.l d6,d0
    beq .right_xz_done
    move.l d0,F_T1(sp)
    move.l a5,d0
    swap d0
    move.w d0,d1
    clr.w d0
    ext.l d1
    divs.l (F_T1,sp),d1:d0
    move.l d0,a5

.right_xz_done:
    suba.l a6,a6
    tst.l d7
    beq .right_s_chkdx
    move.l d7,d0
    tst.l d0
    bpl .right_abs_dz
    neg.l d0

.right_abs_dz:
    move.l d6,d1
    tst.l d1
    bpl .right_abs_dx
    neg.l d1

.right_abs_dx:
    cmp.l d1,d0
    ble .right_s_chkdx
    move.l a5,d0
    sub.l d5,d0
    swap d0
    move.w d0,d1
    clr.w d0
    ext.l d1
    divs.l d7,d1:d0
    move.l d0,a6
    bra .right_s_done

.right_s_chkdx:
    tst.l d6
    beq .right_s_done
    move.l a5,d0
    sub.l d4,d0
    swap d0
    move.w d0,d1
    clr.w d0
    ext.l d1
    divs.l d6,d1:d0
    move.l d0,a6

.right_s_done:
    move.l a5,d4
    move.l a5,d5

    tst.l a6
    beq .right_no_u
    move.l a6,d1
    move.l F_TEXREM(sp),d0
    muls.l d1,d1:d0
    move.w d1,d0
    swap d0
    add.l F_TEXLEN(sp),d0
    move.l d0,F_TEXLEN(sp)
    sub.l F_CURU(sp),d0
    move.l d0,F_TEXREM(sp)

.right_no_u:
    moveq #-1,d0
    move.l d0,F_CLIPR(sp)
    move.l d4,d6
    sub.l d2,d6
    move.l d5,d7
    sub.l d3,d7

.clip_right_done:
    tst.l d3
    blt .near_chk_cross
    tst.l d5
    bge .near_clip

.near_chk_cross:
    bsr .seg_cross
    tst.l d0
    bne .cull

.near_clip:
    cmp.l #ONE_16,d3
    bge .near_z0_only
    cmp.l #ONE_16,d5
    bge .near_z0_only

    tst.l F_CLIPL(sp)
    beq .both_left_else
    moveq #-1,d0
    move.l d0,F_CLIPX0N(sp)
    moveq #-1,d2
    clr.w d2
    bra .both_right

.both_left_else:
    move.l d2,d0
    swap d0
    move.w d0,d1
    clr.w d0
    ext.l d1
    divs.l d3,d1:d0
    move.l d0,d2

.both_right:
    tst.l F_CLIPR(sp)
    beq .both_right_else
    moveq #1,d4
    swap d4
    moveq #-1,d0
    move.l d0,F_CLIPX1N(sp)
    bra .both_done

.both_right_else:
    move.l d4,d0
    swap d0
    move.w d0,d1
    clr.w d0
    ext.l d1
    divs.l d5,d1:d0
    move.l d0,d4

.both_done:
    move.l d4,d6
    sub.l d2,d6
    moveq #0,d7
    moveq #1,d3
    swap d3
    moveq #1,d5
    swap d5
    bra .project

.near_z0_only:
    cmp.l #ONE_16,d3
    bge .near_z1_only

    tst.l F_CLIPL(sp)
    beq .z0_noclip

    tst.l d7
    beq .z0_skip_div
    move.l d3,d0
    swap d0
    move.w d0,d1
    clr.w d0
    ext.l d1
    divs.l d7,d1:d0
    move.l d0,d1
    move.l d6,d0
    muls.l d1,d1:d0
    move.w d1,d0
    swap d0
    add.l d0,d2
    move.l d4,d6
    sub.l d2,d6
    move.l F_TEXLEN(sp),d0
    sub.l F_CURU(sp),d0
    move.l d0,F_TEXREM(sp)

.z0_skip_div:
    moveq #1,d3
    swap d3
    moveq #-1,d0
    move.l d0,F_CLIPX0N(sp)
    move.l d5,d7
    sub.l d3,d7
    bra .project

.z0_noclip:
    move.l d2,d0
    swap d0
    move.w d0,d1
    clr.w d0
    ext.l d1
    divs.l d3,d1:d0
    move.l d0,d2
    moveq #1,d3
    swap d3
    move.l d5,d7
    sub.l d3,d7
    sub.l d2,d6
    bra .project

.near_z1_only:
    cmp.l #ONE_16,d5
    bge .project

    tst.l F_CLIPR(sp)
    beq .z1_noclip

    tst.l d7
    beq .z1_skip_div
    moveq #1,d0
    swap d0
    sub.l d4,d0
    swap d0
    move.w d0,d1
    clr.w d0
    ext.l d1
    divs.l d7,d1:d0
    move.l d0,F_T1(sp)
    move.l d0,d1
    move.l d6,d0
    muls.l d1,d1:d0
    move.w d1,d0
    swap d0
    add.l d0,d4
    move.l F_TEXREM(sp),d0
    muls.l (F_T1,sp),d1:d0
    move.w d1,d0
    swap d0
    add.l d0,F_TEXLEN(sp)
    move.l F_TEXLEN(sp),d0
    sub.l F_CURU(sp),d0
    move.l d0,F_TEXREM(sp)
    move.l d4,d6
    sub.l d2,d6

.z1_skip_div:
    moveq #1,d5
    swap d5
    move.l d5,d7
    sub.l d3,d7
    moveq #-1,d0
    move.l d0,F_CLIPX1N(sp)
    bra .project

.z1_noclip:
    move.l d4,d0
    swap d0
    move.w d0,d1
    clr.w d0
    ext.l d1
    divs.l d5,d1:d0
    move.l d0,d4
    moveq #1,d5
    swap d5
    move.l d4,d6
    sub.l d2,d6
    move.l d5,d7
    sub.l d3,d7

.project:
    move.l RS_FOCAL(a3),d1
    move.l d2,d0
    muls.l d1,d0
    swap d0
    move.w d0,d1
    clr.w d0
    ext.l d1
    divs.l d3,d1:d0
    add.l RS_PROJX(a3),d0
    add.l #HALF_16,d0
    swap d0
    ext.l d0
    move.l d0,F_X0PIX(sp)

    move.l RS_FOCAL(a3),d1
    move.l d4,d0
    muls.l d1,d0
    swap d0
    move.w d0,d1
    clr.w d0
    ext.l d1
    divs.l d5,d1:d0
    add.l RS_PROJX(a3),d0
    add.l #HALF_16,d0
    swap d0
    ext.l d0
    subq.l #1,d0
    move.l d0,F_X1PIX(sp)

    tst.l F_CLIPX0N(sp)
    beq .adj_x1
    move.l __ZN8TFE_Jedi19s_minScreenX_PixelsE,d0
    cmp.l (F_X0PIX,sp),d0
    bge .adj_x1
    moveq #-1,d2
    clr.w d2
    moveq #1,d6
    swap d6
    add.l d4,d6
    move.l d0,F_X0PIX(sp)

.adj_x1:
    tst.l F_CLIPX1N(sp)
    beq .adj_done
    move.l __ZN8TFE_Jedi19s_maxScreenX_PixelsE,d0
    cmp.l (F_X1PIX,sp),d0
    ble .adj_done
    moveq #1,d6
    swap d6
    sub.l d2,d6
    move.l d0,F_X1PIX(sp)

.adj_done:
    move.l F_X0PIX(sp),d0
    move.l F_X1PIX(sp),d1
    cmp.l d1,d0
    bgt .cull

    move.l __ZN8TFE_Jedi19s_maxScreenX_PixelsE,d1
    cmp.l d1,d0
    bgt .cull
    move.l __ZN8TFE_Jedi19s_minScreenX_PixelsE,d1
    cmp.l (F_X1PIX,sp),d1
    bgt .cull

    move.l __ZN8TFE_Jedi10s_nextWallE,d0
    cmp.l #MAX_SEG,d0
    beq .cull

    move.l d0,d1
    addq.l #1,d1
    move.l d1,__ZN8TFE_Jedi10s_nextWallE
    move.l a3,a4
    add.l #RS_WALLSEG,a4
    move.l d0,d1
    asl.l #4,d1
    asl.l #5,d0
    add.l d1,d0
    add.l d0,a4

    move.l F_X0PIX(sp),d0
    move.l __ZN8TFE_Jedi19s_minScreenX_PixelsE,d1
    cmp.l d1,d0
    bge .x0_ok
    move.l d1,d0

.x0_ok:
    move.l F_X1PIX(sp),d1
    move.l __ZN8TFE_Jedi19s_maxScreenX_PixelsE,a5
    cmp.l a5,d1
    ble .x1_ok
    move.l a5,d1

.x1_ok:
    move.l a2,WS_SRCW(a4)
    move.l d0,WS_X0RAW(a4)
    move.l d1,WS_X1RAW(a4)
    move.l d3,WS_Z0(a4)
    move.l d5,WS_Z1(a4)
    move.l d2,WS_X0VIEW(a4)
    move.l d0,WS_X0(a4)
    move.l d1,WS_X1(a4)
    move.l F_CURU(sp),d2
    move.l d2,WS_UCOORD(a4)

    move.l d6,d0
    tst.l d0
    bpl .abs_dx2
    neg.l d0

.abs_dx2:
    move.l d7,d1
    tst.l d1
    bpl .abs_dz2
    neg.l d1

.abs_dz2:
    cmp.l d1,d0
    ble .orient_dxdz

    move.l d7,d0
    swap d0
    move.w d0,d1
    clr.w d0
    ext.l d1
    divs.l d6,d1:d0
    move.l d0,WS_SLOPE(a4)
    move.l F_TEXREM(sp),d0
    swap d0
    move.w d0,d1
    clr.w d0
    ext.l d1
    divs.l d6,d1:d0
    move.l d0,WS_USCALE(a4)
    clr.b WS_ORIENT(a4)
    bra .orient_done

.orient_dxdz:
    move.l d6,d0
    swap d0
    move.w d0,d1
    clr.w d0
    ext.l d1
    divs.l d7,d1:d0
    move.l d0,WS_SLOPE(a4)
    move.l F_TEXREM(sp),d0
    swap d0
    move.w d0,d1
    clr.w d0
    ext.l d1
    divs.l d7,d1:d0
    move.l d0,WS_USCALE(a4)
    moveq #1,d0
    move.b d0,WS_ORIENT(a4)

.orient_done:
    moveq #1,d0
    move.l d0,W_VISIBLE(a2)
    bra .epilogue

.cull:
    clr.l W_VISIBLE(a2)

.epilogue:
    lea FRAMESZ(sp),sp
    movem.l (sp)+,d2-d7/a2-a6
    rts

.seg_cross:
    lea 4(sp),a5
    move.l d2,d0
    asr.l #4,d0
    move.l d0,F_T1(a5)
    move.l d4,d0
    asr.l #4,d0
    move.l d0,F_T2(a5)
    move.l d5,d0
    asr.l #4,d0
    move.l d0,F_T3(a5)
    move.l RS_HALFH(a3),d0
    neg.l d0
    asr.l #4,d0
    move.l d0,F_T4(a5)

    move.l F_T3(a5),d0
    sub.l F_T1(a5),d0
    move.l d0,F_T3(a5)

    move.l F_T1(a5),d0
    neg.l d0
    muls.l (F_T3,a5),d1:d0
    move.w d1,d0
    swap d0
    move.l d0,F_T5(a5)

    move.l F_T2(a5),d0
    sub.l F_T1(a5),d0
    move.l d0,F_T2(a5)

    move.l F_T4(a5),d0
    sub.l F_T1(a5),d0
    muls.l (F_T2,a5),d1:d0
    move.w d1,d0
    swap d0

    move.l F_T5(a5),d1
    sub.l d0,d1
    move.l d1,F_T6(a5)

    move.l F_T1(a5),d0
    neg.l d0
    muls.l (F_T2,a5),d1:d0
    move.w d1,d0
    swap d0

    move.l F_T5(a5),d1
    sub.l d0,d1
    move.l d1,F_T2(a5)

    move.l F_T6(a5),d0
    muls.l (F_T2,a5),d1:d0
    move.w d1,d0
    swap d0

    moveq #0,d1
    tst.l d0
    ble .seg_cross_ret
    moveq #1,d1
    
.seg_cross_ret:
    move.l d1,d0
    rts
