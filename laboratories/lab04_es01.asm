; Computer Architectures
; Lab 04 - Exercise 01
#start=8259.exe#
PORTA	EQU	80H
PORTB	EQU	PORTA+1
PORTC	EQU	PORTA+2
CONTROL	EQU	PORTA+3
PIC		EQU	40H

MAX		EQU	40	; 40 Chars maximum

.MODEL small
.STACK
.DATA
	COUNT	DB	?
	MYWORD	DB	MAX	DUP (?)	
.CODE
.STARTUP
	CLI
	MOV COUNT, 0
	CALL INIT_8255
	CALL INIT_8259
	CALL INIT_IVT
	STI	
CYCLE:
	JMP CYCLE

.EXIT

INIT_8255	PROC
	PUSH AX
	PUSH DX
	MOV DX, CONTROL
	MOV AL, 10110000B	;	Group A Mode 1 Input
	OUT DX, AL
	MOV AL, 00001001B	;	Interrupt for group A
	OUT DX, AL
	POP DX
	POP AX
	RET
INIT_8255	ENDP

INIT_8259	PROC
	PUSH AX
	PUSH DX
	; ICW 1
	MOV DX, PIC
	MOV AL, 00010011B
	OUT DX, AL
	; ICW 2
	MOV DX, PIC+1
	MOV AL, 00100000B	;	ISR Address
	OUT DX, AL
	; ICW 4
	MOV AL, 00000011B
	OUT DX, AL
	; OCW 1
	MOV AL, 01111111B	;	CH7 Enabled (Port A)
	OUT DX, AL
	POP DX
	POP AX
	RET	
INIT_8259	ENDP

INIT_IVT	PROC
	PUSH AX
	PUSH BX
	PUSH DX
	PUSH DS
	
	XOR AX, AX
	MOV DS, AX
	MOV BX, 00100111B
	SHL BX, 1
	SHL BX, 1
	MOV AX, OFFSET ISR_PA_IN
	MOV DS:[BX], AX
	MOV AX, SEG ISR_PA_IN
	MOV DS:[BX+2], AX
	
	POP DS
	POP DX
	POP BX
	POP AX
	RET
INIT_IVT	ENDP

ISR_PA_IN	PROC
	PUSH AX
	PUSH BX
	PUSH DX
	CMP COUNT, 40
	JAE	END_ISR  		;	Check the lenght
	MOV AL, COUNT
	CBW
	LEA BX, MYWORD
	ADD BX, AX			;	BX contains the offset of the cell to write
	MOV DX, PORTA
	IN AL, DX
	CMP AL, 'A'
	JB END_ISR
	CMP AL, 'z'
	JA END_ISR
	CMP AL, 'Z'
	JBE MANAGE_CHAR
	CMP AL, 'a'
	JB END_ISR			; Not an alphabetic character
MANAGE_CHAR:
	MOV [BX], AL		
	INC COUNT
END_ISR:
	POP DX
	POP BX
	POP AX
	IRET
ISR_PA_IN	ENDP		