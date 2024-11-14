#ifndef __HAN_H
#define __HAN_H

#include "CMSDK_CM0.h"
#include "cm0_uart.h"
#include "flybird.h"

#define 	play			0x0d
#define		pause			0x0e
#define		soundup			0x04
#define		sounddown		0x05
#define		next			0x01
#define		last			0x02
#define		choosesong		0x03 	//arg = [1,2999]
#define		volume 			0x06	//arg = [0,30]
#define		songrecycle		0x08	//arg = [0,2999]
#define 	allrecycle		0x11    //arg = 1 or 0
#define		stop			0x16
#define 	advertise		0x13	//arg = [1,9999]
#define		advertise_stop	0x15

//BGM
#define		start_bgm		1
#define		custom1_bgm		2
#define		custom2_bgm		3
#define		custom3_bgm		4
#define 	dead_bgm		5
#define 	method_bgm		6
#define		pause_bgm		7
#define		win_bgm			8

//ADVERTISE
#define		button			1
#define		birddead		2
#define		boom			3

void mp3_Init(void);
void send_func(void);
void mp3_send_cmd (uint8_t cmd, uint16_t arg);
static void fill_uint16_bigend (uint8_t *thebuf, uint16_t data);
uint16_t mp3_get_checksum (uint8_t *thebuf);
void mp3_fill_checksum (void);

void GameBgm(void);

#endif
