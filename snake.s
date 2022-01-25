.include "hardware.s"

    ;; main code
    *=$4000
_entry

    
    ;; entry point address
    *=RUNAD
    .word _entry
