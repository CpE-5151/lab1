;********************************************************************************************
;	file: 	lab1.s
;	author: Albert Perlman
;	desc:	assembly subroutines
;********************************************************************************************

        INCLUDE STM32L4R5xx_constants.inc

        AREA program, CODE, READONLY
		EXPORT COUNTER_RUN
		EXPORT ASSEMBLY_INIT
		EXPORT KEYPAD_INIT
		EXPORT DISPLAY_VALUE
		EXPORT DELAY_MS
		EXPORT PB_INIT
		EXPORT PB_READ
		EXPORT LED_INIT
		EXPORT LED_WRITE
		EXPORT KEYPAD_READ
		ALIGN
		
COUNTER_RUN
	PUSH{R14}
	BL PB_READ
	BL KEYPAD_READ
	
	POP {R14}
	BX R14

ASSEMBLY_INIT
	PUSH {R14}
	MOV R6, #1 ; initial increment value
	MOV R7, #0 ; initial count value
	MOV R8, #0 ; decrement flag
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
; Delay calculation for 1ms:
; 1  / 4*10^6 (cycles/second) = 0.25 microseconds/cycle
; 1 (millisecond) / 0.25 (microseconds/cycle) = 4000 cycles
; delay loop has 4 instructions, 
;	so we loop 1000 times per millisecond of delay
; _______________________________________________________________________
DELAY_MS
	PUSH {R14}
	MOV R3, #1000
	MUL R1, R0, R3	; number of loops (4000*ms_delay)
	MOV R2, #0 		; loop counter

LOOP CMP R1, R2		; loop until counter == number of loops
	BEQ DELAY_DONE
	ADD R2, R2, #1	; increment counter
	B LOOP
	
DELAY_DONE	
	POP {R14}
	BX R14
; _____end PROBLEM #3___________________________________________________


