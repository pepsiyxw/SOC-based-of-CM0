#ifndef _SIMPLE_TIMER_H
#define _SIMPLE_TIMER_H

#include "CMSDK_CM0.h"

#define 	sptimer0	SPTIMER0	
#define 	sptimer1	SPTIMER1	
#define 	sptimer2	SPTIMER2
#define 	sptimer3	SPTIMER3

void SimpleTimer_Init(TIMERType * Timer,u32 reload,FunctionalState state);
u32 GetTimerValue(TIMERType * Timer);
void SimpleTimer_cmd(TIMERType * Timer,FunctionalState state);
void SimpleTimer_reset(TIMERType * Timer);

#endif
