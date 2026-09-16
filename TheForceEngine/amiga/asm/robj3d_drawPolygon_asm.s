
    section .text,code

    XDEF _robj3d_drawFlatColorPolygon_asm
    XDEF robj3d_drawFlatColorPolygon_asm
    XDEF _robj3d_drawShadedColorPolygon_asm
    XDEF robj3d_drawShadedColorPolygon_asm
    XDEF _robj3d_drawFlatTexturePolygon_asm
    XDEF robj3d_drawFlatTexturePolygon_asm
    XDEF _robj3d_drawShadedTexturePolygon_asm
    XDEF robj3d_drawShadedTexturePolygon_asm

    XREF _g_rcfState_ptr
    XREF _g_asm_s_polyProjVtx
    XREF _g_asm_s_polyVertexCount
    XREF _g_asm_s_polyMaxIndex
    XREF _g_asm_s_polyIntensity
    XREF _g_asm_s_polyUv
    XREF _g_asm_s_polyColorIndex
    XREF _g_asm_s_polyColorMap
    XREF _g_asm_s_polyTexture
    XREF _g_asm_s_columnX
    XREF _g_asm_s_columnHeight
    XREF _g_asm_s_pcolumnOut
    XREF _g_asm_s_col_I0
    XREF _g_asm_s_col_dIdY
    XREF _g_asm_s_col_Uv0
    XREF _g_asm_s_col_dUVdY
    XREF _g_asm_s_dither
    XREF _g_asm_s_ditherOffset
    XREF _g_asm_s_edgeBot_Z0
    XREF _g_asm_s_edgeBot_dZdX
    XREF _g_asm_s_edgeBot_dIdX
    XREF _g_asm_s_edgeBot_I0
    XREF _g_asm_s_edgeBot_dUVdX
    XREF _g_asm_s_edgeBot_Uv0
    XREF _g_asm_s_edgeBot_dYdX
    XREF _g_asm_s_edgeBot_Y0
    XREF _g_asm_s_edgeTop_dIdX
    XREF _g_asm_s_edgeTop_dUVdX
    XREF _g_asm_s_edgeTop_Uv0
    XREF _g_asm_s_edgeTop_dYdX
    XREF _g_asm_s_edgeTop_Z0
    XREF _g_asm_s_edgeTop_Y0
    XREF _g_asm_s_edgeTop_dZdX
    XREF _g_asm_s_edgeTop_I0
    XREF _g_asm_s_edgeBotY0_Pixel
    XREF _g_asm_s_edgeTopY0_Pixel
    XREF _g_asm_s_edgeBotIndex
    XREF _g_asm_s_edgeTopIndex
    XREF _g_asm_s_edgeTopLength
    XREF _g_asm_s_edgeBotLength
    XREF __ZN8TFE_Jedi10s_colorMapE
    XREF __ZN8TFE_Jedi9s_displayE
    XREF __ZN8TFE_Jedi14s_objWindowTopE
    XREF __ZN8TFE_Jedi14s_objWindowBotE
    XREF __ZN8TFE_Jedi19s_minScreenX_PixelsE
    XREF __ZN8TFE_Jedi19s_maxScreenX_PixelsE
    XREF __ZN8TFE_Jedi19s_windowMinY_PixelsE
    XREF __ZN8TFE_Jedi19s_windowMaxY_PixelsE

    XREF _robj3d_findNextEdge_asm
    XREF _robj3d_findPrevEdge_asm
    XREF _robj3d_findNextEdgeI_asm
    XREF _robj3d_findPrevEdgeI_asm
    XREF _robj3d_findNextEdgeT_asm
    XREF _robj3d_findPrevEdgeT_asm
    XREF _robj3d_findNextEdgeTI_asm
    XREF _robj3d_findPrevEdgeTI_asm
    XREF _robj3d_drawColumnFlatColor_asm
    XREF _robj3d_drawColumnShadedColor_asm
    XREF _robj3d_drawColumnFlatTexture_asm
    XREF _robj3d_drawColumnShadedTexture_asm

V3_X = 0
V3_Y = 4
V3_Z = 8
V3_SZ = 12

V2_X = 0
V2_Z = 4
V2_SZ = 8

SW = 320
ONE_16 = $10000

F_XMIN = 40
F_XMAX = 44
F_YMIN = 48
F_YMAX = 52
F_MINXIDX = 56
F_COLX = 60
F_FOUND = 64
F_FRAMESZ = 68
F_ARG0 = 116
F_ARG1 = 120
F_ARG2 = 124
F_ARG3 = 128
F_ARG4 = 132

VSHADE_MAX_INTENSITY = $1f0000

_robj3d_drawFlatColorPolygon_asm:
robj3d_drawFlatColorPolygon_asm:
    movem.l d2-d7/a2-a6,-(sp)
    lea -F_FRAMESZ(sp),sp

    move.l F_ARG0(sp),a0
    move.l F_ARG1(sp),d0
    move.l _g_asm_s_polyProjVtx,a2
    move.l a0,(a2)
    move.l _g_asm_s_polyVertexCount,a2
    move.l d0,(a2)

    tst.l d0
    ble .fc_return

    move.l #$7fffffff,d3
    move.l #$80000000,d4
    move.l d3,d5
    move.l d4,d6
    moveq #-1,d7
    moveq #-1,d0
    move.l d0,a4
    move.l _g_asm_s_polyVertexCount,a2
    move.l (a2),d1
    subq.l #1,d1
    moveq #0,d2
    move.l a0,a3

.fc_bbox_loop:
    move.l (a3),d0
    cmp.l d3,d0
    bge .fc_not_min
    move.l d0,d3
    move.l d2,d7

.fc_not_min:
    cmp.l d0,d4
    bge .fc_not_max
    move.l d0,d4
    move.l d2,a4

