#ifndef __USRAT3_H
#define __USRAT3_H 
#include "cm0_uart.h"
#include "flybird.h"

//陀螺仪控制
#define roll_level		40

#define pitch_level		40

void IMU_init(void);
void Bird2_Control(void);
void UARTRX1Handler(void);
#endif

