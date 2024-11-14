module microphone_interface
(
    input   wire            HCLK,
    input   wire            HRESETn,
    input   wire            HSEL,
    input   wire    [31:0]  HADDR,
    input   wire    [1:0]   HTRANS,
    input   wire    [2:0]   HSIZE,
    input   wire    [3:0]   HPROT,
    input   wire            HWRITE,
    input   wire    [31:0]  HWDATA,
    input   wire            HREADY,
    output  wire            HREADYOUT,
    output  wire    [31:0]  HRDATA,
    output  wire            HRESP,

    output  reg     [16:0]  leftfirst_state_cnt,
    output  reg     [16:0]  rightfirst_state_cnt,

    input   wire            microphone_left,
    input   wire            microphone_right
);

assign HRESP = 1'b0;
assign HREADYOUT = 1'b1;

wire read_en;
assign read_en=HSEL&HTRANS[1]&(~HWRITE)&HREADY;

wire write_en;
assign write_en=HSEL&HTRANS[1]&(HWRITE)&HREADY;

reg rd_en_reg;
always@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        rd_en_reg <= 1'b0;
    else if(read_en)
        rd_en_reg <= 1'b1;
    else
        rd_en_reg <= 1'b0;
end

reg wr_en_reg;
always@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        wr_en_reg <= 1'b0;
    else if(write_en)
        wr_en_reg <= 1'b1;
    else
        wr_en_reg <= 1'b0;
end

reg [1:0]   addr_reg;
always@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        addr_reg <= 2'b0;
    else if(HSEL & HREADY & HTRANS[1])
        addr_reg <= HADDR[3:2];
end



assign HRDATA = (addr_reg == 2'd0) ? {15'd0,leftfirst_state_cnt} : (addr_reg == 2'd1) ? {15'd0,rightfirst_state_cnt} : 32'd0;

wire        microphone_left_flag;
wire        microphone_right_flag;

    //500ms定时器，触发一次需要500ms以后才能再次触发
//**************************************************************************
parameter   cnt_500ms = 20000000;

reg     [24:0]  cnt;
reg             cnt_begin;

