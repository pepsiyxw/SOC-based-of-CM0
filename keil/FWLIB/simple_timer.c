#include "simple_timer.h"

void SimpleTimer_Init(TIMERType * Timer,u32 reload,FunctionalState state)
{
	Timer->LOAD = reload;
	Timer->ENABLE = (u32)state;
}

u32 GetTimerValue(TIMERType * Timer)
{
	return Timer->VALUE;
}

void SimpleTimer_cmd(TIMERType * Timer,FunctionalState state)
{
  switch(state){
		case ENABLE:{
			Timer->ENABLE = 1;
			break;
		}
		case DISABLE:{
			Timer->ENABLE = 0;
			break;
		}
	}
}

void SimpleTimer_reset(TIMERType * Timer)
{
	Timer->VALUE = 0;
}

