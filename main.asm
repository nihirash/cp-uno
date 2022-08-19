    DEVICE ZXSPECTRUM128
    SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION

    org #8000
stack_top:
main:
    di
    ld bc, #7ffd : ld a, 6 : out (c),a
    ld hl, page6
    ld de, #c000
    ld bc,page6_len
    ldir
     

    ld bc, #7ffd : ld a, 3 : out (c),a
    ld hl, cpm
    ld de, cpm_start
    ld bc, cpm_size
    ldir
    jp BOOT
    
page6:
    DISP #8000
    include "bios/offload.asm"
    ENT
page6_len = $ - page6

cpm:
    DISP #ffff-cpm_size
    display "BDOS: ", $
cpm_start:
    jp BOOT
    include "bdos.asm"
cpm_size = $ - cpm_start
    ENT

    MMU 0 2,0
    org #100
    incbin "mbasic.com"

    savesna "test.sna", main