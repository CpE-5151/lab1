/***********************************************************************************************
*	file:		main.c
*	author:	Albert Perlman
* desc: 	main program to call assembly subroutines
************************************************************************************************/

extern void ASSEMBLY_INIT (void);
extern void PB_INIT(void);
extern void LED_INIT(void);
extern void DISPLAY_VALUE (int);
extern void DELAY_MS (int);
extern void PB_READ(void);
extern void LED_WRITE(int);

int main (void)
{
	ASSEMBLY_INIT();
	PB_INIT();
	LED_INIT();
	DISPLAY_VALUE(10);
	LED_WRITE(1);
	//PB_READ();
	while(1);
}

