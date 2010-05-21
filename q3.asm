# Mamman 12 - 3
# Input-1: n - number between 1 to 25
# Input-2: char
# Output: draw square with this char(height = witdh = n)
###################### Macro segment #####################
.macro print (%str)
la $a0, %str
li $v0, 4
syscall
.end_macro	

###################### Data segment ######################
.data
error_in:	.asciiz		"Error: Invalid value, you should pass number between 1 to 25"
prompt_in1:	.asciiz 	"Please pass an interger between 1 to 25: "
prompt_in2:	.asciiz 	"Please pass char: "
new_line:	.asciiz		"\n"

###################### Code segment ######################
.text
.globl main
main:
	la	$a0, prompt_in1		# Print the first prompt
	li	$v0, 4
	syscall
	
	li	$v0, 5			# Read the integer to $v0
	syscall
	move	$t1, $v0		# Move it to $s0
	
	bgt	$t1, 25, error_exit	# If greater than 25
	ble	$t1, 0 , error_exit	# If less than 0
	
	la	$a0, prompt_in2		# Message to print char
	li	$v0, 4
	syscall
	
	li	$v0, 12			# Read char and move it to $s0
	syscall
	move 	$s0, $v0

	move	$t3, $t1
	addi	$t2, $zero, 0		# i for iterator
	
loop_outer:
	print (new_line)
	jal	loop_inner
	
	addi	$t2, $zero, 0		# reset `i`
	addi	$t1, $t1, -1
	bne	$t1, $zero, loop_outer
	j	exit
	
loop_inner:				# Print line of chars(`n` times)
	addi	$t2, $t2, 1
	move	$a0, $s0		# Move char to print
	li	$v0, 11
	syscall
	bge 	$t2, $t3, return
	j	loop_inner
return:
	jr	$ra
	
error_exit:				# Print the error and then exit
	print (error_in)
	j	exit
	
exit:					# Exit
	li	$v0, 10
	syscall
