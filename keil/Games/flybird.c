#include "flybird.h"

int PS2_KEY,PS2_LX,PS2_LY,PS2_RX,PS2_RY;		//按键值
u8 KeyUp_flag,KeyDown_flag,KeyLeft_flag,KeyRight_flag,KeyOk_flag,KeyCancle_flag,KeyPause_flag;		//防止重复触发

u8 Score_reg;

int Sobel = 50;

u8 	interrupt_mode1,interrupt_mode2;

void GameInit()
{
	FlyBird->SOBEL = Sobel;
}

void Game_Start()
{
	FlyBird->STARTBUTTON = 1;
}

void First_Custom_Go()
{
	FlyBird->MOVEBUTTON = 1;
}

void Third_Custom_Go()
{
	FlyBird->THIRD_MOVEBUTTON = 1;
}


void Game_Pause()
{
	FlyBird->PAUSEBUTTON = 1;
}

void Game_Continue()
{
	FlyBird->CONTINUEBUTTON = 1;
}

void Game_Restart()
{
	SetGameMode(0x00);
	SetPauseMode(0x00);
	FlyBird->RESTARTBUTTON = 1;
}

void Game_Method()
{
	FlyBird->METHODBUTTON = 1;
}

void Game_Cancle()
{
	FlyBird->CANCLEBUTTON = 1;
}

void Bird1Up()
{
	FlyBird->BIRD1UP = 1;
}

void Bird1Down()
{
	FlyBird->BIRD1DOWN = 1;
}

void Bird1Left()
{
	FlyBird->BIRD1LEFT = 1;
}

void Bird1Right()
{
	FlyBird->BIRD1RIGHT = 1;
}

void Bird1Up_Disable()
{
	FlyBird->BIRD1UP = 0;
}

void Bird1Down_Disable()
{
	FlyBird->BIRD1DOWN = 0;
}

void Bird1Left_Disable()
{
	FlyBird->BIRD1LEFT = 0;
}

void Bird1Right_Disable()
{
	FlyBird->BIRD1RIGHT = 0;
}

void Bird2Up()
{
	FlyBird->BIRD2UP = 1;
}

void Bird2Down()
{
	FlyBird->BIRD2DOWN = 1;
}

void Bird2Left()
{
	FlyBird->BIRD2LEFT = 1;
}

void Bird2Right()
{
	FlyBird->BIRD2RIGHT = 1;
}

void Bird2Up_Disable()
{
	FlyBird->BIRD2UP = 0;
}

void Bird2Down_Disable()
{
	FlyBird->BIRD2DOWN = 0;
}

void Bird2Left_Disable()
{
	FlyBird->BIRD2LEFT = 0;
}

void Bird2Right_Disable()
{
	FlyBird->BIRD2RIGHT = 0;
}

void SetGameSobel(u8 threshold)
{
	FlyBird->SOBEL = threshold;
}

u8 GetGameSobel()
{
	return FlyBird->SOBEL;
}

u8 GetGameScore()
{
	return FlyBird->SCORE;
}

u8 GetGameState()
{
	return FlyBird->STATE;
}

void SetGameMode(u8 Mode)
{
	FlyBird->GAMEMODE = Mode;
}

u8 GetGameMode()
{
	return FlyBird->GAMEMODE;
}

void SetPauseMode(u8 Mode)
{
	FlyBird->PAUSEMODE = Mode;
}

u8 GetPauseMode()
{
	return FlyBird->PAUSEMODE;
}

void NoneButton()
{
	FlyBird->METHODBUTTON = 0;
	FlyBird->CONTINUEBUTTON = 0;
	FlyBird->MOVEBUTTON = 0;
	FlyBird->PAUSEBUTTON = 0;
	FlyBird->RESTARTBUTTON = 0;
	FlyBird->STARTBUTTON = 0;
	FlyBird->CANCLEBUTTON = 0;
	
	FlyBird->BIRD1UP = 0;
	FlyBird->BIRD1DOWN = 0;
	FlyBird->BIRD1LEFT = 0;
	FlyBird->BIRD1RIGHT = 0;

	FlyBird->BIRD2UP = 0;
	FlyBird->BIRD2DOWN = 0;
	FlyBird->BIRD2LEFT = 0;
	FlyBird->BIRD2RIGHT = 0;
}

