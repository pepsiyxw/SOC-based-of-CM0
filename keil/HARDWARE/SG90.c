#include "SG90.h"

u32 CRR_MAX = 93000;
u32 CRR_MIN = 71700;

u8	custom2_servo_done;

u32 crr_value = 93000;

void SG90_Init()
{
	SG90->ENABLE = 1;
	SG90->CRR = 0;
}

void SetSG90(u32 Compare)
{
	if(Compare > CRR_MAX)
		Compare = CRR_MAX;
	if(Compare < CRR_MIN)
		Compare = CRR_MIN;
	SG90->CRR = Compare;
}

void Custom2_Map_Control()
{
	if(GetGameState() == custom2_scene)
	{
		if(custom2_servo_done == 0)
		{
			crr_value = 84400;
			SetSG90(crr_value);
			custom2_servo_done = 1;
		}
	}

	if(GetGameState() == custom2_scene || GetGameState() == pause_scene || GetGameState() == method_scene)
	{
		if(FlyBird->SG90_EN == 1)
		{
			if(crr_value > 71700)
			{
				crr_value -= 500;
				SetSG90(crr_value);
			}
			else
			{
				SetSG90(crr_value);
			}
	
		}
		else
		{
			SetSG90(crr_value);
		}
	}
	else
	{
		custom2_servo_done = 0;
		if(crr_value < 93000)
		crr_value += 5000;
		SetSG90(crr_value);
	}
}
