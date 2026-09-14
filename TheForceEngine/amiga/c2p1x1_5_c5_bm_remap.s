;
; tornado - Port of Tornado DI 1993 x86 ASM to C
;
; Tanausu M. 39:190/101@amiganet 2:341/207@fidonet
;
; 2023
;
; Date: 1999-03-07			Mikael Kalms (Scout/C-Lous & more)
;					Email: mikael@kalms.org
;
; 1x1 5bpl cpu5 C2P for arbitrary BitMaps, with inline palette remap
;
; Based on c2p1x1_6_c5_bm by Mikael Kalms, adapted for 5 bitplanes
; with fused remap to eliminate the intermediate chunky buffer
;
; Reads 4 fb bytes per move.l instead of byte-by-byte
; Handles BytesPerRow padding (modulo path)
;
; Restrictions:
; Chunky-buffer must be an even multiple of 32 pixels wide
; X-Offset must be set to an even multiple of 8
; If these conditions are not met, returns -1 so caller falls back

    include graphics/gfx.i

        rsreset
C2P5R_REMAP    rs.l 1
C2P5R_BITMAP   rs.l 1
C2P5R_OFFSET   rs.l 1
C2P5R_CHUNKYX  rs.w 1
C2P5R_CHUNKYY  rs.w 1
C2P5R_ROWMOD   rs.l 1
C2P5R_BPL4     rs.l 1
C2P5R_BPL3SV   rs.l 1
C2P5R_TEMP     rs.l 8
C2P5R_SIZEOF   rs.b 0

    section code,code

; d0.w  chunkyx [chunky-pixels]
; d1.w  chunkyy [chunky-pixels]
; d2.w  offsx [screen-pixels]
; d3.w  offsy [screen-pixels]
; a0    fb source (raw framebuffer bytes)
; a1    BitMap
; a2    remap table (256 bytes)

    XDEF _c2p1x1_5_c5_bm_remap
    XDEF c2p1x1_5_c5_bm_remap
_c2p1x1_5_c5_bm_remap
c2p1x1_5_c5_bm_remap
    movem.l d2-d7/a2-a6,-(sp)
    suba.l #C2P5R_SIZEOF,sp

    move.l a2,C2P5R_REMAP(sp)
    move.l a1,C2P5R_BITMAP(sp)

    cmpi.b #5,bm_Depth(a1)
    blo .exit_fail
    move.w d0,d4
    move.w d2,d5
    andi.w #$1f,d4
    bne .exit_fail
    andi.w #$7,d5
    bne .exit_fail
    moveq #0,d4
    move.w bm_BytesPerRow(a1),d4

    move.w d0,C2P5R_CHUNKYX(sp)
    beq .exit_fail
    move.w d1,C2P5R_CHUNKYY(sp)
    beq .exit_fail

    ext.l d2
    mulu.w d4,d3
    lsr.l #3,d2
    add.l d2,d3

    move.l d3,C2P5R_OFFSET(sp)

    lsl.w #3,d4
    sub.w d0,d4
    bmi .exit_fail
    bne .c2p_mod

    mulu.w d0,d1
    add.l a0,d1
    move.l d1,a2

    move.l C2P5R_REMAP(sp),a1

REMAP4 MACRO
    move.l (a0)+,\2
    move.l \2,\3
    swap \3
    lsr.w #8,\3
    move.b (a1,\3.w),\3
    move.l \3,\1
    move.l \2,\3
    swap \3
    andi.w #$FF,\3
    move.b (a1,\3.w),\3
    lsl.l #8,\1
    or.b \3,\1
    move.l \2,\3
    lsr.w #8,\3
    move.b (a1,\3.w),\3
    lsl.l #8,\1
    or.b \3,\1
    move.l \2,\3
    andi.w #$FF,\3
    move.b (a1,\3.w),\3
    lsl.l #8,\1
    or.b \3,\1
    ENDM

; Setup bpl0-4 pointers
    move.l C2P5R_BITMAP(sp),a6
    move.l bm_Planes+4*4(a6),d5
    add.l d3,d5
    move.l d5,C2P5R_BPL4(sp)
    movem.l bm_Planes(a6),a3-a6
    add.l d3,a3
    add.l d3,a4
    add.l d3,a5
    add.l d3,a6

