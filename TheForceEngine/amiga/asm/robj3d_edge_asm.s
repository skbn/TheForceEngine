
    section .text,code

    XDEF _robj3d_findNextEdge_asm
    XDEF robj3d_findNextEdge_asm
    XDEF _robj3d_findNextEdgeI_asm
    XDEF robj3d_findNextEdgeI_asm
    XDEF _robj3d_findNextEdgeT_asm
    XDEF robj3d_findNextEdgeT_asm
    XDEF _robj3d_findNextEdgeTI_asm
    XDEF robj3d_findNextEdgeTI_asm
    XDEF _robj3d_findPrevEdge_asm
    XDEF robj3d_findPrevEdge_asm
    XDEF _robj3d_findPrevEdgeI_asm
    XDEF robj3d_findPrevEdgeI_asm
    XDEF _robj3d_findPrevEdgeT_asm
    XDEF robj3d_findPrevEdgeT_asm
    XDEF _robj3d_findPrevEdgeTI_asm
    XDEF robj3d_findPrevEdgeTI_asm

    XREF _g_asm_s_polyProjVtx
    XREF _g_asm_s_polyVertexCount
    XREF _g_asm_s_polyMaxIndex
    XREF _g_asm_s_polyIntensity
    XREF _g_asm_s_polyUv
    XREF _g_asm_s_edgeTopLength
    XREF _g_asm_s_edgeTopY0_Pixel
    XREF _g_asm_s_edgeTop_Y0
    XREF _g_asm_s_edgeTop_dYdX
    XREF _g_asm_s_edgeTop_dZdX
    XREF _g_asm_s_edgeTop_Z0
    XREF _g_asm_s_edgeTop_I0
    XREF _g_asm_s_edgeTop_dIdX
    XREF _g_asm_s_edgeTop_Uv0
    XREF _g_asm_s_edgeTop_dUVdX
    XREF _g_asm_s_edgeTopIndex
    XREF _g_asm_s_edgeBotLength
    XREF _g_asm_s_edgeBotY0_Pixel
    XREF _g_asm_s_edgeBot_Y0
    XREF _g_asm_s_edgeBot_dYdX
    XREF _g_asm_s_edgeBot_dZdX
    XREF _g_asm_s_edgeBot_Z0
    XREF _g_asm_s_edgeBot_I0
    XREF _g_asm_s_edgeBot_dIdX
    XREF _g_asm_s_edgeBot_Uv0
    XREF _g_asm_s_edgeBot_dUVdX
    XREF _g_asm_s_edgeBotIndex
    XREF __ZN8TFE_Jedi19s_maxScreenX_PixelsE

V3_X = 0
V3_Y = 4
V3_Z = 8
V3_SZ = 12

V2_X = 0
V2_Z = 4
V2_SZ = 8

ONE_16 = $10000

VSHADE_MAX_INTENSITY = $1f0000

_robj3d_findNextEdge_asm:
robj3d_findNextEdge_asm:
    movem.l d2-d7/a2-a3/a5-a6,-(sp)

    move.l d0,d5
    move.l _g_asm_s_edgeTopLength,a2
    move.l (a2),d7

    move.l _g_asm_s_polyMaxIndex,a2
    cmp.l (a2),d5
    bne .ne_loop
    move.l _g_asm_s_edgeTopLength,a2
    move.l d7,(a2)
    moveq #-1,d0
    bra .ne_ret

.ne_loop:
    move.l _g_asm_s_polyProjVtx,a6
    move.l (a6),a6
    move.l _g_asm_s_polyVertexCount,a5
    move.l (a5),d4
    move.l _g_asm_s_polyMaxIndex,a3
    move.l (a3),d6

.ne_loop_top:
    move.l d5,d3
    addq.l #1,d3
    cmp.l d4,d3
    blt .ne_next_lo
    moveq #0,d3
    bra .ne_next_set

.ne_next_lo:
    tst.l d3
    bge .ne_next_set
    move.l d4,d3
    subq.l #1,d3

.ne_next_set:
    move.l d5,d0
    mulu.w #V3_SZ,d0
    lea (a6,d0.l),a2
    move.l d3,d0
    mulu.w #V3_SZ,d0
    lea (a6,d0.l),a3

    move.l (a3),d0
    sub.l (a2),d0
    move.l (a3),d1
    cmp.l __ZN8TFE_Jedi19s_maxScreenX_PixelsE,d1
    bne .ne_dx_done
    addq.l #1,d0

