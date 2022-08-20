console_in:
    call CONIN
    call check_char
    ret c          ;; Do not echo some symbols
    push af
    ld c,a
    call console_out
    pop af
    ret

show_it:
    ld a,c
    call check_char
    jr nz, console_out
    push af
    ld c, '^'
    call out_char
    pop af
    or '@'
    ld c,a
console_out:
    ld a,c
    cp TAB
    jp nz, out_char
.loop
    ld c, ' ' : call out_char
    ld a, (char_pos)
    and 7
    jr nz, .loop
    ret

out_char:
    push bc
    call CONOUT
    pop bc
    ld a, c
    ld hl,char_pos
    cp DEL : ret z
    inc (hl)
    cp ' '
    ret nc
    dec (hl)
    ld a, (hl)
    or a
    ret z
    ld a, c
    cp BS
    jr nz, .lfCheck
    dec (hl)
    ret
.lfCheck
    cp LF
    ret nz
    ld (hl),0
    ret

check_char:
    cp CR
    ret z
    cp LF
    ret z
    cp TAB
    ret z
    cp BS
    ret z
    cp ' '
    ret

raw_io:
    ld a, c
    inc a
    jr z, .input
    inc a
    jp z, CONST
    jp CONOUT
.input
    call CONST
    or a
    jp z, bdos_return
    call CONIN
    ret

get_io_byte:
    ld a, (IOBYTE)
    ret

set_io_byte:
    ld a, c
    ld (IOBYTE),a
    ret

write_str:
    ld bc,de
.loop
    ld a,(bc)
    cp '$' : ret z
    inc bc
    push bc
    ld c,a
    call console_out
    pop bc
    jr .loop

read_buf:
    ld a, (char_pos)
    ld (starting),a
    ld hl,(params)
    ld c, (hl)
    inc hl
    push hl
    ld b, 0
.read1
    push bc
    push hl
.read2
    call CONIN
    and #7f
    pop hl
    pop bc
    cp CR
    jp z, .read17
    cp LF
    jp z, .read17
    cp BS
    jr nz, .read3
    ld a,b
    or a
    jr z,.read1
    dec b
    ld a,(char_pos)
    jp .read10
.read3
    cp DEL
    jp nz, .read4
    ld a,b
    or a
    jr z, .read1
    dec b
    jp .read10
.read4
    cp CNTRLE
    jp nz,.read5
    push bc
    push hl
    call outcrlf
    xor a
    ld (starting), a
    jp .read2
.read5
    cp CNTRLP
    jp nz, .read6
    jp .read1
.read6
    cp CNTRLX
    jp nz, .read8
    push hl
.read7
    ld a,(starting)
    ld hl,char_pos
    cp (hl)
    jp nz, read_buf
    dec (hl)
    call backup
    jr .read7
.read8
    cp CNTRLU
    jp nz, .read9
    call new_line
    pop hl
    jr read_buf
.read9
    cp CNTRLR
    jp nz, .read14
.read10
    push bc
    call new_line
    pop bc
    pop hl
    push hl
    push bc
.read11
    ld a,b
    or a
    jp z, .read12
    ld c,(hl)
    dec b
    push bc
    push hl
    call show_it
    pop hl
    pop bc
    jp .read11
.read12
    push hl
    ld hl, char_pos
    sub (hl)
.read13
    call backup
    jp .read2
.read14
    inc hl
    ld (hl),a
    inc b
.read15
    push bc
    push hl
    ld c,a
    call show_it
    pop hl
    pop bc
    ld a,(hl)
    cp CNTRLC
    ld a,b
.read16
    cp c
    jp c, .read1
.read17
    pop hl
    ld (hl),b
    ld c, CR
    jp out_char

backup:
    call .backup1
    ld c,' '
    call CONOUT
.backup1
    ld c, BS
    jp CONOUT

outcrlf:
    ld c, CR
    call out_char
    ld c, LF
    jp out_char

new_line:
    ld c,'#'
    call out_char
    call outcrlf
.nl1
    ld a, (char_pos)
    ld hl, starting
    cp (hl)
    ret nc
    ld c,' '
    call out_char
    jr .nl1

char_pos db 0
starting db 0