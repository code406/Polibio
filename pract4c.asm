;**************************************************************************
; SBM 2019. PRACTICA 4 - ANA ROA, DAVID PALOMO. PAREJA 10.
;**************************************************************************

; DEFINICION DEL SEGMENTO DE DATOS
DATOS SEGMENT
	INPUT_STR 	DB	128 DUP(0)
	OUT_STR		DB	128 DUP(0)
	ENC_MSG		DB	10, 13, 10, 13, "  - CODIFICANDO <", "$"
	DOS_PUNTOS	DB	">: ", "$"
	DEC_MSG		DB  10, 13, 10, 13, "  - DECODIFICANDO <", "$"
	MATRIZ		DB	1BH,"[2","J", 10, 13
				DB	"  - MATRIZ DE POLIBIO:", 10, 10, 13
				DB	"      | 1  2  3  4  5  6", 10, 13
				DB	"    --+-----------------", 10, 13
				DB	"    1 | 1  2  3  4  5  6", 10, 13
				DB	"    2 | 7  8  9  A  B  C", 10, 13
				DB	"    3 | D  E  F  G  H  I", 10, 13
				DB	"    4 | J  K  L  M  N  O", 10, 13
				DB	"    5 | P  Q  R  S  T  U", 10, 13
				DB	"    6 | V  W  X  Y  Z  0", 10, 13, "$"
	PEDIR_OP	DB 	10, 13,"  - INTRODUCE OPCION (cod, decod o quit): ","$"
	PEDIR_INPUT	DB	10, 13, 10, 13, "  - INTRODUCE LA CADENA: ", "$"
	OPCION		DB 	6 DUP(0)
	OP_COD 		DB	"cod", "$"
	OP_DECOD	DB	"decod", "$"
DATOS ENDS

; DEFINICION DEL SEGMENTO DE PILA
PILA SEGMENT STACK "STACK"
	DB 40H DUP (0)
PILA ENDS

; DEFINICION DEL SEGMENTO DE CODIGO
CODE SEGMENT
ASSUME CS:CODE,DS:DATOS,SS:PILA

;**************************************************************************
; PROCEDIMIENTO PRINCIPAL. IMPRIME MATRIZ. CODIFICA O DECODIFICA (SEGUN LO
; ELIJA EL USUARIO) UNA CADENA INTRODUCIDA POR EL USUARIO
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
	CALL GET_OPCION         ;OBTIENE OPCION DE USUARIO

	MOV SI, OFFSET OP_COD
	CALL COMPARE_TO_OPCION  ;COMPARA OPCION CON OP_COD
	TEST AH, AH
	JNZ CHECK_DECOD
	CALL GET_INPUT          ;SI SON IGUALES, PIDE CADENA
	CALL ENCODE_C           ;Y LLAMA A ENCODE
	JMP FIN_MAIN

CHECK_DECOD:
	MOV SI, OFFSET OP_DECOD
	CALL COMPARE_TO_OPCION  ;COMPARA OPCION CON OP_DECOD
	TEST AH, AH
	JNZ FIN_MAIN
	CALL GET_INPUT          ;SI SON IGUALES, PIDE CADENA
	CALL DECODE_C           ;Y LLAMA A DECODE

FIN_MAIN:
	MOV AH, 2
	MOV DL, 10
	INT 21H
	MOV AX, 4C00H
	INT 21H
MAIN ENDP

;**************************************************************************
; PIDE UNA CADENA A USUARIO Y LA ALMACENA EN OPCION CON UN "$"
;**************************************************************************
GET_OPCION PROC NEAR
	MOV AH, 9
	MOV DX, OFFSET PEDIR_OP
	INT 21H

	MOV AH, 0AH
	MOV DX, OFFSET OPCION
	MOV OPCION[0], 6
	INT 21H
	XOR BX, BX
	MOV BL, OPCION[1]
	MOV OPCION[BX+2], "$"
	RET
