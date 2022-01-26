;;; it's snake but on an atari
.include "hardware.s"

;;; MAIN CODE
    *=$0600
_entry
    ;; initialization

    jmp run_game
    
run_title
    ;; setup title
    lda #<dl_title
    sta SDLSTL
    lda #>dl_title
    sta SDLSTL+1

    jmp _hold

    ;; game code
run_game
    ;; set display list
    lda #<dl_game
    sta SDLSTL
    lda #>dl_game
    sta SDLSTL+1
    ;; set DLI address
    lda #<dli_game
    sta VDSLST
    lda #>dli_game
    sta VDSLST+1
    ;; enable
    lda #NMIEN_DLI | NMIEN_VBI
    sta NMIEN

    jmp _hold

_hold
    jmp _hold

    
;;; DISPLAY LISTS AND INTERRUPTS
    *=$3000
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

    ;; game display list
dl_game
    .byte $70,$70,$F0           ; aligning blanks, ending with DLI
    .byte $C6                   ; mode 6 text with DLI
    .word gamescr               ; read from gamescr
    .rept 23
    .byte $04                   ; 23 lines of mode 4
    .endr
    .byte $41                   ; jump and wait for vblank
    .word dl_game               ; loop

    ;; game DLI
    *=$4000
dli_game
    pha
    ;; wait for hsync
    sta WSYNC
    ;; set the ROM charset
    lda #$E0
    sta CHBASE
    lda #$00
    sta CHBASE+1
    ;; set background color to black
    lda #$00
    sta COLBK
    ;; chain next dli
    lda #<dli_game2
    sta VDSLST
    lda #>dli_game2
    sta VDSLST+1
    pla
    rti
dli_game2
    pha
    ;; wait for hsync
    sta WSYNC
    ;; set the custom charset
    lda #<chars
    sta CHBASE
    lda #>chars
    sta CHBASE+1
    ;; set background color to brown
    lda #$14
    sta COLBK
    ;; chain previous dli
    lda #<dli_game
    sta VDSLST
    lda #>dli_game
    sta VDSLST+1
    pla
    rti

;;; GAME DATA
    *=$5000
body
    .dc 512 0                   ; snake body buffer
score
    .dc 1 0                     ; score/length of snake's body
bptr
    .dc 1 <body                 ; pointer into snake body buffer
foodx
    .dc 1 0                     ; food position
foody
    .dc 1 0
snakex
    .dc 1 0                     ; snake position
snakey
    .dc 1 0
snaked
    .dc 1 0                     ; snake direction
speed
    .dc 1 3                     ; game speed
    
;;; SCREEN DATA
    *=$8000
    ;; title screen data
titlepat
    .sbyte +$00, "                    "
    .sbyte +$00, "                    "
    .sbyte +$00, "                    "
    .sbyte +$00, "                    "
    .sbyte +$40, "       SNAKE        "
    .sbyte +$00, "                    "
    .sbyte +$00, "                    "
    .sbyte +$00, "                    "
    .sbyte +$00, "                    "
    .sbyte +$00, "                    "
    .sbyte +$00, "                    "
    .sbyte +$00, "                    "

    ;; game screen memory
gamescr
    ;; heading
    .sbyte +$40, " SCORE    "
    .sbyte +$C0,           " SPEED    "
    ;; mode 4 game board
    .byte 0,1,2,3
    

    ;; character set
chars
    ;; blank char
    .byte ~00000000
    .byte ~00000000
    .byte ~00000000
    .byte ~00000000
    .byte ~00000000
    .byte ~00000000
    .byte ~00000000
    .byte ~00000000
    ;; solid char
    .byte ~11111111
    .byte ~11111111
    .byte ~11111111
    .byte ~11111111
    .byte ~11111111
    .byte ~11111111
    .byte ~11111111
    .byte ~11111111
    ;; apple
    .byte ~00100000
    .byte ~00001000
    .byte ~00101000
    .byte ~10101010
    .byte ~10101010
    .byte ~10101010
    .byte ~00101000
    .byte ~00000000

    
    ;; entry point address
    *=RUNAD
    .word _entry
