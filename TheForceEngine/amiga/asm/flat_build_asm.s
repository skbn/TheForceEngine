    section .text,code

    XDEF _flat_buildScanlineCeiling_asm
    XDEF flat_buildScanlineCeiling_asm
    XDEF _flat_buildScanlineFloor_asm
    XDEF flat_buildScanlineFloor_asm
    XDEF _clipScanline_asm
    XDEF clipScanline_asm

    XREF _g_asm_columnTop
    XREF _g_asm_columnBot
    XREF _g_asm_windowTop
    XREF _g_asm_windowBot
    XREF _g_asm_windowMinX_Pixels
    XREF _g_asm_windowMaxX_Pixels
    XREF _g_asm_windowMaxCeil
    XREF _g_asm_windowMinFloor

EP_DYCEIL = 8
EP_DYFLOOR = 20
EP_YPIXEL_C0 = 24
EP_YPIXEL_C1 = 28
EP_YPIXEL_F0 = 32
EP_YPIXEL_F1 = 36
EP_X0 = 44
EP_X1 = 48
EP_SIZE = 52

CLIP_LEFT = 44
CLIP_RIGHT = 48
CLIP_Y = 52

ARG_I = 48
ARG_COUNT = 52
ARG_X = 56
ARG_Y = 60
ARG_LEFT = 64
ARG_RIGHT = 68
ARG_SCANLENGTH = 72
ARG_EDGES = 76

_clipScanline_asm:
clipScanline_asm:
    movem.l d2-d6/a2-a6,-(sp)

    move.l CLIP_LEFT(sp),a2
    move.l CLIP_RIGHT(sp),a3
    move.l (a2),d2
    move.l (a3),d3
    move.l CLIP_Y(sp),d4

    move.l _g_asm_windowMaxX_Pixels,a0
    move.l (a0),d5
    move.l _g_asm_windowMinX_Pixels,a0
    move.l (a0),d6
    cmp.l d5,d2
    bgt .clip_reject
    cmp.l d6,d3
    blt .clip_reject

    cmp.l d6,d2
    bge .cleft_ok
    move.l d6,d2

.cleft_ok:
    cmp.l d5,d3
    ble .cright_ok
    move.l d5,d3

.cright_ok:
    move.l _g_asm_windowMaxCeil,a0
    move.l (a0),d5
    move.l _g_asm_windowMinFloor,a0
    move.l (a0),d6

    cmp.l d5,d4
    bge .clip_no_overlap
    cmp.l d6,d4
    ble .clip_no_overlap

    move.l _g_asm_windowTop,a0
    move.l (a0),a4
    move.l _g_asm_windowBot,a0
    move.l (a0),a5

    lea (a4,d2.l*4),a1
    lea (a5,d2.l*4),a0
    move.l d2,d0
    bra .clip_ovl_l_test

.clip_ovl_l_loop:
    addq.l #1,d0
    addq.l #4,a1
    addq.l #4,a0

.clip_ovl_l_test:
    cmp.l d3,d0
    bgt .clip_ovl_l_done
    move.l (a1),d6
    cmp.l d6,d4
    blt .clip_ovl_l_loop
    move.l (a0),d6
    cmp.l d6,d4
    bgt .clip_ovl_l_loop

.clip_ovl_l_done:
    move.l d0,d2
    cmp.l d3,d2
    bgt .clip_write

    lea (a4,d3.l*4),a1
    lea (a5,d3.l*4),a0

.clip_ovl_r_loop:
    cmp.l d3,d2
    bgt .clip_write
    move.l (a1),d6
    cmp.l d6,d4
    blt .clip_ovl_r_notv
    move.l (a0),d6
    cmp.l d6,d4
    bgt .clip_ovl_r_notv
    bra .clip_write

.clip_ovl_r_notv:
    subq.l #1,d3
    subq.l #4,a1
    subq.l #4,a0
    bra .clip_ovl_r_loop

.clip_no_overlap:
    cmp.l d5,d4
    bge .clip_floor_plane

    move.l _g_asm_windowTop,a0
    move.l (a0),a4

    lea (a4,d2.l*4),a1
    move.l d2,d0
    bra .clip_ceil_l_test

.clip_ceil_l_loop:
    addq.l #1,d0
    addq.l #4,a1