.ne_dx_done:
    tst.l d0
    ble .ne_not_found

    move.l _g_asm_s_edgeTopLength,a5
    move.l d0,(a5)

    move.l #ONE_16,d1
    divs.l d0,d1
    move.l d1,d7

    move.l V3_Y(a2),d2
    move.l _g_asm_s_edgeTopY0_Pixel,a5
    move.l d2,(a5)

    move.w d2,d3
    swap d3
    move.l _g_asm_s_edgeTop_Y0,a5
    move.l d3,(a5)

    move.l V3_Y(a3),d0
    sub.l V3_Y(a2),d0
    muls.l d7,d0
    move.l _g_asm_s_edgeTop_dYdX,a5
    move.l d0,(a5)

    move.l V3_Z(a3),d2
    sub.l V3_Z(a2),d2
    muls.l d7,d1:d2
    move.w d1,d2
    swap d2
    move.l _g_asm_s_edgeTop_dZdX,a5
    move.l d2,(a5)

    move.l V3_Z(a2),d0
    move.l _g_asm_s_edgeTop_Z0,a5
    move.l d0,(a5)

    move.l d5,d3
    addq.l #1,d3
    cmp.l d4,d3
    blt .ne_index_lo
    moveq #0,d3
    bra .ne_index_set

.ne_index_lo:
    tst.l d3
    bge .ne_index_set
    move.l d4,d3
    subq.l #1,d3

.ne_index_set:
    move.l _g_asm_s_edgeTopIndex,a5
    move.l d3,(a5)
    moveq #0,d0
    bra .ne_ret

.ne_not_found:
    cmp.l d6,d3
    bne .ne_continue
    move.l _g_asm_s_edgeTopLength,a5
    move.l d7,(a5)
    moveq #-1,d0
    bra .ne_ret

.ne_continue:
    move.l d3,d5
    bra .ne_loop_top

.ne_ret:
    movem.l (sp)+,d2-d7/a2-a3/a5-a6
    rts

_robj3d_findPrevEdge_asm:
robj3d_findPrevEdge_asm:
    movem.l d2-d7/a2-a3/a5-a6,-(sp)

    move.l d0,d5
    move.l _g_asm_s_edgeBotLength,a2
    move.l (a2),d7

    move.l _g_asm_s_polyMaxIndex,a2
    cmp.l (a2),d5
    bne .pe_loop
    move.l _g_asm_s_edgeBotLength,a2
    move.l d7,(a2)
    moveq #-1,d0
    bra .pe_ret

.pe_loop:
    move.l _g_asm_s_polyProjVtx,a6
    move.l (a6),a6
    move.l _g_asm_s_polyVertexCount,a5
    move.l (a5),d4
    move.l _g_asm_s_polyMaxIndex,a3
    move.l (a3),d6

.pe_loop_top:
    move.l d5,d3
    subq.l #1,d3
    cmp.l d4,d3
    blt .pe_prev_lo
    moveq #0,d3
    bra .pe_prev_set

.pe_prev_lo:
    tst.l d3
    bge .pe_prev_set
    move.l d4,d3
    subq.l #1,d3

.pe_prev_set:
    move.l d5,d0
    mulu.w #V3_SZ,d0
    lea (a6,d0.l),a2
    move.l d3,d0
    mulu.w #V3_SZ,d0
    lea (a6,d0.l),a3

    move.l (a3),d0
    sub.l (a2),d0
    move.l (a3),d1
    cmp.l __ZN8TFE_Jedi19s_maxScreenX_PixelsE,d1
    bne .pe_dx_done
    addq.l #1,d0

.pe_dx_done:
    tst.l d0
    ble .pe_not_found

    move.l _g_asm_s_edgeBotLength,a5
    move.l d0,(a5)
    move.l #ONE_16,d1
    divs.l d0,d1
    move.l d1,d7
    move.l V3_Y(a2),d2
    move.l _g_asm_s_edgeBotY0_Pixel,a5
    move.l d2,(a5)
    move.w d2,d3
    swap d3
    move.l _g_asm_s_edgeBot_Y0,a5
    move.l d3,(a5)
    move.l V3_Y(a3),d0
    sub.l V3_Y(a2),d0
    muls.l d7,d0
    move.l _g_asm_s_edgeBot_dYdX,a5
    move.l d0,(a5)
    move.l V3_Z(a3),d2
    sub.l V3_Z(a2),d2
    muls.l d7,d1:d2
    move.w d1,d2
    swap d2

    move.l _g_asm_s_edgeBot_dZdX,a5
    move.l d2,(a5)
    move.l V3_Z(a2),d0
    move.l _g_asm_s_edgeBot_Z0,a5
    move.l d0,(a5)
    move.l d5,d3
    subq.l #1,d3
    cmp.l d4,d3
    blt .pe_index_lo
    moveq #0,d3
    bra .pe_index_set

.pe_index_lo:
    tst.l d3
    bge .pe_index_set
    move.l d4,d3
    subq.l #1,d3

.pe_index_set:
    move.l _g_asm_s_edgeBotIndex,a5
    move.l d3,(a5)
    moveq #0,d0
    bra .pe_ret

