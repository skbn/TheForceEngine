;
; TheForceEngine - Amiga port
;
; 68020+
;

    section .text,code

    XDEF _robj3d_shadeVertices_asm
    XDEF robj3d_shadeVertices_asm

    XREF _g_asm_s_sectorAmbient
    XREF _g_asm_s_scaledAmbient
    XREF _g_asm_s_cameraLightSource
    XREF _g_asm_s_worldAmbient
    XREF _g_asm_s_sectorAmbientFraction
    XREF _g_asm_s_lightCount
    XREF _g_asm_s_lightSourceRamp
    XREF _g_asm_s_cameraLight

; void robj3d_shadeVertices_asm
; d0=count a0=out a1=vtx a2=normals
; frame: 4=secAmb 8=lightCnt 12=ambFrac 16=worldAmb 20=camLightSrc 24=scaledAmb 28=ramp
_robj3d_shadeVertices_asm:
robj3d_shadeVertices_asm:
    movem.l d2-d7/a3-a6,-(sp)
    lea -32(sp),sp

    move.l d0,a6

    move.l _g_asm_s_sectorAmbient,a3
    move.l (a3),d0
    move.l d0,4(sp)
    move.l _g_asm_s_lightCount,a3
    move.l (a3),d0
    move.l d0,8(sp)
    move.l _g_asm_s_sectorAmbientFraction,a3
    move.l (a3),d0
    move.l d0,12(sp)
    move.l _g_asm_s_worldAmbient,a3
    move.l (a3),d0
    move.l d0,16(sp)
    move.l _g_asm_s_cameraLightSource,a3
    move.l (a3),d0
    move.l d0,20(sp)
    move.l _g_asm_s_scaledAmbient,a3
    move.l (a3),d0
    move.l d0,24(sp)
    move.l _g_asm_s_lightSourceRamp,a3
    move.l (a3),d0
    move.l d0,28(sp)

    move.l _g_asm_s_cameraLight,a3

    subq.l #1,a6
    move.l a6,d0
    blt .done

.loop:
    movem.l (a1),d1-d3

    movem.l (a2),d4-d6
    sub.l d1,d4
    sub.l d2,d5
    sub.l d3,d6

    move.l 4(sp),d0
    cmp.l #31,d0
    blt .shade

    move.l #$1F0000,(a0)
    bra .next

.shade:
    moveq #0,d7

    move.l 8(sp),a5
    subq.l #1,a5
    blt .lights_done
    move.l a3,a4

.light_loop:
    movem.l 12(a4),d1-d3

    muls.l d4,d0:d1
    swap d0
    swap d1
    move.w d1,d0

    muls.l d5,d1:d2
    swap d1
    swap d2
    move.w d2,d1
    add.l d1,d0

    muls.l d6,d1:d3
    swap d1
    swap d3
    move.w d3,d1
    add.l d1,d0

    tst.l d0
    ble .next_light

    move.l 24(a4),d1
    move.l #$1F0000,d2
    muls.l d1,d3:d2
    swap d3
    swap d2
    move.w d2,d3

    muls.l d3,d2:d0
    swap d2
    swap d0
    move.w d0,d2
    add.l d2,d7

.next_light:
    lea 28(a4),a4
    subq.l #1,a5
    move.l a5,d0
    bpl .light_loop

.lights_done:
    move.l 12(sp),d0
    move.l d7,d1
    muls.l d0,d3:d1
    swap d3
    swap d1
    move.w d1,d3
    move.l d3,d2

    move.l 8(a1),d3
    bge .z_ok
    moveq #0,d3

.z_ok:
    move.l 16(sp),d0
    cmp.l #31,d0
    blt .do_ramp
    move.l 20(sp),d0
    beq .skip_ramp

.do_ramp:
    move.l d3,d0
    lsr.l #7,d0
    lsr.l #7,d0
    cmp.l #127,d0
    ble .ramp_ok
    moveq #127,d0

.ramp_ok:
    move.l 28(sp),a5
    moveq #0,d1
    move.b (a5,d0.l),d1
    add.l 16(sp),d1
    moveq #31,d0
    sub.l d1,d0
    ble .skip_ramp
    swap d0
    add.l d0,d2

.skip_ramp:
    move.l 4(sp),d0
    swap d0
    cmp.l d0,d2
    bge .amb_ok
    move.l d0,d2

.amb_ok:
    move.l d3,d0
    lsr.l #8,d0
    lsr.l #8,d0
    move.l d0,d1
    lsr.l #4,d0
    lsr.l #5,d1
    add.l d1,d0

    sub.l d0,d2
    move.l 24(sp),d0
    cmp.l d0,d2
    bge .falloff_ok
    move.l d0,d2

.falloff_ok:
    tst.l d2
    bge .clamp_hi
    moveq #0,d2
    
.clamp_hi:
    cmp.l #$1F0000,d2
    ble .store
    move.l #$1F0000,d2

.store:
    move.l d2,(a0)

.next:
    lea 12(a1),a1
    lea 12(a2),a2
    addq.l #4,a0
    subq.l #1,a6
    move.l a6,d0
    bpl .loop

.done:
    lea 32(sp),sp
    movem.l (sp)+,d2-d7/a3-a6
    rts