.clip_ceil_l_test:
    cmp.l d3,d0
    bgt .clip_ceil_l_done
    move.l (a1),d6
    cmp.l d6,d4
    blt .clip_ceil_l_loop

.clip_ceil_l_done:
    move.l d0,d2
    cmp.l d3,d2
    bgt .clip_write

    lea (a4,d3.l*4),a1

.clip_ceil_r_loop:
    cmp.l d3,d2
    bgt .clip_ceil_r_done
    move.l (a1),d6
    cmp.l d6,d4
    bge .clip_ceil_r_done
    subq.l #1,d3
    subq.l #4,a1
    bra .clip_ceil_r_loop

.clip_ceil_r_done:
    bra .clip_write

.clip_floor_plane:
    cmp.l d6,d4
    ble .clip_write

    move.l _g_asm_windowBot,a0
    move.l (a0),a4

    lea (a4,d2.l*4),a1
    move.l d2,d0
    bra .clip_floor_l_test

.clip_floor_l_loop:
    addq.l #1,d0
    addq.l #4,a1

.clip_floor_l_test:
    cmp.l d3,d0
    bgt .clip_floor_l_done
    move.l (a1),d6
    cmp.l d6,d4
    bgt .clip_floor_l_loop

.clip_floor_l_done:
    move.l d0,d2
    cmp.l d3,d2
    bgt .clip_write

    lea (a4,d3.l*4),a1

.clip_floor_r_loop:
    cmp.l d3,d2
    bgt .clip_floor_r_done
    move.l (a1),d6
    cmp.l d6,d4
    ble .clip_floor_r_done
    subq.l #1,d3
    subq.l #4,a1
    bra .clip_floor_r_loop

.clip_floor_r_done:
    bra .clip_write

.clip_reject:
    move.l d3,d2
    addq.l #1,d2

.clip_write:
    move.l d2,(a2)
    move.l d3,(a3)

    movem.l (sp)+,d2-d6/a2-a6
    rts

_flat_buildScanlineCeiling_asm:
flat_buildScanlineCeiling_asm:
    movem.l d2-d7/a2-a6,-(sp)

    move.l ARG_I(sp),a2
    move.l ARG_X(sp),a3
    move.l ARG_LEFT(sp),a4
    move.l ARG_RIGHT(sp),a5
    move.l (a2),d2
    move.l (a3),d3
    move.l ARG_COUNT(sp),d1
    move.l ARG_Y(sp),d4
    move.l ARG_EDGES(sp),a6
    moveq #0,d7

    move.l d2,d0
    lsl.l #2,d0
    move.l d0,d5
    lsl.l #2,d5
    add.l d5,d0
    lsl.l #1,d5
    add.l d5,d0
    lea (a6,d0.l),a0

.ceil_l_loop:
    cmp.l d1,d2
    bge .ceil_left_done
    tst.l d7
    bne .ceil_left_done

    move.l EP_YPIXEL_C0(a0),d0
    cmp.l d0,d4
    bge .ceil_l_case2

    move.l d3,d5
    addq.l #1,d2
    move.l EP_X1(a0),d3
    addq.l #1,d3
    lea EP_SIZE(a0),a0
    moveq #-1,d7
    bra .ceil_left_done

.ceil_l_case2:
    move.l EP_YPIXEL_C1(a0),d0
    cmp.l d0,d4
    blt .ceil_l_case3

    move.l EP_X1(a0),d3
    addq.l #1,d3
    addq.l #1,d2
    lea EP_SIZE(a0),a0
    cmp.l d1,d2
    blt .ceil_l_loop
    move.l d3,d5
    moveq #-1,d7
    bra .ceil_left_done

.ceil_l_case3:
    move.l EP_DYCEIL(a0),d0
    ble .ceil_l_case4

    move.l _g_asm_windowMaxX_Pixels,a1
    move.l (a1),d0
    move.l _g_asm_columnTop,a1
    move.l (a1),a1
    move.l EP_X0(a0),d3
    lea (a1,d3.l*4),a1

.ceil_l_scan_loop:
    cmp.l d0,d3
    bge .ceil_l_scan_done
    move.l (a1),d6
    cmp.l d6,d4
    ble .ceil_l_scan_done
    addq.l #1,d3
    addq.l #4,a1
    bra .ceil_l_scan_loop