.fc_not_max:
    move.l V3_Y(a3),d0
    cmp.l d5,d0
    bge .fc_not_ymin
    move.l d0,d5

.fc_not_ymin:
    cmp.l d6,d0
    ble .fc_not_ymax
    move.l d0,d6

.fc_not_ymax:
    addq.l #1,d2
    lea V3_SZ(a3),a3
    dbra d1,.fc_bbox_loop

    move.l _g_asm_s_polyMaxIndex,a2
    move.l a4,(a2)

    cmp.l d4,d3
    bge .fc_return
    cmp.l __ZN8TFE_Jedi19s_windowMaxY_PixelsE,d5
    bgt .fc_return
    cmp.l __ZN8TFE_Jedi19s_windowMinY_PixelsE,d6
    blt .fc_return

    move.l __ZN8TFE_Jedi10s_colorMapE,d0
    move.l _g_asm_s_polyColorMap,a2
    move.l d0,(a2)
    move.l F_ARG2(sp),d1
    move.l _g_asm_s_polyColorIndex,a2
    move.b d1,(a2)

    move.l _g_asm_s_columnX,a2
    move.l d3,(a2)
    move.l d3,F_COLX(sp)

    move.l d7,d0
    move.l d3,d1
    jsr _robj3d_findNextEdge_asm
    tst.l d0
    bne .fc_return

    move.l d7,d0
    jsr _robj3d_findPrevEdge_asm
    tst.l d0
    bne .fc_return

    lea _robj3d_drawColumnFlatColor_asm,a6
    moveq #0,d0
    move.l d0,F_FOUND(sp)

.fc_col_loop:
    tst.l F_FOUND(sp)
    bne .fc_return
    move.l F_COLX(sp),d0
    cmp.l __ZN8TFE_Jedi19s_minScreenX_PixelsE,d0
    blt .fc_return
    cmp.l __ZN8TFE_Jedi19s_maxScreenX_PixelsE,d0
    bgt .fc_return

    move.l _g_asm_s_edgeBot_Z0,a2
    move.l (a2),d1
    move.l _g_asm_s_edgeTop_Z0,a2
    move.l (a2),d2
    cmp.l d2,d1
    ble .fc_zmin_ok
    move.l d2,d1

.fc_zmin_ok:
    move.l _g_rcfState_ptr,a3
    move.l 40(a3),a3
    move.l F_COLX(sp),d3
    lsl.l #2,d3
    move.l (a3,d3.l),d4

    cmp.l d4,d1
    bge .fc_advance
    move.l _g_asm_s_edgeTopY0_Pixel,a2
    move.l (a2),d1
    cmp.l __ZN8TFE_Jedi19s_windowMaxY_PixelsE,d1
    bgt .fc_advance
    move.l _g_asm_s_edgeBotY0_Pixel,a2
    move.l (a2),d2
    move.l d2,F_XMIN(sp)
    cmp.l __ZN8TFE_Jedi19s_windowMinY_PixelsE,d2
    blt .fc_advance

    move.l __ZN8TFE_Jedi14s_objWindowTopE,a2
    move.l F_COLX(sp),d3
    lsl.l #2,d3
    move.l (a2,d3.l),d4
    move.l __ZN8TFE_Jedi14s_objWindowBotE,a2
    move.l (a2,d3.l),d5

    move.l d1,d6
    move.l d2,d7
    cmp.l d4,d6
    bge .fc_top_ok
    move.l d4,d6

.fc_top_ok:
    cmp.l d5,d7
    ble .fc_bot_ok
    move.l d5,d7

.fc_bot_ok:
    move.l d7,d0
    sub.l d6,d0
    addq.l #1,d0
    move.l _g_asm_s_columnHeight,a2
    move.l d0,(a2)
    ble .fc_advance

    move.l d6,d0
    lsl.l #8,d0
    move.l d6,d1
    lsl.l #6,d1
    add.l d1,d0
    add.l F_COLX(sp),d0
    move.l __ZN8TFE_Jedi9s_displayE,a3
    lea (a3,d0.l),a3
    move.l _g_asm_s_pcolumnOut,a2
    move.l a3,(a2)

    jsr (a6)

.fc_advance:
    move.l _g_asm_s_edgeTopLength,a2
    move.l (a2),d0
    subq.l #1,d0
    move.l d0,(a2)
    ble .fc_top_findnext

    move.l _g_asm_s_edgeTop_Y0,a2
    move.l (a2),d0
    move.l _g_asm_s_edgeTop_dYdX,a3
    add.l (a3),d0
    move.l d0,(a2)
    move.l _g_asm_s_edgeTop_dZdX,a3
    move.l (a3),d1
    move.l _g_asm_s_edgeTop_Z0,a2
    add.l d1,(a2)

    add.l #$8000,d0
    swap d0
    ext.l d0
    move.l _g_asm_s_edgeTopY0_Pixel,a2
    move.l d0,(a2)
    bra .fc_bot_check

.fc_top_findnext:
    move.l _g_asm_s_edgeTopIndex,a2
    move.l (a2),d0
    move.l F_COLX(sp),d1
    jsr _robj3d_findNextEdge_asm
    move.l d0,F_FOUND(sp)

.fc_bot_check:
    tst.l F_FOUND(sp)
    bne .fc_loop_next

    move.l _g_asm_s_edgeBotLength,a2
    move.l (a2),d0
    subq.l #1,d0
    move.l d0,(a2)
    ble .fc_bot_findprev
    
    move.l _g_asm_s_edgeBot_Y0,a2
    move.l (a2),d0
    move.l _g_asm_s_edgeBot_dYdX,a3
    add.l (a3),d0
    move.l d0,(a2)
    move.l _g_asm_s_edgeBot_dZdX,a3
    move.l (a3),d1
    move.l _g_asm_s_edgeBot_Z0,a2
    add.l d1,(a2)
    add.l #$8000,d0
    swap d0
    ext.l d0
    move.l _g_asm_s_edgeBotY0_Pixel,a2
    move.l d0,(a2)
    bra .fc_loop_next

