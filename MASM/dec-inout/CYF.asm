DATA	SEGMENT
BUFFER	DB	6,?,6 DUP(?)
C10	DW	10
X	DW	?
P	DW	10000
DATA	ENDS

CODE	SEGMENT
	ASSUME	DS:DATA,CS:CODE
START:
	MOV	AX,DATA
	MOV 	DS,AX

	LEA	DX,BUFFER
	MOV	AH,0AH
	INT	21H
	MOV AX,0
	MOV	CL,BUFFER+1
	MOV	CH,0
	LEA	BX,BUFFER+2
    ;say "\nbx=",bx
ONE:
    
    MUL	C10
	MOV	DL,[BX]
	AND	DL,0FH
	ADD	AL,DL
	ADC	AH,0
	INC	BX
	LOOP	ONE
	MOV	X,AX
    ;say "x=",x
	MOV	CL,BUFFER+1
	MOV	DX,0
TWO:
    MOV	AX,X
    xor dx,dx
	DIV	P
	ADD	AL,30H
	MOV	DL,AL
	MOV	AH,2
	INT	21H
	LOOP	TWO
	MOV	AX,4C00H
	INT	21H
CODE	ENDS
	END	START
	