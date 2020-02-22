/***********************************************************************************************
*	file:		main.c
*	author:	Albert Perlman
* desc: 	main program to call assembly subroutines
************************************************************************************************/

extern void ASSEMBLY_INIT (void);
extern void DISPLAY_VALUE (int);

int main (void)
{
	ASSEMBLY_INIT();
	DISPLAY_VALUE(15);
	while(1);
}

