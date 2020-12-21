; -----------------------------------------------------------------------------
; Author:    Diego Falk
; Created:   19.12.2020
; 
; A 64-bit function that returns the transpose of a 16x16 matrix
;
;       void transpose(uint8_t *x, uint8_t *y)
;
; x -> input matrix (16 rows of 16 bytes)
; y -> output transposed matrix (should allocate 256 bytes)
; -----------------------------------------------------------------------------

MATRIX_SIZE equ 16*16                       ; stack size used as aux variable (16x16 matrix)           
            
            global      _transpose16x16

section     .text

_transpose16x16:

            push        rbp                 ; save current rbp value
            mov         rbp, rsp            ; copy rsp value on rbp to restore it later
            sub         rsp, MATRIX_SIZE    ; reserve memory on stack for a temporal matrix (tmp)

Step1:                                      ; Step1: interleave bytes from consecutive rows
            mov         rax, rdi            ; rax (input) will point to rdi (x)
            mov         rbx, rsp            ; rbx (output) will point to rsp (tmp)
            mov         rcx, 8              ; we will interleave 2 rows 8 times (16 rows)
S1_L1:
            movdqa      xmm0, [rax]         ; copy n row from input  
            movdqa      xmm2, xmm0          ; do another copy
            movdqa      xmm1, [rax + 16]    ; copy the n+1 row

            punpcklbw   xmm0, xmm1          ; interleave the lower bytes
            punpckhbw   xmm2, xmm1          ; interleave the higher bytes
            
            movdqa      [rbx], xmm0         ; move the first row to the ouput matrix
            movdqa      [rbx + 16], xmm2    ; move the second row to the ouput matrix
            
            add         rax, 32             ; increment the input pointer by two rows
            add         rbx, 32             ; increment the output pointer by two rows
            dec         rcx                 ; decrement the counter
            jnz         S1_L1               

Step2:                                      ; Step2: interleave words
            mov         rax, rsp            ; rax (input) will point to rsp (tmp) 
            mov         rbx, rsi            ; rbx (output) will point to rsi (y)
            mov         rcx, 4              ; outer loop counter 
S2_L2:
            mov         r8, 2               ; inner loop counter
S2_L1:
            movdqa      xmm0, [rax]         ; copy n row from input 
            movdqa      xmm2, xmm0          ; do another copy
            movdqa      xmm1, [rax + 32]    ; copy the n+2 row

            punpcklwd   xmm0, xmm1          ; interleave the lower words
            punpckhwd   xmm2, xmm1          ; interleave the higher words
            
            movdqa      [rbx], xmm0         ; move the first row to the ouput matrix
            movdqa      [rbx + 16], xmm2    ; move the second row to the ouput matrix
            
            add         rax, 16             ; increment the input pointer by one row
            add         rbx, 32             ; increment the output pointer by two rows
            dec         r8                  ; decrement the inner counter
            
            jnz         S2_L1
            
            add         rax, 32             ; increment the input pointer by two rows
            dec         rcx                 ; decrement the outer counter

            jnz         S2_L2

Step3:                                      ; Step3: interleave double-words
            mov         rax, rsi            ; rax (input) will point to rsi (y)
            mov         rbx, rsp            ; rax (input) will point to rsp (tmp)
            mov         rcx, 2              ; outer loop counter
S3_L2:
            mov         r8, 4               ; inner loop counter
S3_L1:
            movdqa      xmm0, [rax]         ; copy n row from input
            movdqa      xmm2, xmm0          ; do another copy 
            movdqa      xmm1, [rax + 64]    ; copy the n+4 row      

            punpckldq   xmm0, xmm1          ; interleave the lower double-words   
            punpckhdq   xmm2, xmm1          ; interleave the higher double-words   
            
            movdqa      [rbx], xmm0         ; move the first row to the ouput matrix
            movdqa      [rbx + 16], xmm2    ; move the second row to the ouput matrix
            
            add         rax, 16             ; increment the input pointer by one row
            add         rbx, 32             ; increment the output pointer by two rows
            dec         r8                  ; decrement the inner counter
            
            jnz         S3_L1
            
            add         rax, 64             ; increment the input pointer by four rows
            dec         rcx                 ; decrement the outer counter

            jnz         S3_L2

Step4:                                      ; Step4: interleave quad-words
            mov         rax, rsp            ; rax (input) will point to rsi (tmp)
            mov         rbx, rsi            ; rax (input) will point to rsp (y)
            mov         rcx, 8              ; loop counter
S4_L1:
            movdqa      xmm0, [rax]         ; copy first row from input
            movdqa      xmm2, xmm0          ; do another copy 
            movdqa      xmm1, [rax + 128]   ; copy the n+4 row

            punpcklqdq  xmm0, xmm1          ; interleave the lower quad-word
            punpckhqdq  xmm2, xmm1          ; interleave the higher quad-word
            
            movdqa      [rbx], xmm0         ; move the first row to the ouput matrix
            movdqa      [rbx + 16], xmm2    ; move the second row to the ouput matrix
            
            add         rax, 16             ; increment the input pointer by one row
            add         rbx, 32             ; increment the output pointer by two rows
            dec         rcx                 ; decrement counter

            jnz         S4_L1 

end:    
            mov        rsp, rbp             ; restore rsp old value
            pop        rbp                  ; restore rbp old value
            ret                             ; return    