module sdcard_rd_synchro
(
    input   wire            hdmi_clk,
    input   wire            sys_rst_n,

    input   wire    [11:0]  hcnt,
    input   wire    [11:0]  vcnt,
    input   wire    [6:0]   state,
    input   wire            all_photo_en,

    output  wire            sdram_rst_n,
    output  wire            sdram_rden,
    output  wire    [22:0]  sdram_rd_b_addr,
    output  wire    [22:0]  sdram_rd_e_addr
);

parameter start_scene       = 7'b0000001;
parameter custom1_scene     = 7'b0000010;
parameter custom2_scene     = 7'b0000100;
parameter custom3_scene     = 7'b0001000;
parameter pause_scene       = 7'b0010000;
parameter gameover_scene    = 7'b0100000;
parameter method_scene      = 7'b1000000;
parameter win_scene         = 7'b1111111;

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
reg [6:0]   last_state;

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
    else if(one_frame_start == 1'b1 && state == custom1_scene)
        two_flag <= 1'b1;
    else
        two_flag <= 1'b0;

reg     two_state;
always@(posedge hdmi_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        two_state <= 1'b0;
    else if(state != custom1_scene)
        two_state <= 1'b0;
    else if(two_flag == 1'b1)
        two_state <= 1'b1;
    else
        two_state <= two_state;

//第三张图片显示状态配置
reg     three_flag;
always@(posedge hdmi_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        three_flag <= 1'b0;
    else if(one_frame_start == 1'b1 && state == custom2_scene)
        three_flag <= 1'b1;
    else
        three_flag <= 1'b0;

reg     three_state;
always@(posedge hdmi_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        three_state <= 1'b0;
    else if(state != custom2_scene)
        three_state <= 1'b0;
    else if(three_flag == 1'b1)
        three_state <= 1'b1;
    else
        three_state <= three_state;

//第四张图片显示状态配置
reg     four_flag;
always@(posedge hdmi_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        four_flag <= 1'b0;
    else if(one_frame_start == 1'b1 && state == custom3_scene)
        four_flag <= 1'b1;
    else
        four_flag <= 1'b0;

reg     four_state;
always@(posedge hdmi_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        four_state <= 1'b0;
    else if(state != custom3_scene)
        four_state <= 1'b0;
    else if(four_flag == 1'b1)
        four_state <= 1'b1;
    else
        four_state <= four_state;

//第五张图片显示状态配置
reg     five_flag;
always@(posedge hdmi_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        five_flag <= 1'b0;
    else if(one_frame_start == 1'b1 && state == pause_scene)
        five_flag <= 1'b1;
    else
        five_flag <= 1'b0;

reg     five_state;
always@(posedge hdmi_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        five_state <= 1'b0;
    else if(state != pause_scene)
        five_state <= 1'b0;
    else if(five_flag == 1'b1)
        five_state <= 1'b1;
    else
        five_state <= five_state;

//第六张图片显示状态配置
reg     six_flag;
always@(posedge hdmi_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        six_flag <= 1'b0;
    else if(one_frame_start == 1'b1 && state == gameover_scene)
        six_flag <= 1'b1;
    else
        six_flag <= 1'b0;

reg     six_state;
always@(posedge hdmi_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        six_state <= 1'b0;
    else if(state != gameover_scene)
        six_state <= 1'b0;
    else if(six_flag == 1'b1)
        six_state <= 1'b1;
    else
        six_state <= six_state;

//第七张图片显示状态配置
reg     seven_flag;
always@(posedge hdmi_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        seven_flag <= 1'b0;
    else if(one_frame_start == 1'b1 && state == method_scene)
        seven_flag <= 1'b1;
    else
        seven_flag <= 1'b0;

reg     seven_state;
always@(posedge hdmi_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        seven_state <= 1'b0;
    else if(state != method_scene)
        seven_state <= 1'b0;
    else if(seven_flag == 1'b1)
        seven_state <= 1'b1;
    else
        seven_state <= seven_state;

//第七张图片显示状态配置
reg     eight_flag;
always@(posedge hdmi_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        eight_flag <= 1'b0;
    else if(one_frame_start == 1'b1 && state == win_scene)
        eight_flag <= 1'b1;
    else
        eight_flag <= 1'b0;

reg     eight_state;
always@(posedge hdmi_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        eight_state <= 1'b0;
    else if(state != win_scene)
        eight_state <= 1'b0;
    else if(eight_flag == 1'b1)
        eight_state <= 1'b1;
    else
        eight_state <= eight_state;

//输出sdram使能信号与其起止地址位
assign sdram_rd_b_addr  =   (state == start_scene && one_state == 1'b1) ? 23'd0 : 
                            (state == custom1_scene && two_state == 1'b1) ? 23'd786432 : 
                            (state == custom2_scene && three_state == 1'b1) ? 23'd1572864 : 
                            (state == custom3_scene && four_state == 1'b1) ? 23'd2359296 : 
                            (state == pause_scene && five_state == 1'b1) ? 23'd3145728 : 
                            (state == gameover_scene && six_state == 1'b1) ? 23'd3932160 : 
                            (state == method_scene && seven_state == 1'b1) ? 23'd4718592 : 
                            (state == win_scene && eight_state == 1'b1) ? 23'd5505024 : 23'd0;

assign sdram_rd_e_addr  =   (state == start_scene && one_state == 1'b1) ? 23'd786431 : 
                            (state == custom1_scene && two_state == 1'b1) ? 23'd1572863 : 
                            (state == custom2_scene && three_state == 1'b1) ? 23'd2359295 : 
                            (state == custom3_scene && four_state == 1'b1) ? 23'd3145727 : 
                            (state == pause_scene && five_state == 1'b1) ? 23'd3932159 : 
                            (state == gameover_scene && six_state == 1'b1) ? 23'd4718591 : 
                            (state == method_scene && seven_state == 1'b1) ? 23'd5505023 : 
                            (state == win_scene && eight_state == 1'b1) ? 23'd6291455 : 23'd786431;

assign sdram_rden = (two_state == 1'b1 || one_state == 1'b1 || three_state == 1'b1 || four_state == 1'b1 || five_state == 1'b1 || six_state == 1'b1 || seven_state == 1'b1 || eight_state == 1'b1) ? all_photo_en : 1'b0;

endmodule
