module camera_rd_synchro
(
    input   wire            clk,
    input   wire            rst_n,

    input   wire    [11:0]  hcnt,
    input   wire    [11:0]  vcnt,
    input   wire            one_flag,
    input   wire            two_flag,
    input   wire            first_rden,
    input   wire            second_rden,

    output  wire            sdram_rst_n,
    output  wire            sdram_rden
);

//每一帧图象开始与结束的标志位，用于对齐sdram使能信号
reg     one_frame_start;
reg     one_frame_end;

always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        one_frame_start <= 1'b0;
    else if(hcnt == 12'd100 && vcnt == 12'd10)
        one_frame_start <= 1'b1;
    else
        one_frame_start <= 1'b0;

always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        one_frame_end <= 1'b0;
    else if(hcnt == 12'd1340 && vcnt == 12'd804)
        one_frame_end <= 1'b1;
    else
        one_frame_end <= 1'b0;

//状态改变标志位，用于更新sdram
wire        change_flag;

//分别表示两个游戏状态
reg     one_state;
reg     two_state;

always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        one_state <= 1'b1;
    else if(two_flag == 1'b1)
        one_state <= 1'b0;
    else if(one_flag == 1'b1)
        one_state <= 1'b1;
    else
        one_state <= one_state;

always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        two_state <= 1'b0;
    else if(one_flag == 1'b1)
        two_state <= 1'b0;
    else if(two_flag == 1'b1)
        two_state <= 1'b1;
    else
        two_state <= two_state;

//当状态切换时，信号拉高，用于更新sdram
assign  change_flag = (one_flag == 1'b1 && one_state != 1'b1) | (two_flag == 1'b1 && two_state != 1'b1);
assign  sdram_rst_n = ~change_flag;

//在不同的游戏状态中第一个帧头开始标志位，用于对齐sdram读取信号
reg     first_state;
reg     second_state;

always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        first_state <= 1'b0;
    else if(one_state == 1'b0)
        first_state <= 1'b0;
    else if(one_state == 1'b1 && one_frame_start == 1'b1)
        first_state <= 1'b1;
    else
        first_state <= first_state;

always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        second_state <= 1'b0;
    else if(two_state == 1'b0)
        second_state <= 1'b0;
    else if(two_state == 1'b1 && one_frame_start == 1'b1)
        second_state <= 1'b1;
    else
        second_state <= second_state;

assign sdram_rden = (first_state == 1'b1) ? first_rden : (second_state == 1'b1) ? second_rden : 1'b0;

endmodule