.fc_bot_findprev:
    move.l _g_asm_s_edgeBotIndex,a2
    move.l (a2),d0
    jsr _robj3d_findPrevEdge_asm
    move.l d0,F_FOUND(sp)

.fc_loop_next:
    move.l _g_asm_s_columnX,a2
    addq.l #1,(a2)
    addq.l #1,F_COLX(sp)
    bra .fc_col_loop

.fc_return:
    lea F_FRAMESZ(sp),sp
    movem.l (sp)+,d2-d7/a2-a6
    rts

_robj3d_drawShadedColorPolygon_asm:
robj3d_drawShadedColorPolygon_asm:
    movem.l d2-d7/a2-a6,-(sp)
    lea -F_FRAMESZ(sp),sp

    move.l F_ARG0(sp),a0
    move.l F_ARG1(sp),a1
    move.l F_ARG2(sp),d0
    move.l _g_asm_s_polyProjVtx,a2
    move.l a0,(a2)
    move.l _g_asm_s_polyVertexCount,a2
    move.l d0,(a2)
    move.l _g_asm_s_polyIntensity,a2
    move.l a1,(a2)

    tst.l d0
    ble .sc_return

    move.l #$7fffffff,d3
    move.l #$80000000,d4
    move.l d3,d5
    move.l d4,d6
    moveq #-1,d7
    moveq #-1,d0
    move.l d0,a4
    move.l _g_asm_s_polyVertexCount,a2
    move.l (a2),d1
    subq.l #1,d1
    moveq #0,d2
    move.l a0,a3

.sc_bbox_loop:
    move.l (a3),d0
    cmp.l d3,d0
    bge .sc_not_min
    move.l d0,d3
    move.l d2,d7

.sc_not_min:
    cmp.l d0,d4
    bge .sc_not_max
    move.l d0,d4
    move.l d2,a4

.sc_not_max:
    move.l V3_Y(a3),d0
    cmp.l d5,d0
    bge .sc_not_ymin
    move.l d0,d5

.sc_not_ymin:
    cmp.l d6,d0
    ble .sc_not_ymax
    move.l d0,d6

.sc_not_ymax:
    addq.l #1,d2
    lea V3_SZ(a3),a3
    dbra d1,.sc_bbox_loop

    move.l _g_asm_s_polyMaxIndex,a2
    move.l a4,(a2)

    cmp.l d4,d3
    bge .sc_return
    cmp.l __ZN8TFE_Jedi19s_windowMaxY_PixelsE,d5
    bgt .sc_return
    cmp.l __ZN8TFE_Jedi19s_windowMinY_PixelsE,d6
    blt .sc_return

    move.l __ZN8TFE_Jedi10s_colorMapE,d0
    move.l _g_asm_s_polyColorMap,a2
    move.l d0,(a2)
    move.l F_ARG3(sp),d1
    move.l _g_asm_s_polyColorIndex,a2
    move.b d1,(a2)
    move.l _g_asm_s_ditherOffset,a2
    move.l #$8000,(a2)

    move.l _g_asm_s_columnX,a2
    move.l d3,(a2)
    move.l d3,F_COLX(sp)

    move.l d7,d0
    move.l d3,d1
    jsr _robj3d_findNextEdgeI_asm
    tst.l d0
    bne .sc_return

    move.l d7,d0
    jsr _robj3d_findPrevEdgeI_asm
    tst.l d0
    bne .sc_return

    lea _robj3d_drawColumnShadedColor_asm,a6
    moveq #0,d0
    move.l d0,F_FOUND(sp)

.sc_col_loop:
    tst.l F_FOUND(sp)
    bne .sc_return
    move.l F_COLX(sp),d0
    cmp.l __ZN8TFE_Jedi19s_minScreenX_PixelsE,d0
    blt .sc_return
    cmp.l __ZN8TFE_Jedi19s_maxScreenX_PixelsE,d0
    bgt .sc_return

    move.l _g_asm_s_edgeBot_Z0,a2
    move.l (a2),d1
    move.l _g_asm_s_edgeTop_Z0,a2
    move.l (a2),d2
    cmp.l d2,d1
    ble .sc_zmin_ok
    move.l d2,d1

.sc_zmin_ok:
    move.l _g_rcfState_ptr,a3
    move.l 40(a3),a3
    move.l F_COLX(sp),d3
    lsl.l #2,d3
    move.l (a3,d3.l),d4

    cmp.l d4,d1
    bge .sc_advance
    move.l _g_asm_s_edgeTopY0_Pixel,a2
    move.l (a2),d1
    cmp.l __ZN8TFE_Jedi19s_windowMaxY_PixelsE,d1
    bgt .sc_advance
    move.l _g_asm_s_edgeBotY0_Pixel,a2
    move.l (a2),d2
    move.l d2,F_XMIN(sp)
    cmp.l __ZN8TFE_Jedi19s_windowMinY_PixelsE,d2
    blt .sc_advance

    move.l __ZN8TFE_Jedi14s_objWindowTopE,a2
    move.l F_COLX(sp),d3
    lsl.l #2,d3
    move.l (a2,d3.l),d4
    move.l __ZN8TFE_Jedi14s_objWindowBotE,a2
    move.l (a2,d3.l),d5

    move.l d1,d6
    move.l d2,d7
    cmp.l d4,d6
    bge .sc_top_ok
    move.l d4,d6

.sc_top_ok:
    cmp.l d5,d7
    ble .sc_bot_ok
    move.l d5,d7