.pe_not_found:
    move.l d3,d5
    cmp.l d6,d3
    bne .pe_loop_top
    move.l _g_asm_s_edgeBotLength,a5
    move.l d7,(a5)
    moveq #-1,d0

.pe_ret:
    movem.l (sp)+,d2-d7/a2-a3/a5-a6
    rts


_robj3d_findNextEdgeI_asm:
robj3d_findNextEdgeI_asm:
    movem.l d2-d7/a2-a3/a5-a6,-(sp)

    move.l d0,d5
    move.l _g_asm_s_edgeTopLength,a2
    move.l (a2),d7

    move.l _g_asm_s_polyMaxIndex,a2
    cmp.l (a2),d5
    bne .neI_loop
    move.l _g_asm_s_edgeTopLength,a2
    move.l d7,(a2)
    moveq #-1,d0
    bra .neI_ret

.neI_loop:
    move.l _g_asm_s_polyProjVtx,a6
    move.l (a6),a6
    move.l _g_asm_s_polyVertexCount,a5
    move.l (a5),d4
    move.l _g_asm_s_polyMaxIndex,a3
    move.l (a3),d6
    move.l _g_asm_s_polyIntensity,a1
    move.l (a1),a1

.neI_loop_top:
    move.l d5,d3
    addq.l #1,d3
    cmp.l d4,d3
    blt .neI_next_lo
    moveq #0,d3
    bra .neI_next_set

.neI_next_lo:
    tst.l d3
    bge .neI_next_set
    move.l d4,d3
    subq.l #1,d3

.neI_next_set:
    move.l d5,d0
    mulu.w #V3_SZ,d0
    lea (a6,d0.l),a2
    move.l d3,d0
    mulu.w #V3_SZ,d0
    lea (a6,d0.l),a3

    move.l (a3),d0
    sub.l (a2),d0
    move.l (a3),d1
    cmp.l __ZN8TFE_Jedi19s_maxScreenX_PixelsE,d1
    bne .neI_dx_done
    addq.l #1,d0

.neI_dx_done:
    tst.l d0
    ble .neI_not_found

    move.l _g_asm_s_edgeTopLength,a5
    move.l d0,(a5)
    move.l #ONE_16,d1
    divs.l d0,d1
    move.l d1,d7
    move.l V3_Y(a2),d2
    move.l _g_asm_s_edgeTopY0_Pixel,a5
    move.l d2,(a5)
    move.w d2,d3
    swap d3
    move.l _g_asm_s_edgeTop_Y0,a5
    move.l d3,(a5)
    move.l V3_Y(a3),d0
    sub.l V3_Y(a2),d0
    muls.l d7,d0
    move.l _g_asm_s_edgeTop_dYdX,a5
    move.l d0,(a5)
    move.l V3_Z(a3),d2
    sub.l V3_Z(a2),d2
    muls.l d7,d1:d2
    move.w d1,d2
    swap d2
    move.l _g_asm_s_edgeTop_dZdX,a5
    move.l d2,(a5)
    move.l V3_Z(a2),d0
    move.l _g_asm_s_edgeTop_Z0,a5
    move.l d0,(a5)

    move.l (a1,d5.l*4),d2
    tst.l d2
    bge .neI_i0_pos
    moveq #0,d2
    bra .neI_i0_clamped

.neI_i0_pos:
    cmp.l #VSHADE_MAX_INTENSITY,d2
    ble .neI_i0_clamped
    move.l #VSHADE_MAX_INTENSITY,d2

.neI_i0_clamped:
    move.l _g_asm_s_edgeTop_I0,a5
    move.l d2,(a5)

    move.l d5,d3
    addq.l #1,d3
    cmp.l d4,d3
    blt .neI_idx_lo
    moveq #0,d3
    bra .neI_idx_set

.neI_idx_lo:
    tst.l d3
    bge .neI_idx_set
    move.l d4,d3
    subq.l #1,d3

.neI_idx_set:
    move.l (a1,d3.l*4),d0
    sub.l d2,d0
    muls.l d7,d1:d0
    move.w d1,d0
    swap d0
    move.l _g_asm_s_edgeTop_dIdX,a5
    move.l d0,(a5)

    move.l _g_asm_s_edgeTopIndex,a5
    move.l d3,(a5)
    moveq #0,d0
    bra .neI_ret

.neI_not_found:
    cmp.l d6,d3
    bne .neI_continue
    move.l _g_asm_s_edgeTopLength,a5
    move.l d7,(a5)
    moveq #-1,d0
    bra .neI_ret

.neI_continue:
    move.l d3,d5
    bra .neI_loop_top

.neI_ret:
    movem.l (sp)+,d2-d7/a2-a3/a5-a6
    rts


