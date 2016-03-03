; CIS-261
; M08.ASM
; Console Input/Output

.386                ; Tells MASM to use Intel 80386 instruction set.
.MODEL FLAT         ; Flat memory model
option casemap:none ; Treat labels as case-sensitive

INCLUDE IO.H        ; header file for input/output

.CONST  ; Constant data segment

    LINE_FEED               equ     10    ; line feed character
    TXT_INPUT_0_255         BYTE    "Input a number in range [0-255]: ", 0
    TXT_RESULT_SUM_BYTES    BYTE    "Resulting sum is ", 0
    ENDL                    BYTE    13, 10, 0
    TXT_BAD_NUMBER          BYTE    "*** Bad number, please try again!", 0
    TXT_OVERFLOW            BYTE    "*** Overflow!, please try again!", 0
    TXT_PAUSE               BYTE    9, 9, "Type any character and hit <Enter> to continue: ", 0

.STACK 100h ; (default is 1-kilobyte stack)

.DATA       ; Begin initialized data segment
    buffer          BYTE    2*12 DUP (?)
    dtoa_buffer     BYTE    11 DUP (?), 0
    number_one      BYTE    0
    number_two      BYTE    0
    number_8bit_sum BYTE    0

.CODE           ; Begin code segment
_main PROC      ; Beginning of code

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
input_first_8bit_number:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    output  TXT_INPUT_0_255
    input   buffer, SIZEOF buffer

    ; validate numeric input format and [0-255] range

    atod    buffer                  ; convert to DWORD, result in EAX
    jno     @F                      ; if number format is okay, then move on
    output  TXT_BAD_NUMBER          ; validation failed
    output  ENDL
    jmp     input_first_8bit_number
@@:
    test    eax, 0FFFFFF00h         ; make sure all bits except AL are zero
    jz      @F                      ; if yes, then continue
    output  TXT_BAD_NUMBER          ; otherwise validation failed
    output  ENDL
    jmp     input_first_8bit_number
@@:
    mov     BYTE PTR [number_one], AL   ; store valid input

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
input_second_8bit_number:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    output  TXT_INPUT_0_255
    input   buffer, SIZEOF buffer

    ; validate numeric input format and [0-255] range

    atod    buffer                  ; convert to DWORD, result in EAX
    jno     @F                      ; if number format is okay, then move on
    output  TXT_BAD_NUMBER          ; validation failed
    output  ENDL
    jmp     input_second_8bit_number
@@:
    test    eax, 0FFFFFF00h         ; make sure all bits except AL are zero
    jz      @F                      ; if yes, then continue
    output  TXT_BAD_NUMBER          ; otherwise validation failed
    output  ENDL
    jmp     input_second_8bit_number
@@:
    mov     BYTE PTR [number_two], AL   ; store valid input

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Compute the sum of two 8-bit unsigned integers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    add     AL, BYTE PTR [number_one]   ; add two values
    jnc     @F                          ; if okay, continue
    output  TXT_OVERFLOW                ; unsigned overflow detected
    output  ENDL
    jmp     input_first_8bit_number
@@:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Store and print the result
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov     BYTE PTR [number_8bit_sum], AL  ; store the result
    and     eax, 000000FFh              ; make sure all bits except AL are zero
    dtoa    dtoa_buffer, eax            ; Convert EAX value to string
    output  TXT_RESULT_SUM_BYTES
    output  dtoa_buffer                 ; Print result
    output  ENDL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EXIT THE PROGRAM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    call    pause_proc
    ret

_main ENDP

pause_proc PROC
    output  TXT_PAUSE
pause_again:
    input   buffer, SIZEOF buffer
    ; commented out after making buffer "large enough" 24 characters
    ; cmp   BYTE PTR [buffer], LINE_FEED ; if empty line (LF) then get something
    ; je    pause_again
    ret
pause_proc ENDP

END _main        ; Marks the end of the module and sets the program entry point label

        ;; Sample code checking the range of unsigned integers 0 through 255
        ;;
        ;;    cmp     eax, 0                  ; check low bound of 8-bit unsigned int
        ;;    jae     @F                      ; if ( eax >= 0 ) then move on
        ;;    output  TXT_BAD_NUMBER          ; otherwise validation failed
        ;;    output  ENDL
        ;;    jmp     input_first_8bit_number
        ;;@@:
        ;;    cmp     eax, 255                ; check low bound of 8-bit unsigned int
        ;;    jbe     @F                      ; if ( eax <= 255 ) then move on
        ;;    output  TXT_BAD_NUMBER          ; otherwise validation failed
        ;;    output  ENDL
        ;;    jmp     input_first_8bit_number