.sc_bot_ok:
    move.l d7,d0
    sub.l d6,d0
    addq.l #1,d0
    move.l _g_asm_s_columnHeight,a2
    move.l d0,(a2)
    ble .sc_advance

    move.l d2,d0
    sub.l d1,d0
    addq.l #1,d0
    move.l _g_asm_s_edgeTop_I0,a2
    move.l (a2),d1
    move.l _g_asm_s_edgeBot_I0,a2
    sub.l (a2),d1
    divs.l d0,d1
    move.l _g_asm_s_col_dIdY,a2
    move.l d1,(a2)
    move.l _g_asm_s_edgeBot_I0,a2
    move.l (a2),d1
    move.l _g_asm_s_col_I0,a2
    move.l d1,(a2)

    move.l F_XMIN(sp),d1
    cmp.l d5,d1
    ble .sc_no_yoff
    sub.l d5,d1
    move.l _g_asm_s_col_dIdY,a2
    move.l (a2),d2
    muls.l d2,d1
    move.l _g_asm_s_col_I0,a2
    add.l d1,(a2)

.sc_no_yoff:
    move.l F_COLX(sp),d0
    and.l #1,d0
    move.l d7,d1
    and.l #1,d1
    eor.l d1,d0
    subq.l #1,d0
    move.l _g_asm_s_dither,a2
    move.l d0,(a2)

    move.l d6,d0
    lsl.l #8,d0
    move.l d6,d1
    lsl.l #6,d1
    add.l d1,d0
    add.l F_COLX(sp),d0
    move.l __ZN8TFE_Jedi9s_displayE,a3
    lea (a3,d0.l),a3
    move.l _g_asm_s_pcolumnOut,a2
    move.l a3,(a2)

    jsr (a6)

.sc_advance:
    move.l _g_asm_s_edgeTopLength,a2
    move.l (a2),d0
    subq.l #1,d0
    move.l d0,(a2)
    ble .sc_top_findnext
    move.l _g_asm_s_edgeTop_Y0,a2
    move.l (a2),d0
    move.l _g_asm_s_edgeTop_dYdX,a3
    add.l (a3),d0
    move.l d0,(a2)
    move.l _g_asm_s_edgeTop_dZdX,a3
    move.l (a3),d1
    move.l _g_asm_s_edgeTop_Z0,a2
    add.l d1,(a2)
    move.l _g_asm_s_edgeTop_I0,a2
    move.l (a2),d0
    move.l _g_asm_s_edgeTop_dIdX,a3
    add.l (a3),d0
    tst.l d0
    bge .sc_i0_pos
    moveq #0,d0
    bra .sc_i0_clamped

.sc_i0_pos:
    cmp.l #VSHADE_MAX_INTENSITY,d0
    ble .sc_i0_clamped
    move.l #VSHADE_MAX_INTENSITY,d0

.sc_i0_clamped:
    move.l _g_asm_s_edgeTop_I0,a2
    move.l d0,(a2)
    move.l _g_asm_s_edgeTop_Y0,a2
    move.l (a2),d0
    add.l #$8000,d0
    swap d0
    ext.l d0
    move.l _g_asm_s_edgeTopY0_Pixel,a2
    move.l d0,(a2)
    bra .sc_bot_check

.sc_top_findnext:
    move.l _g_asm_s_edgeTopIndex,a2
    move.l (a2),d0
    move.l F_COLX(sp),d1
    jsr _robj3d_findNextEdgeI_asm
    move.l d0,F_FOUND(sp)

.sc_bot_check:
    tst.l F_FOUND(sp)
    bne .sc_loop_next
    move.l _g_asm_s_edgeBotLength,a2
    move.l (a2),d0
    subq.l #1,d0
    move.l d0,(a2)
    ble .sc_bot_findprev
    move.l _g_asm_s_edgeBot_Y0,a2
    move.l (a2),d0
    move.l _g_asm_s_edgeBot_dYdX,a3
    add.l (a3),d0
    move.l d0,(a2)
    move.l _g_asm_s_edgeBot_dZdX,a3
    move.l (a3),d1
    move.l _g_asm_s_edgeBot_Z0,a2
    add.l d1,(a2)
    move.l _g_asm_s_edgeBot_I0,a2
    move.l (a2),d0
    move.l _g_asm_s_edgeBot_dIdX,a3
    add.l (a3),d0
    tst.l d0
    bge .sc_i0_pos2
    moveq #0,d0
    bra .sc_i0_clamped2

.sc_i0_pos2:
    cmp.l #VSHADE_MAX_INTENSITY,d0
    ble .sc_i0_clamped2
    move.l #VSHADE_MAX_INTENSITY,d0

.sc_i0_clamped2:
    move.l _g_asm_s_edgeBot_I0,a2
    move.l d0,(a2)
    move.l _g_asm_s_edgeBot_Y0,a2
    move.l (a2),d0
    add.l #$8000,d0
    swap d0
    ext.l d0
    move.l _g_asm_s_edgeBotY0_Pixel,a2
    move.l d0,(a2)
    bra .sc_loop_next

.sc_bot_findprev:
    move.l _g_asm_s_edgeBotIndex,a2
    move.l (a2),d0
    jsr _robj3d_findPrevEdgeI_asm
    move.l d0,F_FOUND(sp)

.sc_loop_next:
    move.l _g_asm_s_columnX,a2
    addq.l #1,(a2)
    addq.l #1,F_COLX(sp)
    bra .sc_col_loop

.sc_return:
    lea F_FRAMESZ(sp),sp
    movem.l (sp)+,d2-d7/a2-a6
    rts


