%include "io.inc"

%define MAX_INPUT_SIZE 4096

section .data
        length dd 0

section .bss
        expr: resb MAX_INPUT_SIZE

section .text
global CMAIN
CMAIN:
        push ebp
        mov ebp, esp
    
        GET_STRING expr, MAX_INPUT_SIZE     ; Load string into memory
        
        mov al, 0                           ; Load string terminator into al
        lea edi, [expr]                     ; Load string into register
        mov ecx, 0                          ; Set length counter to 0
        cld                                 ; Clear DF
    
parse_expression:  
        scasb                               ; Scan string for NULL terminator
        je found                            
        inc ecx                             ; Increase length counter 
        jmp parse_expression                ; Loop
    
found:
        mov [length], ecx                   ; Save length when NULL terminator is found
        
        mov ecx, 0                          ; Reset ecx
        lea esi, [expr]                     ; Load string into ESI

evaluate_expression:                        ; Loop for expression evaluation
        cmp byte [esi + ecx], " "           ; Checks if current char is space
        je next_char                        
        
        cmp byte [esi + ecx], "+"           ; Checks if current char is +
        je add_operation                    ; Jumps to the add operation instructions
        
        cmp byte [esi + ecx], "*"           ; Checks if current char is *
        je mul_operation                    ; Jumps to the mul operation instructions
        
        cmp byte [esi + ecx], "/"           ; Checks if current char is /
        je div_operation                    ; Jumps to the div operation instructions
        
        cmp byte [esi + ecx], "-"           ; - can be an operation or a negative number
        je check_negative                   ; Check if - preceeds a number or a space
        
        movzx eax, byte [esi + ecx]         ; Move the character to a register
        sub eax, '0'                        ; Convert it into a number
        
check_number:
        inc ecx                             ; Move onto the next character
        cmp byte [esi + ecx], " "           
        je push_number                      ; If we found space, we push the number found until space
        
        mov bx, 10                          ; If we found another number we multiply the current number by 10
        mul bx                              
        movzx ebx, byte [esi + ecx]         ; Move the new character into a different register
        sub ebx, '0'                        ; Convert it into a number
        add eax, ebx                        ; Add it to the previous number multiplied
        jmp check_number                    ; Loop until we build the whole number byte by byte
        
push_number:
        push eax                            ; Push the number found onto the stack
        inc ecx                             ; Move to the next character in the expression
        cmp ecx, [length]
        jl evaluate_expression              ; If we didn't reach the end of the expression, we keep parsing it
        jmp end                             ; Otherwise we jump to the end

check_negative:
        mov edx, ecx
        inc edx                             ; Move to the next character after -
        cmp edx, [length]                   ; If we were on the last character of the expression, - was an operation
        je sub_operation                    ; Move back to the previous character
        
        mov ecx, edx
        cmp byte [esi + ecx], " "
        je sub_operation                    ; If - is followed by space, is an operation, else is a negative number
        
get_negative:
        movzx eax, byte [esi + ecx]         ; Move the character after - into a register
        sub eax, '0'                        ; Convert it into a number

parse_negative:
        inc ecx
        cmp byte [esi + ecx], " "
        je push_negative_number             ; If the next character is space, we reached the end of the number
        
        mov bx, 10                          ; If we found another number, we multiply the current number by 10
        mul bx
        movzx ebx, byte [esi + ecx]         ; Same procedure as for the positive numbers
        sub ebx, '0'
        add eax, ebx
        jmp parse_negative
        
push_negative_number:
        neg eax                             ; Negate the positive number found after "-"
        push eax                            ; Push it onto the stack
        inc ecx                             ; Move to the next character in the expression
        cmp ecx, [length]
        jl evaluate_expression              ; If we didn't reach the end of the expression, we keep parsing it
        jmp end                             ; Otherwise, we jump to the end

next_char:
        inc ecx                             ; Jump over the space
        jmp evaluate_expression
        
add_operation:
        pop edx                             ; Pop the 2nd operand
        pop ebx                             ; Pop the 1st operand
        add ebx, edx                        ; Efectuate the addition
        push ebx                            ; Push the result back onto the stack
        inc ecx                             ; Move to the next character in the expression
        cmp ecx, [length]
        jl evaluate_expression              ; If we didn't reach the end of the expression, we keep parsing it
        jmp end                             ; Otherwise, jump to the end

sub_operation:
        pop edx                             ; Same as the addition
        pop ebx
        sub ebx, edx
        push ebx
        inc ecx
        cmp ecx, [length]
        jl evaluate_expression
        jmp end

mul_operation:
        pop ebx                             ; Same as the addition
        pop eax
        imul ebx
        push eax
        inc ecx
        cmp ecx, [length]
        jl evaluate_expression
        jmp end

div_operation:
        pop ebx                             ; Same as the addition
        pop eax
        cdq                                 ; Conver eax to quadword for 32-bit division
        idiv ebx
        push eax
        inc ecx
        cmp ecx, [length]
        jl evaluate_expression     
        
end:
        pop eax                             ; Pop the final result from the stack
        PRINT_DEC 4, eax
        xor eax, eax
        pop ebp
        ret
