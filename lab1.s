;********************************************************************************************
;	file: 	lab1.s
;	author: Albert Perlman
;	desc:	assembly subroutines
;********************************************************************************************

        INCLUDE STM32L4R5xx_constants.inc

        AREA program, CODE, READONLY
		EXPORT ASSEMBLY_INIT
		EXPORT DISPLAY_VALUE
		EXPORT DELAY_MS
		EXPORT PB_INIT
		EXPORT PB_READ
		EXPORT LED_INIT
		EXPORT LED_WRITE
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

; PROBLEM #1
; _______________________________________________________________________

	; set PF12 ~ PF15 to outputs
	LDR R2, [R0, #GPIO_MODER]	; read Port F MODE register
	BIC R2, R2, #(3 << (2*12))	; clear PF12 MODE bits
	BIC R2, R2, #(3 << (2*13))	; clear PF13 MODE bits
	BIC R2, R2, #(3 << (2*14))	; clear PF14 MODE bits
	BIC R2, R2, #(3 << (2*15))	; clear PF15 MODE bits
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
; _____end PROBLEM #1___________________________________________________


; PROBLEM #2
; _______________________________________________________________________
DISPLAY_VALUE
	PUSH {R14}
	LDR R4, =GPIOF_BASE		; Base address for GPIOF
	LDR R5, [R4, #GPIO_ODR]	; read Port F OUTPUT DATA register
	
	BIC R0, R0, #0xFFFFFFF0	; clear bits 4~31 of input value
	LSL R0, R0, #12			; shift by 12 to align with ODR
	
	BIC R5, R5, #0x0FFFFFFF ; clear bits 12~15 of ODR
	ORR R5, R0, R5			; set output bits for PF12~PF15
	
	STR R5, [R4, #GPIO_ODR]	; write Port F OUTPUT DATA register
	
	POP {R14}
	BX R14
; _____end PROBLEM #2___________________________________________________


; PROBLEM #3
; _______________________________________________________________________
DELAY_MS
	PUSH {R14}
	MOV R3, #4000
	MUL R1, R0, R3	; number of loops (4000*ms_delay)
	MOV R2, #0 		; loop counter

LOOP CMP R1, R2		; loop until counter == number of loops
	BEQ DELAY_DONE
	ADD R2, R2, #1	; increment counter
	
DELAY_DONE	
	POP {R14}
	BX R14
; _____end PROBLEM #3___________________________________________________


; PROBLEM #4
; _______________________________________________________________________
PB_INIT
	PUSH {R14}
	LDR R0, =GPIOC_BASE			; Base address for GPIOC
	
	; set PC13 to input
	LDR R1, [R0, #GPIO_MODER]	; read Port C MODE register
	BIC R1, R1, #(3 << (2*13))	; set PC13 MODE bits to '00' (input)
	STR R1, [R0, #GPIO_MODER]	; write Port C MODE register
	
	; set PC13 to pull-down
	LDR R1, [R0, #GPIO_PUPDR]	; read Port C PU-PD register
	BIC R1, R1, #(3 << (2*13))	; clear PC13 PU-PD bits
	ORR R1, R1, #(2 << (2*13))	; set PC13 MODE bits to '10' (pull-down)
	STR R1, [R0, #GPIO_PUPDR]	; write Port C PU-PD register
	
	POP {R14}
	BX R14
; _____end PROBLEM #4___________________________________________________


; PROBLEM #5
; _______________________________________________________________________
PB_READ
	PUSH {R14}

PB_READ_LOOP
	LDR R0, =GPIOC_BASE		; Base address for GPIOC
	LDR R1, [R0, #GPIO_IDR]	; read Port C IDR
	TST R1, #(1<<13)		; check PC13 for button press
	MOV R0, #50
	;BNE PB_READ_LOOP
	BNE DELAY_MS
	
	LDR R0, =GPIOC_BASE		; Base address for GPIOC
	LDR R1, [R0, #GPIO_IDR]	; read Port C IDR
	TST R1, #(1<<13)		; check PC13 for button press
	;BNE PB_READ_LOOP
	
	ADD R3, R3, #1
	MOV R0, R3
	B DISPLAY_VALUE
	B PB_READ_LOOP
	
	POP {R14}
	BX R14
; _____end PROBLEM #5___________________________________________________


; PROBLEM #6
; _______________________________________________________________________
LED_INIT
	PUSH {R14}
	
	; set PE9 to output
	LDR R0, =GPIOE_BASE			; base address for GPIOE
	LDR R2, [R0, #GPIO_MODER]	; read Port E MODE register
	BIC R2, R2, #(3 << (2*9))	; clear PE9 MODE bits
	ORR R2, R2, #(1 << (2*9))	; set PE9 MODE bits to '01' (output)
	STR R2, [R0, #GPIO_MODER]	; write Port E MODE register
	
	; set PE9 to push-pull output type
	LDR R2, [R0, #GPIO_OTYPER]	; read Port E OUTPUT TYPE register
	BIC R2, R2, #(1<<9)			; set PE9 OUTPUT TYPE bit to '0' (push-pull)
	STR R2, [R0, #GPIO_OTYPER]	; write Port E OUTPUT TYPE register
	
	; disable pull-up/pull-down resistors
	LDR R2, [R0, #GPIO_PUPDR]	; read Port E PU-PD register
	BIC R2, R2, #(3 << (2*12))	; clear PE9 PU-PD bits (disabled)
	STR R2, [R0, #GPIO_PUPDR]	; write Port E PU-PD register
	
	POP {R14}
	BX R14
; _____end PROBLEM #6___________________________________________________


; PROBLEM #7
; _______________________________________________________________________
LED_WRITE
	PUSH {R14}
	
	LDR R1, =GPIOE_BASE		; base address for GPIOE
	LDR R2, [R1, #GPIO_ODR]	; read Port E OUTPUT DATA register
	LSL R0, R0, #9			; shift value to pin 9
	ORR R2, R2, R0
	STR R2, [R1, #GPIO_ODR]	; write Port E OUTPUT DATA register
	
	POP {R14}
	BX R14
; _____end PROBLEM #7___________________________________________________


    ; Area defined for variables, if needed.
			AREA VARS, DATA, READWRITE
		ALIGN
			
DISPLAY_VAL	DCB 0  ; display value
	
	
	END
		
		