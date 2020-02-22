;********************************************************************************************
;	file: 	lab1.s
;	author: Albert Perlman
;	desc:	assembly subroutines
;********************************************************************************************

        INCLUDE STM32L4R5xx_constants.inc

        AREA program, CODE, READONLY
		EXPORT ASSEMBLY_INIT
		EXPORT DISPLAY_VALUE
		ALIGN
		
ASSEMBLY_INIT
	PUSH {R14}
	LDR R0, =RCC_BASE
	LDR R1, [R0, #RCC_AHB2ENR]
	ORR R1, R1, #(RCC_AHB2ENR_GPIOFEN)      ; Enables clock for GPIOF
	STR R1, [R0, #RCC_AHB2ENR]

	; MODE: 00: Input mode, 01: General purpose output mode
    ;       10: Alternate function mode, 11: Analog mode (reset state)
	LDR R0, =GPIOF_BASE                     ; Base address for GPIOF
	; CpE5151 Programers code continues here

; QUESTION #1
; _______________________________________________________________________

	; set PF12 ~ PF15 to outputs
	LDR R2, [R0, #GPIO_MODER]	; read Port F MODE register
	BIC R2, R2, #(3 << (2*12))	; clear MODE bits for PF12
	BIC R2, R2, #(3 << (2*13))	; clear MODE bits for PF13
	BIC R2, R2, #(3 << (2*14))	; clear MODE bits for PF14
	BIC R2, R2, #(3 << (2*15))	; clear MODE bits for PF15
	ORR R2, R2, #(1 << (2*12))	; set PF12 MODE bits to '01' (output)
	ORR R2, R2, #(1 << (2*13))	; set PF13 MODE bits to '01' (output)
	ORR R2, R2, #(1 << (2*14))	; set PF14 MODE bits to '01' (output)
	ORR R2, R2, #(1 << (2*15))	; set PF15 MODE bits to '01' (output)
	STR R2, [R0, #GPIO_MODER]	; write Port F MODE register
	
	; set PF12 ~ PF15 to push-pull output type
	LDR R2, [R0, #GPIO_OTYPER]	; read Port F OUTPUT TYPE register
	BIC R2, R2, #(1<<12)		; set PF12 OUTPUT TYPE bit to '0' (push-pull)
	BIC R2, R2, #(1<<13)		; set PF13 OUTPUT TYPE bit to '0' (push-pull)
	BIC R2, R2, #(1<<14)		; set PF14 OUTPUT TYPE bit to '0' (push-pull)
	BIC R2, R2, #(1<<15)		; set PF15 OUTPUT TYPE bit to '0' (push-pull)
	STR R2, [R0, #GPIO_OTYPER]	; write Port F OUTPUT TYPE register
	
	; disable pull-up / pull-down resistors for PF12 ~ PF15
	LDR R2, [R0, #GPIO_PUPDR]	; read Port F PU-PD register
	BIC R2, R2, #(3 << (2*12))	; clear PF12 PU-PD bits (disabled)
	BIC R2, R2, #(3 << (2*13))	; clear PF13 PU-PD bits (disabled)
	BIC R2, R2, #(3 << (2*14))	; clear PF14 PU-PD bits (disabled)
	BIC R2, R2, #(3 << (2*15))	; clear PF15 PU-PD bits	(disabled)
	STR R2, [R0, #GPIO_PUPDR]	; write Port F PU-PD register
	
	POP {R14}
	BX R14
; _____end QUESTION #1__________________________________________________________________


; QUESTION #2
; _______________________________________________________________________
DISPLAY_VALUE
	PUSH {R14}
	LDR R4, =GPIOF_BASE		; Base address for GPIOF
	LDR R5, [R4, #GPIO_ODR]	; read Port F OUTPUT DATA register
	
	BIC R0, R0, #0xFFFFFFF0	; clear bits 4~31 of input value
	LSL R0, R0, #12			; shift by 12 to align with ODR
	ORR R5, R0, R5			; set output bits for PF12~PF15
	
	STR R5, [R4, #GPIO_ODR]	; write Port F OUTPUT DATA register
	
	POP {R14}
	BX R14
; _____end QUESTION #2__________________________________________________________________



    ; Area defined for variables, if needed.
			AREA VARS, DATA, READWRITE
		ALIGN
			
ASM_V1	DCD 0            ; Variables for use in assembly
ASM_V2	DCD 0
	
	
	END
		
		