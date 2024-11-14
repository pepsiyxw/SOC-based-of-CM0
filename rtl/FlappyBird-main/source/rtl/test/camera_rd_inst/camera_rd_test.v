`timescale 1ns/1ns
module synchro_test();

parameter   H_SYNC  = 136,      // 行同步信号时间
            H_BACK  = 160,      // 行消隐后肩时间
            H_DISP  = 1024,     // 行数据有效时间
            H_FRONT = 24,       // 行消隐前肩时间
            H_TOTAL = 1344,     // 行扫描总时间
            V_SYNC  = 6,        // 列同步信号时间
            V_BACK  = 29,       // 列消隐后肩时间
            V_DISP  = 768,      // 列数据有效时间
            V_FRONT = 3,        // 列消隐前肩时间
            V_TOTAL = 806;      // 列扫描总时间

parameter   IMG_W   = 256,      //摄像头分辨率
            IMG_H   = 208,
            IMG_X   = 0,
            IMG_Y   = 0;

parameter   IMG_W2   = 800,      //摄像头分辨率
            IMG_H2   = 600,
            IMG_X2   = 112,
            IMG_Y2   = 84;

parameter   THB     =   296;
parameter   TVB     =   35;

reg     [11:0]  hcnt;
reg     [11:0]  vcnt;

reg     sys_clk;
reg     sys_rst_n;

always  #10 sys_clk <=  ~sys_clk;

reg     one_flag;
reg     two_flag;

initial
    begin
        sys_clk     =   1'b1;
        sys_rst_n   <=  1'b0;
        one_flag    <= 1'b0;
        two_flag    <= 1'b0;
        #100
        sys_rst_n   <=  1'b1;
        #300000000
        one_flag <= 1'b1;
        #20
        one_flag <= 1'b0;
        #300000000
        one_flag <= 1'b1;
        #20
        one_flag <= 1'b0;
        #300000000
        two_flag <= 1'b1;
        #20
        two_flag <= 1'b0;
        #300000000
        one_flag <= 1'b1;
        #20
        one_flag <= 1'b0;
        #200000000
        two_flag <= 1'b1;
        #20
        two_flag <= 1'b0;
        #200000000
        one_flag <= 1'b1;
        #20
        one_flag <= 1'b0;
    end

always @ (posedge sys_clk or negedge sys_rst_n)
    begin
        if (!sys_rst_n)
            hcnt <= 12'd0;
        else
        begin
            if(hcnt < H_TOTAL - 1'b1)
                hcnt <= hcnt + 1'b1;
            else
                hcnt <= 12'd0;
        end
    end 

always@(posedge sys_clk or negedge sys_rst_n)
    begin
        if (!sys_rst_n)
            vcnt <= 12'b0;
        else if(hcnt == H_TOTAL - 1'b1)
            begin
            if(vcnt == V_TOTAL - 1'b1)
                vcnt <= 12'd0;
            else
                vcnt <= vcnt + 1'b1;
            end
    end

wire    first_ack;
wire    second_ack;

assign first_ack = ((hcnt - (THB - 2'd1)) >= IMG_X && (hcnt - (THB - 2'd1)) < (IMG_X + IMG_W)) &&
                 ((vcnt - TVB) >= IMG_Y && (vcnt - TVB) < (IMG_Y + IMG_H)) ? 1'b1 : 1'b0;
                 
assign second_ack = ((hcnt - (THB - 2'd1)) >= IMG_X2 && (hcnt - (THB - 2'd1)) < (IMG_X2 + IMG_W2)) &&
                 ((vcnt - TVB) >= IMG_Y2 && (vcnt - TVB) < (IMG_Y2 + IMG_H2)) ? 1'b1 : 1'b0;

wire            sdram_rst_n;
wire            sdram_rden;
wire    [22:0]  sdram_rd_b_addr;
wire    [22:0]  sdram_rd_e_addr;

camera_rd_synchro camera_rd_synchro_inst
(
    .clk         (sys_clk),
    .rst_n       (sys_rst_n),

    .hcnt        (hcnt),
    .vcnt        (vcnt),
    .one_flag    (one_flag),
    .two_flag    (two_flag),
    .first_rden  (first_ack),
    .secon_rden  (second_ack),

    .sdram_rst_n (sdram_rst_n),
    .sdram_rden  (sdram_rden)
);

endmodule
