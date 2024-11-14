module rd_synchro
(
    input   wire            hdmi_clk,
    input   wire            sys_rst_n,

    input   wire    [11:0]  hcnt,
    input   wire    [11:0]  vcnt,
    input   wire    [3:0]   state,
    input   wire            all_photo_en,

    output  wire            sdram_rst_n,
    output  wire            sdram_rden,
    output  wire    [22:0]  sdram_rd_b_addr,
    output  wire    [22:0]  sdram_rd_e_addr
);

parameter start_scene       = 4'b0001;
parameter gameplay_scene    = 4'b0010;
parameter pause_scene       = 4'b0100;
parameter gameover_scene    = 4'b1000;
parameter second_scene      = 4'b1010;

//每一帧图象开始与结束的标志位，用于对齐sdram使能信号
reg     one_frame_start;
reg     one_frame_end;

always@(posedge hdmi_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        one_frame_start <= 1'b0;
    else if(hcnt == 12'd100 && vcnt == 12'd10)
        one_frame_start <= 1'b1;
    else
        one_frame_start <= 1'b0;

always@(posedge hdmi_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        one_frame_end <= 1'b0;
    else if(hcnt == 12'd1340 && vcnt == 12'd804)
        one_frame_end <= 1'b1;
    else
        one_frame_end <= 1'b0;

//状态改变标志位，用于更新sdram
reg         change_flag;
reg [3:0]   last_state;

assign sdram_rst_n = ~change_flag;

always@(posedge hdmi_clk)
    last_state <= state;

always@(posedge hdmi_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        change_flag <= 1'b0;
    else if(last_state != state)
        change_flag <= 1'b1;
    else
        change_flag <= 1'b0;

//第一张图片显示状态配置
reg     one_flag;
always@(posedge hdmi_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        one_flag <= 1'b0;
    else if(one_frame_start == 1'b1 && state == start_scene)
        one_flag <= 1'b1;
    else
        one_flag <= 1'b0;

reg     one_state;
always@(posedge hdmi_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        one_state <= 1'b0;
    else if(state != start_scene)
        one_state <= 1'b0;
    else if(one_flag == 1'b1)
        one_state <= 1'b1;
    else
        one_state <= one_state;

//第二张图片显示状态配置
reg     two_flag;
always@(posedge hdmi_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        two_flag <= 1'b0;
    else if(one_frame_start == 1'b1 && state == gameplay_scene)
        two_flag <= 1'b1;
    else
        two_flag <= 1'b0;

reg     two_state;
always@(posedge hdmi_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        two_state <= 1'b0;
    else if(state != gameplay_scene)
        two_state <= 1'b0;
    else if(two_flag == 1'b1)
        two_state <= 1'b1;
    else
        two_state <= two_state;

//输出sdram使能信号与其起止地址位
assign sdram_rd_b_addr = (state == gameplay_scene) ? 23'd786432 : (state == start_scene) ? 23'd0 : 23'd0;
assign sdram_rd_e_addr = (state == gameplay_scene) ? 23'd1572864 : (state == start_scene) ? 23'd786430 : 23'd786432;
assign sdram_rden = (two_state == 1'b1 || one_state == 1'b1) ? all_photo_en : 1'b0;

endmodule