_robj3d_drawFlatTexturePolygon_asm:
robj3d_drawFlatTexturePolygon_asm:
    movem.l d2-d7/a2-a6,-(sp)
    lea -F_FRAMESZ(sp),sp

    move.l F_ARG0(sp),a0
    move.l F_ARG1(sp),a1
    move.l F_ARG2(sp),d0
    move.l F_ARG3(sp),a2
    move.l _g_asm_s_polyProjVtx,a3
    move.l a0,(a3)
    move.l _g_asm_s_polyVertexCount,a3
    move.l d0,(a3)
    move.l _g_asm_s_polyUv,a3
    move.l a1,(a3)
    move.l _g_asm_s_polyTexture,a3
    move.l a2,(a3)

    tst.l d0
    ble .ft_return

    move.l #$7fffffff,d3
    move.l #$80000000,d4
    move.l d3,d5
    move.l d4,d6
    moveq #-1,d7
    moveq #-1,d0
    move.l d0,a4
    move.l _g_asm_s_polyVertexCount,a3
    move.l (a3),d1
    subq.l #1,d1
    moveq #0,d2
    move.l a0,a5

.ft_bbox_loop:
    move.l (a5),d0
    cmp.l d3,d0
    bge .ft_not_min
    move.l d0,d3
    move.l d2,d7

.ft_not_min:
    cmp.l d0,d4
    bge .ft_not_max
    move.l d0,d4
    move.l d2,a4

.ft_not_max:
    move.l V3_Y(a5),d0
    cmp.l d5,d0
    bge .ft_not_ymin
    move.l d0,d5

.ft_not_ymin:
    cmp.l d6,d0
    ble .ft_not_ymax
    move.l d0,d6

.ft_not_ymax:
    addq.l #1,d2
    lea V3_SZ(a5),a5
    dbra d1,.ft_bbox_loop

    move.l _g_asm_s_polyMaxIndex,a3
    move.l a4,(a3)

    cmp.l d4,d3
    bge .ft_return
    cmp.l __ZN8TFE_Jedi19s_windowMaxY_PixelsE,d5
    bgt .ft_return
    cmp.l __ZN8TFE_Jedi19s_windowMinY_PixelsE,d6
    blt .ft_return

    move.l __ZN8TFE_Jedi10s_colorMapE,d0
    move.l _g_asm_s_polyColorMap,a3
    move.l d0,(a3)
    move.l F_ARG4(sp),d1
    move.l _g_asm_s_polyColorIndex,a3
    move.b d1,(a3)

    move.l _g_asm_s_columnX,a3
    move.l d3,(a3)
    move.l d3,F_COLX(sp)

    move.l d7,d0
    move.l d3,d1
    jsr _robj3d_findNextEdgeT_asm
    tst.l d0
    bne .ft_return

    move.l d7,d0
    jsr _robj3d_findPrevEdgeT_asm
    tst.l d0
    bne .ft_return

    lea _robj3d_drawColumnFlatTexture_asm,a6
    moveq #0,d0
    move.l d0,F_FOUND(sp)

.ft_col_loop:
    tst.l F_FOUND(sp)
    bne .ft_return
    move.l F_COLX(sp),d0
    cmp.l __ZN8TFE_Jedi19s_minScreenX_PixelsE,d0
    blt .ft_return
    cmp.l __ZN8TFE_Jedi19s_maxScreenX_PixelsE,d0
    bgt .ft_return

    move.l _g_asm_s_edgeBot_Z0,a3
    move.l (a3),d1
    move.l _g_asm_s_edgeTop_Z0,a3
    move.l (a3),d2
    cmp.l d2,d1
    ble .ft_zmin_ok
    move.l d2,d1

.ft_zmin_ok:
    move.l _g_rcfState_ptr,a5
    move.l 40(a5),a5
    move.l F_COLX(sp),d3
    lsl.l #2,d3
    move.l (a5,d3.l),d4

    cmp.l d4,d1
    bge .ft_advance
    move.l _g_asm_s_edgeTopY0_Pixel,a3
    move.l (a3),d1
    cmp.l __ZN8TFE_Jedi19s_windowMaxY_PixelsE,d1
    bgt .ft_advance
    move.l _g_asm_s_edgeBotY0_Pixel,a3
    move.l (a3),d2
    move.l d2,F_XMIN(sp)
    cmp.l __ZN8TFE_Jedi19s_windowMinY_PixelsE,d2
    blt .ft_advance

    move.l __ZN8TFE_Jedi14s_objWindowTopE,a3
    move.l F_COLX(sp),d3
    lsl.l #2,d3
    move.l (a3,d3.l),d4
    move.l __ZN8TFE_Jedi14s_objWindowBotE,a3
    move.l (a3,d3.l),d5

    move.l d1,d6
    move.l d2,d7
    cmp.l d4,d6
    bge .ft_top_ok
    move.l d4,d6

.ft_top_ok:
    cmp.l d5,d7
    ble .ft_bot_ok
    move.l d5,d7

.ft_bot_ok:
    move.l d7,d0
    sub.l d6,d0
    addq.l #1,d0
    move.l _g_asm_s_columnHeight,a3
    move.l d0,(a3)
    ble .ft_advance

    move.l d2,d0
    sub.l d1,d0
    addq.l #1,d0
    move.l #ONE_16,d1
    divs.l d0,d1
    move.l _g_asm_s_edgeTop_Uv0,a3
    move.l (a3),d2
    move.l _g_asm_s_edgeBot_Uv0,a3
    sub.l (a3),d2
    muls.l d1,d0:d2
    move.w d0,d2
    swap d2
    move.l _g_asm_s_col_dUVdY,a3
    move.l d2,(a3)
    move.l _g_asm_s_edgeTop_Uv0,a3
    move.l 4(a3),d2
    move.l _g_asm_s_edgeBot_Uv0,a3
    sub.l 4(a3),d2
    muls.l d1,d0:d2
    move.w d0,d2
    swap d2
    move.l _g_asm_s_col_dUVdY,a3
    move.l d2,4(a3)
    move.l _g_asm_s_edgeBot_Uv0,a3
    move.l (a3),d2
    move.l 4(a3),d0
    move.l _g_asm_s_col_Uv0,a3
    move.l d2,(a3)
    move.l d0,4(a3)

    move.l F_XMIN(sp),d1
    cmp.l d5,d1
    ble .ft_no_yoff
    sub.l d5,d1
    move.l _g_asm_s_col_dUVdY,a3
    move.l (a3),d2
    muls.l d2,d1
    move.l _g_asm_s_col_Uv0,a3
    add.l d1,(a3)
    move.l _g_asm_s_col_dUVdY,a3
    move.l 4(a3),d2
    move.l F_XMIN(sp),d1
    sub.l d5,d1
    muls.l d2,d1
    move.l _g_asm_s_col_Uv0,a3
    add.l d1,4(a3)

