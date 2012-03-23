#######################################
## 
## Name: Kah Jing Lee
## Section: 1
## 
## Partner's Name: Ter Chrng Ng
## Section: 2
##
#######################################
#  This simple MAL program reads in 2 integers and 1 operator, 
#  do the operations on them, and prints it out.

   .data
ask_int:      .asciiz  "Enter 2 integers: "
bad_int:      .asciiz  "\nBad integer input.  Quitting. "
ask_ope:      .asciiz  "Enter operator (a, s, m, or d): "
bad_ope:      .asciiz  "Bad operator encountered.  Quitting. "
bad_div:      .asciiz  "Divide by 0 encountered.  Quitting. "
str_res:      .asciiz  "Operation result is "
str_neg:      .byte  '-'

newlineC:     .byte  '\n'
  spaceC:     .byte  ' '
    plus:     .byte  'a'
   minus:     .byte  's'
 product:     .byte  'm'
division:     .byte  'd'
 divisor:     .word  0x05F5E100     # largest integer possible

.text

__start:
########## Read two integers and an operator ##########
##  $23 -- operator
##  $24 -- first integer
##  $25 -- second integer

read_int:  puts ask_int         # print ask integers
           lb   $10, spaceC     # read characters and calculate
           li   $11, 57         # the integer represented
           li   $12, 48
           getc $9          # read the first character input

get_1st_c: beq  $9, $10, end_1st_c  # space char terminates loop
           bgt  $9, $11, int_error  # check if the character is within 0-9 
           blt  $9, $12, int_error
           sub  $13, $9, 48     # convert char to digit
           mul  $14, $14, 10        # int = int * 10 + digit
           add  $14, $14, $13   # get the first integer and store it in $14
           getc $9      # keep checking if more char(integer) input
           b    get_1st_c

end_1st_c: move $24, $14        # copy the value in $14 to $24
           lb   $10, newlineC   # read characters and calculate
           getc $9
           li   $14, 0          # clear result

get_2nd_c: beq  $9, $10, end_2nd_c  # newline char terminates loop
           bgt  $9, $11, int_error
           blt  $9, $12, int_error
           sub  $13, $9, 48         # convert char to digit
           mul  $14, $14, 10        # int = int * 10 + digit
           add  $14, $14, $13   # get the first integer and store it in $14
           getc $9      
           b    get_2nd_c   # unconditional branch to check for input

end_2nd_c: move $25, $14    # move the value in $14 to $25


read_ope:  puts ask_ope         # print ask operator
           getc $9              # get the operator
           move $23, $9         # move the operator in $9 to $23
           putc newlineC

           lb   $10, plus           # check if operator 'a' is entered
           beq  $23, $10, op_add
           lb   $10, minus          # check if operator 's' is entered
           beq  $23, $10, op_min
           lb   $10, product        # check if operator 'm' is entered
           beq  $23, $10, op_pro
           lb   $10, division       # check if operator 'd' is entered
           beq  $23, $10, op_div
           b ope_error              # invalid characters encountered

########## Error Control ##########
int_error: la   $8, bad_int # error displayed when bad integer encountered
           puts $8
           j    end_program

ope_error: la   $8, bad_ope # error displayed when bad operator encountered
           puts $8
           j    end_program

div_error: la   $8, bad_div # error displayed when divided by 0
           puts $8
           j    end_program

########## Operator Waterfall ##########
##  $14 -- result
##  $23 -- operator
##  $24 -- first integer
##  $25 -- second integer

op_add:    add $14, $24, $25        # addition
           b print_int
op_min:    sub $14, $24, $25        # substraction
           b print_int
op_pro:    mul $14, $24, $25        # multiplication
           b print_int
op_div:    li $8, 0
           beq $25, $8, div_error   # check for divide by zero error
           div $14, $24, $25
           b print_int

########## Result Printer ##########
##  $14 -- the integer to be printed
##  $15 -- digit mask
##  $16 -- value to be printed
##  $18 -- non-leading zero indicator

print_int: la $8, str_res
           puts $8              # print the negative character

           bgez $14, positive   # check if less than zero
           not $14, $14         # get the 2's complement 
           li   $19, 1
           add $14, $14, $19        
           putc str_neg         # Display negative character

positive:  #Check for zero
           beqz $14, value_zero 
           
#Check for the largest int possible (100M)
           li  $18, 0          # load 0 into $8
           lw  $15, divisor    # load word(largest integer) into $15

print_loop: 
           beqz $15, end_program    
           div $16, $14, $15        # get the most significant bit in $14
           bgtz $16, non_zero       # branch if value is greater than 0
           div $15, $15, 10         # divide the divisor by 10
           beqz $18, print_loop     # loop till divisor equal to most 
           putc '0'                 # significant bit   
           mul $15, $15, 10     
           beqz $15, end_program    # check if integer has been all printed
           rem $14, $14, $15        # get rid of the most significant bit
           div $15, $15, 10 
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