.loop
    REMAP4 d0,d5,d6
    REMAP4 d2,d5,d6
    REMAP4 d1,d5,d6
    REMAP4 d3,d5,d6

    movem.l d0-d3,C2P5R_TEMP(sp)

    ; Merge 4x1 part 1
    move.l #$0f0f0f0f,d6
    and.l d6,d0
    and.l d6,d1
    and.l d6,d2
    and.l d6,d3
    lsl.l #4,d0
    lsl.l #4,d1
    or.l d2,d0
    or.l d3,d1

    REMAP4 d2,d5,d4
    REMAP4 d6,d5,d4
    REMAP4 d3,d5,d4
    REMAP4 d7,d5,d4

    movem.l d2/d3/d6/d7,C2P5R_TEMP+16(sp)

    ; Merge 4x1 part 2
    move.l #$0f0f0f0f,d4
    and.l d4,d2
    and.l d4,d6
    and.l d4,d3
    and.l d4,d7
    lsl.l #4,d2
    lsl.l #4,d3
    or.l d6,d2
    or.l d7,d3

    ; Swap 16x2
    move.w d2,d6
    move.w d3,d7
    move.w d0,d2
    move.w d1,d3
    swap d2
    swap d3
    move.w d2,d0
    move.w d3,d1
    move.w d6,d2
    move.w d7,d3

    ; Swap 2x2
    move.l #$33333333,d4
    move.l d2,d6
    move.l d3,d7
    lsr.l #2,d6
    lsr.l #2,d7
    eor.l d0,d6
    eor.l d1,d7
    and.l d4,d6
    and.l d4,d7
    eor.l d6,d0
    eor.l d7,d1
    lsl.l #2,d6
    lsl.l #2,d7
    eor.l d6,d2
    eor.l d7,d3

    ; Swap 8x1
    move.l #$00ff00ff,d4
    move.l d1,d6
    move.l d3,d7
    lsr.l #8,d6
    lsr.l #8,d7
    eor.l d0,d6
    eor.l d2,d7
    and.l d4,d6
    and.l d4,d7
    eor.l d6,d0
    eor.l d7,d2
    lsl.l #8,d6
    lsl.l #8,d7
    eor.l d6,d1
    eor.l d7,d3

    ; Swap 1x1
    move.l #$55555555,d4
    move.l d1,d5
    move.l d3,d7
    lsr.l #1,d5
    lsr.l #1,d7
    eor.l d0,d5
    eor.l d2,d7
    and.l d4,d5
    and.l d4,d7
    eor.l d5,d0
    eor.l d7,d2
    add.l d5,d5
    add.l d7,d7
    eor.l d1,d5
    eor.l d3,d7

    ; Store bpl0-3 (d7=bpl0, d2=bpl1, d5=bpl2, d0=bpl3)
    move.l d7,(a3)+
    move.l d2,(a4)+
    move.l d5,(a5)+
    move.l d0,(a6)+

    ; PASS 2: bpl4 (bit 4 only)
    movem.l C2P5R_TEMP(sp),d0-d3

    ; Merge 4x1 part 1
    move.l #$10101010,d4
    and.l d4,d0
    and.l d4,d1
    and.l d4,d2
    and.l d4,d3
    lsr.l #4,d0
    lsr.l #4,d1
    lsr.l #4,d2
    lsr.l #4,d3
    move.l #$0f0f0f0f,d6
    and.l d6,d0
    and.l d6,d1
    and.l d6,d2
    and.l d6,d3
    lsl.l #4,d0
    lsl.l #4,d1
    or.l d2,d0
    or.l d3,d1

    movem.l C2P5R_TEMP+16(sp),d2/d3/d6/d7

    ; Merge 4x1 part 2
    move.l #$10101010,d4
    and.l d4,d2
    and.l d4,d6
    and.l d4,d3
    and.l d4,d7
    lsr.l #4,d2
    lsr.l #4,d6
    lsr.l #4,d3
    lsr.l #4,d7
    move.l #$0f0f0f0f,d4
    and.l d4,d2
    and.l d4,d6
    and.l d4,d3
    and.l d4,d7
    lsl.l #4,d2
    lsl.l #4,d3
    or.l d6,d2
    or.l d7,d3

    ; Swap 16x2
    move.w d2,d6
    move.w d3,d7
    move.w d0,d2
    move.w d1,d3
    swap d2
    swap d3
    move.w d2,d0
    move.w d3,d1
    move.w d6,d2
    move.w d7,d3

    ; Swap 2x2
    move.l #$33333333,d4
    move.l d2,d6
    move.l d3,d7
    lsr.l #2,d6
    lsr.l #2,d7
    eor.l d0,d6
    eor.l d1,d7
    and.l d4,d6
    and.l d4,d7
    eor.l d6,d0
    eor.l d7,d1
    lsl.l #2,d6
    lsl.l #2,d7
    eor.l d6,d2
    eor.l d7,d3

    ; Swap 8x1
    move.l #$00ff00ff,d4
    move.l d1,d6
    move.l d3,d7
    lsr.l #8,d6
    lsr.l #8,d7
    eor.l d0,d6
    eor.l d2,d7
    and.l d4,d6
    and.l d4,d7
    eor.l d6,d0
    eor.l d7,d2
    lsl.l #8,d6
    lsl.l #8,d7
    eor.l d6,d1
    eor.l d7,d3

    ; Swap 1x1
    move.l #$55555555,d4
    move.l d1,d5
    move.l d3,d7
    lsr.l #1,d5
    lsr.l #1,d7
    eor.l d0,d5
    eor.l d2,d7
    and.l d4,d5
    and.l d4,d7
    eor.l d5,d0
    eor.l d7,d2
    add.l d5,d5
    add.l d7,d7
    eor.l d1,d5
    eor.l d3,d7

    ; Store bpl4 (d7=bpl0 of the transformed data)
    move.l a6,C2P5R_BPL3SV(sp)
    move.l C2P5R_BPL4(sp),a6

    move.l d7,(a6)+

    move.l a6,C2P5R_BPL4(sp)
    move.l C2P5R_BPL3SV(sp),a6

    cmpa.l a0,a2
    bne .loop

    moveq #0,d0
    adda.l #C2P5R_SIZEOF,sp
    movem.l (sp)+,d2-d7/a2-a6
    rts

