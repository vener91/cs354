# Name and section: Kah Jing Lee, Section 1
# Partner's Name and section: Ter Chrng Ng, Section 2

# This program reads in exactly 4 base-10 zero or positive integers, placing
# valid ones into an array (a stack, really). Then, 3 characters are
# prompted for and read in, representing the operators for a limited RPN
# expression evaluation.  The program does the evaluation and prints the
# result in decimal. 

.data
STACK_SIZE:     .word   4       # integer size
NUM_OPERATORS:  .word   3       # number of operators
stack:          .word   0:4     # stack for integers
operators:      .byte   0:3     # array for operators
str_prompt1:    .asciiz "RPN expression evaluation. Enter 4 integers and 3 operators.\n"
str_prompt2:    .asciiz "Enter integer:  "
str_prompt3:    .asciiz "Enter operator:  "
msg_out1:       .asciiz "Result is "
str_badinput:   .asciiz "\nBad user input.  Quitting.\n"	
str_divideby0:  .asciiz "Divide by 0 encountered.  Quitting.\n"	
newline:        .asciiz "\n"	

 .text
__start:
   sub  $sp, $sp, 12     # 3 parameters (max) passed from main()
 #   so allocate stack space for them
   puts str_prompt1
   # set up parameters and call readInts()
   lw   $8, STACK_SIZE   # $8 is number of elements in array/stack
   la   $9, stack# $9 is base addr of stack
   li   $10, -1  # $10 is value returned by readInts() or
 #    readOperators() if input is bad
   sw   $9, 4($sp)       # P1 is base address of array
   sw   $8, 8($sp)       # P2 is number of elements to read
   jal  readInts

   # check validity of user input integers
   beq  $v0, $10, bad_input
   bne  $v0, $8, bad_input

   # set up parameters and call readOperators()
   lw   $8, NUM_OPERATORS# $8 is number of elements in array
   la   $9, operators    # $9 is base addr of array
   sw   $9, 4($sp)       # P1 is base address of array
   sw   $8, 8($sp)       # P2 is number of chars to read
   jal  readOperators

   # check validity of user input operators
   beq  $v0, $10, bad_input
   bne  $v0, $8, bad_input

   # evaluate using user input
   la   $8, stack # $8 is now base address of stack 
   la   $9, operators     # $9 is now base address of operators 
   lw   $10, STACK_SIZE   # $10 is now number of integers
   sw   $8, 4($sp)# P1 is base address of stack
   sw   $9, 8($sp)# P2 is base address of ops array
   sw   $10, 12($sp)      # P3 is number of integers
   jal  evaluate
   li   $11, -1   # return value of -1 was divide by 0
   beq  $v1, $11, div_by_0
   move $11, $v0  # expression evaluation result in $11

   # print result
   puts msg_out1
   sw   $11, 4($sp)       # P1 is result to print
   li   $12, 10   # P2 is radix to print in
   sw   $12, 8($sp)       
   jal  print_integer
   puts newline
   b    end_program

bad_input:  
   puts str_badinput
   b    end_program

div_by_0:
   puts str_divideby0
   b    end_program

end_program:    
   add  $sp, $sp, 12
   done


#################################################################
#readInts
# The function reads the integers, and place them on the stack. If value -1 is # returned from the get_integer function, it halts. After all valid integers 
# are stored, it returns the number of integers. 
# It receives two parameters: the base address of the stack (array), and the 
# number of integers it hopes to read in.
#################################################################
##  Register usage
##
##  $8 -- int array pointer
##  $9 -- array size(integer array)
##  $10 -- store the returned integer and later put it in address of $8
#################################################################
readInts:    
   sub  $sp, $sp, 20 # allocate AR
   sw   $ra, 16($sp) # save registers in AR
   sw   $8,  4($sp)  
   sw   $9,  8($sp)
   sw   $10,  12($sp)
   
   lw   $8, 24($sp) # load integer stack location
   lw   $9, 28($sp) # number of integers expected

# store the input integer and increase integer array pointer
read_int:  
   puts str_prompt2     # print message
   jal get_integer
   bltz $v0, ri_return_bad # return bad input
   move $10, $v0      # move the returned integer into $10
   sw   $10, ($8)     # store the returned integer in address of $8 
   sub  $9, 1         # decrement counter
   add  $8, $8, 4     # increment pointer
   bnez $9, read_int  # check if more integer to be read (total of $9)
   sub  $8, $8, 4     # Go back to top of the stack
   lw   $9, 28($sp)   # number of integers expected
   b ri_return_good   #

ri_return_bad:
   li   $9, -1	     # return value = -1

ri_return_good:
   move $v0, $9      # set return value (number of ints)
   lw   $8,  4($sp)  # restore register values
   lw   $9,  8($sp)
   lw   $10, 12($sp)
   lw   $ra, 16($sp)
   add  $sp, $sp,20  # deallocate AR space
   jr   $ra          # return