GET_OPCION ENDP

;**************************************************************************
; COMPARA LA CADENA DE OFFSET "SI" CON OPCION. SI SON IGUALES, AH=0.
;**************************************************************************
COMPARE_TO_OPCION PROC NEAR
	XOR BX, BX
	BUCLE_CMP:
		MOV AL, [SI][BX]
		CMP AL, OPCION[BX+2]
		JNE FIN_CMP
		INC BL
		CMP AL, "$"
		JNE BUCLE_CMP
	XOR AH, AH
FIN_CMP: RET
COMPARE_TO_OPCION ENDP

;**************************************************************************
; IMPRIME CADENA_ENTRADA. LA CODIFICA (INT 57H). IMPRIME LA CADENA_SALIDA
; CON UN RETRASO DE UN SEGUNDO ENTRE CADA CARACTER (HABILITANDO INT 1CH)
;**************************************************************************
ENCODE_C PROC NEAR
	MOV AH, 9
	MOV DX, OFFSET ENC_MSG
	INT 21H
	MOV DX, OFFSET INPUT_STR[2]
	INT 21H
	MOV DX, OFFSET DOS_PUNTOS
	INT 21H

	MOV AH, 10H       ;DECODIFICAR
	MOV DX, OFFSET INPUT_STR[2]
	MOV BX, OFFSET OUT_STR
	INT 57H

	MOV CL, 2         ;NUM CARACTERES/SEGUNDO
	XOR SI, SI        ;CONTADOR = 0
	MOV DH, "."       ;SEPARADOR
	XOR BL, BL
	in al, 21H
	AND al, 11111110B ;HABILITA TIMER (IMPRIMIR)
	out 21H ,al
	WAIT_COD:
		TEST BL, BL   ;MIENTRAS BL = 0
		JZ WAIT_COD   ;DEJAR QUE IMPRIMAN
	RET
ENCODE_C ENDP

;**************************************************************************
; IMPRIME CADENA_ENTRADA. LA DECODIFICA (INT 57H). IMPRIME LA CADENA_SALIDA
; CON UN RETRASO DE UN SEGUNDO ENTRE CADA CARACTER (HABILITANDO INT 1CH)
;**************************************************************************
DECODE_C PROC NEAR
	MOV AH, 9
	MOV DX, OFFSET DEC_MSG
	INT 21H
	MOV DX, OFFSET INPUT_STR[2]
	INT 21H
	MOV DX, OFFSET DOS_PUNTOS
	INT 21H

	MOV AH, 11H       ;DECODIFICAR
	MOV DX, OFFSET INPUT_STR[2]
	MOV BX, OFFSET OUT_STR
	INT 57H

	MOV CL, 1         ;NUM CARACTERES/SEGUNDO
	XOR SI, SI        ;CONTADOR = 0
	XOR DH, DH        ;SEPARADOR
	XOR BL, BL
	in al, 21H
	AND al, 11111110B ;HABILITA TIMER (IMPRIMIR)
	out 21H ,al
	WAIT_DECOD:
		TEST BL, BL   ;MIENTRAS BL = 0
		JZ WAIT_DECOD ;DEJAR QUE IMPRIMAN
	RET
DECODE_C ENDP

;**************************************************************************
; PIDE UNA CADENA A USUARIO Y LA ALMACENA EN INPUT_STR CON UN "$"
;**************************************************************************
GET_INPUT PROC NEAR
	MOV AH, 9
	MOV DX, OFFSET PEDIR_INPUT
	INT 21H

	MOV AH, 0AH
	MOV DX, OFFSET INPUT_STR
	MOV INPUT_STR[0], 128
	INT 21H
	XOR BX, BX
	MOV BL, INPUT_STR[1]
	MOV INPUT_STR[BX+2], "$"
	RET
GET_INPUT ENDP

CODE ENDS
END MAIN
