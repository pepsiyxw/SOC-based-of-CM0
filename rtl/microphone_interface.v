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

    input   wire            microphone_left,
    input   wire            microphone_right,
    input   wire            microphone_up,
    input   wire            microphone_down
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

reg [2:0]   addr_reg;
always@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        addr_reg <= 3'b0;
    else if(HSEL & HREADY & HTRANS[1])
        addr_reg <= HADDR[4:2];
end

parameter   UPFIRST     = 2'b01;
parameter   DOWNFIRST   = 2'b10;
parameter   LEFTFIRST   = 2'b01;
parameter   RIGHTFIRST  = 2'b10;

reg     [16:0]  leftfirst_state_cnt;    // 0
reg     [16:0]  rightfirst_state_cnt;   // 1
reg     [16:0]  upfirst_state_cnt;      // 2
reg     [16:0]  downfirst_state_cnt;    // 3
reg     [1:0]   up_down_state;          // 4
reg     [1:0]   left_right_state;       // 5

assign HRDATA = (addr_reg == 3'd5) ? {30'd0,left_right_state} : (addr_reg == 3'd4) ? {30'd0,up_down_state} : (addr_reg == 3'd3) ? {15'd0,downfirst_state_cnt} : (addr_reg == 3'd2) ? {15'd0,upfirst_state_cnt} : (addr_reg == 3'd1) ? {15'd0,rightfirst_state_cnt} : (addr_reg == 3'd0) ? {15'd0,leftfirst_state_cnt} : 32'd0;

    //500ms定时器，触发一次需要500ms以后才能再次触发
//**************************************************************************
parameter   cnt_100ms = 4000000;

reg     [21:0]  cnt_left_right;
reg             cnt_begin_left_right;

