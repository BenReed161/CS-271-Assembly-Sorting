TITLE Program Template     (Program5.asm)

; Author: Benjamin Reed
; Last Modified: 2/28/2022
; OSU email address: reedbe@oregonstate.edu
; Course number/section: CS 271 001
; Assignment Number: 5                Due Date: 2/27/2022
; Description: This program asks the user for an ammount of random numbers they'd like to generate
; from 15 to 200, and the values can be within 100 and 999. It'll then print out the list of random numbers by however much the user specified.
; The program will then print the median of the sorted list, and then print the sorted list after.

INCLUDE Irvine32.inc

min EQU 15
max EQU 200
lo EQU 100
hi EQU 999

.data

introduction	BYTE	"Hello Julian?", 13, 10, "Sorting Random Integers, ", 13, 10, "Programmed by Ben Reed", 13, 10, "This program generates random numbers in the range [100 .. 999], ", 13, 10, "displays the original list, sorts the list, and calculates the median value. Finally, it displays the list sorted in decending order. ", 13, 10, 0
prompt			BYTE	"How many numbers should bextr generated? [15 .. 200]: ", 0
invalid			BYTE	"Invalid input", 13, 10, 0
sorted			BYTE	"The sorted list: ", 0
unsorted		BYTE	"The unsorted random numbers: ", 0
median			BYTE	"The median is ", 0
tabbed			BYTE	"      ", 0
request			DWORD	?
list			DWORD	max		DUP(?)

.code
; introduction
; desc: Takes the introduction BYTE string and moves it to the edx register and calls WriteString
; receives: -----
; returns: -----
; preconditions: -----
; registers changed: edx
intro PROC
	MOV		edx, OFFSET introduction
	CALL	WriteString
	RET
intro ENDP

; getdata
; desc: Asks the user for a number between 15 and 200, If it's not within the 
; receives: request passed by reference, on the stack
; returns: -----
; preconditions: request
; registers changed: edx, eax
getdata PROC
	PUSH	ebp
	MOV		ebp, esp
	L1:
		MOV		edx, OFFSET prompt
		CALL	WriteString
		CALL	ReadDec
		CMP		eax, min
		JL		ERROR
		CMP		eax, max
		JG		ERROR
		JMP		DONE
	ERROR:
		MOV		edx, OFFSET invalid
		CALL	WriteString
		JMP		L1
	DONE:
	MOV		[ebp+8], eax
	POP		ebp
	RET
getdata ENDP

; fillarray
; desc: This functio ngenerates a random number for each element of the array to a certain amount that's been decided by the user
; returns: -----
; preconditions: request, &list
; registers changed: ebp, esp, edi, ecx, eax
fillarray PROC
	CALL	Randomize
	PUSH	ebp
	MOV		ebp, esp
	MOV		edi, [ebp+12]
	MOV		ecx, [ebp+8]
	NEXT:
		MOV		eax, hi
		SUB		eax, lo
		INC		eax
		CALL	RandomRange
		ADD		eax, lo
		MOV		[edi], eax
		ADD		edi, 4
		LOOP	NEXT
	
	POP		ebp
	RET		8

fillarray ENDP

; displaymedian
; desc: Displays the median of the sorted list. The function iterates along the list until the middle.
; the process for finding the middle of a even number of elements differs slightly from the odd implementation
; however it's basically the same. As it iterates along finding elemnet at the number of elements divided by 2 and the 
; element before that one, adding them up and then dividing them, and rounding up.
; returns: -----
; preconditions: request, list
; registers changed: ebp, esp, esi, ebx, edx, eax, ecx
displaymedian PROC
	PUSH	ebp
	MOV		ebp, esp
	MOV		esi, [ebp+12]
	MOV		eax, [ebp+8]
	CDQ
	MOV		ebx, 2
	DIV		ebx
	CMP		edx, 0
	JE		EVEN_JUMP
	JMP		ODD_JUMP
	EVEN_JUMP:
		DEC		eax
		MOV		ecx, [esi + eax * 4]
		ADD		esi, 4
		MOV		ebx, [esi + eax * 4]
		ADD		ecx, ebx
		MOV		eax, ecx
		CDQ
		MOV		ebx, 2
		INC		eax
		DIV		ebx
		MOV		ebx, eax
		JMP		DONE
	ODD_JUMP:
		MOV		ebx, [esi + eax * 4]
		JMP		DONE

	DONE:
		MOV		edx, OFFSET median
		CALL	WriteString
		MOV		eax, ebx
		CALL	WriteDec
		CALL	Crlf
	POP		ebp
	RET		8
