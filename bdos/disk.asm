
get_drives:
    ld hl,1
    ret

get_drive:
    xor a
    ret

    include "fcb.asm"