always@(posedge HCLK or negedge HRESETn)
    if(~HRESETn)
        cnt_left_right <= 25'd0;
    else if(cnt_begin_left_right == 1'b1)
        cnt_left_right <= cnt_left_right + 1'b1;
    else
        cnt_left_right <= 25'd0;

always@(posedge HCLK or negedge HRESETn)
    if(~HRESETn)
        cnt_begin_left_right <= 1'b0;
    else if(cnt_left_right == cnt_100ms - 2'd2)
        cnt_begin_left_right <= 1'b0;
    else if((microphone_left_flag == 1'b0 && cnt_begin_left_right == 1'b0) || (microphone_right_flag == 1'b0 && cnt_begin_left_right == 1'b0))
        cnt_begin_left_right <= 1'b1;
    else
        cnt_begin_left_right <= cnt_begin_left_right;

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

wire        microphone_left_flag;
wire        microphone_right_flag;

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
    else if(microphone_right_flag == 1'b0 && cnt_begin_left_right == 1'b1)
        leftfirst_state <= 1'b0;
    else if(microphone_left_flag == 1'b0 && cnt_begin_left_right == 1'b0)
        leftfirst_state <= 1'b1;
    else if(cnt_begin_left_right == 1'b0)
        leftfirst_state <= 1'b0;
    else
        leftfirst_state <= leftfirst_state;

always@(posedge HCLK or negedge HRESETn)
    if(~HRESETn)
        rightfirst_state <= 1'b0;
    else if(microphone_left_flag == 1'b0 && cnt_begin_left_right == 1'b1)
        rightfirst_state <= 1'b0;
    else if(microphone_right_flag == 1'b0 && cnt_begin_left_right == 1'b0)
        rightfirst_state <= 1'b1;
    else if(cnt_begin_left_right == 1'b0)
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
    else if(microphone_left_flag == 1'b0 && cnt_begin_left_right == 1'b0)
        leftfirst_cnt <= 17'd0;
    else if(leftfirst_state == 1'b1)
        leftfirst_cnt <= leftfirst_cnt + 1'b1;
    else
        leftfirst_cnt <= leftfirst_cnt;

always@(posedge HCLK or negedge HRESETn)
    if(~HRESETn)
        rightfirst_cnt <= 17'd0;
    else if(microphone_right_flag == 1'b0 && cnt_begin_left_right == 1'b0)
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
    else if(microphone_right_flag == 1'b0 && cnt_begin_left_right == 1'b1 && leftfirst_state == 1'b1)
        leftfirst_end <= 1'b1;
    else
        leftfirst_end <= 1'b0;

always@(posedge HCLK or negedge HRESETn)
    if(~HRESETn)
        rightfirst_end <= 1'b0;
    else if(microphone_left_flag == 1'b0 && cnt_begin_left_right == 1'b1 && rightfirst_state == 1'b1)
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

    //500ms定时器，触发一次需要500ms以后才能再次触发
//**************************************************************************
reg     [21:0]  cnt_up_down;
reg             cnt_begin_up_down;

always@(posedge HCLK or negedge HRESETn)
    if(~HRESETn)
        cnt_up_down <= 25'd0;
    else if(cnt_begin_up_down == 1'b1)
        cnt_up_down <= cnt_up_down + 1'b1;
    else
        cnt_up_down <= 25'd0;

always@(posedge HCLK or negedge HRESETn)
    if(~HRESETn)
        cnt_begin_up_down <= 1'b0;
    else if(cnt_up_down == cnt_100ms - 2'd2)
        cnt_begin_up_down <= 1'b0;
    else if((microphone_up_flag == 1'b0 && cnt_begin_up_down == 1'b0) || (microphone_down_flag == 1'b0 && cnt_begin_up_down == 1'b0))
        cnt_begin_up_down <= 1'b1;
    else
        cnt_begin_up_down <= cnt_begin_up_down;

//**************************************************************************


    //左右麦克风触发的脉冲信号
//**************************************************************************
reg     microphone_up_reg;
reg     microphone_down_reg;
reg     microphone_up_reg_reg;
reg     microphone_down_reg_reg;

always@(posedge HCLK or negedge HRESETn)
    if(~HRESETn)
        begin
            microphone_up_reg <= 1'b0;
            microphone_down_reg <= 1'b0;
        end
    else
        begin
            microphone_up_reg <= microphone_up;
            microphone_down_reg <= microphone_down;
        end

always@(posedge HCLK or negedge HRESETn)
    if(~HRESETn)
        begin
            microphone_up_reg_reg <= 1'b0;
            microphone_down_reg_reg <= 1'b0;
        end
    else
        begin
            microphone_up_reg_reg <= microphone_up_reg;
            microphone_down_reg_reg <= microphone_down_reg;
        end

wire        microphone_up_flag;
wire        microphone_down_flag;

    //低电平脉冲信号
assign microphone_up_flag = microphone_up_reg | ~microphone_up_reg_reg;
assign microphone_down_flag = microphone_down_reg | ~microphone_down_reg_reg;
//**************************************************************************

    //左右麦克风先后触发进入不同的状态
//**************************************************************************
reg     upfirst_state;
reg     downfirst_state;

always@(posedge HCLK or negedge HRESETn)
    if(~HRESETn)
        upfirst_state <= 1'b0;
    else if(microphone_down_flag == 1'b0 && cnt_begin_up_down == 1'b1)
        upfirst_state <= 1'b0;
    else if(microphone_up_flag == 1'b0 && cnt_begin_up_down == 1'b0)
        upfirst_state <= 1'b1;
    else if(cnt_begin_up_down == 1'b0)
        upfirst_state <= 1'b0;
    else
        upfirst_state <= upfirst_state;

always@(posedge HCLK or negedge HRESETn)
    if(~HRESETn)
        downfirst_state <= 1'b0;
    else if(microphone_up_flag == 1'b0 && cnt_begin_up_down == 1'b1)
        downfirst_state <= 1'b0;
    else if(microphone_down_flag == 1'b0 && cnt_begin_up_down == 1'b0)
        downfirst_state <= 1'b1;
    else if(cnt_begin_up_down == 1'b0)
        downfirst_state <= 1'b0;
    else
        downfirst_state <= downfirst_state;

//**************************************************************************

//两种状态下计时器的计数值
//**************************************************************************
reg     [16:0]  upfirst_cnt;
reg     [16:0]  downfirst_cnt;

always@(posedge HCLK or negedge HRESETn)
    if(~HRESETn)
        upfirst_cnt <= 17'd0;
    else if(microphone_up_flag == 1'b0 && cnt_begin_up_down == 1'b0)
        upfirst_cnt <= 17'd0;
    else if(upfirst_state == 1'b1)
        upfirst_cnt <= upfirst_cnt + 1'b1;
    else
        upfirst_cnt <= upfirst_cnt;

always@(posedge HCLK or negedge HRESETn)
    if(~HRESETn)
        downfirst_cnt <= 17'd0;
    else if(microphone_down_flag == 1'b0 && cnt_begin_up_down == 1'b0)
        downfirst_cnt <= 17'd0;
    else if(downfirst_state == 1'b1)
        downfirst_cnt <= downfirst_cnt + 1'b1;
    else
        downfirst_cnt <= downfirst_cnt;

//两种状态计数器计时结束标志信号
//**************************************************************************
reg         upfirst_end;
reg         downfirst_end;

always@(posedge HCLK or negedge HRESETn)
    if(~HRESETn)
        upfirst_end <= 1'b0;
    else if(microphone_down_flag == 1'b0 && cnt_begin_up_down == 1'b1 && upfirst_state == 1'b1)
        upfirst_end <= 1'b1;
    else
        upfirst_end <= 1'b0;

always@(posedge HCLK or negedge HRESETn)
    if(~HRESETn)
        downfirst_end <= 1'b0;
    else if(microphone_up_flag == 1'b0 && cnt_begin_up_down == 1'b1 && downfirst_state == 1'b1)
        downfirst_end <= 1'b1;
    else
        downfirst_end <= 1'b0;

//**************************************************************************
always@(posedge HCLK or negedge HRESETn)
    if(~HRESETn)
        upfirst_state_cnt <= 17'd0;
    else if(upfirst_end == 1'b1)
        upfirst_state_cnt <= upfirst_cnt;
    else
        upfirst_state_cnt <= upfirst_state_cnt;

always@(posedge HCLK or negedge HRESETn)
    if(~HRESETn)
        downfirst_state_cnt <= 17'd0;
    else if(downfirst_end == 1'b1)
        downfirst_state_cnt <= downfirst_cnt;
    else
        downfirst_state_cnt <= downfirst_state_cnt;

//**************************************************************************

//两种状态分别表示上下麦克风先后收到声音信号的状态，和左右麦克风先后收到声音信号的状态
always@(posedge HCLK or negedge HRESETn)
    if(~HRESETn)
        up_down_state <= UPFIRST;
    else if(upfirst_end == 1'b1)
        up_down_state <= UPFIRST;
    else if(downfirst_end == 1'b1)
        up_down_state <= DOWNFIRST;
    else
        up_down_state <= up_down_state;

always@(posedge HCLK or negedge HRESETn)
    if(~HRESETn)
        left_right_state <= LEFTFIRST;
    else if(leftfirst_end == 1'b1)
        left_right_state <= LEFTFIRST;
    else if(rightfirst_end == 1'b1)
        left_right_state <= RIGHTFIRST;
    else
        left_right_state <= left_right_state;

endmodule
