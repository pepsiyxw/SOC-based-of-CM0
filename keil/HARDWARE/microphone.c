#include "microphone.h"

u8 angle;

u32 GetLeftFirstCnt(void)
{
	return MICROPHONE->LEFTFIRST_CNT;
}

u32 GetRightFirstCnt(void)
{
	return MICROPHONE->RIGHTFIRST_CNT;
}

u32 GetUpFirstCnt(void)
{
	return MICROPHONE->UPFIRST_CNT;
}

u32 GetDownFirstCnt(void)
{
	return MICROPHONE->DOWNFIRST_CNT;
}

u8 GetUpDownState(void)
{
	return MICROPHONE->UPDOWN_STATE;
}

u8 GetLeftRightState(void)
{
	return MICROPHONE->LEFTRIGHT_STATE;
}

void GetAngle(void)
{
	if(GetGameState() == custom3_scene)
	{
		if(GetUpDownState() == Upfirst && GetLeftRightState() == Rightfirst)
		{
			if(GetRightFirstCnt() > GetUpFirstCnt())
			{
				angle = 1;
			}
			else
			{
				angle = 2;
			}
		}
		else if(GetUpDownState() == Upfirst && GetLeftRightState() == Leftfirst)
		{
			if(GetUpFirstCnt() > GetLeftFirstCnt())
			{
				angle = 3;
			}
			else
			{
				angle = 4;
			}
		}
		else if(GetUpDownState() == Downfirst && GetLeftRightState() == Leftfirst)
		{
			if(GetLeftFirstCnt() > GetDownFirstCnt())
			{
				angle = 5;
			}
			else
			{
				angle = 6;
			}
		}
		else
		{
			if(GetDownFirstCnt() > GetRightFirstCnt())
			{
				angle = 7;
			}
			else
			{
				angle = 8;
			}
		}
		FlyBird->ANGLE = angle;
	}
	else
	{
		FlyBird->ANGLE = 0;
	}

}