_robj3d_findNextEdgeT_asm:
robj3d_findNextEdgeT_asm:
    movem.l d2-d7/a2-a3/a5-a6,-(sp)

    move.l d0,d5
    move.l _g_asm_s_edgeTopLength,a2
    move.l (a2),d7

    move.l _g_asm_s_polyMaxIndex,a2
    cmp.l (a2),d5
    bne .neT_loop
    move.l _g_asm_s_edgeTopLength,a2
    move.l d7,(a2)
    moveq #-1,d0
    bra .neT_ret

.neT_loop:
    move.l _g_asm_s_polyProjVtx,a6
    move.l (a6),a6
    move.l _g_asm_s_polyVertexCount,a5
    move.l (a5),d4
    move.l _g_asm_s_polyMaxIndex,a3
    move.l (a3),d6
    move.l _g_asm_s_polyUv,a1
    move.l (a1),a1

.neT_loop_top:
    move.l d5,d3
    addq.l #1,d3
    cmp.l d4,d3
    blt .neT_next_lo
    moveq #0,d3
    bra .neT_next_set

.neT_next_lo:
    tst.l d3
    bge .neT_next_set
    move.l d4,d3
    subq.l #1,d3

.neT_next_set:
    move.l d5,d0
    mulu.w #V3_SZ,d0
    lea (a6,d0.l),a2
    move.l d3,d0
    mulu.w #V3_SZ,d0
    lea (a6,d0.l),a3

    move.l (a3),d0
    sub.l (a2),d0
    move.l (a3),d1
    cmp.l __ZN8TFE_Jedi19s_maxScreenX_PixelsE,d1
    bne .neT_dx_done
    addq.l #1,d0

.neT_dx_done:
    tst.l d0
    ble .neT_not_found

    move.l _g_asm_s_edgeTopLength,a5
    move.l d0,(a5)
    move.l #ONE_16,d1
    divs.l d0,d1
    move.l d1,d7
    move.l V3_Y(a2),d2
    move.l _g_asm_s_edgeTopY0_Pixel,a5
    move.l d2,(a5)
    move.w d2,d3
    swap d3
    move.l _g_asm_s_edgeTop_Y0,a5
    move.l d3,(a5)
    move.l V3_Y(a3),d0
    sub.l V3_Y(a2),d0
    muls.l d7,d0
    move.l _g_asm_s_edgeTop_dYdX,a5
    move.l d0,(a5)
    move.l V3_Z(a3),d2
    sub.l V3_Z(a2),d2
    muls.l d7,d1:d2
    move.w d1,d2
    swap d2
    move.l _g_asm_s_edgeTop_dZdX,a5
    move.l d2,(a5)
    move.l V3_Z(a2),d0
    move.l _g_asm_s_edgeTop_Z0,a5
    move.l d0,(a5)

    move.l (a1,d5.l*8),d2
    move.l 4(a1,d5.l*8),d0
    move.l _g_asm_s_edgeTop_Uv0,a5
    move.l d2,(a5)
    move.l d0,4(a5)

    move.l d5,d3
    addq.l #1,d3
    cmp.l d4,d3
    blt .neT_uv_lo
    moveq #0,d3
    bra .neT_uv_set

.neT_uv_lo:
    tst.l d3
    bge .neT_uv_set
    move.l d4,d3
    subq.l #1,d3

.neT_uv_set:
    move.l (a1,d3.l*8),d2
    move.l _g_asm_s_edgeTop_Uv0,a5
    move.l (a5),d0
    sub.l d0,d2
    muls.l d7,d1:d2
    move.w d1,d2
    swap d2
    move.l _g_asm_s_edgeTop_dUVdX,a5
    move.l d2,(a5)

    move.l 4(a1,d3.l*8),d2
    move.l _g_asm_s_edgeTop_Uv0,a5
    move.l 4(a5),d0
    sub.l d0,d2
    muls.l d7,d1:d2
    move.w d1,d2
    swap d2
    move.l _g_asm_s_edgeTop_dUVdX,a5
    move.l d2,4(a5)

    move.l _g_asm_s_edgeTopIndex,a5
    move.l d3,(a5)
    moveq #0,d0
    bra .neT_ret

.neT_not_found:
    cmp.l d6,d3
    bne .neT_continue
    move.l _g_asm_s_edgeTopLength,a5
    move.l d7,(a5)
    moveq #-1,d0
    bra .neT_ret

.neT_continue:
    move.l d3,d5
    bra .neT_loop_top

.neT_ret:
    movem.l (sp)+,d2-d7/a2-a3/a5-a6
    rts


_robj3d_findNextEdgeTI_asm:
robj3d_findNextEdgeTI_asm:
    movem.l d2-d7/a2-a3/a5-a6,-(sp)

    move.l d0,d5
    move.l _g_asm_s_edgeTopLength,a2
    move.l (a2),d7

    move.l _g_asm_s_polyMaxIndex,a2
    cmp.l (a2),d5
    bne .neTI_loop
    move.l _g_asm_s_edgeTopLength,a2
    move.l d7,(a2)
    moveq #-1,d0
    bra .neTI_ret

