#ifndef __FLYBIRD_H
#define __FLYBIRD_H

#include "CMSDK_CM0.h"
#include "Systick.h"
#include "Handcontroller.h"
#include "IMU.h"
#include "microphone.h"
#include "music.h"

extern int Sobel,Binary;

#define	start_scene 	0x01
#define	custom1_scene 	0x02
#define	custom2_scene 	0x04
#define	custom3_scene 	0x08
#define	pause_scene 	0x10
#define	gameover_scene 	0x20
#define method_scene	0x40
#define win_scene		0x7f

#define	middle_speed	0
#define	high_speed		1

//手柄摇杆控制
#define PS2_LX_RIGHT	200
#define PS2_LX_LEFT		20

#define PS2_LY_UP		100
#define PS2_LY_DOWN		254

void GameInit(void);
void Game_Start(void);
void First_Custom_Go(void);
void Third_Custom_Go(void);
void Game_Pause(void);
void Game_Continue(void);
void Game_Restart(void);
void Game_Method(void);
void Game_Cancle(void);

void Bird1Up(void);
void Bird1Down(void);
void Bird1Left(void);
void Bird1Right(void);
void Bird1Up_Disable(void);
void Bird1Down_Disable(void);
void Bird1Left_Disable(void);
void Bird1Right_Disable(void);

void Bird2Up(void);
void Bird2Down(void);
void Bird2Left(void);
void Bird2Right(void);
void Bird2Up_Disable(void);
void Bird2Down_Disable(void);
void Bird2Left_Disable(void);
void Bird2Right_Disable(void);

void SetGameSobel(u8 threshold);
u8 GetGameSobel(void);
u8 GetGameScore(void);
u8 GetGameState(void);
void SetGameMode(u8 Mode);
u8 GetGameMode(void);
void SetPauseMode(u8 Mode);
u8 GetPauseMode(void);
void NoneButton(void);

void Bird1_Control(void);
void Servo_Control(void);

#endif
