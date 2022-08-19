TDRIVE = 4
IOBYTE = 3
TFCB = #5c

CNTRLC	=	3		;control-c
CNTRLE	=	05H		;control-e
BS	=	08H		;backspace
TAB	=	09H		;tab
LF	=	0AH		;line feed
FF	=	0CH		;form feed
CR	=	0DH		;carriage return
CNTRLP	=	10H		;control-p
CNTRLR	=	12H		;control-r
CNTRLS	=	13H		;control-s
CNTRLU	=	15H		;control-u
CNTRLX	=	18H		;control-x
CNTRLZ	=	1AH		;control-z (end-of-file mark)
DEL	=	7FH		;rubout


NFUNCS = 41 ; CP/M 2.2 default

;; BDOS replacement by Nihirash
;; 

FBASE:
    di
    ld (params), de  ; store params

    ld (user_stack_save), sp
    ld sp, bdos_stack
    ei
    
    ld hl, bdos_return
    push hl

    ld a, c ; function number
    cp NFUNCS
    ret nc ; If function number more than we can use
    ld e, a
    ld d, 0 
    ld hl, function_table
    add hl, de
    add hl, de
    ;; Load function address
    ld e, (hl)
    inc hl
    ld d, (hl)
    ld hl, (params)
    ld c, l
    ex hl, de
    jp (hl)

bdos_return:
    di
    ld sp, (user_stack_save)
    ei
    ret

do_nothing:
    xor a
    ld hl,0
    ret

function_table:
    dw  WBOOT        ; 0 Reset
    dw  console_in   ; 1 Console In
    dw  console_out  ; 2 Console Out
    dw  do_nothing   ; 3 Aux Read
    dw  do_nothing   ; 4 Aux Write
    dw  do_nothing   ; 5 Printer write
    dw  raw_io       ; 6 raw_io
    dw  get_io_byte  ; 7 get_io_byte
    dw  set_io_byte  ; 8 set_io_byte
    dw  write_str    ; 9 write string finishes with $
    dw  read_buf     ; 10 buffered read
    dw  CONST        ; 11 - console status
    dw  dos_ver      ; 12 - BDOS version
    dw  do_nothing   ; 13 - Reset disks
    dw  do_nothing   ; 14 - Set drive
    dw  do_nothing   ; 15 - fopen
    dw  do_nothing   ; 16 - fclose
    dw  do_nothing   ; 17 - search for first
    dw  do_nothing   ; 18 - search for next
    dw  do_nothing   ; 19 - delete file
    dw  do_nothing   ; 20 - fread
    dw  do_nothing   ; 21 - fwrite
    dw  do_nothing   ; 22 - fcreate
    dw  do_nothing   ; 23 - frename
    dw  get_drives   ; 24 - return bitmap of drives
    dw  get_drive    ; 25 - return current drive
    dw  set_dma      ; 26 - set DMA
    dw  do_nothing   ; 27 - get allocation bitmap
    dw  do_nothing   ; 28 - write protect drive
    dw  do_nothing   ; 29 - get read only drives vector
    dw  do_nothing   ; 30 - set file attributes
    dw  do_nothing   ; 31 - get DPB address
    dw  do_nothing   ; 32 - get user area
    dw  do_nothing   ; 33 - random access read
    dw  do_nothing   ; 34 - random access write
    dw  do_nothing   ; 35 - compute file size
    dw  do_nothing   ; 36 - update random access pointer
    dw  do_nothing   ; 37 - reset selected disks
    dw  do_nothing   ; 38 - not implemented in 2.2
    dw  do_nothing   ; 39 - not implemented in 2.2
    dw  do_nothing   ; 40 - fill random access block with zeros
    dw  do_nothing


;;;; BDOS functions
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

dos_ver:
    xor a
    ld h,a
    ld b,a
    ld a,#22
    ld l,a
    ld c,a
    ret

get_drives:
    ld hl,1
    ret

get_drive:
    xor a
    ret

set_dma:
    ld (dma),de
    ret

;;; BDOS Vars
dma dw 0 
user_stack_save dw 0
params dw 0
char_pos db 0
starting db 0

;;; BDOS stack
    ds 128
bdos_stack = $ - 1

    include "bios/bios.asm"