.neTI_loop:
    move.l _g_asm_s_polyProjVtx,a6
    move.l (a6),a6
    move.l _g_asm_s_polyVertexCount,a5
    move.l (a5),d4
    move.l _g_asm_s_polyMaxIndex,a3
    move.l (a3),d6
    move.l _g_asm_s_polyIntensity,a0
    move.l (a0),a0
    move.l _g_asm_s_polyUv,a1
    move.l (a1),a1

.neTI_loop_top:
    move.l d5,d3
    addq.l #1,d3
    cmp.l d4,d3
    blt .neTI_next_lo
    moveq #0,d3
    bra .neTI_next_set

.neTI_next_lo:
    tst.l d3
    bge .neTI_next_set
    move.l d4,d3
    subq.l #1,d3

.neTI_next_set:
    move.l d5,d0
    mulu.w #V3_SZ,d0
    lea (a6,d0.l),a2
    move.l d3,d0
    mulu.w #V3_SZ,d0
    lea (a6,d0.l),a3

    move.l (a3),d0
    sub.l (a2),d0
    move.l (a3),d1
    cmp.l __ZN8TFE_Jedi19s_maxScreenX_PixelsE,d1
    bne .neTI_dx_done
    addq.l #1,d0

.neTI_dx_done:
    tst.l d0
    ble .neTI_not_found

    move.l _g_asm_s_edgeTopLength,a5
    move.l d0,(a5)
    move.l #ONE_16,d1
    divs.l d0,d1
    move.l d1,d7
    move.l V3_Y(a2),d2
    move.l _g_asm_s_edgeTopY0_Pixel,a5
    move.l d2,(a5)
    move.w d2,d3
    swap d3
    move.l _g_asm_s_edgeTop_Y0,a5
    move.l d3,(a5)
    move.l V3_Y(a3),d0
    sub.l V3_Y(a2),d0
    muls.l d7,d0
    move.l _g_asm_s_edgeTop_dYdX,a5
    move.l d0,(a5)
    move.l V3_Z(a3),d2
    sub.l V3_Z(a2),d2
    muls.l d7,d1:d2
    move.w d1,d2
    swap d2
    move.l _g_asm_s_edgeTop_dZdX,a5
    move.l d2,(a5)
    move.l V3_Z(a2),d0
    move.l _g_asm_s_edgeTop_Z0,a5
    move.l d0,(a5)

    move.l (a0,d5.l*4),d2
    tst.l d2
    bge .neTI_i0_pos
    moveq #0,d2
    bra .neTI_i0_clamped

.neTI_i0_pos:
    cmp.l #VSHADE_MAX_INTENSITY,d2
    ble .neTI_i0_clamped
    move.l #VSHADE_MAX_INTENSITY,d2

.neTI_i0_clamped:
    move.l _g_asm_s_edgeTop_I0,a5
    move.l d2,(a5)

    move.l d5,d3
    addq.l #1,d3
    cmp.l d4,d3
    blt .neTI_idx_lo
    moveq #0,d3
    bra .neTI_idx_set

.neTI_idx_lo:
    tst.l d3
    bge .neTI_idx_set
    move.l d4,d3
    subq.l #1,d3

.neTI_idx_set:
    move.l (a0,d3.l*4),d0
    sub.l d2,d0
    muls.l d7,d1:d0
    move.w d1,d0
    swap d0
    move.l _g_asm_s_edgeTop_dIdX,a5
    move.l d0,(a5)

    move.l (a1,d5.l*8),d2
    move.l 4(a1,d5.l*8),d0
    move.l _g_asm_s_edgeTop_Uv0,a5
    move.l d2,(a5)
    move.l d0,4(a5)
    move.l (a1,d3.l*8),d2
    move.l _g_asm_s_edgeTop_Uv0,a5
    move.l (a5),d0
    sub.l d0,d2
    muls.l d7,d1:d2
    move.w d1,d2
    swap d2
    move.l _g_asm_s_edgeTop_dUVdX,a5
    move.l d2,(a5)
    move.l 4(a1,d3.l*8),d2
    move.l _g_asm_s_edgeTop_Uv0,a5
    move.l 4(a5),d0
    sub.l d0,d2
    muls.l d7,d1:d2
    move.w d1,d2
    swap d2
    move.l _g_asm_s_edgeTop_dUVdX,a5
    move.l d2,4(a5)

    move.l _g_asm_s_edgeTopIndex,a5
    move.l d3,(a5)
    moveq #0,d0
    bra .neTI_ret

.neTI_not_found:
    cmp.l d6,d3
    bne .neTI_continue
    move.l _g_asm_s_edgeTopLength,a5
    move.l d7,(a5)
    moveq #-1,d0
    bra .neTI_ret

