/************************************************************\
 **  Copyright (c) 2011-2021 Anlogic, Inc.
 **  All Right Reserved.
\************************************************************/
/************************************************************\
 ** Log	:	This file is generated by Anlogic IP Generator.
 ** File	:	E:/_CM0_Soc/bird_test/FlappyBird-main/al_ip/sdram.v
 ** Date	:	2023 04 30
 ** TD version	:	5.0.30786
\************************************************************/

`timescale 1ns / 1ps

module sdram ( clk, ras_n, cas_n, we_n, addr, ba, dq, cs_n, dm0, dm1, dm2, dm3, cke );
	input  		clk;
	input  		ras_n;
	input  		cas_n;
	input  		we_n;
	input  		[10:0] addr;
	input  		[1:0] ba;
	inout  		[31:0] dq;
	input  		cs_n;
	input  		dm0;
	input  		dm1;
	input  		dm2;
	input  		dm3;
	input  		cke;

	EG_PHY_SDRAM_2M_32 sdram(
		.clk(clk),
		.ras_n(ras_n),
		.cas_n(cas_n),
		.we_n(we_n),
		.addr(addr),
		.ba(ba),
		.dq(dq),
		.cs_n(cs_n),
		.dm0(dm0),
		.dm1(dm1),
		.dm2(dm2),
		.dm3(dm3),
		.cke(cke));

endmodule