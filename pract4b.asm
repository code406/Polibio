;**************************************************************************
; SBM 2019. PRACTICA 4 - ANA ROA, DAVID PALOMO. PAREJA 10.
;**************************************************************************

; DEFINICION DEL SEGMENTO DE DATOS
DATOS SEGMENT
	INPUT_LETR  DB  "SBM2019", "$"
	INPUT_NUM   DB  "54","25","44","12","66","11","23","$"
	OUT_STR     DB  128 DUP(0)
	ENC_MSG     DB  10, 13, "  - CODIFICANDO <", "$"
	DOS_PUNTOS  DB  ">: ", "$"
	DEC_MSG     DB  10, 13, "  - DECODIFICANDO <", "$"
	MATRIZ      DB  1BH,"[2","J", 10, 13
	            DB  "  - MATRIZ DE POLIBIO:", 10, 10, 13
	            DB  "      | 1  2  3  4  5  6", 10, 13
	            DB  "    --+-----------------", 10, 13
	            DB  "    1 | 1  2  3  4  5  6", 10, 13
	            DB  "    2 | 7  8  9  A  B  C", 10, 13
	            DB  "    3 | D  E  F  G  H  I", 10, 13
	            DB  "    4 | J  K  L  M  N  O", 10, 13
	            DB  "    5 | P  Q  R  S  T  U", 10, 13
	            DB  "    6 | V  W  X  Y  Z  0", 10, 13, "$"
DATOS ENDS

; DEFINICION DEL SEGMENTO DE PILA
PILA SEGMENT STACK "STACK"
	DB 40H DUP (0)
PILA ENDS

; DEFINICION DEL SEGMENTO DE CODIGO
CODE SEGMENT
ASSUME CS:CODE,DS:DATOS,SS:PILA

;**************************************************************************
; PROCEDIMIENTO PRINCIPAL. IMPRIME MATRIZ. LLAMA A CODIFICAR Y DECODIFICAR
;**************************************************************************
MAIN PROC
	MOV AX, DATOS
	MOV DS, AX
	MOV AX, PILA
	MOV SS, AX
	MOV SP, 64

	MOV AH, 9
	MOV DX, OFFSET MATRIZ
	INT 21H

	CALL ENCODE_B
	CALL DECODE_B

	MOV AX, 4C00H
	INT 21H
MAIN ENDP

;**************************************************************************
; IMPRIME LA CADENA INICIAL, LA CODIFICA (INT 57H) E IMPRIME LA SALIDA
;**************************************************************************
ENCODE_B PROC NEAR
	MOV DX, OFFSET ENC_MSG
	INT 21H
	MOV DX, OFFSET INPUT_LETR
	INT 21H
	MOV DX, OFFSET DOS_PUNTOS
	INT 21H

	MOV AH, 10H  ;CODIFICAR
	MOV DX, OFFSET INPUT_LETR
	MOV BX, OFFSET OUT_STR
	INT 57H

	MOV AH, 9
	MOV DX, OFFSET OUT_STR
	INT 21H
	MOV AH, 2
	MOV DL, 10
	INT 21H
	RET
ENCODE_B ENDP

;**************************************************************************
; IMPRIME LA CADENA INICIAL, LA DECODIFICA (INT 57H) E IMPRIME LA SALIDA
;**************************************************************************
DECODE_B PROC NEAR
	MOV AH, 9
	MOV DX, OFFSET DEC_MSG
	INT 21H
	MOV DX, OFFSET INPUT_NUM
	INT 21H
	MOV DX, OFFSET DOS_PUNTOS
	INT 21H

	MOV AH, 11H  ;DECODIFICAR
	MOV DX, OFFSET INPUT_NUM
	MOV BX, OFFSET OUT_STR
	INT 57H

	MOV AH, 9
	MOV DX, OFFSET OUT_STR
	INT 21H
	MOV AH, 2
	MOV DL, 10
	INT 21H
	RET
DECODE_B ENDP

CODE ENDS
END MAIN