#################################################################
#readOperators
# The function reads the operators, and place them in the array. If bad 
# operator is encountered, it halts and returns -1. After all valid operators
# are stored, it returns the number of operators. It receives two parameters: 
# the base address of the array, and the number of operators it hopes to read 
# in.
#################################################################
##  Register usage
##
##  $8 -- operator array pointer
##  $9 -- number of operators 
##  $10 -- store the characters for valid operators to compare
##  $11 -- get the operator character input
#################################################################
readOperators:
   sub  $sp, $sp, 24 # allocate AR
   sw   $ra, 20($sp) # save registers in AR
   sw   $8,  4($sp)
   sw   $9,  8($sp)
   sw   $10, 12($sp)
   sw   $11, 16($sp)
   
   lw   $8, 28($sp) # load operator array base location 
   lw   $9, 32($sp) # number of operators expected
   
# store the input operator and increase operator array pointer
get_ope:  
   puts str_prompt3     # print message
   getc $11             # get the operator
   puts newline         
   li   $10, 'a'            # check if operator 'a' is entered
   beq  $11, $10, store_op  # if it is 'a', store it 
   li   $10, 's'            # check if operator 's' is entered
   beq  $11, $10, store_op  # if it is 's', store it 
   li   $10, 'm'            # check if operator 'm' is entered
   beq  $11, $10, store_op  # if it is 'm', store it 
   li   $10, 'd'            # check if operator 'd' is entered
   beq  $11, $10, store_op  # if it is 'd', store it 
   b    ro_return_bad       # invalid characters encountered
   
store_op:
   sw   $11, ($8)       # store the operator to address $8 pointing at
   sub  $9, 1           # decrement counter
   add  $8, $8, 4       # increment pointer
   bnez $9, get_ope     # check if more operator to be read (total of 3)
   sub  $8, $8, 4       # point at the first operator
   lw   $9, 32($sp)     # number of operators expected
   b ro_return_good

ro_return_bad:
   li   $9, -1	     # return value = -1

ro_return_good: 
   move $v0, $9      # set return value (number of operator)
   lw   $8,  4($sp)  # restore register values
   lw   $9,  8($sp)
   lw   $10,  12($sp)
   lw   $11,  16($sp)
   lw   $ra, 20($sp)
   add  $sp, $sp,24  # deallocate AR space
   jr   $ra          # return

#################################################################
#evaluate
# This function uses the integers in the stack (array) and the operators (in  
# their array), and does the Reverse Polish notation evaluation of the 
# expression they represent. The first parameter is the base address of the 
# array (stack) holding the integer values, the second parameter is the array 
# of operators , and the third parameter is the number of integers in the 
# stack. This function makes use of both return value registers: $v0 is to have # the result of expression evaluation, and $v1 is to contain the value -1 if 
# there was a divide by 0 operation encountered during evaluation, and not -1 
# otherwise.
#################################################################
##  Register usage
##  $8  -- integer stack
##  $9  -- operator array
##  $10 -- size of integer stack
##  $11 -- temp ope value holder
##  $12 -- temp int value holder
##  $13 -- temp result, also the first integer value holder
##  $14 -- temp ope comparison storage
#################################################################
evaluate:
   sub  $sp, $sp, 36 # allocate AR
   sw   $ra, 32($sp) # save registers in AR
   sw   $8,  4($sp)
   sw   $9,  8($sp) 
   sw   $10, 12($sp)
   sw   $11, 16($sp) #  $11 -- temp ope value 
   sw   $12, 20($sp) #  $12 -- temp int value
   sw   $13, 24($sp) #  $13 -- temp result
   sw   $14, 28($sp) #  $14 -- temp ope comparison storage


   lw   $8, 40($sp)     # integer stack
   lw   $9,  44($sp)    # operator array
   lw   $10,  48($sp)   # size of integer stack
   
   # Go to end of stack
   sub  $10, $10, 1         # Decrease counter
   mul  $11, $10, 4
   add  $8, $8, $11
   
   lw   $13, ($8)         # load first value(integer)
   sub  $8, $8, 4         # decrement int pointer
   
read_ope:  
   lw  $12, ($8)   # load pointer value, should be 2nd 
                   # element on first run
   sub $8, $8, 4   # decrement int pointer
   lw  $11, ($9)   # load operator into $11
   add $9, $9, 4   # increment ope pointer
   li   $14, 'a'   # check if operator 'a' is entered
   beq  $11, $14, op_add
   li   $14, 's'  # check if operator 's' is entered
   beq  $11, $14, op_min
   li   $14, 'm'  # check if operator 'm' is entered
   beq  $11, $14, op_pro
   li   $14, 'd'  # check if operator 'd' is entered
   beq  $11, $14, op_div
   b    e_return_bad   # invalid characters encountered

#Start of operator waterfall
op_add:    
   add $13, $12, $13# addition
   b next_op
op_min:    
   sub $13, $12, $13# substraction
   b next_op
op_pro:    
   mul $13, $12, $13# multiplication
   b next_op
op_div:
   beqz $13, e_return_bad   # check for divide by zero error
   div $13, $12, $13

next_op:   
   sub  $10, 1          # decrement counter
   bnez $10, read_ope   # if more operator, keep the operations on
   b e_return_good      # else branch to return

