#ifndef _CM0_TIMER_H
#define _CM0_TIMER_H
//Timer重装值不能太小
#include "CMSDK_CM0.h"

#define Timer0		CMSDK_TIMER0
#define Timer1		CMSDK_TIMER1

void Timer_EnableIRQ(CMSDK_TIMER_TypeDef *CMSDK_TIMER);
void Timer_DisableIRQ(CMSDK_TIMER_TypeDef *CMSDK_TIMER);
void Timer_StartTimer(CMSDK_TIMER_TypeDef *CMSDK_TIMER,uint32_t irq_en);
void Timer_StopTimer(CMSDK_TIMER_TypeDef *CMSDK_TIMER);

uint32_t Timer_GetValue(CMSDK_TIMER_TypeDef *CMSDK_TIMER);
void Timer_SetValue(CMSDK_TIMER_TypeDef *CMSDK_TIMER, uint32_t value);
uint32_t Timer_GetReload(CMSDK_TIMER_TypeDef *CMSDK_TIMER);
void Timer_SetReload(CMSDK_TIMER_TypeDef *CMSDK_TIMER, uint32_t value);
void Timer_ClearIRQ(CMSDK_TIMER_TypeDef *CMSDK_TIMER);
uint32_t  Timer_StatusIRQ(CMSDK_TIMER_TypeDef *CMSDK_TIMER);
void Timer_Init_IntClock(CMSDK_TIMER_TypeDef *CMSDK_TIMER, uint32_t reload,uint32_t irq_en);
void Timer_Init_ExtClock(CMSDK_TIMER_TypeDef *CMSDK_TIMER, uint32_t reload,uint32_t irq_en);
void Timer_Init_ExtEnable(CMSDK_TIMER_TypeDef *CMSDK_TIMER, uint32_t reload,uint32_t irq_en);

#endif