.neTI_continue:
    move.l d3,d5
    bra .neTI_loop_top

.neTI_ret:
    movem.l (sp)+,d2-d7/a2-a3/a5-a6
    rts


_robj3d_findPrevEdgeI_asm:
robj3d_findPrevEdgeI_asm:
    movem.l d2-d7/a2-a3/a5-a6,-(sp)

    move.l d0,d5
    move.l _g_asm_s_edgeBotLength,a2
    move.l (a2),d7

    move.l _g_asm_s_polyMaxIndex,a2
    cmp.l (a2),d5
    bne .peI_loop
    move.l _g_asm_s_edgeBotLength,a2
    move.l d7,(a2)
    moveq #-1,d0
    bra .peI_ret

.peI_loop:
    move.l _g_asm_s_polyProjVtx,a6
    move.l (a6),a6
    move.l _g_asm_s_polyVertexCount,a5
    move.l (a5),d4
    move.l _g_asm_s_polyMaxIndex,a3
    move.l (a3),d6
    move.l _g_asm_s_polyIntensity,a1
    move.l (a1),a1

.peI_loop_top:
    move.l d5,d3
    subq.l #1,d3
    cmp.l d4,d3
    blt .peI_prev_lo
    moveq #0,d3
    bra .peI_prev_set

.peI_prev_lo:
    tst.l d3
    bge .peI_prev_set
    move.l d4,d3
    subq.l #1,d3

.peI_prev_set:
    move.l d5,d0
    mulu.w #V3_SZ,d0
    lea (a6,d0.l),a2
    move.l d3,d0
    mulu.w #V3_SZ,d0
    lea (a6,d0.l),a3

    move.l (a3),d0
    sub.l (a2),d0
    move.l (a3),d1
    cmp.l __ZN8TFE_Jedi19s_maxScreenX_PixelsE,d1
    bne .peI_dx_done
    addq.l #1,d0

.peI_dx_done:
    tst.l d0
    ble .peI_not_found

    move.l _g_asm_s_edgeBotLength,a5
    move.l d0,(a5)
    move.l #ONE_16,d1
    divs.l d0,d1
    move.l d1,d7
    move.l V3_Y(a2),d2
    move.l _g_asm_s_edgeBotY0_Pixel,a5
    move.l d2,(a5)
    move.w d2,d3
    swap d3
    move.l _g_asm_s_edgeBot_Y0,a5
    move.l d3,(a5)
    move.l V3_Y(a3),d0
    sub.l V3_Y(a2),d0
    muls.l d7,d0
    move.l _g_asm_s_edgeBot_dYdX,a5
    move.l d0,(a5)
    move.l V3_Z(a3),d2
    sub.l V3_Z(a2),d2
    muls.l d7,d1:d2
    move.w d1,d2
    swap d2
    move.l _g_asm_s_edgeBot_dZdX,a5
    move.l d2,(a5)
    move.l V3_Z(a2),d0
    move.l _g_asm_s_edgeBot_Z0,a5
    move.l d0,(a5)

    move.l (a1,d5.l*4),d2
    tst.l d2
    bge .peI_i0_pos
    moveq #0,d2
    bra .peI_i0_clamped

.peI_i0_pos:
    cmp.l #VSHADE_MAX_INTENSITY,d2
    ble .peI_i0_clamped
    move.l #VSHADE_MAX_INTENSITY,d2

.peI_i0_clamped:
    move.l _g_asm_s_edgeBot_I0,a5
    move.l d2,(a5)

    move.l d5,d3
    subq.l #1,d3
    cmp.l d4,d3
    blt .peI_idx_lo
    moveq #0,d3
    bra .peI_idx_set

.peI_idx_lo:
    tst.l d3
    bge .peI_idx_set
    move.l d4,d3
    subq.l #1,d3
.peI_idx_set:

    move.l (a1,d3.l*4),d0
    sub.l d2,d0
    muls.l d7,d1:d0
    move.w d1,d0
    swap d0
    move.l _g_asm_s_edgeBot_dIdX,a5
    move.l d0,(a5)

    move.l _g_asm_s_edgeBotIndex,a5
    move.l d3,(a5)
    moveq #0,d0
    bra .peI_ret

.peI_not_found:
    move.l d3,d5
    cmp.l d6,d3
    bne .peI_loop_top
    move.l _g_asm_s_edgeBotLength,a5
    move.l d7,(a5)
    moveq #-1,d0

.peI_ret:
    movem.l (sp)+,d2-d7/a2-a3/a5-a6
    rts

_robj3d_findPrevEdgeT_asm:
robj3d_findPrevEdgeT_asm:
    movem.l d2-d7/a2-a3/a5-a6,-(sp)

    move.l d0,d5
    move.l _g_asm_s_edgeBotLength,a2
    move.l (a2),d7

    move.l _g_asm_s_polyMaxIndex,a2
    cmp.l (a2),d5
    bne .peT_loop
    move.l _g_asm_s_edgeBotLength,a2
    move.l d7,(a2)
    moveq #-1,d0
    bra .peT_ret