e_return_bad:
   li   $13, -1	     # return value = -1
   move $v1, $13     # set value in $13 as return

e_return_good:
   move $v0, $13        # set answer as return value
   lw   $8,  4($sp)     # restore register values
   lw   $9,  8($sp)
   lw   $10,  12($sp)
   lw   $11,  16($sp)
   lw   $12,  20($sp)
   lw   $13,  24($sp)
   lw   $14,  28($sp)
   lw   $ra, 32($sp)
   add  $sp, $sp,36     # deallocate AR space
   jr   $ra             # return
   
#################################################################
# print_integer:
# It receives two parameters: the integer to be printed out and the base(radix) # to print in.
#################################################################
##  Register usage
##   $8  -- store the radix
##   $9  -- the integer to be printed
##   $10 -- divisor
##   $11 -- value to be printed(character form)
##   $12 -- non-leading zero indicator
##   $13 -- used to get the largest divisor
#################################################################

print_integer:

   sub  $sp, $sp, 32 # allocate AR
   sw   $ra, 28($sp) # save registers in AR
   sw   $8,  4($sp) 
   sw   $9,  8($sp)     #  $9 -- the integer to be printed
   sw   $10,  12($sp)   #  $10 -- divisor
   sw   $11,  16($sp)   #  $11 -- value to be printed(character form)
   sw   $12,  20($sp)   #  $12 -- non-leading zero indicator
   sw   $13,  24($sp)   #  $13 -- store value to be printed
   
   lw   $9, 36($sp)     # integer to be printed
   lw   $8, 40($sp)     # radix
   
   
print_int: bgez $9, positive   # check if less than zero
           not $9, $9          # get the 2's complement 
           add $9, $9, 1        
           putc '-'            # Display negative character


positive: 
           beqz $9, value_zero  # Check for zero
           
           #Calculate biggest possible divisor
           li   $12, 0          # load 0 into $12
           move $13, $9         # store the value to be printed in $13
           li   $10, 1          

get_divisor:
           div  $13, $13, $8        # divide to get the most significant bit
                                    # using radix input
           beqz $13, print_loop     # biggest divisor reached
           mul  $10, $10, $8        # get the multiple of the radix
           b    get_divisor
           
print_loop: 
           beqz $10, p_return_good  # end program, all digits has been printed
           div $11, $9, $10         # get the most significant bit in $9
           bgtz $11, non_zero       # branch if value is greater than 0
           div $10, $10, $8         # divide the divisor by the radix(10)
           beqz $12, print_loop     # loop till divisor equal to most 
           putc '0'                 # significant bit   
           mul $10, $10, $8     
           beqz $10, p_return_good    # check if integer has been all printed
           rem $9, $9, $10            # get rid of the most significant bit
           div $10, $10, $8           # divide the divisor by the radix(10)
           b print_loop     

non_zero:  rem $9, $9, $10        # get rid of the most significant bit
           div $10, $10, $8       # divide the divisor by the radix(10)
           add  $11, $11, 48      # get the character to be printed
           putc $11               # print the character 
           li $12, 1              # load 1 as divisor is set to m.s.b.
           b print_loop
           
value_zero: putc '0'                # Display 0 if the output is zero

p_return_good:
   lw   $8,  4($sp)  # restore register values
   lw   $9,  8($sp)
   lw   $10, 12($sp)
   lw   $11, 16($sp)
   lw   $12, 20($sp)
   lw   $13, 24($sp)
   lw   $ra, 28($sp)
   add  $sp, $sp,32  # deallocate AR space
   jr   $ra          # return
##################################
# get_integer: 
# A function that reads in, and returns a user-integer, or the value -1 
# for a badly formed integer. A well-formed integer has only the
# digits '0'-'9', and is ended with the newline character.

get_integer:
   sub  $sp, $sp, 16 # allocate AR
   sw   $ra, 16($sp) # save registers in AR
   sw   $8,  4($sp)
   sw   $9,  8($sp)
   sw   $10, 12($sp)

   li   $10, 0       # $10 is the calcuated integer
   getc $8   # $8 holds 1 user-entered character 
   li   $9, 10       # check if 1st character is newline
   beq  $8, $9, not_pos_int

gi_while_1:
   li   $9, 10       # check if character is newline
   beq  $8, $9, gi_epilogue

   li   $9, 48       # $9 is the ASCII character '0'
   blt  $8, $9, not_pos_int
   sub  $8, $8, $9   # $8 is now 2's comp rep that is >= 0

   li   $9, 10       # $9 is now the constant 10
   bge  $8, $9, not_pos_int 
	 
   mul  $10, $10, $9 # int = ( int * 10 ) + digit
   add  $10, $10, $8
 
   getc $8
   b    gi_while_1   # loop to get more digits

not_pos_int:  
   li   $10, -1	     # return value = -1

gi_epilogue: 
   move $v0, $10     # set return value in its proper register
   lw   $8,  4($sp)  # restore register values
   lw   $9,  8($sp)
   lw   $10, 12($sp)
   lw   $ra, 16($sp)
   add  $sp, $sp,16  # deallocate AR space
   jr   $ra  # return