.ceil_l_scan_done:
    move.l d3,d5
    move.l EP_X1(a0),d3
    addq.l #1,d3
    addq.l #1,d2
    lea EP_SIZE(a0),a0
    moveq #-1,d7
    bra .ceil_left_done

.ceil_l_case4:
    move.l d3,d5
    moveq #-1,d7

.ceil_left_done:
    cmp.l d1,d2
    bge .ceil_no_right

.ceil_r_loop:
    cmp.l d1,d2
    bge .ceil_right_done

    move.l EP_YPIXEL_C0(a0),d0
    cmp.l d0,d4
    bge .ceil_r_case2

    move.l EP_X1(a0),d3
    addq.l #1,d3
    addq.l #1,d2
    lea EP_SIZE(a0),a0
    cmp.l d1,d2
    blt .ceil_r_loop
    move.l d3,d6
    bra .ceil_right_done

.ceil_r_case2:
    move.l EP_YPIXEL_C1(a0),d0
    cmp.l d0,d4
    blt .ceil_r_case3

    move.l d3,d6
    subq.l #1,d6
    move.l EP_X1(a0),d3
    addq.l #1,d3
    addq.l #1,d2
    bra .ceil_right_done

.ceil_r_case3:
    move.l EP_DYCEIL(a0),d0
    blt .ceil_r_scan

    move.l d3,d6
    bra .ceil_right_done

.ceil_r_scan:
    move.l _g_asm_windowMaxX_Pixels,a1
    move.l (a1),d0
    move.l _g_asm_columnTop,a1
    move.l (a1),a1
    move.l EP_X0(a0),d3
    lea (a1,d3.l*4),a1

.ceil_r_scan_loop:
    cmp.l d0,d3
    bge .ceil_r_scan_done
    move.l (a1),d6
    cmp.l d4,d6
    blt .ceil_r_scan_done
    addq.l #1,d3
    addq.l #4,a1
    bra .ceil_r_scan_loop

.ceil_r_scan_done:
    move.l d3,d6
    move.l EP_X1(a0),d3
    addq.l #1,d3
    addq.l #1,d2
    bra .ceil_right_done

.ceil_no_right:
    tst.l d7
    beq .ceil_false
    move.l d3,d6

.ceil_right_done:
    move.l d5,(a4)
    move.l d6,(a5)
    move.l d4,-(sp)
    move.l a5,-(sp)
    move.l a4,-(sp)
    jsr _clipScanline_asm
    lea 12(sp),sp

    move.l (a4),d5
    move.l (a5),d6
    move.l d6,d0
    sub.l d5,d0
    addq.l #1,d0
    move.l ARG_SCANLENGTH(sp),a0
    move.l d0,(a0)

    move.l d2,(a2)
    move.l d3,(a3)
    move.l d5,(a4)
    move.l d6,(a5)

    moveq #1,d0
    movem.l (sp)+,d2-d7/a2-a6
    rts

.ceil_false:
    move.l d2,(a2)
    move.l d3,(a3)
    moveq #0,d0
    movem.l (sp)+,d2-d7/a2-a6
    rts

_flat_buildScanlineFloor_asm:
flat_buildScanlineFloor_asm:
    movem.l d2-d7/a2-a6,-(sp)

    move.l ARG_I(sp),a2
    move.l ARG_X(sp),a3
    move.l ARG_LEFT(sp),a4
    move.l ARG_RIGHT(sp),a5
    move.l (a2),d2
    move.l (a3),d3
    move.l ARG_COUNT(sp),d1
    move.l ARG_Y(sp),d4
    move.l ARG_EDGES(sp),a6
    moveq #0,d7

    move.l d2,d0
    lsl.l #2,d0
    move.l d0,d5
    lsl.l #2,d5
    add.l d5,d0
    lsl.l #1,d5
    add.l d5,d0
    lea (a6,d0.l),a0

.floor_l_loop:
    cmp.l d1,d2
    bge .floor_left_done
    tst.l d7
    bne .floor_left_done

    move.l EP_YPIXEL_F0(a0),d0
    cmp.l d0,d4
    blt .floor_l_case2

    move.l d3,d5
    addq.l #1,d2
    move.l EP_X1(a0),d3
    addq.l #1,d3
    lea EP_SIZE(a0),a0
    moveq #-1,d7
    bra .floor_left_done

