;;; it's snake but on an atari
.include "hardware.s"

    ;; main code
    *=$0600
_entry


    ;; title display list
dl_title
    .byte $70,$70,$70           ; aligning blanks
    .byte $47                   ; mode 7 text
    .word titlepat              ; read from titlepat
    .rept 11
    .byte $07                   ; rest of screen mode 7
    .endr
    .byte $41                   ; jump and wait for vertical blank
    .word dl_title              ; loop

    ;; title screen data
titlepat
    .sbyte +$00, "                    "
    .sbyte +$00, "                    "
    .sbyte +$00, "                    "
    .sbyte +$00, "                    "
    .sbyte +$00, "                    "
    .sbyte +$00, "                    "
    .sbyte +$00, "                    "
    .sbyte +$00, "                    "
    .sbyte +$00, "                    "
    .sbyte +$00, "                    "
    .sbyte +$00, "                    "
    .sbyte +$00, "                    "
    
    ;; entry point address
    *=RUNAD
    .word _entry
 
