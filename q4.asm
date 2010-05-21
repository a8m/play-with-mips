# Mamman 12 - 4
# Name: Mashraki Ariel
###################### Macro segment #####################
# Print numbers
.macro printn (%int)
move	$a0, %int
li	$v0, 1
syscall
.end_macro
# Print string
.macro print (%str)
la	$a0, %str
li	$v0, 4
syscall
.end_macro
# load num and list to $a0 and $a1
.macro load_arr(%a0, %a1)
la	$a0, %a0
la	$a1, %a1
.end_macro
# push arguments and $ra to stack using frame pointer
.macro push()
# frame pointer
addi	$sp, $sp, -4
sw	$fp, 0($sp)
move	$fp, $sp
# $a0, $a1 and $ra
addi	$sp, $sp, -12
sw	$ra, -4($fp)
sw	$a0, -8($fp)
sw	$a1, -12($fp)
.end_macro
# popup arguments and $ra from stack(i.e: `restore`)
.macro pop()
lw	$a1, -12($fp)
lw	$a0, -8($fp)
lw	$ra, -4($fp)
lw	$fp, 0($fp)
addi	$sp, $sp, 16
.end_macro
###################### Data segment ######################
.data
# Globals
num:		.word	0	# i.e: length
arr:		.space	80	# allocate 80 consecutive bytes(4 bytes * 20 indexs)
# Inputs:
menu:		.asciiz "The options are:\n1. Enter a number \n2. DEL a number \n3. Find a number in the array \n4. Find average \n5. Find Max \n6. Num of elements in the Array \n7. Print Array \n8. END\n"
input_num:	.asciiz	"Please Insert some number: "
# Outputs :
new_line:	.asciiz	"\n"
comma:		.asciiz ", "
# System:
bra_r:		.asciiz	"[ "
bra_l:		.asciiz	" ]"
repl_arrow:	.asciiz "> "
add_msg:	.asciiz "[System]: Number added\n"
del_msg:	.asciiz "[System]: Number deleted\n"
len_msg:	.asciiz	"[System]: The Array length is: "
max_msg:	.asciiz	"[System]: The max value is: "
average_msg:	.asciiz	"[System]: The average is: "
err_empty:	.asciiz "[System]: Array is empty\n"
err_full:	.asciiz "[System]: Array is full\n"
err_exist:	.asciiz "[System]: The number is exist in index: "
err_not_exist:	.asciiz "[System]: The given number not exist in the Array\n"
err_invalid_op:	.asciiz "[System]: Invalid options, try again\n"

###################### Code segment ######################
.text
.globl main
main:
	print (menu)
	j	repl
repl:
	print (repl_arrow)
	li	$v0, 5				# Insert option
	syscall
	move	$t5, $v0
	load_arr (num, arr)			# Load array and num
	beq	$t5, 1, add_action
	beq	$t5, 2, del_action
	beq	$t5, 3, find_action
	beq	$t5, 4, average_action
	beq	$t5, 5, max_action
	beq	$t5, 6, length_action
	beq	$t5, 7, print_action
	beq	$t5, 8, exit
	print (err_invalid_op)
	j	repl
	
print_action:
	jal	printer
	j	repl	
length_action:
	jal	length
	j	repl
max_action:
	jal	max_number
	j	repl
average_action:
	jal	average
	j	repl	
find_action:
	jal	find_number
	j	repl	
del_action:
	jal	del_number
	j	repl
add_action:
	jal	add_number
	j	repl

length:
	lw	$s1, 0($a0)
	print (len_msg)
	printn ($s1)
	print (new_line)
	jr	$ra
	
# $a0 - num, $a1 - arr
max_number:
	lw	$s1, 0($a0)
	ble	$s1, 0, empty_error
	push()
	move	$a0, $s1
	addi	$a2, $zero, 1
	addi	$t0, $zero, 0
	addi	$t1, $zero, 0
	jal	max
	move	$s2, $v0	# Get max value
	move	$s3, $v1	# Get max index
	pop()
	print (max_msg)
	printn ($s2)
	print (new_line)
	print (err_exist)
	printn ($s3)
	print (new_line)
	jr	$ra
# $a0 - num value, $a1 - arr address, $a2 - i
max:
	bgt	$a2, $a0, return_max
	sll	$t3, $a2, 2		# i
	add	$t3, $t3, $a1		#
	lw	$t4, 0($t3)		# A[i]
	bgt	$t4, $t0, set_max
	addi	$a2, $a2, 1		# else, no change
	j	max
set_max:
	move	$t0, $t4		# set max value
	move	$t1, $a2		# set max index
	addi	$a2, $a2, 1		# i++
	j	max
return_max:
	move	$v0, $t0	# Value max size
	move	$v1, $t1	# Index max size
	jr	$ra

# $a0 - num, $a1 - arr
# [1, ..., n] / n
average:
	lw	$s1, 0($a0)
	ble	$s1, 0, empty_error
	push()
	move	$a0, $s1
	addi	$s2, $zero, 0
	jal	sum
	pop()
	div	$s2, $s1		# Divide
	mflo	$t0			# Get result
	print (average_msg)		# Print messages
	move	$a0, $t0
	li	$v0, 1
	syscall
	print (new_line)
	jr	$ra			# Return
	
