/*** asmSort.s   ***/
.syntax unified

/* Declare the following to be in data memory */
.data
.align    

/* Define the globals so that the C code can access them */
/* define and initialize global variables that C can access */
/* create a string */
.global nameStr
.type nameStr,%gnu_unique_object
    
/*** STUDENTS: Change the next line to your name!  **/
nameStr: .asciz "Mason Boelter"  

.align   /* realign so that next mem allocations are on word boundaries */
 
/* initialize a global variable that C can access to print the nameStr */
.global nameStrPtr
.type nameStrPtr,%gnu_unique_object
nameStrPtr: .word nameStr   /* Assign the mem loc of nameStr to nameStrPtr */

/* Tell the assembler that what follows is in instruction memory     */
.text
.align

/********************************************************************
function name: asmSwap(inpAddr,signed,elementSize)
function description:
    Checks magnitude of each of two input values 
    v1 and v2 that are stored in adjacent in 32bit memory words.
    v1 is located in memory location (inpAddr)
    v2 is located at mem location (inpAddr + M4 word size)
    
    If v1 or v2 is 0, this function immediately
    places -1 in r0 and returns to the caller.
    
    Else, if v1 <= v2, this function 
    does not modify memory, and returns 0 in r0. 

    Else, if v1 > v2, this function 
    swaps the values and returns 1 in r0

Inputs: r0: inpAddr: Address of v1 to be examined. 
	             Address of v2 is: inpAddr + M4 word size
	r1: signed: 1 indicates values are signed, 
	            0 indicates values are unsigned
	r2: size: number of bytes for each input value.
                  Valid values: 1, 2, 4
                  The values v1 and v2 are stored in
                  the least significant bits at locations
                  inpAddr and (inpAddr + M4 word size).
                  Any bits not used in the word may be
                  set to random values. They should be ignored
                  and must not be modified.
Outputs: r0 returns: -1 If either v1 or v2 is 0
                      0 If neither v1 or v2 is 0, 
                        and a swap WAS NOT made
                      1 If neither v1 or v2 is 0, 
                        and a swap WAS made             
             
         Memory: if v1>v2:
			swap v1 and v2.
                 Else, if v1 == 0 OR v2 == 0 OR if v1 <= v2:
			DO NOT swap values in memory.

NOTE: definitions: "greater than" means most positive number
********************************************************************/     
.global asmSwap
.type asmSwap,%function     
asmSwap:

    /* REMEMBER TO FOLLOW THE ARM CALLING CONVENTION!            */

    /* YOUR asmSwap CODE BELOW THIS LINE! VVVVVVVVVVVVVVVVVVVVV  */
    
    /* Preserve callers registers, as required by ARM calling convention */
    push {r4-r11, lr}
    
    
    /* Load values based off of elementSize */
    cmp r2, 1 /* Compare elementSize to byte size */
    bEQ byteLoad
    cmp r2, 2 /* Compare elementSize to halfword size */
    bEQ halfwordLoad
    cmp r2, 4 /* Compare elementSize to word size */
    bEQ wordLoad
    mov r0, -1 /* If invalid elementSize move -1 into r0 and branch to Return */
    b return
    
    /* Load byte size element */
    byteLoad:
    /* Check if value is signed or unsigned */
    cmp r1, 1
    /* Load signed byte at r0 address */
    ldrsbEQ r3, [r0]
    /* Load signed byte at next word */
    ldrsbEQ r4, [r0, 4]
    /* Load unsigned byte at r0 address */
    ldrbLO r3, [r0]
    /* Load unsigned byte at next word */
    ldrbLO r4, [r0, 4]
    /* Branch to zeroCheck block */
    b zeroCheck
    
    /* Load halfword size element */
    halfwordLoad:
    /* Check if value is signed or unsigned */
    cmp r1, 1
    /* Load signed halfword at r0 address */
    ldrshEQ r3, [r0]
    /* Load signed halfword at next address */
    ldrshEQ r4, [r0, 4]
    /* Load unsigned halfword at r0 address */
    ldrhLO r3, [r0]
    /* Load unsigned halfword at next word */
    ldrhLO r4, [r0, 4]
    /* Branch to zeroCheck block */
    b zeroCheck
    
    /* Load word size element */
    wordLoad:
    /* Load word at r0 address */
    ldr r3, [r0]
    /* Load word at next word */
    ldr r4, [r0,4]
    
    zeroCheck:
    cmp r3, 0
    /* If r3 is zero branch to isZero block*/
    bEQ isZero
    cmp r4, 0
    /* If r4 is zero branch to isZero block */
    bEQ isZero
    /* If neither r3 or r4 is zero branch to comparison */
    b comparison
    
    isZero:
    /* mov -1 into r0 and b return */
    mov r0, -1
    b return
    
    comparison:
    /* Check for signed or unsigned Compare */
    cmp r1, 1
    bNE unsignedComp
    /* Compare signed r3 and r4 */
    cmp r3, r4
    /* If r3 greater than r4 branch to swap */
    bGT swap
    /* If r3 is less than or equal to r4 branch to noSwap */
    bLE noSwap
    
    unsignedComp:
    /* Compare unsigned r3 and r4 */
    cmp r3, r4
    /* If r3 is greater than r4 branch to swap */
    bHI swap
    /* If r3 is less than or equal to r4 branch to noSwap */
    bLS noSwap
    
    swap:
    /* Check for elementSize from r2 */
    cmp r2, 2
    /* If less than branch to byteSwap */
    bLO byteSwap
    /* If equal branch to halfwordSwap */
    bEQ halfwordSwap
    /* If greater than branch to wordSwap */
    bGT wordSwap
    
    byteSwap:
    /* Store value in r4 into r0 address */
    strb r4, [r0]
    /* Store value in r3 into next word address */
    strb r3, [r0, 4]
    /* Set r0 to 1 and branch to return */
    mov r0, 1
    b return
    
    halfwordSwap:
    /* Store value in r4 into r0 address */
    strh r4, [r0]
    /* Store value in r3 into next word address */
    strh r3, [r0, 4]
    /* Set r0 to 1 and branch to return */
    mov r0, 1
    b return
    
    wordSwap:
    /* Store value in r4 into r0 address */
    str r4, [r0]
    /* Store value in r3 into next word address */
    str r3, [r0, 4]
    /* Set r0 to 1 and branch to return */
    mov r0, 1
    b return
    
    noSwap:
    /* Set r0 to 0 to indicate no swap was made */
    mov r0 , 0
    
    return:
    
    /* Restore callers registers, as required by ARM calling convention */
    pop {r4-r11, lr}
    
    bx lr


    /* YOUR asmSwap CODE ABOVE THIS LINE! ^^^^^^^^^^^^^^^^^^^^^  */
    
    
