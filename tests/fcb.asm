
    module TestSuite_FCB
UT_convert_from_fcb_to_esx_name:
    ld hl, .fcbName1
    call fcb_to_esx
    TEST_STRING_PTR esx_name, .expected1
    ld hl, .fcbName2
    call fcb_to_esx
    TEST_STRING_PTR esx_name, .expected2

    ld hl, .fcbName3
    call fcb_to_esx
    TEST_STRING_PTR esx_name, .expected3
    
    ld hl, .fcbName4
    call fcb_to_esx
    TEST_STRING_PTR esx_name, .expected4
    TC_END
    
.fcbName1 db "MBASIC45COM"
.expected1 db "MBASIC45.COM",0

.fcbName2 db "TINYBAS COM"
.expected2 db "TINYBAS.COM",0

.fcbName3 db "CPM     SYS"
.expected3 db "CPM.SYS",0

.fcbName4 db "README     "
.expected4 db "README",0


UT_convert_from_esx_to_fcb_name:
    ld hl, .esxName1
    ld de, .fcbbuf
    call esx_to_fcb
    TEST_STRING_PTR .fcbbuf, .fcbName1

    ld hl, .esxName2
    ld de, .fcbbuf
    call esx_to_fcb
    TEST_STRING_PTR .fcbbuf, .fcbName2

    ld hl, .esxName3
    ld de, .fcbbuf
    call esx_to_fcb
    TEST_STRING_PTR .fcbbuf, .fcbName3
    TC_END
.fcbbuf ds 12,0
.esxName1 db "CPM.SYS",0
.fcbName1 db "CPM     SYS",0

.esxName2 db "DISK",0
.fcbName2 db "DISK       ",0

.esxName3 db "HELLO.C",0
.fcbName3 db "HELLO   C  ",0

    endmodule
    
    include "../bdos/fcb.asm"