.ft_no_yoff:
    move.l d6,d0
    lsl.l #8,d0
    move.l d6,d1
    lsl.l #6,d1
    add.l d1,d0
    add.l F_COLX(sp),d0
    move.l __ZN8TFE_Jedi9s_displayE,a5
    lea (a5,d0.l),a5
    move.l _g_asm_s_pcolumnOut,a3
    move.l a5,(a3)

    jsr (a6)

.ft_advance:
    move.l _g_asm_s_edgeTopLength,a3
    move.l (a3),d0
    subq.l #1,d0
    move.l d0,(a3)
    ble .ft_top_findnext
    move.l _g_asm_s_edgeTop_Y0,a3
    move.l (a3),d0
    move.l _g_asm_s_edgeTop_dYdX,a5
    add.l (a5),d0
    move.l d0,(a3)
    move.l _g_asm_s_edgeTop_dZdX,a5
    move.l (a5),d1
    move.l _g_asm_s_edgeTop_Z0,a3
    add.l d1,(a3)
    move.l _g_asm_s_edgeTop_dUVdX,a5
    move.l (a5),d1
    move.l _g_asm_s_edgeTop_Uv0,a3
    add.l d1,(a3)
    move.l _g_asm_s_edgeTop_dUVdX,a5
    move.l 4(a5),d1
    move.l _g_asm_s_edgeTop_Uv0,a3
    add.l d1,4(a3)
    move.l _g_asm_s_edgeTop_Y0,a3
    move.l (a3),d0
    add.l #$8000,d0
    swap d0
    ext.l d0
    move.l _g_asm_s_edgeTopY0_Pixel,a3
    move.l d0,(a3)
    bra .ft_bot_check

.ft_top_findnext:
    move.l _g_asm_s_edgeTopIndex,a3
    move.l (a3),d0
    move.l F_COLX(sp),d1
    jsr _robj3d_findNextEdgeT_asm
    move.l d0,F_FOUND(sp)

.ft_bot_check:
    tst.l F_FOUND(sp)
    bne .ft_loop_next
    move.l _g_asm_s_edgeBotLength,a3
    move.l (a3),d0
    subq.l #1,d0
    move.l d0,(a3)
    ble .ft_bot_findprev
    move.l _g_asm_s_edgeBot_Y0,a3
    move.l (a3),d0
    move.l _g_asm_s_edgeBot_dYdX,a5
    add.l (a5),d0
    move.l d0,(a3)
    move.l _g_asm_s_edgeBot_dZdX,a5
    move.l (a5),d1
    move.l _g_asm_s_edgeBot_Z0,a3
    add.l d1,(a3)
    move.l _g_asm_s_edgeBot_dUVdX,a5
    move.l (a5),d1
    move.l _g_asm_s_edgeBot_Uv0,a3
    add.l d1,(a3)
    move.l _g_asm_s_edgeBot_dUVdX,a5
    move.l 4(a5),d1
    move.l _g_asm_s_edgeBot_Uv0,a3
    add.l d1,4(a3)
    move.l _g_asm_s_edgeBot_Y0,a3
    move.l (a3),d0
    add.l #$8000,d0
    swap d0
    ext.l d0
    move.l _g_asm_s_edgeBotY0_Pixel,a3
    move.l d0,(a3)
    bra .ft_loop_next

.ft_bot_findprev:
    move.l _g_asm_s_edgeBotIndex,a3
    move.l (a3),d0
    jsr _robj3d_findPrevEdgeT_asm
    move.l d0,F_FOUND(sp)

.ft_loop_next:
    move.l _g_asm_s_columnX,a3
    addq.l #1,(a3)
    addq.l #1,F_COLX(sp)
    bra .ft_col_loop

.ft_return:
    lea F_FRAMESZ(sp),sp
    movem.l (sp)+,d2-d7/a2-a6
    rts

_robj3d_drawShadedTexturePolygon_asm:
robj3d_drawShadedTexturePolygon_asm:
    movem.l d2-d7/a2-a6,-(sp)
    lea -F_FRAMESZ(sp),sp

    move.l F_ARG0(sp),a0
    move.l F_ARG1(sp),a1
    move.l F_ARG2(sp),a2
    move.l F_ARG3(sp),d0
    move.l F_ARG4(sp),a3
    move.l _g_asm_s_polyProjVtx,a4
    move.l a0,(a4)
    move.l _g_asm_s_polyVertexCount,a4
    move.l d0,(a4)
    move.l _g_asm_s_polyUv,a4
    move.l a1,(a4)
    move.l _g_asm_s_polyIntensity,a4
    move.l a2,(a4)
    move.l _g_asm_s_polyTexture,a4
    move.l a3,(a4)

    tst.l d0
    ble .st_return

    move.l #$7fffffff,d3
    move.l #$80000000,d4
    move.l d3,d5
    move.l d4,d6
    moveq #-1,d7
    moveq #-1,d0
    move.l d0,a4
    move.l _g_asm_s_polyVertexCount,a5
    move.l (a5),d1
    subq.l #1,d1
    moveq #0,d2
    move.l a0,a6