/********************************************************************
function name: asmSort(startAddr,signed,elementSize)
function description:
    Sorts value in an array from lowest to highest.
    The end of the input array is marked by a value
    of 0.
    The values are sorted "in-place" (i.e. upon returning
    to the caller, the first element of the sorted array 
    is located at the original startAddr)
    The function returns the total number of swaps that were
    required to put the array in order in r0. 
    
         
Inputs: r0: startAddr: address of first value in array.
		      Next element will be located at:
                          inpAddr + M4 word size
	r1: signed: 1 indicates values are signed, 
	            0 indicates values are unsigned
	r2: elementSize: number of bytes for each input value.
                          Valid values: 1, 2, 4
Outputs: r0: number of swaps required to sort the array
         Memory: The original input values will be
                 sorted and stored in memory starting
		 at mem location startAddr
NOTE: definitions: "greater than" means most positive number    
********************************************************************/     
.global asmSort
.type asmSort,%function
asmSort:   

    /* REMEMBER TO FOLLOW THE ARM CALLING CONVENTION!            */

    /* YOUR asmSort CODE BELOW THIS LINE! VVVVVVVVVVVVVVVVVVVVV  */
    
    /* Preserve callers registers, as required by ARM calling convention */
    push {r4-r11, lr}
    
    /* r12 will be totalSwapCount counter */
    mov r12, 0
    
    /* Preserve startAddr */
    mov r10, r0
    
    /************ Begin outer loop ***************/
    
    outerLoop:
    /* Initialize hasSwapped flag */
    mov r11, 0
    /* Copy pointer value into r3 */
    mov r3, r10
    
    /* Load element at pointer based on element size */
    cmp r2, 2
    bLO byteLoadSort
    bEQ halfwordLoadSort
    bHI wordLoadSort
    
    byteLoadSort:
    /* Check for signed or unsigned byte value */
    cmp r1, 0
    /* Load unsigned byte value at r3 address */
    ldrbEQ r4, [r3]
    /* Load signed byte value at r3 address */
    ldrsbHI r4, [r3]
    b zeroCheckSort
    
    halfwordLoadSort:
    /* Check for signed or unsigned halfword value */
    cmp r1, 0
    /* Load unsigned halfword value at r3 address */
    ldrhEQ r4, [r3]
    /* Load signed halfword value at r3 address */
    ldrshHI r4, [r3]
    b zeroCheckSort
    
    wordLoadSort:
    /* Load word value at r3 address (No sign needed, yesss) */
    ldr r4, [r3]
    
    zeroCheckSort:
    /* Check if element at r4 equal zero */
    cmp r4, 0
    bEQ endPass
    
    /****************** Begin inner loop *****************/
    innerLoop:
    
    /* Call asmSwap */
    mov r0, r3
    bl asmSwap
    
    /* Check asmSwap return value in r0 */
    cmp r0, 0
    bLO endPass
    movHI r11, 1
    addHI r12, 1
    
    /* Increment pointer to next word */
    add r3, 4
    
    /* Branch back to inner loop */
    
    b innerLoop
    
    endPass:
    /* Check hasSwapped flag */
    cmp r11, 0
    bEQ returnSwap
    b outerLoop
    
    returnSwap:
    mov r0, r12
    
    /* Return callers registers, as required by the ARM calling convention */
    pop {r4-r11, lr}
    
    bx lr


    /* YOUR asmSort CODE ABOVE THIS LINE! ^^^^^^^^^^^^^^^^^^^^^  */

   

/**********************************************************************/   
.end  /* The assembler will not process anything after this directive!!! */
           