void Bird1_Control(void)
{
	if(GetGameState() == custom2_scene || GetGameState() == custom3_scene)
	{
		//鸟1的遥感左右控制
		if(PS2_LX < PS2_LX_LEFT)
		{
			Bird1Left();
			Bird1Right_Disable();
		}
		else if(PS2_LX > PS2_LX_RIGHT)
		{
			Bird1Right();
			Bird1Left_Disable();
		}
		else
		{
			Bird1Right_Disable();
			Bird1Left_Disable();
		}
		
		//鸟1的遥感上下控制
		if(PS2_LY < PS2_LY_UP)
		{
			Bird1Up();
			Bird1Down_Disable();
		}
		else if(PS2_LY > PS2_LY_DOWN)
		{
			Bird1Down();
			Bird1Up_Disable();
		}
		else
		{
			Bird1Down_Disable();
			Bird1Up_Disable();
		}
	}
	else
	{
		Bird1Up_Disable();
		Bird1Down_Disable();
		Bird1Left_Disable();
		Bird1Right_Disable();
	}
}

void Fourth_Control(void)
{
		//鸟1的遥感左右控制
		if(PS2_LX < PS2_LX_LEFT)
		{
			FlyBird->FOURTH_LEFT = 1;
			FlyBird->FOURTH_RIGHT = 0;
		}
		else if(PS2_LX > PS2_LX_RIGHT)
		{
			FlyBird->FOURTH_LEFT = 0;
			FlyBird->FOURTH_RIGHT = 1;
		}
		else
		{
			FlyBird->FOURTH_LEFT = 0;
			FlyBird->FOURTH_RIGHT = 0;
		}
		
		if(PS2_LY < PS2_LY_UP)
		{
			FlyBird->FOURTH_UP = 1;
		}
		else
		{
			FlyBird->FOURTH_UP = 0;
		}
}

void Servo_Control()
{
	//当位于第一关时，通过摇杆控制云台，击杀小鸟
	if(GetGameState() == custom1_scene)
	{
		//云台的遥感左右控制
		if(PS2_LX < PS2_LX_LEFT)
		{
			COMMUNICATE->SERVO_LEFT = 1;
			COMMUNICATE->SERVO_RIGHT = 0;
		}
		else if(PS2_LX > PS2_LX_RIGHT)
		{
			COMMUNICATE->SERVO_LEFT = 0;
			COMMUNICATE->SERVO_RIGHT = 1;
		}
		else
		{
			COMMUNICATE->SERVO_LEFT = 0;
			COMMUNICATE->SERVO_RIGHT = 0;
		}

		//云台的遥感上下控制
		if(PS2_LY < PS2_LY_UP)
		{
			COMMUNICATE->SERVO_UP = 1;
			COMMUNICATE->SERVO_DOWN = 0;
		}
		else if(PS2_LY > PS2_LY_DOWN)
		{
			COMMUNICATE->SERVO_UP = 0;
			COMMUNICATE->SERVO_DOWN = 1;
		}
		else
		{
			COMMUNICATE->SERVO_UP = 0;
			COMMUNICATE->SERVO_DOWN = 0;
		}
	}
	else
	{
		COMMUNICATE->SERVO_UP = 0;
		COMMUNICATE->SERVO_DOWN = 0;
		COMMUNICATE->SERVO_LEFT = 0;
		COMMUNICATE->SERVO_RIGHT = 0;
	}
	
	if(GetGameState() == start_scene)
	{
		COMMUNICATE->SERVO_RESET = 1;
	}
	else
	{
		COMMUNICATE->SERVO_RESET = 0;
	}
	
	//当单人模式第一关时，打开自动追踪
	if(FlyBird->GAMEMODE == 0x00)
	{
		if(GetGameState() == custom1_scene)
		{
			COMMUNICATE->SERVO_TRACK_EN = 1;
		}
		else
		{
			COMMUNICATE->SERVO_TRACK_EN = 0;
		}
	}
}
//*****************************************************************************
/************ ****************************************************************
**      ***** ********** ***** **********************************************
** **** ***** *********** *** ***********************************************
** **** *         ******** ** ***********************************************
** **** ***** *************  ************************************************
**      ***** ************ * ************************************************
************* *********** *** ***********************************************/
//*****************************************************************************
void SPTIMER0Handler(void)
{
	PS2_LX=PS2_AnologData(PSS_LX);
	PS2_LY=PS2_AnologData(PSS_LY);
	PS2_RX=PS2_AnologData(PSS_RX);
	PS2_RY=PS2_AnologData(PSS_RY);
	PS2_KEY=PS2_DataKey();
	GetAngle();					//获取角度值
}

