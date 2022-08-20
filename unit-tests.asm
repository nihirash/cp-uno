    DEVICE ZXSPECTRUM128
    SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION
    org 32768
start:
    include "unit_tests.inc"
    UNITTEST_INITIALIZE
    ret
    
    include "tests/fcb.asm"

    savesna "tests.sna",start