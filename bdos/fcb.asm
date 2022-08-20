; HL - FCB name
fcb_to_esx:
    push hl
    ld de, esx_name
    ld b,8
.loop_name
    ld a, (hl)
    and #7f
    cp ' '
    jr z, .ext
    ld (de),a
    inc hl
    inc de
    djnz .loop_name
.ext
    pop hl
    ld bc, 8
    add hl, bc
    ld a, (hl) 
    and #7f
    cp ' '
    jr z, .fin
    ld a,'.'
    ld (de),a
    inc de
    ld b, 3
.loop_ext
    ld a,(hl)
    and #7f
    cp ' '
    jr z, .fin
    ld (de),a
    inc hl
    inc de
    djnz .loop_ext
.fin
    xor a 
    ld (de), a
    ret

esx_name ds 12

; HL - esx_name
; DE - fcb name ptr
esx_to_fcb:
    ld b,8
.loop_name
    ld a,(hl)
    and #7f
    jr z,.fill_zeros
    cp '.'
    jr z,.fill_zeros
    ld (de), a
    inc hl
    inc de
    djnz .loop_name
.fill_zeros
    ld a, b
    and a
    jr z, .ext_copy
    ld a, ' '
.zeros_loop
    ld (de),a
    inc de
    djnz .zeros_loop

.ext_copy
    ld a, (hl)
    cp '.'
    jr nz, .do_copy
    inc hl
.do_copy
    ld b,3
.ext_loop
    ld a,(hl)
    and #7f
    jr z,.fin
    ld (de),a
    inc hl
    inc de
    djnz .ext_loop
.fin
    ld a, b
    and a
    ret z
    ld a, ' '
.fin_loop
    ld (de),a
    inc de
    djnz .fin_loop
    ret