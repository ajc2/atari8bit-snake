;;; it's snake but on an atari
.include "hardware.s"

;;; MAIN CODE
    *=$0600
_entry
    ;; initialization
    ;; set color registers (these don't change for the most part)
    lda #$00                    ; black
    sta COLBK
    lda #$0F                    ; white
    sta COLOR0
    lda #$48                    ; red
    sta COLOR1
    lda #$CA                    ; green
    sta COLOR2
    jmp run_game
    
run_title
    ;; setup title
    lda #<dl_title
    sta SDLSTL
    lda #>dl_title
    sta SDLSTL+1

    jmp _hold

    ;; game init code
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
    ;; set deferred vblank for game logic
    lda #<vbi_game
    sta VVBLKD
    lda #>vbi_game
    sta VVBLKD+1
    ;; enable
    lda #NMIEN_DLI | NMIEN_VBI
    sta NMIEN

    jmp _hold

    ;; core game logic
vbi_game
    pha
    lda #2
    sta gamescr+20
    pla
    ;; exit vbi
    jmp $E642

    ;; do nothing. game logic occurs in vbi
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
    .byte $70,$70,$70           ; aligning blanks
    .byte $C6                   ; mode 6 text with DLI
    .word gamescr               ; read from gamescr
    .rept 22
    .byte $04                   ; 22 lines of mode 4
    .endr
    .byte $84                   ; mode 4 line with dli
    .byte $41                   ; jump and wait for vblank
    .word dl_game               ; loop

    ;; game DLI
    *=$4000
dli_game2
    pha
    ;; wait for hsync
    sta WSYNC
    ;; set the ROM charset
    lda #$E0
    sta CHBASE
    ;; set background color to black
    lda #$00
    sta COLBK
    ;; chain next dli
    lda #<dli_game
    sta VDSLST
    pla
    rti
dli_game
    pha
    ;; wait for hsync
    sta WSYNC
    ;; set the custom charset
    lda #>chars
    sta CHBASE
    ;; set background color to brown
    lda #$12
    sta COLBK
    ;; chain previous dli
    lda #<dli_game2
    sta VDSLST
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

    ;; title screen data
titlepat
    .sbyte +$00, "                    "
    .sbyte +$00, "                    "
    .sbyte +$00, "                    "
    .sbyte +$00, "                    "
    .sbyte +$80, "       SNAKE        "
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
    .sbyte +$80, " SCORE    "
    .sbyte +$40,           " SPEED    "
    ;; mode 4 game board
    .dc 920 0
    
    
    ;; entry point address
    *=RUNAD
    .word _entry
