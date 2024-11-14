#include "speech.h"

void Speech_Init()
{
	NVIC_EnableIRQ(EXIT0_IRQn);
	NVIC_EnableIRQ(EXIT1_IRQn);
	NVIC_EnableIRQ(EXIT2_IRQn);
	NVIC_EnableIRQ(EXIT3_IRQn);
	NVIC_EnableIRQ(EXIT4_IRQn);
	NVIC_EnableIRQ(EXIT5_IRQn);
	NVIC_EnableIRQ(EXIT6_IRQn);
	NVIC_EnableIRQ(EXIT7_IRQn);
	NVIC_EnableIRQ(EXIT8_IRQn);
//	NVIC_EnableIRQ(EXIT9_IRQn);
}

void EXITHandler0(void)	//单人模式
{
	if(GetGameState() == start_scene)
	{
		SetGameMode(0x00);
		Game_Start();
	}
}

void EXITHandler1(void)	//双人模式
{
	if(GetGameState() == start_scene)
	{
		SetGameMode(0x01);
		Game_Start();
	}
}

void EXITHandler2(void)	//操作指南
{
	if(GetGameState() == start_scene)
	{
		SetGameMode(0x02);
		Game_Method();
	}
	else if(GetGameState() == pause_scene)
	{
		SetPauseMode(0x02);
		Game_Method();
	}
}

void EXITHandler3(void)	//退出游戏
{
	Game_Restart();
}

void EXITHandler4(void)	//暂停游戏
{
	if(GetGameState() == custom1_scene || GetGameState() == custom2_scene || GetGameState() == custom3_scene)
	{
		Game_Pause();
	}
}

void EXITHandler5(void)	//继续游戏
{
	if(GetGameState() == pause_scene)
	{
		Game_Continue();
	}
	else if(GetGameState() == method_scene && GetPauseMode() == 0x02)
	{
		Game_Cancle();
	}
	else if(GetGameState() == method_scene)
	{
		Game_Restart();
	}
}

void EXITHandler6(void)	//开始游戏
{
	if(GetGameState() == custom3_scene)
	{
		Third_Custom_Go();
	}

}

void EXITHandler7(void)	//提高音量
{
	mp3_send_cmd(soundup,0);
}

void EXITHandler8(void)	//降低音量
{
	mp3_send_cmd(sounddown,0);
}

void EXITHandler9(void)	//降低音量
{
	mp3_send_cmd(sounddown,0);
}