.peT_loop:
    move.l _g_asm_s_polyProjVtx,a6
    move.l (a6),a6
    move.l _g_asm_s_polyVertexCount,a5
    move.l (a5),d4
    move.l _g_asm_s_polyMaxIndex,a3
    move.l (a3),d6
    move.l _g_asm_s_polyUv,a1
    move.l (a1),a1

.peT_loop_top:
    move.l d5,d3
    subq.l #1,d3
    cmp.l d4,d3
    blt .peT_prev_lo
    moveq #0,d3
    bra .peT_prev_set

.peT_prev_lo:
    tst.l d3
    bge .peT_prev_set
    move.l d4,d3
    subq.l #1,d3

.peT_prev_set:
    move.l d5,d0
    mulu.w #V3_SZ,d0
    lea (a6,d0.l),a2
    move.l d3,d0
    mulu.w #V3_SZ,d0
    lea (a6,d0.l),a3

    move.l (a3),d0
    sub.l (a2),d0
    move.l (a3),d1
    cmp.l __ZN8TFE_Jedi19s_maxScreenX_PixelsE,d1
    bne .peT_dx_done
    addq.l #1,d0

.peT_dx_done:
    tst.l d0
    ble .peT_not_found

    move.l _g_asm_s_edgeBotLength,a5
    move.l d0,(a5)
    move.l #ONE_16,d1
    divs.l d0,d1
    move.l d1,d7
    move.l V3_Y(a2),d2
    move.l _g_asm_s_edgeBotY0_Pixel,a5
    move.l d2,(a5)
    move.w d2,d3
    swap d3
    move.l _g_asm_s_edgeBot_Y0,a5
    move.l d3,(a5)
    move.l V3_Y(a3),d0
    sub.l V3_Y(a2),d0
    muls.l d7,d0
    move.l _g_asm_s_edgeBot_dYdX,a5
    move.l d0,(a5)
    move.l V3_Z(a3),d2
    sub.l V3_Z(a2),d2
    muls.l d7,d1:d2
    move.w d1,d2
    swap d2
    move.l _g_asm_s_edgeBot_dZdX,a5
    move.l d2,(a5)
    move.l V3_Z(a2),d0
    move.l _g_asm_s_edgeBot_Z0,a5
    move.l d0,(a5)

    move.l (a1,d5.l*8),d2
    move.l 4(a1,d5.l*8),d0
    move.l _g_asm_s_edgeBot_Uv0,a5
    move.l d2,(a5)
    move.l d0,4(a5)
    move.l d5,d3
    subq.l #1,d3
    cmp.l d4,d3
    blt .peT_idx_lo
    moveq #0,d3
    bra .peT_idx_set

.peT_idx_lo:
    tst.l d3
    bge .peT_idx_set
    move.l d4,d3
    subq.l #1,d3

.peT_idx_set:
    move.l (a1,d3.l*8),d2
    move.l _g_asm_s_edgeBot_Uv0,a5
    move.l (a5),d0
    sub.l d0,d2
    muls.l d7,d1:d2
    move.w d1,d2
    swap d2
    move.l _g_asm_s_edgeBot_dUVdX,a5
    move.l d2,(a5)
    move.l 4(a1,d3.l*8),d2
    move.l _g_asm_s_edgeBot_Uv0,a5
    move.l 4(a5),d0
    sub.l d0,d2
    muls.l d7,d1:d2
    move.w d1,d2
    swap d2
    move.l _g_asm_s_edgeBot_dUVdX,a5
    move.l d2,4(a5)

    move.l _g_asm_s_edgeBotIndex,a5
    move.l d3,(a5)
    moveq #0,d0
    bra .peT_ret

.peT_not_found:
    move.l d3,d5
    cmp.l d6,d3
    bne .peT_loop_top
    move.l _g_asm_s_edgeBotLength,a5
    move.l d7,(a5)
    moveq #-1,d0

.peT_ret:
    movem.l (sp)+,d2-d7/a2-a3/a5-a6
    rts

_robj3d_findPrevEdgeTI_asm:
robj3d_findPrevEdgeTI_asm:
    movem.l d2-d7/a2-a3/a5-a6,-(sp)

    move.l d0,d5
    move.l _g_asm_s_edgeBotLength,a2
    move.l (a2),d7

    move.l _g_asm_s_polyMaxIndex,a2
    cmp.l (a2),d5
    bne .peTI_loop
    move.l _g_asm_s_edgeBotLength,a2
    move.l d7,(a2)
    moveq #-1,d0
    bra .peTI_ret