void SPTIMER1Handler(void)
{
//*****************************************************************************
	//按下按键上
	if(PS2_KEY == KEY_UP)
	{
		if(PS2_KEY == KEY_UP && KeyUp_flag == 0)
		{
			KeyUp_flag = 1;
			if(GetGameState() == pause_scene)
			{
				if(GetPauseMode() == 0x00)
				{
					mp3_send_cmd(advertise,1);
					SetPauseMode(0x02);
				}
				else if(GetPauseMode() == 0x01)
				{
					mp3_send_cmd(advertise,1);
					SetPauseMode(0x00);
				}
				else
				{
					mp3_send_cmd(advertise,1);
					SetPauseMode(0x01);
				}
			}
			else if(GetGameState() == start_scene)
			{
				if(GetGameMode() == 0x00)
				{
					mp3_send_cmd(advertise,1);
					SetGameMode(0x02);
				}
				else if(GetGameMode() == 0x02)
				{
					mp3_send_cmd(advertise,1);
					SetGameMode(0x01);
				}
				else
				{
					mp3_send_cmd(advertise,1);
					SetGameMode(0x00);
				}
			}
		}
	}
	else
	{
		KeyUp_flag = 0;
	}
//*****************************************************************************

//*****************************************************************************
	//按下按键下
	if(PS2_KEY == KEY_DOWN)
	{
		if(PS2_KEY == KEY_DOWN && KeyDown_flag == 0)
		{
			KeyDown_flag = 1;
			if(GetGameState() == pause_scene)
			{
				if(GetPauseMode() == 0x02)
				{
					mp3_send_cmd(advertise,1);
					SetPauseMode(0x00);
				}
				else if(GetPauseMode() == 0x01)
				{
					mp3_send_cmd(advertise,1);
					SetPauseMode(0x02);
				}
				else
				{
					mp3_send_cmd(advertise,1);
					SetPauseMode(0x01);
				}
			}
			else if(GetGameState() == start_scene)
			{
				if(GetGameMode() == 0x02)
				{
					mp3_send_cmd(advertise,1);
					SetGameMode(0x00);
				}
				else if(GetGameMode() == 0x00)
				{
					mp3_send_cmd(advertise,1);
					SetGameMode(0x01);
				}
				else
				{
					mp3_send_cmd(advertise,1);
					SetGameMode(0x02);
				}
			}
		}		
	}
	else
	{
		KeyDown_flag = 0;
	}
//*****************************************************************************

//*****************************************************************************
	//按下按键左
	if(PS2_KEY == KEY_LEFT)
	{
		if(PS2_KEY == KEY_LEFT && KeyLeft_flag == 0)
		{
			mp3_send_cmd(sounddown,0);
			KeyLeft_flag = 1;
		}		
	}
	else
	{
		KeyLeft_flag = 0;
	}
//*****************************************************************************

//*****************************************************************************
	//按下按键右
	if(PS2_KEY == KEY_RIGHT)
	{
		if(PS2_KEY == KEY_RIGHT && KeyRight_flag == 0)
		{
			mp3_send_cmd(soundup,0);
			KeyRight_flag = 1;
		}	
	}
	else
	{
		KeyRight_flag = 0;
	}
//*****************************************************************************

//*****************************************************************************
	//按下按键确定
	if(PS2_KEY == KEY_OK)
	{
		if(PS2_KEY == KEY_OK && KeyOk_flag == 0)
		{
			KeyOk_flag = 1;
			if(GetGameState() == start_scene && GetGameMode() == 0x02)
			{
				Game_Method();
			}
			else if(GetGameState() == start_scene)
			{
				Game_Start();
			}
			else if(GetGameState() == pause_scene)
			{
				if(GetPauseMode() == 0x00)
				{
					Game_Continue();
				}
				else if(GetPauseMode() == 0x01)
				{
					Game_Restart();
				}
				else if(GetPauseMode() == 0x02)
				{
					Game_Method();
				}

			}
			else if(GetGameState() == gameover_scene)
			{
				Game_Restart();
			}
			else if(GetGameState() == custom1_scene)
			{
				mp3_send_cmd(advertise,2);
				FlyBird->CUSTOM1_GUN_ENABLE = 1;
			}
			else if(GetGameState() == custom3_scene)
			{
				Third_Custom_Go();
			}
			else if(GetGameState() == win_scene)
			{
				Game_Restart();
			}
		}		
	}
	else
	{
		KeyOk_flag = 0;
		FlyBird->METHODBUTTON = 0;
		FlyBird->CONTINUEBUTTON = 0;
		FlyBird->MOVEBUTTON = 0;
		FlyBird->RESTARTBUTTON = 0;
		FlyBird->STARTBUTTON = 0;
		FlyBird->THIRD_MOVEBUTTON = 0;
		FlyBird->CUSTOM1_GUN_ENABLE = 0;
	}
//*****************************************************************************

//*****************************************************************************
	//按下按键取消
	if(PS2_KEY == KEY_CANCLE)
	{
		if(PS2_KEY == KEY_CANCLE && KeyCancle_flag == 0)
		{
			KeyCancle_flag = 1;
			if(GetGameState() == method_scene && GetPauseMode() == 0x00)
			{
				Game_Restart();
			}
			else if(GetGameState() == method_scene && GetPauseMode() == 0x02)
			{
				Game_Cancle();
			}
		}		
	}
	else
	{
		KeyCancle_flag = 0;
		FlyBird->CANCLEBUTTON = 0;
		FlyBird->RESTARTBUTTON = 0;
		FlyBird->CONTINUEBUTTON = 0;
	}
//*****************************************************************************

//*****************************************************************************
	//按下按键暂停
	if(PS2_KEY == KEY_PAUSE)
	{
		if(PS2_KEY == KEY_PAUSE && KeyPause_flag == 0)
		{
			KeyPause_flag = 1;
			if(GetGameState() == custom2_scene || GetGameState() == custom1_scene || GetGameState() == custom3_scene)
			{
				SetPauseMode(0x00);
				Game_Pause();
			}
		}		
	}
	else
	{
		KeyPause_flag = 0;
		FlyBird->PAUSEBUTTON = 0;
	}
//*****************************************************************************

//*****************************************************************************
	if(PS2_KEY == KEY_LEFT1)
	{
		if(GetGameState() == custom2_scene)
		{
			Sobel += 1;
			SetGameSobel(Sobel);
		}
	}
//*****************************************************************************
	
//*****************************************************************************
	if(PS2_KEY == KEY_RIGHT1)
	{
		if(GetGameState() == custom2_scene)
		{
			Sobel -= 1;
			SetGameSobel(Sobel);
		}
	}
//*****************************************************************************
	
//*****************************************************************************
	if(PS2_KEY == KEY_LEFT2)
	{
	}
	else
	{
	}
//*****************************************************************************
	
//*****************************************************************************
	if(PS2_KEY == KEY_RIGHT2)
	{
		if(GetGameState() == custom2_scene ||GetGameState() == custom3_scene)
		{
			FlyBird->BIRD1_SPEED = high_speed;
		}

		if(FlyBird->GAMEMODE == 0x01)
		{
			if(GetGameState() == custom1_scene)
			{
				COMMUNICATE->SERVO_TRACK_EN = 1;
			}
			else
			{
				COMMUNICATE->SERVO_TRACK_EN = 0;
			}
		}
	}
	else
	{
		FlyBird->BIRD1_SPEED = middle_speed;
		if(FlyBird->GAMEMODE == 0x01)
		{
			COMMUNICATE->SERVO_TRACK_EN = 0;
		}
	}
//*****************************************************************************
	if(PS2_KEY == 0x00)
	{
		FlyBird->METHODBUTTON = 0;
		FlyBird->CONTINUEBUTTON = 0;
		FlyBird->MOVEBUTTON = 0;
		FlyBird->PAUSEBUTTON = 0;
		FlyBird->RESTARTBUTTON = 0;
		FlyBird->STARTBUTTON = 0;
		FlyBird->CANCLEBUTTON = 0;
		FlyBird->THIRD_MOVEBUTTON = 0;
	}
	
//*****************************************************************************
	
	Bird1_Control();
	Bird2_Control();	//通过陀螺仪控制第二关鸟2
	Fourth_Control();
	Servo_Control();
}