.floor_l_case2:
    move.l EP_YPIXEL_F1(a0),d0
    cmp.l d0,d4
    bge .floor_l_case3

    move.l EP_X1(a0),d3
    addq.l #1,d3
    addq.l #1,d2
    lea EP_SIZE(a0),a0
    cmp.l d1,d2
    blt .floor_l_loop
    move.l d3,d5
    moveq #-1,d7
    bra .floor_left_done

.floor_l_case3:
    move.l EP_DYFLOOR(a0),d0
    bge .floor_l_case4

    move.l _g_asm_windowMaxX_Pixels,a1
    move.l (a1),d0
    move.l _g_asm_columnBot,a1
    move.l (a1),a1
    move.l EP_X0(a0),d3
    lea (a1,d3.l*4),a1

.floor_l_scan_loop:
    cmp.l d0,d3
    bge .floor_l_scan_done
    move.l (a1),d6
    cmp.l d4,d6
    ble .floor_l_scan_done
    addq.l #1,d3
    addq.l #4,a1
    bra .floor_l_scan_loop

.floor_l_scan_done:
    move.l d3,d5
    move.l EP_X1(a0),d3
    addq.l #1,d3
    addq.l #1,d2
    lea EP_SIZE(a0),a0
    moveq #-1,d7
    bra .floor_left_done

.floor_l_case4:
    move.l d3,d5
    moveq #-1,d7

.floor_left_done:
    cmp.l d1,d2
    bge .floor_no_right

.floor_r_loop:
    cmp.l d1,d2
    bge .floor_right_done

    move.l EP_YPIXEL_F0(a0),d0
    cmp.l d0,d4
    blt .floor_r_case2

    move.l EP_X1(a0),d3
    addq.l #1,d3
    addq.l #1,d2
    lea EP_SIZE(a0),a0
    cmp.l d1,d2
    blt .floor_r_loop
    move.l d3,d6
    bra .floor_right_done

.floor_r_case2:
    move.l EP_YPIXEL_F1(a0),d0
    cmp.l d0,d4
    bge .floor_r_case3

    move.l d3,d6
    subq.l #1,d6
    move.l EP_X1(a0),d3
    addq.l #1,d3
    addq.l #1,d2
    bra .floor_right_done

.floor_r_case3:
    move.l EP_DYFLOOR(a0),d0
    bgt .floor_r_scan

    move.l d3,d6
    bra .floor_right_done

.floor_r_scan:
    move.l _g_asm_windowMaxX_Pixels,a1
    move.l (a1),d0
    move.l _g_asm_columnBot,a1
    move.l (a1),a1
    move.l EP_X0(a0),d3
    lea (a1,d3.l*4),a1

.floor_r_scan_loop:
    cmp.l d0,d3
    bge .floor_r_scan_done
    move.l (a1),d6
    cmp.l d4,d6
    bgt .floor_r_scan_done
    addq.l #1,d3
    addq.l #4,a1
    bra .floor_r_scan_loop

.floor_r_scan_done:
    move.l d3,d6
    move.l EP_X1(a0),d3
    addq.l #1,d3
    addq.l #1,d2
    bra .floor_right_done

.floor_no_right:
    tst.l d7
    beq .floor_false
    move.l d3,d6

.floor_right_done:
    move.l d5,(a4)
    move.l d6,(a5)
    move.l d4,-(sp)
    move.l a5,-(sp)
    move.l a4,-(sp)
    jsr _clipScanline_asm
    lea 12(sp),sp

    move.l (a4),d5
    move.l (a5),d6
    move.l d6,d0
    sub.l d5,d0
    addq.l #1,d0
    move.l ARG_SCANLENGTH(sp),a0
    move.l d0,(a0)

    move.l d2,(a2)
    move.l d3,(a3)
    move.l d5,(a4)
    move.l d6,(a5)

    moveq #1,d0
    movem.l (sp)+,d2-d7/a2-a6
    rts

.floor_false:
    move.l d2,(a2)
    move.l d3,(a3)
    moveq #0,d0
    movem.l (sp)+,d2-d7/a2-a6
    rts