.c2p_mod
    lsr.w #3,d4
    move.l d4,C2P5R_ROWMOD(sp)

    move.l a0,a2
    add.w C2P5R_CHUNKYX(sp),a2

    movem.l a0-a2/d1/d3,-(sp)

    ; Setup bpl0-4 pointers
    move.l C2P5R_BITMAP+20(sp),a6
    move.l bm_Planes+4*4(a6),d5
    add.l d3,d5
    move.l d5,C2P5R_BPL4+20(sp)
    movem.l bm_Planes(a6),a3-a6
    add.l d3,a3
    add.l d3,a4
    add.l d3,a5
    add.l d3,a6

    move.l C2P5R_REMAP+20(sp),a1

    bra .modx1

.modx1y
    add.w C2P5R_CHUNKYX+20(sp),a2
    move.l C2P5R_ROWMOD+20(sp),d0
    add.l d0,a3
    add.l d0,a4
    add.l d0,a5
    add.l d0,a6
    move.l C2P5R_BPL4+20(sp),d1
    add.l d0,d1
    move.l d1,C2P5R_BPL4+20(sp)
.modx1
    REMAP4 d0,d5,d6
    REMAP4 d2,d5,d6
    REMAP4 d1,d5,d6
    REMAP4 d3,d5,d6

    movem.l d0-d3,C2P5R_TEMP+20(sp)

    ; Merge 4x1 part 1
    move.l #$0f0f0f0f,d6
    and.l d6,d0
    and.l d6,d1
    and.l d6,d2
    and.l d6,d3
    lsl.l #4,d0
    lsl.l #4,d1
    or.l d2,d0
    or.l d3,d1

    REMAP4 d2,d5,d4
    REMAP4 d6,d5,d4
    REMAP4 d3,d5,d4
    REMAP4 d7,d5,d4

    movem.l d2/d3/d6/d7,C2P5R_TEMP+36(sp)

    ; Merge 4x1 part 2
    move.l #$0f0f0f0f,d4
    and.l d4,d2
    and.l d4,d6
    and.l d4,d3
    and.l d4,d7
    lsl.l #4,d2
    lsl.l #4,d3
    or.l d6,d2
    or.l d7,d3

    ; Swap 16x2
    move.w d2,d6
    move.w d3,d7
    move.w d0,d2
    move.w d1,d3
    swap d2
    swap d3
    move.w d2,d0
    move.w d3,d1
    move.w d6,d2
    move.w d7,d3

    ; Swap 2x2
    move.l #$33333333,d4
    move.l d2,d6
    move.l d3,d7
    lsr.l #2,d6
    lsr.l #2,d7
    eor.l d0,d6
    eor.l d1,d7
    and.l d4,d6
    and.l d4,d7
    eor.l d6,d0
    eor.l d7,d1
    lsl.l #2,d6
    lsl.l #2,d7
    eor.l d6,d2
    eor.l d7,d3

    ; Swap 8x1
    move.l #$00ff00ff,d4
    move.l d1,d6
    move.l d3,d7
    lsr.l #8,d6
    lsr.l #8,d7
    eor.l d0,d6
    eor.l d2,d7
    and.l d4,d6
    and.l d4,d7
    eor.l d6,d0
    eor.l d7,d2
    lsl.l #8,d6
    lsl.l #8,d7
    eor.l d6,d1
    eor.l d7,d3

    ; Swap 1x1
    move.l #$55555555,d4
    move.l d1,d5
    move.l d3,d7
    lsr.l #1,d5
    lsr.l #1,d7
    eor.l d0,d5
    eor.l d2,d7
    and.l d4,d5
    and.l d4,d7
    eor.l d5,d0
    eor.l d7,d2
    add.l d5,d5
    add.l d7,d7
    eor.l d1,d5
    eor.l d3,d7

    ; Store bpl0-3
    move.l d7,(a3)+
    move.l d2,(a4)+
    move.l d5,(a5)+
    move.l d0,(a6)+

    ; PASS 2: bpl4 (bit 4 only)
    movem.l C2P5R_TEMP+20(sp),d0-d3

    ; Merge 4x1 part 1
    move.l #$10101010,d4
    and.l d4,d0
    and.l d4,d1
    and.l d4,d2
    and.l d4,d3
    lsr.l #4,d0
    lsr.l #4,d1
    lsr.l #4,d2
    lsr.l #4,d3
    move.l #$0f0f0f0f,d6
    and.l d6,d0
    and.l d6,d1
    and.l d6,d2
    and.l d6,d3
    lsl.l #4,d0
    lsl.l #4,d1
    or.l d2,d0
    or.l d3,d1

    movem.l C2P5R_TEMP+36(sp),d2/d3/d6/d7

    ; Merge 4x1 part 2
    move.l #$10101010,d4
    and.l d4,d2
    and.l d4,d6
    and.l d4,d3
    and.l d4,d7
    lsr.l #4,d2
    lsr.l #4,d6
    lsr.l #4,d3
    lsr.l #4,d7
    move.l #$0f0f0f0f,d4
    and.l d4,d2
    and.l d4,d6
    and.l d4,d3
    and.l d4,d7
    lsl.l #4,d2
    lsl.l #4,d3
    or.l d6,d2
    or.l d7,d3

    ; Swap 16x2
    move.w d2,d6
    move.w d3,d7
    move.w d0,d2
    move.w d1,d3
    swap d2
    swap d3
    move.w d2,d0
    move.w d3,d1
    move.w d6,d2
    move.w d7,d3

    ; Swap 2x2
    move.l #$33333333,d4
    move.l d2,d6
    move.l d3,d7
    lsr.l #2,d6
    lsr.l #2,d7
    eor.l d0,d6
    eor.l d1,d7
    and.l d4,d6
    and.l d4,d7
    eor.l d6,d0
    eor.l d7,d1
    lsl.l #2,d6
    lsl.l #2,d7
    eor.l d6,d2
    eor.l d7,d3

    ; Swap 8x1
    move.l #$00ff00ff,d4
    move.l d1,d6
    move.l d3,d7
    lsr.l #8,d6
    lsr.l #8,d7
    eor.l d0,d6
    eor.l d2,d7
    and.l d4,d6
    and.l d4,d7
    eor.l d6,d0
    eor.l d7,d2
    lsl.l #8,d6
    lsl.l #8,d7
    eor.l d6,d1
    eor.l d7,d3

    ; Swap 1x1
    move.l #$55555555,d4
    move.l d1,d5
    move.l d3,d7
    lsr.l #1,d5
    lsr.l #1,d7
    eor.l d0,d5
    eor.l d2,d7
    and.l d4,d5
    and.l d4,d7
    eor.l d5,d0
    eor.l d7,d2
    add.l d5,d5
    add.l d7,d7
    eor.l d1,d5
    eor.l d3,d7

    ; Store bpl4 (d7=bpl0 of the transformed data)
    move.l a6,C2P5R_BPL3SV+20(sp)
    move.l C2P5R_BPL4+20(sp),a6

    move.l d7,(a6)+

    move.l a6,C2P5R_BPL4+20(sp)
    move.l C2P5R_BPL3SV+20(sp),a6

    cmpa.l a0,a2
    bne .modx1

    subq.w #1,C2P5R_CHUNKYY+20(sp)
    bne .modx1y

    movem.l (sp)+,a0-a2/d1/d3

    moveq #0,d0
    adda.l #C2P5R_SIZEOF,sp
    movem.l (sp)+,d2-d7/a2-a6
    rts

.exit_fail
    moveq #-1,d0
    adda.l #C2P5R_SIZEOF,sp
    movem.l (sp)+,d2-d7/a2-a6
    rts
