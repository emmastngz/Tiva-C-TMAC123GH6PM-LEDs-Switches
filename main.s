SYSCTL_RCGCGPIO_R	EQU		0x400FE608
GPIO_PORTF_DATA_R	EQU		0x400253FC
GPIO_PORTF_DIR_R	EQU		0x40025400
GPIO_PORTF_DEN_R	EQU		0x4002551C
GPIO_PORTF_PUR_R 	EQU		0x40025510
GPIO_PORTF_LOCK_R	EQU		0x40025520
GPIO_PORTF_CR_R		EQU		0x40025524
GPIO_LOCK_KEY		EQU		0X4C4F434B


RED					EQU		0x02 ; Ob 0000 0010
; Switch = PF4		
; Switch = PF0
SEC_DIV_FIVE		EQU		1066666 ; 1 second divided by 5


				AREA |.text|,CODE,READONLY,ALIGN=2
				THUMB
				EXPORT Main
					
Main
	BL	GPIO_init

loop 
	LDR 	R0,=SEC_DIV_FIVE
	BL 		delay
	BL 		Input
	CMP 	R0,#0x01
	BEQ 	Switch_On
	BL 		Output
	B 		loop
	
Switch_On
	MOV R0,#RED
	BL 	Output
	B loop
	
Output
	LDR R1,=GPIO_PORTF_DATA_R
	STR R0,[R1]
	BX LR
	
Input
	LDR R1,=GPIO_PORTF_DATA_R
	LDR R0,[R1]
	AND R0,R0,#0X11 ; 0b 0001 0001, 0x01, 0x10
	BX 	LR

	
delay
	SUBS 	R0,R0,#1
	BNE 	delay
	BX 		LR


GPIO_init
	LDR R1,=SYSCTL_RCGCGPIO_R
	LDR R0,[R1]
	ORR R0,R0,#0x20
	STR R0,[R1] ; R0 source, R1 destination
	
	LDR R1,=GPIO_PORTF_LOCK_R
	LDR R0,=GPIO_LOCK_KEY
	STR R0,[R1]
	
	LDR R1,=GPIO_PORTF_CR_R
	MOV R0,#0XFF ; 0b 1111 1111
	STR R0,[R1]
	
	LDR R1,=GPIO_PORTF_DIR_R
	MOV R0, #0x02 ; 0b 0000 0010
	STR R0,[R1]
	
	LDR R1,=GPIO_PORTF_PUR_R
	MOV R0,#0x10 ; 0b 0001 0000
	STR R0,[R1]
	
	LDR R1,=GPIO_PORTF_DEN_R
	MOV R0,#0X13 ; 0b 0001 0011
	STR R0,[R1]
	
	BX LR
	
	ALIGN
	END
	
	