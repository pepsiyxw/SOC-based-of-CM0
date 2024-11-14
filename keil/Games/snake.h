#ifndef _SNAKE_H
#define _SNAKE_H

#include "CMSDK_CM0.h"

struct snake  //�ṹ�壬���ڴ��������λ�ã�
{
 unsigned char x;
 unsigned char y;
};

void SnakeGame_Init(void);
void Game_Process(void);
void delay(u32 i);
void Game_Restart(void);
void Snake_Over(void);
void Food_Init(void);
void Snake_Init(void);
void leftkey(void);
void rightkey(void);
void upkey(void);
void downkey(void);
void keypros(void);
void modeleft(void);
void moderight(void);
void modeup(void);
void modedown(void);
void choice(void); 
void modepros(void);
void page0(void);


#endif
