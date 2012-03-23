# Name and section: Kah Jing Lee, Section 1
# Partner's Name and section: Ter Chrng Ng, Section 2

# This MIPS assembly language program loops to read a
# user-entered integer (entered in decimal).  For each 0 
# or positive integer read, the integer is printed back out,
# first in decimal, and then in base 2.
# The program ends when a poorly-formed integer is
# read.

.data
int_prompt: .asciiz "Enter a zero or positive integer: "
divisor:    .word   0x05F5E100     # largest integer possible

.text
__start:
    sub   $sp, $sp, 8   # 2 word AR, for 2 parameters
while:    

    puts  int_prompt
    jal   get_integer 
    move  $8, $v0

    # the program ends when a non-integer value is entered
    bltz  $8, end       # check that int >= 0
	 
    sw    $8, 4($sp)
    li    $9, 10        # set base of integer to 10
    sw    $9, 8($sp)
    jal   print_integer
    putc  '\n'

    sw    $8, 4($sp)
    li    $9, 2         # set base of integer to 2
    sw    $9, 8($sp)
    jal   print_integer
    putc  '\n'

    b     while

end:
    putc  '\n'
    add   $sp, $sp, 8   # pop AR
    done
          
####################

#get_integer: 
# A function that reads in, and returns a user-integer, or the value -1 
# for a badly formed integer. A well-formed integer has only the
# digits '0'-'9', and is ended with the newline character.

get_integer:
   sub  $sp, $sp, 16         # allocate AR
   sw   $ra, 16($sp)         # save registers in AR
   sw   $8,  4($sp)
   sw   $9,  8($sp)
   sw   $10, 12($sp)

   li   $10, 0               # $10 is the calcuated integer
   getc $8                   # $8 holds 1 user-entered character 
   li   $9, 10               # check if 1st character is newline
   beq  $8, $9, not_pos_int

gi_while_1:
   li   $9, 10               # check if character is newline
   beq  $8, $9, gi_epilogue

   li   $9, 48               # $9 is the ASCII character '0'
   blt  $8, $9, not_pos_int
   sub  $8, $8, $9           # $8 is now 2's comp rep that is >= 0

   li   $9, 10               # $9 is now the constant 10
   bge  $8, $9, not_pos_int 
	 
   mul  $10, $10, $9         # int = ( int * 10 ) + digit
   add  $10, $10, $8
         
   getc $8
   b    gi_while_1           # loop to get more digits

not_pos_int:  
   li   $10, -1	             # return value = -1

gi_epilogue: 
   move $v0, $10             # set return value in its proper register
   lw   $8,  4($sp)          # restore register values
   lw   $9,  8($sp)
   lw   $10, 12($sp)
   lw   $ra, 16($sp)
   add  $sp, $sp,16          # deallocate AR space
   jr   $ra                  # return



##################################
# print_integer:
# It receives two parameters: the integer to be printed out and the base to 
# print in.
#################################################################
##  Register usage
##
##  $8   -- the radix(base)
##  $9   -- the integer to be printed
##  $10  -- divisor
##  $11  -- value to be printed(character form)
##  $12  -- non-leading zero indicator
##  $13  -- used to get biggest divisor
#################################################################


print_integer:

   sub  $sp, $sp, 32    # allocate AR
   sw   $ra, 28($sp)    # save registers in AR
   sw   $8,  4($sp)     #  base/radix
   sw   $9,  8($sp)     #  the integer to be printed
   sw   $10,  12($sp)   #  divisor
   sw   $11,  16($sp)   #  value to be printed(character form)
   sw   $12,  20($sp)   #  non-leading zero indicator
   sw   $13,  24($sp)   #  
   
   lw   $9, 36($sp)     # integer
   lw   $8, 40($sp)     # radix
   
   
print_int: bgez $9, positive   # check if less than zero
           not $9, $9          # get the 2's complement 
           add $9, $9, 1        
           putc '-'            # Display negative character

positive:  # Check for zero
           beqz $9, value_zero 
           
           #Calculate biggest possible divisor
           li   $12, 0          # load 0 into $12
           move $13, $9         # move int to be printed into $13
           li   $10, 1

get_divisor:
           div  $13, $13, $8        # divide to get biggest divisor
           beqz $13, print_loop     # biggest divisor reached
           mul  $10, $10, $8        # get the multiple of the radix/base
           b    get_divisor 
           
print_loop: 
           beqz $10, p_return_good    # end program, all digits has been printed
           div $11, $9, $10           # get the most significant bit in $9
           bgtz $11, non_zero         # branch if value is greater than 0
           div $10, $10, $8           # divide the divisor by base/radix
           beqz $12, print_loop       # loop till divisor equal to most 
           putc '0'                   # significant bit   
           mul $10, $10, $8     
           beqz $10, p_return_good    # check if integer has been all printed
           rem $9, $9, $10            # get rid of the most significant bit
           div $10, $10, $8           # divide the divisor by base/radix
           b print_loop     

non_zero:  rem $9, $9, $10          # get rid of the most significant bit
           div $10, $10, $8         # divide the divisor by the radix/base
           add  $11, $11, 48        # get the character to be printed
           putc $11                 # print the character 
           li $12, 1                # load 1 as divisor is set to m.s.b.
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


