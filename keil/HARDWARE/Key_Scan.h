#ifndef __KEY_SCAN_H
#define __KEY_SCAN_H

#include "CMSDK_CM0.h"
#include "cm0_gpio.h"
#include "Systick.h"

#define Key_Col3   ((GPIOA->DATA)>>15)%2
#define Key_Col2   ((GPIOA->DATA)>>14)%2
#define Key_Col1   ((GPIOA->DATA)>>13)%2
#define Key_Col0   ((GPIOA->DATA)>>12)%2

#define Key_Row3   GPIO_Pin_11
#define Key_Row2   GPIO_Pin_10
#define Key_Row1   GPIO_Pin_9
#define Key_Row0   GPIO_Pin_8


void Key_Init(void);
u8 key_scan(void);
#endif
