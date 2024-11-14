#ifndef __MICROPHONE_H
#define __MICROPHONE_H

#include "CMSDK_CM0.h"                  // Device header
#include "flybird.h" 

#define		Upfirst		0x01
#define		Downfirst	0x02
#define		Leftfirst	0x01
#define		Rightfirst	0x02

u32 GetLeftFirstCnt(void);
u32 GetRightFirstCnt(void);
u32 GetUpFirstCnt(void);
u32 GetDownFirstCnt(void);
u8 GetUpDownState(void);
u8 GetLeftRightState(void);
void GetAngle(void);

#endif
