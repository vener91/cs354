###############################################################################
## 
## Name: Kah Jing Lee
## Section: 1
## 
## Partner's Name: Ter Chrng Ng
## Section: 2
##
###############################################################################
#  This simple MAL program reads in 4 integers and 3 operators, and put them 
#  into 2 arrays. Operations are then being done on them, and the result is 
#  then printed out.

.data

#  Instruction, error messages, output messages, and negative sign
instuct:      .asciiz  "RPN expression evaluation. Enter 4 integers and 3 operators. \n"
ask_int:      .asciiz  "Enter integer: "
bad_inp:      .asciiz  "Bad user input.  Quitting. "
ask_ope:      .asciiz  "Enter operator: "
bad_div:      .asciiz  "Divide by 0 encountered.  Quitting. "
str_res:      .asciiz  "Operation result is "
str_neg:      .byte  '-'

#  Operations signs, space sign, and newline
newlineC:     .byte  '\n'
  spaceC:     .byte  ' '
    plus:     .byte  'a'
   minus:     .byte  's'
 product:     .byte  'm'
division:     .byte  'd'
 divisor:     .word  0x05F5E100     # largest integer possible
 
#  Arrays and sizes of arrays
int_array:    .word 0:4     # array to hold integers
int_a_size:   .word 4
ope_array:    .word 0:3     # array to hold integers
ope_a_size:   .word 3

.text

__start:

########## Read 4 integers #########################
##  $9  -- input character of integer
##  $10 -- newline character
##  $11 -- biggest range of integer(digit) possible
##  $12 -- biggest range of integer(digit) possible
##  $14 -- integer(digit) input
##  $24 -- int array pointer
##  $25 -- array size(integer array)

           lb   $10, newlineC     # stores newline character
           la   $24, int_array    # load the pointer to first address into $24
           lw   $25, int_a_size   # store the array size into $25
           
read_int:  puts ask_int         # print ask integer message
           li   $14, 0          # store 0 into $14
           li   $11, 57        
           li   $12, 48         
           getc $9              # read the first character input
           
# read the input integer(in character form) and convert it to integer
get_int:   beq  $9, $10, get_int_end  # space char terminates loop
           bgt  $9, $11, inp_error    # check if the character is within 0-9 
           blt  $9, $12, inp_error
           sub  $13, $9, 48           # convert char to digit
           mul  $14, $14, 10          # int = int * 10 + digit
           add  $14, $14, $13   # get the integer and store it in $14
           getc $9              # keep checking if more char(integer) input
           b    get_int    
           
# store the input integer and increase integer array pointer
get_int_end: 
           sw  $14, ($24)       # store the integer in address of $24 
           sub $25, 1           # decrement counter
           add $24, $24, 4      # increment pointer
           bnez $25, read_int   # check if more integer to be read (total of 4)
           sub  $24, $24, 4     # Go back to top of the stack

########## Read operators ############
##  $9  -- charcter tmp reg
##  $23 -- operator array pointer
##  $24 -- int array pointer
##  $25 -- array size
           
           
           la   $23, ope_array  # load the pointer to first address into $23
           lw   $25, ope_a_size # store the array size into $25
           
get_ope:  puts ask_ope              # print ask operator
           getc $9                  # get the operator
           lb   $10, plus           # check if operator 'a' is entered
           beq  $9, $10, store_op
           lb   $10, minus          # check if operator 's' is entered
           beq  $9, $10, store_op
           lb   $10, product        # check if operator 'm' is entered
           beq  $9, $10, store_op
           lb   $10, division       # check if operator 'd' is entered
           beq  $9, $10, store_op
           b    inp_error           # invalid characters encountered

# store the input operator and increase operator array pointer
store_op:  sw  $9, ($23)
           sub $25, 1           # decrement counter
           add $23, $23, 4      # increment pointer (character array)
           putc newlineC        
           bnez $25, get_ope    # no more operator, continue on

########## RPN evaluator Waterfall ##########
##  $9  -- temp ope value
##  $14 -- result
##  $15 -- temp int value
##  $23 -- operator array pointer
##  $24 -- int array pointer
##  $25 -- array size   (operator array)

           la   $23, ope_array      # load operator array
           lw   $25, ope_a_size     # load operator array size
           lw   $14, ($24)          # load first value(integer)
           sub  $24, $24, 4         # decrement int pointer
read_ope:  
           lw  $15, ($24)           # load pointer value, should be 2nd 
                                    # element on first run
           sub $24, $24, 4          # decrement int pointer
           lw  $9, ($23)            # load operator into $9
           add $23, $23, 4          # increment ope pointer
           lb   $16, plus           # check if operator 'a' is entered
           beq  $9, $16, op_add
           lb   $16, minus          # check if operator 's' is entered
           beq  $9, $16, op_min
           lb   $16, product        # check if operator 'm' is entered
           beq  $9, $16, op_pro
           lb   $16, division       # check if operator 'd' is entered
           beq  $9, $16, op_div
           b    inp_error           # invalid characters encountered

#Start of operator waterfall
op_add:    add $14, $15, $14        # addition
           b next_op
op_min:    sub $14, $15, $14        # substraction
           b next_op
op_pro:    mul $14, $15, $14        # multiplication
           b next_op
op_div:    li $8, 0
           beq $14, $8, div_error   # check for divide by zero error
           div $14, $15, $14

next_op:   sub  $25, 1              # decrement counter
           bnez $25, read_ope       # if more operator, keep the operations on
           b print_int              # else print result
           
########## Error Control ##########
inp_error: la   $8, bad_inp # error displayed when bad integer encountered
           puts $8
           j    end_program

div_error: la   $8, bad_div # error displayed when divided by 0
           puts $8
           j    end_program

########## Result Printer ##########
##  $8  -- negative sign
##  $14 -- the integer to be printed
##  $15 -- digit mask
##  $16 -- value to be printed(character form)
##  $18 -- non-leading zero indicator
##  $19 -- immediate value of 1

print_int: la $8, str_res
           puts $8              

           bgez $14, positive   # check if less than zero
           not $14, $14         # get the 2's complement 
           li   $19, 1
           add $14, $14, $19        
           putc str_neg         # Display negative character

positive:  # Check for zero
           beqz $14, value_zero 
           
# Check for the largest int possible (100M)
           li  $18, 0          # load 0 into $18
           lw  $15, divisor    # load word(largest integer) into $15

print_loop: 
           beqz $15, end_program    # end program, all digits has been printed
           div $16, $14, $15        # get the most significant bit in $14
           bgtz $16, non_zero       # branch if value is greater than 0
           div $15, $15, 10         # divide the divisor by 10
           beqz $18, print_loop     # loop till divisor equal to most 
           putc '0'                 # significant bit   
           mul $15, $15, 10     
           beqz $15, end_program    # check if integer has been all printed
           rem $14, $14, $15        # get rid of the most significant bit
           div $15, $15, 10         # divide the divisor by 10
           b print_loop     

non_zero:  rem $14, $14, $15        # get rid of the most significant bit
           div $15, $15, 10         # divide the divisor by 10
           add  $16, $16, 48        # get the character to be printed
           putc $16                 # print the character 
           li $18, 1                # load 1 as divisor is set to m.s.b.
           b print_loop
           
value_zero: putc '0'                # Display 0 if the output is zero
           
end_program:
            putc newlineC           # put new line and end program
            done