# $a0 - value of num, $a1 - arr
sum:
	ble	$a0, 0, return_sum
	sll	$t0, $a0, 2 			# index of array
	add	$t0, $t0, $a1			# Now $t0 = address of A[i]
	lw	$t1, 0($t0)			# Load the content to $t2
	add	$s2, $s2, $t1			# sum += A[i]
	addi	$a0, $a0, -1			# i--
	j	sum
	
return_sum:
	move	$v0, $s2
	jr	$ra

# $a0 - num, $a1 - arr
find_number:
	lw	$s1, 0($a0)
	ble	$s1, 0, empty_error
	push()
	jal	scan_num
	pop()
	move	$a2, $v0			# The result of scaning
	push()
	move	$a0, $s1			# Move the value of Num to check
	jal	check
	move	$s0, $v0			# Save the return value of indexOf
	pop()
	
	beq	$s0, -1, not_exist_error	# If the number exist
	j 	exist_error

# $a0 - num, $a1 - arr
del_number:
	lw	$s1, 0($a0)
	ble	$s1, 0, empty_error
	push()
	jal	scan_num
	pop()
	move	$a2, $v0			# The result of scaning
	push()
	move	$a0, $s1			# Move the value of Num to check
	jal	check
	move	$s0, $v0			# Save the return value of indexOf
	pop()
	
	beq	$s0, -1, not_exist_error	# If the number not exist
	j	rearrange
rearrange:
	beq	$s0, $s1, return_del_number	# if i == Num
						# else
	sll	$t0, $s0, 2 			# index of array
	add	$t0, $t0, $a1			# Now $t0 = address of A[i]
	addi	$t1, $t0, 4			# Now $t0 = address of A[i+1]
	lw	$t2, 0($t1)			# Get the value of A[i+1]
	sw	$t2, 0($t0)			# store scan-number($a2) in A[i]
	
	addi	$s0, $s0, 1			# i++
	j	rearrange
	
return_del_number:
 	addi	$s1, $s1, -1			# else increment num by one		
	sw	$s1, 0($a0)			# Load word to save it
	print (del_msg)
	jr	$ra
	
empty_error:
	print (err_empty)
	jr	$ra

not_exist_error:
	print (err_not_exist)
	jr	$ra

# $a0 - num, $a1 - arr
add_number:
	lw	$s1, 0($a0)			# Get the num value
	bge	$s1, 20, full_error
	push()
	jal	scan_num
	pop()
	move	$a2, $v0			# The result of scaning
	push()
	move	$a0, $s1
	jal	check
	move	$s0, $v0			# Save the return value of indexOf
	pop()
	
	bne	$s0, -1, exist_error		# If the number exist
	addi	$s1, $s1, 1			# else increment num by one		
	sw	$s1, 0($a0)
	
	sll	$t0, $s1, 2 			# index of array
	add	$t0, $t0, $a1			# Now $t0 = address of A[i]
	sw	$a2, 0($t0)			# store scan-number($a2) in A[i]
	print (add_msg)
	jr	$ra

full_error:
	print (err_full)
	jr	$ra
	
exist_error:
	print (err_exist)
	move	$a0, $s0
	li	$v0, 1
	syscall
	print (new_line)
	jr	$ra

# description:
# test if given number is in the given array, 
# if it exist return is index, else -1
# 
# params:
# $a0 - array length
# $a1 - base refrence to array
# $a2 - number to find
check:
	ble	$a0, 0, check_failed		# If the length is less than 0
	sll	$t0, $a0, 2			# Index in array(i * 4)
	add	$t0, $t0, $a1			# Now $t0 = address of A[i]
	lw	$t1, 0($t0)			# $t1 = whatever is in A[i]
	beq	$a2, $t1, check_success		# Check success, it exist in the index($a0)
	addi	$a0, $a0, -1
	j	check
check_failed:
	addi	$v0, $zero, -1
	jr	$ra
check_success:
	move	$v0, $a0
	jr	$ra
	
# This is kind of scanner
scan_num:
	print (input_num)
	li	$v0, 5
	syscall
	jr	$ra

# Printer function
printer:
	lw	$t0, 0($a0)		# Num value
	move	$t1, $a1		# Array address
	addi	$t2, $zero, 1		# `i` iterator
	print (bra_r)
print:
	sll	$t3, $t2, 2
	add	$t3, $t3, $t1		# Get the address array-address + index * 4(word-size)
	lw	$a0, 0($t3)		# Load the content from A[i]
	li	$v0, 1
	syscall
	addi	$t2, $t2, 1		# Increment `i` by one
	bgt	$t2, $t0, return_print
	print (comma)			# Print comma `, `
	j	print			# Keep running the loop
return_print:
	print (bra_l)
	print (new_line)
	jr	$ra

# exit the program
exit:
	li	$v0, 10
	syscall




