.data

students:
    student_ids:
        .word 1001
        .word 1002
        .word 1003
        .word 1004
        .word 1005
        .word 0         # This indicates end of array

    student_names:
        .asciiz "John Doe"
        .asciiz "Jane Smith"
        .asciiz "Alex Johnson"
        .asciiz "Emily Davis"
        .asciiz "Michael Wilson"

    student_status:
        .word 0
        .word 0
        .word 0
        .word 0
        .word 0           

prompt:     .asciiz "Choose an option (1 for dropoff, 2 for pickup): "
input_prompt: .asciiz "Enter student ID: "
dropoff_msg: .asciiz "Student status has been updated to Present.\n"
pickup_msg:  .asciiz "Student has been alerted for pick-up.\n"
already_picked_up_msg: .asciiz "Error: Student has already been picked up.\n"
invalid_id_msg: .asciiz "Invalid student ID. Please try again or contact school admin if you forgot the ID\n"
show_name: .asciiz "Student: "

.text
.globl main

main:
    # Step 1: Prompt the user to choose an option
    li $v0, 4
    la $a0, prompt
    syscall

    # Step 2: Get user's choice
    li $v0, 5
    syscall
    move $t0, $v0   # Save the user's choice

    # Step 3: Handle dropoff or pickup based on user's choice
    beq $t0, 1, dropoff
    beq $t0, 2, pickup
    j main

dropoff:
    # Step 4: Prompt the user for the student ID
    li $v0, 4
    la $a0, input_prompt
    syscall

    # Step 5: Get the student ID from the user
    li $v0, 5
    syscall
    move $t1, $v0   # Save the student ID

    # Step 6: Search for the student ID in the array
    la $t2, student_ids
    li $t3, 0   # Index

search_loop:
    lw $t4, 0($t2)
    beq $t4, $t1, update_status_dropoff   # Match found, go to update_status_dropoff
    addiu $t2, $t2, 4   # Move to the next student id
    addiu $t3, $t3, 1   # Increment the index
    bne $t3, 5, search_loop   # Continue searching until all students are checked

    # Step 7: No match found, display invalid message and prompt again
    j invalid_message_dropoff

update_status_dropoff:
    # Step 8: Update student status to "Present"

    # Show student name
    li $v0, 4
    la $a0, show_name
    syscall
    mul $t2, $t3, 4     # Get offset to student_name item
    la $t5, student_names
    add $t2, $t2, $t5
    move $a0, $t2
    syscall
    li $v0, 11
    li $a0, '\n'    # Print newline
    syscall

    li $v0, 4
    la $a0, dropoff_msg
    syscall

    # Update the status to "1" (Present)
    li $v0, 1
    mul $t2, $t3, 4     # Get offset to student_status item
    la $t5, student_status
    add $t2, $t2, $t5
    sw $v0, 0($t2)

    j main

pickup:
    # Step 9: Prompt the user for the student ID
    li $v0, 4
    la $a0, input_prompt
    syscall

    # Step 10: Get the student ID from the user
    li $v0, 5
    syscall
    move $t1, $v0   # Save the student ID

    # Step 11: Search for the student ID in the array
    la $t2, student_ids
    li $t3, 0   # Index

search_loop2:
    lw $t4, 0($t2)
    beq $t4, $t1, update_status_pickup   # Match found, go to update_status_pickup
    addiu $t2, $t2, 4   # Move to the next student id
    addiu $t3, $t3, 1   # Increment the index
    bne $t3, 5, search_loop2   # Continue searching until all students are checked

    # Step 12: No match found, display invalid message and prompt again
    j invalid_message_pickup

update_status_pickup:
    # Step 13: Check if the status is already "Picked Up" (2)

    # Show student name
    li $v0, 4
    la $a0, show_name
    syscall
    mul $t2, $t3, 4     # Get offset to student_name item
    la $t5, student_names
    add $t2, $t2, $t5
    move $a0, $t2
    syscall
    li $v0, 11
    li $a0, '\n'    # Print newline
    syscall

    mul $t2, $t3, 4     # Get offset to student_status item
    la $t5, student_status
    add $t2, $t2, $t5
    lw $v0, 0($t2)   # Load the status
    beq $v0, 2, invalid_status_pickup   # Status is already "Picked Up", display error message

    # Step 14: Update student status to "2" (Picked Up)
    li $v0, 4
    la $a0, pickup_msg
    syscall

    # Update the status to "2" (Picked Up)
    li $v0, 2
    sw $v0, 0($t2)

    j main

invalid_status_pickup:
    # Step 15: Display error message for invalid status
    li $v0, 4
    la $a0, already_picked_up_msg
    syscall

    j main

invalid_message_dropoff:
    # Step 16: Display error message for invalid student ID in dropoff
    li $v0, 4
    la $a0, invalid_id_msg
    syscall

    j main

invalid_message_pickup:
    # Step 17: Display error message for invalid student ID in pickup
    li $v0, 4
    la $a0, invalid_id_msg
    syscall

    j main
