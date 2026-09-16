;
; TheForceEngine - Amiga port
;
; 68020+
;

    section .text,code

    XDEF _adjoin_setupAdjoinWindow_asm
    XDEF adjoin_setupAdjoinWindow_asm

    XREF __ZN8TFE_Jedi19s_minScreenX_PixelsE

EP_DYCEIL = 8
EP_YFLOOR0 = 12
EP_DYFLOOR = 20
EP_X0 = 44
EP_X1 = 48
EP_SIZE = 52

_adjoin_setupAdjoinWindow_asm:
adjoin_setupAdjoinWindow_asm:
    movem.l d2-d7/a2-a6,-(sp)

    move.l __ZN8TFE_Jedi19s_minScreenX_PixelsE,d1
    lsl.l #2,d1
    lea (a2,d1.l),a5
    lea (a3,d1.l),a6
    moveq #39,d7
    
.copy_top:
    move.l (a5)+,(a6)+
    move.l (a5)+,(a6)+
    move.l (a5)+,(a6)+
    move.l (a5)+,(a6)+
    move.l (a5)+,(a6)+
    move.l (a5)+,(a6)+
    move.l (a5)+,(a6)+
    move.l (a5)+,(a6)+
    dbra d7,.copy_top

    lea (a0,d1.l),a5
    lea (a1,d1.l),a6
    moveq #39,d7

.copy_bot:
    move.l (a5)+,(a6)+
    move.l (a5)+,(a6)+
    move.l (a5)+,(a6)+
    move.l (a5)+,(a6)+
    move.l (a5)+,(a6)+
    move.l (a5)+,(a6)+
    move.l (a5)+,(a6)+
    move.l (a5)+,(a6)+
    dbra d7,.copy_bot

    move.l d0,d7
    ble .done

.adjoin_loop:
    move.l EP_X0(a4),d3
    move.l EP_X1(a4),d4
    move.l d3,d2
    lsl.l #2,d2

    lea (a2,d2.l),a5
    lea (a1,d2.l),a6
    cmp.l d4,d3
    bgt .ceil_done
    move.l EP_DYCEIL(a4),d5
    move.l (a4),d6

.ceil_loop:
    move.l d6,d1
    add.l #$8000,d1
    swap d1
    ext.l d1
    cmp.l (a5),d1
    ble .ceil_next
    move.l (a6),d0
    cmp.l d0,d1
    ble .ceil_store
    move.l d0,d1
    addq.l #1,d1

.ceil_store:
    move.l d1,(a3,d3.l*4)

.ceil_next:
    addq.l #4,a5
    addq.l #4,a6
    addq.l #1,d3
    add.l d5,d6
    cmp.l d4,d3
    ble .ceil_loop

.ceil_done:
    move.l EP_X0(a4),d3
    lea (a2,d2.l),a5
    lea (a0,d2.l),a6
    cmp.l d4,d3
    bgt .floor_done
    move.l EP_DYFLOOR(a4),d5
    move.l EP_YFLOOR0(a4),d6

.floor_loop:
    move.l d6,d1
    add.l #$8000,d1
    swap d1
    ext.l d1
    cmp.l (a6),d1
    bge .floor_next
    move.l (a5),d0
    cmp.l d0,d1
    bge .floor_store
    move.l d0,d1
    subq.l #1,d1

.floor_store:
    move.l d1,(a1,d3.l*4)

.floor_next:
    addq.l #4,a5
    addq.l #4,a6
    addq.l #1,d3
    add.l d5,d6
    cmp.l d4,d3
    ble .floor_loop

.floor_done:
    lea EP_SIZE(a4),a4
    subq.l #1,d7
    bgt .adjoin_loop

.done:
    movem.l (sp)+,d2-d7/a2-a6
    rts
