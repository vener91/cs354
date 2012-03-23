# Name and section: Kah Jing Lee, Section 1
# Partner's Name and section: Ter Chrng Ng, Section 2

# This program reads in an integer number(which then serves as                 
# to switch between user and kernel mode). After newline 
# character is typed, the user is allowed to key in any 
# character. The program ends with a newline character being 
# typed.

.data
str_prompt1:    .asciiz "Enter positive integer: "
str_badinput:   .asciiz "\nBad user input.  Quitting.\n"
newline:        .asciiz "\n"	

 .text
__start:
   puts str_prompt1     # print message
   
   jal get_integer
   move $10, $v0        # move the returned integer into $10
   bltz $10, bad_input  # jump to bad input if not positive integer
   
read_loop:
   getc $8              # get the operator
   li   $9, 10          # check if 1st character is newline
   bne  $8, $9, read_loop   # if not, loop back
   b end_program            # end program if newline character encountered
   
bad_input:  
   puts str_badinput    # bad input message if not positive integer
   b    end_program

end_program:    
   done

##########################################################################
# get_integer: 
# A function that reads in, and returns a positive user-integer, or the 
# value -1 for a badly formed postive integer. A well-formed postive integer  
# has only the digits '1'-'9', and is ended with the newline character.
##########################################################################
#####################################
# Register usage:
#
# $8 - to get the character input(positive integer input)
# $9 - immediate value for checking newline character
# $10 - the positive integer or -1 to be returned if bad input encountered
#
#####################################

get_integer:
   sub  $sp, $sp, 16 # allocate AR
   sw   $ra, 16($sp) # save registers in AR
   sw   $8,  4($sp)
   sw   $9,  8($sp)
   sw   $10, 12($sp)

   li   $10, 0       # $10 is the calculated integer
   getc $8   # $8 holds 1 user-entered character 
   li   $9, 10       # check if 1st character is newline
   beq  $8, $9, not_pos_int

gi_while_1:
   li   $9, 10       # check if character is newline
   beq  $8, $9, gi_epilogue

   li   $9, 48       # $9 is the ASCII character '0'
   ble  $8, $9, not_pos_int
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