.st_bbox_loop:
    move.l (a6),d0
    cmp.l d3,d0
    bge .st_not_min
    move.l d0,d3
    move.l d2,d7

.st_not_min:
    cmp.l d0,d4
    bge .st_not_max
    move.l d0,d4
    move.l d2,a4

.st_not_max:
    move.l V3_Y(a6),d0
    cmp.l d5,d0
    bge .st_not_ymin
    move.l d0,d5

.st_not_ymin:
    cmp.l d6,d0
    ble .st_not_ymax
    move.l d0,d6

.st_not_ymax:
    addq.l #1,d2
    lea V3_SZ(a6),a6
    dbra d1,.st_bbox_loop

    move.l _g_asm_s_polyMaxIndex,a5
    move.l a4,(a5)

    cmp.l d4,d3
    bge .st_return
    cmp.l __ZN8TFE_Jedi19s_windowMaxY_PixelsE,d5
    bgt .st_return
    cmp.l __ZN8TFE_Jedi19s_windowMinY_PixelsE,d6
    blt .st_return

    move.l __ZN8TFE_Jedi10s_colorMapE,d0
    move.l _g_asm_s_polyColorMap,a5
    move.l d0,(a5)

    move.l _g_asm_s_columnX,a5
    move.l d3,(a5)
    move.l d3,F_COLX(sp)

    move.l d7,d0
    move.l d3,d1
    jsr _robj3d_findNextEdgeTI_asm
    tst.l d0
    bne .st_return

    move.l d7,d0
    jsr _robj3d_findPrevEdgeTI_asm
    tst.l d0
    bne .st_return

    lea _robj3d_drawColumnShadedTexture_asm,a6
    moveq #0,d0
    move.l d0,F_FOUND(sp)

.st_col_loop:
    tst.l F_FOUND(sp)
    bne .st_return
    move.l F_COLX(sp),d0
    cmp.l __ZN8TFE_Jedi19s_minScreenX_PixelsE,d0
    blt .st_return
    cmp.l __ZN8TFE_Jedi19s_maxScreenX_PixelsE,d0
    bgt .st_return

    move.l _g_asm_s_edgeBot_Z0,a5
    move.l (a5),d1
    move.l _g_asm_s_edgeTop_Z0,a5
    move.l (a5),d2
    cmp.l d2,d1
    ble .st_zmin_ok
    move.l d2,d1

.st_zmin_ok:
    move.l _g_rcfState_ptr,a0
    move.l 40(a0),a0
    move.l F_COLX(sp),d3
    lsl.l #2,d3
    move.l (a0,d3.l),d4

    cmp.l d4,d1
    bge .st_advance
    move.l _g_asm_s_edgeTopY0_Pixel,a5
    move.l (a5),d1
    cmp.l __ZN8TFE_Jedi19s_windowMaxY_PixelsE,d1
    bgt .st_advance
    move.l _g_asm_s_edgeBotY0_Pixel,a5
    move.l (a5),d2
    move.l d2,F_XMIN(sp)
    cmp.l __ZN8TFE_Jedi19s_windowMinY_PixelsE,d2
    blt .st_advance

    move.l __ZN8TFE_Jedi14s_objWindowTopE,a5
    move.l F_COLX(sp),d3
    lsl.l #2,d3
    move.l (a5,d3.l),d4
    move.l __ZN8TFE_Jedi14s_objWindowBotE,a5
    move.l (a5,d3.l),d5

    move.l d1,d6
    move.l d2,d7
    cmp.l d4,d6
    bge .st_top_ok
    move.l d4,d6

.st_top_ok:
    cmp.l d5,d7
    ble .st_bot_ok
    move.l d5,d7

.st_bot_ok:
    move.l d7,d0
    sub.l d6,d0
    addq.l #1,d0
    move.l _g_asm_s_columnHeight,a5
    move.l d0,(a5)
    ble .st_advance

    move.l d2,d0
    sub.l d1,d0
    addq.l #1,d0
    move.l _g_asm_s_edgeTop_I0,a5
    move.l (a5),d1
    move.l _g_asm_s_edgeBot_I0,a5
    sub.l (a5),d1
    divs.l d0,d1
    move.l _g_asm_s_col_dIdY,a5
    move.l d1,(a5)
    move.l _g_asm_s_edgeBot_I0,a5
    move.l (a5),d1
    move.l _g_asm_s_col_I0,a5
    move.l d1,(a5)

    move.l #ONE_16,d1
    divs.l d0,d1
    move.l _g_asm_s_edgeTop_Uv0,a5
    move.l (a5),d2
    move.l _g_asm_s_edgeBot_Uv0,a5
    sub.l (a5),d2
    muls.l d1,d0:d2
    move.w d0,d2
    swap d2
    move.l _g_asm_s_col_dUVdY,a5
    move.l d2,(a5)
    move.l _g_asm_s_edgeTop_Uv0,a5
    move.l 4(a5),d2
    move.l _g_asm_s_edgeBot_Uv0,a5
    sub.l 4(a5),d2
    muls.l d1,d0:d2
    move.w d0,d2
    swap d2
    move.l _g_asm_s_col_dUVdY,a5
    move.l d2,4(a5)
    move.l _g_asm_s_edgeBot_Uv0,a5
    move.l (a5),d2
    move.l 4(a5),d0
    move.l _g_asm_s_col_Uv0,a5
    move.l d2,(a5)
    move.l d0,4(a5)

    move.l F_XMIN(sp),d1
    cmp.l d5,d1
    ble .st_no_yoff
    sub.l d5,d1
    move.l _g_asm_s_col_dIdY,a5
    move.l (a5),d2
    muls.l d2,d1
    move.l _g_asm_s_col_I0,a5
    add.l d1,(a5)
    move.l _g_asm_s_col_dUVdY,a5
    move.l (a5),d2
    move.l F_XMIN(sp),d1
    sub.l d5,d1
    muls.l d2,d1
    move.l _g_asm_s_col_Uv0,a5
    add.l d1,(a5)
    move.l _g_asm_s_col_dUVdY,a5
    move.l 4(a5),d2
    move.l F_XMIN(sp),d1
    sub.l d5,d1
    muls.l d2,d1
    move.l _g_asm_s_col_Uv0,a5
    add.l d1,4(a5)