displaymedian ENDP

; display
; desc: Displays the list by returning it to the screen seperated by 6 spaces
; also finds when the 10th element has been printed out and returns a newline
; so the 11th element is on a newline.
; returns: -----
; preconditions: request, list
; registers changed: ebp, esp, esi, eax, ecx, ebx, edx
display	PROC
	PUSH	ebp
	MOV		ebp, esp
	MOV		esi, [ebp+12]
	MOV		ecx, [ebp+8]
	MOV		eax, 0
	NEXT:
		PUSH	eax
		CDQ
		MOV		ebx, 10
		DIV		ebx
		CMP		edx, 0
		JE		ENTERLINE
		JMP		SKIP
		ENTERLINE:
			CALL Crlf
		SKIP:
		MOV		eax, [esi]
		CALL	WriteDec
		MOV		edx, OFFSET tabbed
		CALL	WriteString
		ADD		esi, 4
		POP		eax
		INC		eax
		LOOP	NEXT
	CALL	Crlf
	POP		ebp
	RET		8
display ENDP

; exchange
; desc: swaps the values that are pushed to the stack (array[k], array[i]), takes the references
; of array[k] and array[i] putting them in the ecx and ebx, then it swaps them with the eax edx, which
; are holding references to the pointers that were pushed to the stack, the registers edx and eax are then
; moved to the references of ecx and edx, which holds the references to the orginal pointers pushed to the stack
; in the main.
; returns: -----
; preconditions: &array[k], &array[i]
; registers changed: edx, eax, ebx, ecx, esp, ebp
exchange PROC
	PUSH	ebp
	MOV		ebp, esp
	MOV		ecx, [ebp+8]
	MOV		ebx, [ebp+12]
	MOV		eax, [ecx]
	MOV		edx, [ebx]
	MOV		[ecx], edx
	MOV		[ebx], eax
	POP		ebp
	RET		8
exchange ENDP

; exchange
; desc: Sorts the list in decending order by comparing the array positions at two different points
; to find the greaetest out of all the values within the list. It then calls the swap function to 
; in the main.
; returns: -----
; preconditions: request, &list
; registers changed: ebp, esi, esp, ecx, edx, eax, ebx

; Note to help grader understand code: 
; ecx = handle looping
; edx = handle incrementing for k
; ebx = handle incrementing for j
; eax = handle i, push and pop when needed, eax reg will be needed

selectsort PROC
	PUSH	ebp
	MOV		ebp, esp
	MOV		esi, [ebp+12]
	MOV		ecx, [ebp+8]
	PUSH	ecx
	DEC		ecx

	MOV		edx, 0

	OUTER:
		MOV		ebx, 0
		PUSH	esi

		MOV		eax, edx
		PUSH	ecx

		PUSH	eax
		INC		edx
		MOV		ebx, edx
		DEC		edx
		MOV		ecx, [ebp+8]

		SUB		ecx, ebx

		POP		eax
		
		INNER:
			PUSH	edx
			MOV		edx, [esi + (ebx * 4)]
			CMP 	edx, [esi + (eax * 4)]
			JG		SET_EQUAL
			JMP		EXIT_INNER
			SET_EQUAL:
				MOV		eax, ebx
			EXIT_INNER:
			INC		ebx
			POP		edx
			LOOP	INNER
		POP		ecx

		POP		esi

		PUSH	edx
		PUSH	eax
		PUSH	ecx
		PUSH	ebx

		LEA		eax, [esi + (eax * 4)]
		PUSH	eax
		LEA		eax, [esi + (edx * 4)]
		PUSH	eax

		CALL	exchange
		
		POP		ebx
		POP		ecx
		POP		eax
		POP		edx

		INC		edx
		LOOP OUTER

	POP		ecx
	POP		ebp
	RET	8
selectsort ENDP

; main
; desc: Consists of calls to the functions of the program, shows the subproceses of the program
; returns: -----
; preconditions: -----
; registers changed: edx
main PROC
	CALL	intro
	PUSH	request
	CALL	getdata
	POP		request

	
	PUSH	OFFSET list
	PUSH	request
	CALL	fillarray

	MOV		edx, OFFSET unsorted
	CALL	WriteString

	PUSH	OFFSET list
	PUSH	request
	CALL	display

	PUSH	OFFSET list
	PUSH	request
	CALL	selectsort

	PUSH	OFFSET list
	PUSH	request
	CALL	displaymedian

	MOV		edx, OFFSET sorted
	CALL	WriteString
	PUSH	OFFSET list
	PUSH	request
	CALL	display
	
	exit
main ENDP

END main