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

    include "bdos/console.asm"
    include "bdos/disk.asm"

dos_ver:
    xor a
    ld h,a
    ld b,a
    ld a,#22
    ld l,a
    ld c,a
    ret

set_dma:
    ld (dma),de
    ret

;;; BDOS Vars
dma dw 0 
user_stack_save dw 0
params dw 0

;;; BDOS stack
    ds 128
bdos_stack = $ - 1

    include "bios/bios.asm"