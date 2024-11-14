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

reg     [11:0]  hcnt;
reg     [11:0]  vcnt;

reg     sys_clk;
reg     sys_rst_n;

always  #10 sys_clk <=  ~sys_clk;

reg [3:0]   state;

initial
    begin
        sys_clk     =   1'b1;
        sys_rst_n   <=  1'b0;
        state <= 4'b0001;
        #100
        sys_rst_n   <=  1'b1;
        #10000
        state <= 4'b0010;
        #10000
        state <= 4'b0001;
        #10000
        state <= 4'b0010;
        #30000000
        state <= 4'b0001;
    end

always @ (posedge sys_clk or negedge sys_rst_n)
begin
    if (!sys_rst_n)
        hcnt <= 12'd0;
    else
    begin
        if(hcnt < H_TOTAL - 1'b1)   //line over
            hcnt <= hcnt + 1'b1;
        else
            hcnt <= 12'd0;
    end
end 

always@(posedge sys_clk or negedge sys_rst_n)
begin
    if (!sys_rst_n)
        vcnt <= 12'b0;
    else if(hcnt == H_TOTAL - 1'b1)	//line over
        begin
        if(vcnt == V_TOTAL - 1'b1)		//frame over
            vcnt <= 12'd0;
        else
            vcnt <= vcnt + 1'b1;
        end
end

wire    all_photo_en;

assign  all_photo_en = (hcnt >= H_SYNC + H_BACK - 1 && hcnt < H_SYNC + H_BACK + H_DISP - 1) &&
                        (vcnt >= V_SYNC + V_BACK && vcnt < V_SYNC + V_BACK + V_DISP) 
                        ? 1'b1 : 1'b0;

wire            sdram_rst_n    ;
wire            sdram_rden     ;
wire    [22:0]  sdram_rd_b_addr;
wire    [22:0]  sdram_rd_e_addr;

rd_synchro rd_synchro_inst
(
    .hdmi_clk           (sys_clk),
    .sys_rst_n          (sys_rst_n),

    .hcnt               (hcnt),
    .vcnt               (vcnt),
    .state              (state),
    .all_photo_en       (all_photo_en),

    .sdram_rst_n        (sdram_rst_n    ),
    .sdram_rden         (sdram_rden     ),
    .sdram_rd_b_addr    (sdram_rd_b_addr),
    .sdram_rd_e_addr    (sdram_rd_e_addr)
);


endmodule