.peTI_loop:
    move.l _g_asm_s_polyProjVtx,a6
    move.l (a6),a6
    move.l _g_asm_s_polyVertexCount,a5
    move.l (a5),d4
    move.l _g_asm_s_polyMaxIndex,a3
    move.l (a3),d6
    move.l _g_asm_s_polyIntensity,a0
    move.l (a0),a0
    move.l _g_asm_s_polyUv,a1
    move.l (a1),a1

.peTI_loop_top:
    move.l d5,d3
    subq.l #1,d3
    cmp.l d4,d3
    blt .peTI_prev_lo
    moveq #0,d3
    bra .peTI_prev_set

.peTI_prev_lo:
    tst.l d3
    bge .peTI_prev_set
    move.l d4,d3
    subq.l #1,d3

.peTI_prev_set:
    move.l d5,d0
    mulu.w #V3_SZ,d0
    lea (a6,d0.l),a2
    move.l d3,d0
    mulu.w #V3_SZ,d0
    lea (a6,d0.l),a3

    move.l (a3),d0
    sub.l (a2),d0
    move.l (a3),d1
    cmp.l __ZN8TFE_Jedi19s_maxScreenX_PixelsE,d1
    bne .peTI_dx_done
    addq.l #1,d0

.peTI_dx_done:
    tst.l d0
    ble .peTI_not_found

    move.l _g_asm_s_edgeBotLength,a5
    move.l d0,(a5)
    move.l #ONE_16,d1
    divs.l d0,d1
    move.l d1,d7
    move.l V3_Y(a2),d2
    move.l _g_asm_s_edgeBotY0_Pixel,a5
    move.l d2,(a5)
    move.w d2,d3
    swap d3
    move.l _g_asm_s_edgeBot_Y0,a5
    move.l d3,(a5)
    move.l V3_Y(a3),d0
    sub.l V3_Y(a2),d0
    muls.l d7,d0
    move.l _g_asm_s_edgeBot_dYdX,a5
    move.l d0,(a5)
    move.l V3_Z(a3),d2
    sub.l V3_Z(a2),d2
    muls.l d7,d1:d2
    move.w d1,d2
    swap d2
    move.l _g_asm_s_edgeBot_dZdX,a5
    move.l d2,(a5)
    move.l V3_Z(a2),d0
    move.l _g_asm_s_edgeBot_Z0,a5
    move.l d0,(a5)

    move.l (a0,d5.l*4),d2
    tst.l d2
    bge .peTI_i0_pos
    moveq #0,d2
    bra .peTI_i0_clamped

.peTI_i0_pos:
    cmp.l #VSHADE_MAX_INTENSITY,d2
    ble .peTI_i0_clamped
    move.l #VSHADE_MAX_INTENSITY,d2

.peTI_i0_clamped:
    move.l _g_asm_s_edgeBot_I0,a5
    move.l d2,(a5)
    move.l d5,d3
    subq.l #1,d3
    cmp.l d4,d3
    blt .peTI_idx_lo
    moveq #0,d3
    bra .peTI_idx_set

.peTI_idx_lo:
    tst.l d3
    bge .peTI_idx_set
    move.l d4,d3
    subq.l #1,d3
    
.peTI_idx_set:
    move.l (a0,d3.l*4),d0
    sub.l d2,d0
    muls.l d7,d1:d0
    move.w d1,d0
    swap d0
    move.l _g_asm_s_edgeBot_dIdX,a5
    move.l d0,(a5)

    move.l (a1,d5.l*8),d2
    move.l 4(a1,d5.l*8),d0
    move.l _g_asm_s_edgeBot_Uv0,a5
    move.l d2,(a5)
    move.l d0,4(a5)
    move.l (a1,d3.l*8),d2
    move.l _g_asm_s_edgeBot_Uv0,a5
    move.l (a5),d0
    sub.l d0,d2
    muls.l d7,d1:d2
    move.w d1,d2
    swap d2
    move.l _g_asm_s_edgeBot_dUVdX,a5
    move.l d2,(a5)
    move.l 4(a1,d3.l*8),d2
    move.l _g_asm_s_edgeBot_Uv0,a5
    move.l 4(a5),d0
    sub.l d0,d2
    muls.l d7,d1:d2
    move.w d1,d2
    swap d2
    move.l _g_asm_s_edgeBot_dUVdX,a5
    move.l d2,4(a5)

    move.l _g_asm_s_edgeBotIndex,a5
    move.l d3,(a5)
    moveq #0,d0
    bra .peTI_ret

.peTI_not_found:
    move.l d3,d5
    cmp.l d6,d3
    bne .peTI_loop_top
    move.l _g_asm_s_edgeBotLength,a5
    move.l d7,(a5)
    moveq #-1,d0

.peTI_ret:
    movem.l (sp)+,d2-d7/a2-a3/a5-a6
    rts
