BOOT:	JP	bios.boot		
WBOOT:	JP	bios.wboot
CONST:	JP	console.status
CONIN:	JP	console.in
CONOUT:	JP	console.out
LIST:	JP	bios.nothing
PUNCH:	JP	bios.nothing
READER:	JP	bios.nothing
HOME:	JP	bios.nothing
SELDSK:	JP	bios.nothing
SETTRK:	JP	bios.nothing
SETSEC:	JP	bios.nothing
SETDMA:	JP	bios.nothing
READ:	JP	bios.nothing
WRITE:	JP	bios.nothing
PRSTAT:	JP	bios.nothing
SECTRN:	JP	bios.nothing

    macro localStack
    di
    ld (bios.int_handler.sp_save), sp
    ld sp, #ffff
    push af, bc, de, hl,ix,iy
    exx
    push af, bc, de, hl,ix,iy
    exx
    endm

    macro usualStack
    exx
    pop iy,ix,hl, de, bc, af
    exx
    pop iy,ix,hl, de, bc, af
    ld sp, (bios.int_handler.sp_save)
    endm

    module bios
int_handler:
    localStack
    call    keyboard.update
    usualStack
    ei
    reti
.sp_save dw 0

nothing:
    ld a, #ff
    ret
boot:
    di
    im 1
    ld sp, #ffff
    ld a, 3 : ld bc, #7ffd : out (c), a

    call display.init
    call uart.init

; CCP backup or load
    ld hl, welcome
    call bios_print
    
    xor a : ld (4), a
wboot:
    di
    ld sp, cpm-1
;; Restore CCP
    ld a,%00000001 : ld bc, #1ffd : out (c),a
     
    call gocpm
    ld a, (TDRIVE)
    ld c,a
    ;jp CBASE
    jp #100
gocpm:
; Setup jump table
    ld a, #0c3
    ld (0),a
    ld hl, WBOOT
    ld (1), hl
    
    ld (5), a
    ld hl, FBASE 
    ld (6), hl

    ld bc, #80
    call   SETDMA
    
    ld a, 1 : ld (IOBYTE),a
    
    call install_int

    call HOME
    im 1
    ei

    ret

install_int:
    ld (.set_a),a
    ld (.set_hl), hl
    ld a, #0c3
    ld (#38),a
    ld hl, int_handler
    ld (#39), hl
    ld a,0
.set_a = $ -1
    ld hl, 0
.set_hl = $ - 2
    ret

bios_print:
    ld a, (hl)
    and a 
    ret z
    inc hl
    push hl : call display.putC : pop hl
    jr bios_print

    endmodule

    include "display.asm"
    include "console.asm"
    include "keyboard.asm"
    include "uart.asm"

welcome db 26, "Stop the war in Ukraine!", 13, 10, 13, 10
        db "CP/Uno",13,10
        db "CP/M 2.2 compatibility layer",13,10
        db "2022 (c) Nihirash",13,10,13,10
        db 0
    display "BIOS SIZE: ", $
    ds  #ff