; PROBLEM #4
; _______________________________________________________________________
PB_INIT
	PUSH {R14}
	
	LDR R0, =RCC_BASE
	LDR R1, [R0, #RCC_AHB2ENR]
	ORR R1, R1, #(RCC_AHB2ENR_GPIOCEN)      ; Enables clock for GPIOC
	STR R1, [R0, #RCC_AHB2ENR]
	
	; set PC13 to input
	LDR R0, =GPIOC_BASE			; base address for GPIOC
	LDR R2, [R0, #GPIO_MODER]	; read Port C MODE register
	BIC R2, R2, #(3 << (2*13))	; clear PC13 MODE bits
	STR R2, [R0, #GPIO_MODER]	; write Port C MODE register
	
	; set PC13 to pull-down
	LDR R1, [R0, #GPIO_PUPDR]	; read Port C PU-PD register
	BIC R1, R1, #(3 << (2*13))	; clear PC13 PU-PD bits
	ORR R1, R1, #(2 << 13)	; set PC13 MODE bits to '10' (pull-down)
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
	MOV R0, #100
	BEQ PB_READ_DONE
	BL DELAY_MS
	
	LDR R0, =GPIOC_BASE		; Base address for GPIOC
	LDR R1, [R0, #GPIO_IDR]	; read Port C IDR
	TST R1, #(1<<13)		; check PC13 for button press
	BEQ PB_READ_DONE
	
	CMP R8, #0
	ADDEQ R7, R7, R6
	SUBNE R7, R7, R6
	CMP R7, #16
	MOVHS R7, #0		; reset count to 0 if count >= 16
	MOV R0, R7
	
	BL DISPLAY_VALUE

PB_READ_DONE
	POP {R14}
	BX R14
; _____end PROBLEM #5___________________________________________________


; PROBLEM #6
; _______________________________________________________________________
LED_INIT
	PUSH {R14}
	
	LDR R0, =RCC_BASE
	LDR R1, [R0, #RCC_AHB2ENR]
	ORR R1, R1, #(RCC_AHB2ENR_GPIOEEN) ; Enables clock for GPIOE
	STR R1, [R0, #RCC_AHB2ENR]
	
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
	BIC R2, R2, #(3 << (2*9))	; clear PE9 PU-PD bits (disabled)
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
	BIC R2, #(1<<9)			; clear pin 9 output bit
	
	LSL R0, R0, #9			; shift input value to pin 9
	ORR R2, R2, R0
	STR R2, [R1, #GPIO_ODR]	; write Port E OUTPUT DATA register
	
	POP {R14}
	BX R14
; _____end PROBLEM #7___________________________________________________


; PROBLEM #8
; _______________________________________________________________________
KEYPAD_INIT
	PUSH {R14}
	
	; Enable clock for GPIOC
	LDR R0, =RCC_BASE
	LDR R1, [R0, #RCC_AHB2ENR]
	ORR R1, R1, #(RCC_AHB2ENR_GPIOCEN)
	STR R1, [R0, #RCC_AHB2ENR]
	
	; set PC0, PC1, PC3, PC4 to input
	LDR R0, =GPIOC_BASE			; base address for GPIOC
	LDR R2, [R0, #GPIO_MODER]	; read Port C MODE register
	BIC R2, R2, #(3 << (2*0))	; clear PC0 MODE bits to '00' (input)
	BIC R2, R2, #(3 << (2*1))	; clear PC1 MODE bits to '00' (input)
	BIC R2, R2, #(3 << (2*3))	; clear PC3 MODE bits to '00' (input)
	BIC R2, R2, #(3 << (2*4))	; clear PC4 MODE bits to '00' (input)
	STR R2, [R0, #GPIO_MODER]	; write Port C MODE register
	
	; disable pull-up / pull-down resistors for PC0, PC1, PC3, PC4
	LDR R2, [R0, #GPIO_PUPDR]	; read Port F PU-PD register
	BIC R2, R2, #(3 << (2*0))	; clear PC0 PU-PD bits (disabled)
	BIC R2, R2, #(3 << (2*1))	; clear PC1 PU-PD bits (disabled)
	BIC R2, R2, #(3 << (2*3))	; clear PC3 PU-PD bits (disabled)
	BIC R2, R2, #(3 << (2*4))	; clear PC4 PU-PD bits (disabled)
	STR R2, [R0, #GPIO_PUPDR]	; write Port F PU-PD register
	
	; Enable clock for GPIOD
	LDR R0, =RCC_BASE
	LDR R1, [R0, #RCC_AHB2ENR]
	ORR R1, R1, #(RCC_AHB2ENR_GPIODEN)
	STR R1, [R0, #RCC_AHB2ENR]
	
	; set PD8, PD9, PD14, PD15 to output
	LDR R0, =GPIOD_BASE			; base address for GPIOD
	LDR R2, [R0, #GPIO_MODER]	; read Port D MODE register
	BIC R2, R2, #(3 << (2*8))	; clear PD8 MODE bits
	BIC R2, R2, #(3 << (2*9))	; clear PD9 MODE bits
	BIC R2, R2, #(3 << (2*14))	; clear PD14 MODE bits
	BIC R2, R2, #(3 << (2*15))	; clear PD15 MODE bits
	ORR R2, R2, #(1 << (2*8))	; set PD8 MODE bits to '01' (output)
	ORR R2, R2, #(1 << (2*9))	; set PD9 MODE bits to '01' (output)
	ORR R2, R2, #(1 << (2*14))	; set PD14 MODE bits to '01' (output)
	ORR R2, R2, #(1 << (2*15))	; set PD15 MODE bits to '01' (output)
	STR R2, [R0, #GPIO_MODER]	; write Port D MODE register
	
	; set PD8, PD9, PD14, PD15 to open-drain output type
	; open-drain output type gives pins high impedance at '1' state
	; this protects from dangerous shorts when 2 buttons are pressed simultaneously
	LDR R2, [R0, #GPIO_OTYPER]	; read Port D OUTPUT TYPE register
	ORR R2, R2, #(1<<8)			; set PD8 OUTPUT TYPE bit to '1' (open-drain)
	ORR R2, R2, #(1<<9)			; set PD9 OUTPUT TYPE bit to '1' (open-drain)
	ORR R2, R2, #(1<<14)		; set PD14 OUTPUT TYPE bit to '1' (open-drain)
	ORR R2, R2, #(1<<15)		; set PD15 OUTPUT TYPE bit to '1' (open-drain)
	STR R2, [R0, #GPIO_OTYPER]	; write Port D OUTPUT TYPE register
	
	POP {R14}
	BX R14
; _____end PROBLEM #8___________________________________________________

LED_FLASH
	PUSH{R14}
	MOV R0, #1
	BL LED_WRITE			; flash green LED
	MOV R0, #250
	BL DELAY_MS				; delay 250ms
	MOV R0, #0
	BL LED_WRITE			; turn off green LED
	
	POP {R14}
	BX R14

; PROBLEM #9
; _______________________________________________________________________
KEYPAD_READ
	PUSH {R14}

READ_ROW_1
	LDR R2, =GPIOD_BASE		; Base address for GPIOD
	MOV R1, #0xFFFF
	STR R1, [R2, #GPIO_ODR]	; set all bits high
	
	LDR R1, [R2, #GPIO_ODR]	; read Port D ODR
	BIC R1, R1, #(1<<8)		; set row 1 output
	STR R1, [R2, #GPIO_ODR]	; write Port D ODR - row 1
	LDR R2, =GPIOC_BASE		; Base address for GPIOC
	
READ_1
	LDR R1, [R2, #GPIO_IDR]	; read Port C IDR
	TST R1, #(1<<0)			; check PC0 for button press
	BNE READ_2
	BL LED_FLASH			; flash green LED
	MOV R7, #1				; count value
	MOV R0, #1				; display value
	BL DISPLAY_VALUE
	POP {R14}
	BX R14
	
READ_2
	LDR R1, [R2, #GPIO_IDR]	; read Port C IDR
	TST R1, #(1<<1)			; check PC1 for button press
	BNE READ_3
	BL LED_FLASH			; flash green LED
	MOV R7, #2				; count value
	MOV R0, #2				; display value
	BL DISPLAY_VALUE
	POP {R14}
	BX R14

READ_3
	LDR R1, [R2, #GPIO_IDR]	; read Port C IDR
	TST R1, #(1<<3)			; check PC3 for button press
	BNE READ_A
	BL LED_FLASH			; flash green LED
	MOV R7, #3				; count value
	MOV R0, #3				; display value
	BL DISPLAY_VALUE
	POP {R14}
	BX R14

READ_A
	LDR R1, [R2, #GPIO_IDR]	; read Port C IDR
	TST R1, #(1<<4)			; check PC4 for button press
	BNE READ_ROW_2
	BL LED_FLASH			; flash green LED
	MOV R6, #1				; set increment
	MOV R0, #0xA			; return value
	POP {R14}
	BX R14
	
READ_ROW_2
	LDR R2, =GPIOD_BASE		; Base address for GPIOD
	MOV R1, #0xFFFF
	STR R1, [R2, #GPIO_ODR]	; set all bits high
	
	LDR R1, [R2, #GPIO_ODR]	; read Port D ODR
	BIC R1, R1, #(1<<9)		; set row 2 output
	STR R1, [R2, #GPIO_ODR]	; write Port D ODR - row 2
	LDR R2, =GPIOC_BASE		; Base address for GPIOC

READ_4
	LDR R1, [R2, #GPIO_IDR]	; read Port C IDR
	TST R1, #(1<<0)			; check PC0 for button press
	BNE READ_5
	BL LED_FLASH			; flash green LED
	MOV R7, #4				; count value
	MOV R0, #4				; display value
	BL DISPLAY_VALUE
	POP {R14}
	BX R14
	
READ_5
	LDR R1, [R2, #GPIO_IDR]	; read Port C IDR
	TST R1, #(1<<1)			; check PC1 for button press
	BNE READ_6
	BL LED_FLASH			; flash green LED
	MOV R7, #5				; count value
	MOV R0, #5				; display value
	BL DISPLAY_VALUE
	POP {R14}
	BX R14

READ_6
	LDR R1, [R2, #GPIO_IDR]	; read Port C IDR
	TST R1, #(1<<3)			; check PC3 for button press
	BNE READ_B
	BL LED_FLASH			; flash green LED
	MOV R7, #6				; count value
	MOV R0, #6				; display value
	BL DISPLAY_VALUE
	POP {R14}
	BX R14
	
READ_B
	LDR R1, [R2, #GPIO_IDR]	; read Port C IDR
	TST R1, #(1<<4)			; check PC4 for button press
	BNE READ_ROW_3
	BL LED_FLASH			; flash green LED
	MOV R6, #2				; set increment
	MOV R0, #0xB			; return value
	POP {R14}
	BX R14
	
READ_ROW_3
	LDR R2, =GPIOD_BASE		; Base address for GPIOD
	MOV R1, #0xFFFF
	STR R1, [R2, #GPIO_ODR]	; set all bits high
	
	LDR R1, [R2, #GPIO_ODR]	; read Port D ODR
	BIC R1, R1, #(1<<14)	; set row 3 output
	STR R1, [R2, #GPIO_ODR]	; write Port D ODR - row 3
	LDR R2, =GPIOC_BASE		; Base address for GPIOC
	
READ_7
	LDR R1, [R2, #GPIO_IDR]	; read Port C IDR
	TST R1, #(1<<0)			; check PC0 for button press
	BNE READ_8
	BL LED_FLASH			; flash green LED
	MOV R7, #7				; count value
	MOV R0, #7				; display value
	BL DISPLAY_VALUE
	POP {R14}
	BX R14
	
READ_8
	LDR R1, [R2, #GPIO_IDR]	; read Port C IDR
	TST R1, #(1<<1)			; check PC1 for button press
	BNE READ_9
	BL LED_FLASH			; flash green LED
	MOV R7, #8				; count value
	MOV R0, #8				; display value
	BL DISPLAY_VALUE
	POP {R14}
	BX R14

READ_9
	LDR R1, [R2, #GPIO_IDR]	; read Port C IDR
	TST R1, #(1<<3)			; check PC3 for button press
	BNE READ_C
	BL LED_FLASH			; flash green LED
	MOV R7, #9				; count value
	MOV R0, #9				; display value
	BL DISPLAY_VALUE
	POP {R14}
	BX R14

READ_C
	LDR R1, [R2, #GPIO_IDR]	; read Port C IDR
	TST R1, #(1<<4)			; check PC4 for button press
	BNE READ_ROW_4
	BL LED_FLASH			; flash green LED
	MOV R6, #3				; set increment
	MOV R0, #0xC			; display value
	POP {R14}
	BX R14
	
READ_ROW_4
	LDR R2, =GPIOD_BASE		; Base address for GPIOD
	MOV R1, #0xFFFF
	STR R1, [R2, #GPIO_ODR]	; set all bits high
	
	LDR R1, [R2, #GPIO_ODR]	; read Port D ODR
	BIC R1, R1, #(1<<15)		; set row 2 output
	STR R1, [R2, #GPIO_ODR]	; write Port D ODR - row 2
	LDR R2, =GPIOC_BASE		; Base address for GPIOC

; READ '*'
	LDR R1, [R2, #GPIO_IDR]	; read Port C IDR
	TST R1, #(1<<0)			; check PC0 for button press
	BNE READ_0
	BL LED_FLASH			; flash green LED
	MOV R8, #1				; set decrement flag
	MOV R0, #0x0E			; return value
	POP {R14}
	BX R14
	
READ_0
	LDR R1, [R2, #GPIO_IDR]	; read Port C IDR
	TST R1, #(1<<1)			; check PC1 for button press
	BNE READ_HASH
	BL LED_FLASH			; flash green LED
	MOV R7, #0				; count value
	MOV R0, #0				; display value
	BL DISPLAY_VALUE
	POP {R14}
	BX R14

READ_HASH
	LDR R1, [R2, #GPIO_IDR]	; read Port C IDR
	TST R1, #(1<<3)			; check PC3 for button press
	BNE READ_D
	BL LED_FLASH			; flash green LED
	MOV R8, #0				; clear decrement flag
	MOV R0, #0x0F			; return value
	POP {R14}
	BX R14
	
READ_D
	LDR R1, [R2, #GPIO_IDR]	; read Port C IDR
	TST R1, #(1<<4)			; check PC4 for button press
	BNE KEYPAD_READ_DONE
	BL LED_FLASH			; flash green LED
	MOV R6, #4				; set increment
	MOV R0, #0xD			; return value
	POP {R14}
	BX R14
	
KEYPAD_READ_DONE
	POP {R14}
	BX R14
; _____end PROBLEM #9___________________________________________________

    ; Area defined for variables, if needed.
			AREA VARS, DATA, READWRITE
		ALIGN
			
DISPLAY_VAL	DCB 0  ; display value
	
	END
		