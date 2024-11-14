#include "music.h"

uint8_t send_buf[10];

u8 startbgm_flag,custom1bgm_flag,custom2bgm_flag,custom3bgm_flag,deadbgm_flag,methodbgm_flag,pausebgm_flag,winbgm_flag;

void mp3_Init(void)
{
	UART_Init(UART2,9600,1,0);
	startbgm_flag = 0;
	custom1bgm_flag = 0;
	custom2bgm_flag = 0;
	custom3bgm_flag = 0;
	deadbgm_flag = 0;
	methodbgm_flag = 0;
	pausebgm_flag = 0;
	winbgm_flag = 0;
	mp3_send_cmd(volume,20);
}

void send_func(void)
{
	UART_SendArray(UART2,send_buf,10);
}

//
static void fill_uint16_bigend (uint8_t *thebuf, uint16_t data) {
	* thebuf =	(uint8_t)(data>>8);
	*(thebuf+1) =	(uint8_t)data;
}

//calc checksum (1~6 byte)
uint16_t mp3_get_checksum (uint8_t *thebuf) {
	uint16_t sum = 0;
	char i;
	for ( i=1; i<7; i++) {
		sum += thebuf[i];
	}
	return -sum;
}

//fill checksum to send_buf (7~8 byte)
void mp3_fill_checksum (void) {
	uint16_t checksum = mp3_get_checksum (send_buf);
	fill_uint16_bigend (send_buf+7, checksum);
}

//
void mp3_send_cmd (uint8_t cmd, uint16_t arg) {
	send_buf[0] = 0x7E;
	send_buf[1] = 0xFF;
	send_buf[2] = 0x06;
	send_buf[9] = 0xEF;
	send_buf[3] = cmd;
	fill_uint16_bigend ((send_buf+5), arg);
	mp3_fill_checksum ();
	send_func ();
}

void GameBgm()
{
	if(FlyBird->PHOTO_DONE == 1)
	{
		if(GetGameState() == start_scene)
		{
			if(startbgm_flag == 0)
			{
				startbgm_flag = 1;
				custom1bgm_flag = 0;
				custom2bgm_flag = 0;
				custom3bgm_flag = 0;
				deadbgm_flag = 0;
				methodbgm_flag = 0;
				pausebgm_flag = 0;
				winbgm_flag = 0;
				mp3_send_cmd(songrecycle,start_bgm);
			}

		}
		else if(GetGameState() == custom1_scene)
		{
			if(custom1bgm_flag == 0)
			{
				startbgm_flag = 0;
				custom1bgm_flag = 1;
				custom2bgm_flag = 0;
				custom3bgm_flag = 0;
				deadbgm_flag = 0;
				methodbgm_flag = 0;
				pausebgm_flag = 0;
				winbgm_flag = 0;
				mp3_send_cmd(songrecycle,custom1_bgm);
			}
		}
		else if(GetGameState() == custom2_scene)
		{
			if(custom2bgm_flag == 0)
			{
				startbgm_flag = 0;
				custom1bgm_flag = 0;
				custom2bgm_flag = 1;
				custom3bgm_flag = 0;
				deadbgm_flag = 0;
				methodbgm_flag = 0;
				pausebgm_flag = 0;
				winbgm_flag = 0;
				mp3_send_cmd(songrecycle,custom2_bgm);
			}
		}
		else if(GetGameState() == custom3_scene)
		{
			if(custom3bgm_flag == 0)
			{
				startbgm_flag = 0;
				custom1bgm_flag = 0;
				custom2bgm_flag = 0;
				custom3bgm_flag = 1;
				deadbgm_flag = 0;
				methodbgm_flag = 0;
				pausebgm_flag = 0;
				winbgm_flag = 0;
				mp3_send_cmd(songrecycle,custom3_bgm);
			}
		}
		else if(GetGameState() == gameover_scene)
		{
			if(deadbgm_flag == 0)
			{
				startbgm_flag = 0;
				custom1bgm_flag = 0;
				custom2bgm_flag = 0;
				custom3bgm_flag = 0;
				deadbgm_flag = 1;
				methodbgm_flag = 0;
				pausebgm_flag = 0;
				winbgm_flag = 0;
				mp3_send_cmd(songrecycle,dead_bgm);
			}
		}
		else if(GetGameState() == method_scene)
		{
			if(methodbgm_flag == 0)
			{
				startbgm_flag = 0;
				custom1bgm_flag = 0;
				custom2bgm_flag = 0;
				custom3bgm_flag = 0;
				deadbgm_flag = 0;
				methodbgm_flag = 1;
				pausebgm_flag = 0;
				winbgm_flag = 0;
				mp3_send_cmd(songrecycle,method_bgm);
			}
		}
		else if(GetGameState() == pause_scene)
		{
			if(pausebgm_flag == 0)
			{
				startbgm_flag = 0;
				custom1bgm_flag = 0;
				custom2bgm_flag = 0;
				custom3bgm_flag = 0;
				deadbgm_flag = 0;
				methodbgm_flag = 0;
				pausebgm_flag = 1;
				winbgm_flag = 0;
				mp3_send_cmd(songrecycle,pause_bgm);
			}
		}
		else if(GetGameState() == win_scene)
		{
			if(winbgm_flag == 0)
			{
				startbgm_flag = 0;
				custom1bgm_flag = 0;
				custom2bgm_flag = 0;
				custom3bgm_flag = 0;
				deadbgm_flag = 0;
				methodbgm_flag = 0;
				pausebgm_flag = 0;
				winbgm_flag = 1;
				mp3_send_cmd(songrecycle,win_bgm);
			}
		}
		else
		{
			startbgm_flag = 0;
			custom1bgm_flag = 0;
			custom2bgm_flag = 0;
			custom3bgm_flag = 0;
			deadbgm_flag = 0;
			methodbgm_flag = 0;
			pausebgm_flag = 0;
			winbgm_flag = 0;
			mp3_send_cmd(stop,0);
		}		
	}

}


