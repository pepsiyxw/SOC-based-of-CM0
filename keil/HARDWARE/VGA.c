#include "VGA.h"

void VGA_Drow(u16 pixel_x,u16 pixel_y,u16 color,STATE state)
{
	VGA->PIXEL_LOCATION =  pixel_x + (pixel_y<<16);
	VGA->STATE = state;
	VGA->COLOR = color;
}