.st_no_yoff:
    move.l F_COLX(sp),d0
    and.l #1,d0
    move.l d7,d1
    and.l #1,d1
    eor.l d1,d0
    subq.l #1,d0
    move.l _g_asm_s_dither,a5
    move.l d0,(a5)

    move.l d6,d0
    lsl.l #8,d0
    move.l d6,d1
    lsl.l #6,d1
    add.l d1,d0
    add.l F_COLX(sp),d0
    move.l __ZN8TFE_Jedi9s_displayE,a0
    lea (a0,d0.l),a0
    move.l _g_asm_s_pcolumnOut,a5
    move.l a0,(a5)

    jsr (a6)

.st_advance:
    move.l _g_asm_s_edgeTopLength,a5
    move.l (a5),d0
    subq.l #1,d0
    move.l d0,(a5)
    ble .st_top_findnext
    move.l _g_asm_s_edgeTop_Y0,a5
    move.l (a5),d0
    move.l _g_asm_s_edgeTop_dYdX,a0
    add.l (a0),d0
    move.l d0,(a5)
    move.l _g_asm_s_edgeTop_dZdX,a0
    move.l (a0),d1
    move.l _g_asm_s_edgeTop_Z0,a5
    add.l d1,(a5)
    move.l _g_asm_s_edgeTop_I0,a5
    move.l (a5),d0
    move.l _g_asm_s_edgeTop_dIdX,a0
    add.l (a0),d0
    tst.l d0
    bge .st_i0_pos
    moveq #0,d0
    bra .st_i0_clamped

.st_i0_pos:
    cmp.l #VSHADE_MAX_INTENSITY,d0
    ble .st_i0_clamped
    move.l #VSHADE_MAX_INTENSITY,d0

.st_i0_clamped:
    move.l _g_asm_s_edgeTop_I0,a5
    move.l d0,(a5)
    move.l _g_asm_s_edgeTop_dUVdX,a0
    move.l (a0),d1
    move.l _g_asm_s_edgeTop_Uv0,a5
    add.l d1,(a5)
    move.l _g_asm_s_edgeTop_dUVdX,a0
    move.l 4(a0),d1
    move.l _g_asm_s_edgeTop_Uv0,a5
    add.l d1,4(a5)
    move.l _g_asm_s_edgeTop_Y0,a5
    move.l (a5),d0
    add.l #$8000,d0
    swap d0
    ext.l d0
    move.l _g_asm_s_edgeTopY0_Pixel,a5
    move.l d0,(a5)
    bra .st_bot_check

.st_top_findnext:
    move.l _g_asm_s_edgeTopIndex,a5
    move.l (a5),d0
    move.l F_COLX(sp),d1
    jsr _robj3d_findNextEdgeTI_asm
    move.l d0,F_FOUND(sp)

.st_bot_check:
    tst.l F_FOUND(sp)
    bne .st_loop_next
    move.l _g_asm_s_edgeBotLength,a5
    move.l (a5),d0
    subq.l #1,d0
    move.l d0,(a5)
    ble .st_bot_findprev
    move.l _g_asm_s_edgeBot_Y0,a5
    move.l (a5),d0
    move.l _g_asm_s_edgeBot_dYdX,a0
    add.l (a0),d0
    move.l d0,(a5)
    move.l _g_asm_s_edgeBot_dZdX,a0
    move.l (a0),d1
    move.l _g_asm_s_edgeBot_Z0,a5
    add.l d1,(a5)
    move.l _g_asm_s_edgeBot_I0,a5
    move.l (a5),d0
    move.l _g_asm_s_edgeBot_dIdX,a0
    add.l (a0),d0
    tst.l d0
    bge .st_i0_pos2
    moveq #0,d0
    bra .st_i0_clamped2

.st_i0_pos2:
    cmp.l #VSHADE_MAX_INTENSITY,d0
    ble .st_i0_clamped2
    move.l #VSHADE_MAX_INTENSITY,d0
    
.st_i0_clamped2:
    move.l _g_asm_s_edgeBot_I0,a5
    move.l d0,(a5)
    move.l _g_asm_s_edgeBot_dUVdX,a0
    move.l (a0),d1
    move.l _g_asm_s_edgeBot_Uv0,a5
    add.l d1,(a5)
    move.l _g_asm_s_edgeBot_dUVdX,a0
    move.l 4(a0),d1
    move.l _g_asm_s_edgeBot_Uv0,a5
    add.l d1,4(a5)
    move.l _g_asm_s_edgeBot_Y0,a5
    move.l (a5),d0
    add.l #$8000,d0
    swap d0
    ext.l d0
    move.l _g_asm_s_edgeBotY0_Pixel,a5
    move.l d0,(a5)
    bra .st_loop_next

.st_bot_findprev:
    move.l _g_asm_s_edgeBotIndex,a5
    move.l (a5),d0
    jsr _robj3d_findPrevEdgeTI_asm
    move.l d0,F_FOUND(sp)

.st_loop_next:
    move.l _g_asm_s_columnX,a5
    addq.l #1,(a5)
    addq.l #1,F_COLX(sp)
    bra .st_col_loop

.st_return:
    lea F_FRAMESZ(sp),sp
    movem.l (sp)+,d2-d7/a2-a6
    rts
