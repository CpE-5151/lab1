/***********************************************************************************************
*	file:		main.c
*	author:	Albert Perlman
* desc: 	main program to call assembly subroutines
************************************************************************************************/

#include <stdint.h>

extern void ASSEMBLY_INIT (void);
extern void PB_INIT(void);
extern void LED_INIT(void);
extern void KEYPAD_INIT(void);
extern void DISPLAY_VALUE (uint8_t);
extern void DELAY_MS (int);
extern void PB_READ(void);
extern void LED_WRITE(uint8_t);
extern uint8_t KEYPAD_READ(void);

int main (void)
{
	ASSEMBLY_INIT();
	PB_INIT();
	LED_INIT();
	KEYPAD_INIT();
	while(1){
	KEYPAD_READ();
	}
	/*while(1){
	//PB_READ();
	DISPLAY_VALUE(10);
	LED_WRITE(0);
	DELAY_MS(1000);
	DISPLAY_VALUE(0);
	LED_WRITE(1);
	DELAY_MS(1000);
	}
	*/
	while(1);
}
