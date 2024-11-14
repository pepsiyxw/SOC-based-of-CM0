#ifndef _VGA_H_
#define _VGA_H_

#include "CMSDK_CM0.h"                  // Device header

typedef enum {WRITE = 1, CLEAR = !WRITE} STATE;

#define	BLACK      0x0000	
#define	WHITE      0xFFFF
#define	GOLDEN     0xFEC0
#define	RED        0xF800
#define	ORANGE     0xFC00
#define	YELLOW     0xFFE0
#define	GREEN      0x07E0
#define	CYAN       0x07FF
#define	BLUE       0x001F
#define	PURPPLE    0xF81F
#define	GRAY       0xD69A
	
void VGA_Drow(u16 pixel_x,u16 pixel_y,u16 color,STATE state);	
		
#endif