always@(posedge HCLK or negedge HRESETn)
    if(~HRESETn)
        cnt <= 25'd0;
    else if(cnt_begin == 1'b1)
        cnt <= cnt + 1'b1;
    else
        cnt <= 25'd0;

always@(posedge HCLK or negedge HRESETn)
    if(~HRESETn)
        cnt_begin <= 1'b0;
    else if(cnt == cnt_500ms - 2'd2)
        cnt_begin <= 1'b0;
    else if((microphone_left_flag == 1'b0 && cnt_begin == 1'b0) || (microphone_right_flag == 1'b0 && cnt_begin == 1'b0))
        cnt_begin <= 1'b1;
    else
        cnt_begin <= cnt_begin;

//**************************************************************************


    //左右麦克风触发的脉冲信号
//**************************************************************************
reg     microphone_left_reg;
reg     microphone_right_reg;
reg     microphone_left_reg_reg;
reg     microphone_right_reg_reg;

always@(posedge HCLK or negedge HRESETn)
    if(~HRESETn)
        begin
            microphone_left_reg <= 1'b0;
            microphone_right_reg <= 1'b0;
        end
    else
        begin
            microphone_left_reg <= microphone_left;
            microphone_right_reg <= microphone_right;
        end

always@(posedge HCLK or negedge HRESETn)
    if(~HRESETn)
        begin
            microphone_left_reg_reg <= 1'b0;
            microphone_right_reg_reg <= 1'b0;
        end
    else
        begin
            microphone_left_reg_reg <= microphone_left_reg;
            microphone_right_reg_reg <= microphone_right_reg;
        end

/* wire        microphone_left_flag;
wire        microphone_right_flag; */

    //低电平脉冲信号
assign microphone_left_flag = microphone_left_reg | ~microphone_left_reg_reg;
assign microphone_right_flag = microphone_right_reg | ~microphone_right_reg_reg;
//**************************************************************************

    //左右麦克风先后触发进入不同的状态
//**************************************************************************
reg     leftfirst_state;
reg     rightfirst_state;

always@(posedge HCLK or negedge HRESETn)
    if(~HRESETn)
        leftfirst_state <= 1'b0;
    else if(microphone_right_flag == 1'b0 && cnt_begin == 1'b1)
        leftfirst_state <= 1'b0;
    else if(microphone_left_flag == 1'b0 && cnt_begin == 1'b0)
        leftfirst_state <= 1'b1;
    else if(cnt_begin == 1'b0)
        leftfirst_state <= 1'b0;
    else
        leftfirst_state <= leftfirst_state;

always@(posedge HCLK or negedge HRESETn)
    if(~HRESETn)
        rightfirst_state <= 1'b0;
    else if(microphone_left_flag == 1'b0 && cnt_begin == 1'b1)
        rightfirst_state <= 1'b0;
    else if(microphone_right_flag == 1'b0 && cnt_begin == 1'b0)
        rightfirst_state <= 1'b1;
    else if(cnt_begin == 1'b0)
        rightfirst_state <= 1'b0;
    else
        rightfirst_state <= rightfirst_state;

//**************************************************************************

//两种状态下计时器的计数值
//**************************************************************************
reg     [16:0]  leftfirst_cnt;
reg     [16:0]  rightfirst_cnt;

always@(posedge HCLK or negedge HRESETn)
    if(~HRESETn)
        leftfirst_cnt <= 17'd0;
    else if(microphone_left_flag == 1'b0 && cnt_begin == 1'b0)
        leftfirst_cnt <= 17'd0;
    else if(leftfirst_state == 1'b1)
        leftfirst_cnt <= leftfirst_cnt + 1'b1;
    else
        leftfirst_cnt <= leftfirst_cnt;

always@(posedge HCLK or negedge HRESETn)
    if(~HRESETn)
        rightfirst_cnt <= 17'd0;
    else if(microphone_right_flag == 1'b0 && cnt_begin == 1'b0)
        rightfirst_cnt <= 17'd0;
    else if(rightfirst_state == 1'b1)
        rightfirst_cnt <= rightfirst_cnt + 1'b1;
    else
        rightfirst_cnt <= rightfirst_cnt;

//两种状态计数器计时结束标志信号
//**************************************************************************
reg         leftfirst_end;
reg         rightfirst_end;

always@(posedge HCLK or negedge HRESETn)
    if(~HRESETn)
        leftfirst_end <= 1'b0;
    else if(microphone_right_flag == 1'b0 && cnt_begin == 1'b1 && leftfirst_state == 1'b1)
        leftfirst_end <= 1'b1;
    else
        leftfirst_end <= 1'b0;

always@(posedge HCLK or negedge HRESETn)
    if(~HRESETn)
        rightfirst_end <= 1'b0;
    else if(microphone_left_flag == 1'b0 && cnt_begin == 1'b1 && rightfirst_state == 1'b1)
        rightfirst_end <= 1'b1;
    else
        rightfirst_end <= 1'b0;

//**************************************************************************
always@(posedge HCLK or negedge HRESETn)
    if(~HRESETn)
        leftfirst_state_cnt <= 17'd0;
    else if(leftfirst_end == 1'b1)
        leftfirst_state_cnt <= leftfirst_cnt;
    else
        leftfirst_state_cnt <= leftfirst_state_cnt;

always@(posedge HCLK or negedge HRESETn)
    if(~HRESETn)
        rightfirst_state_cnt <= 17'd0;
    else if(rightfirst_end == 1'b1)
        rightfirst_state_cnt <= rightfirst_cnt;
    else
        rightfirst_state_cnt <= rightfirst_state_cnt;

//**************************************************************************
endmodule
