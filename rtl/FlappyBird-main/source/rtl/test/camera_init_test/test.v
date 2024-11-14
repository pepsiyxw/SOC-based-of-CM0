`timescale 1ns/1ns
module test();

reg     sys_clk;
reg     sys_clk2;
reg     sys_rst_n;

always  #10 sys_clk <=  ~sys_clk;
always  #10 sys_clk2 <=  ~sys_clk2;

reg     one_flag;
reg     two_flag;

initial
    begin
        sys_clk     =   1'b1;
        sys_clk2    = 1'b0;
        sys_rst_n   <=  1'b0;
        one_flag    <= 1'b0;
        two_flag    <= 1'b0;
        #19
        sys_clk2    <= 1'b1;
        #100
        sys_rst_n   <=  1'b1;
        #10000
        two_flag <= 1'b1;
        #20
        two_flag <= 1'b0;
        #10000
        one_flag <= 1'b1;
        #20
        one_flag <= 1'b0;
        #10000
        one_flag <= 1'b1;
        #20
        one_flag <= 1'b0;
        #10000
        two_flag <= 1'b1;
        #20
        two_flag <= 1'b0;
    end

wire            camera_rstn;
wire    [15:0]  x_lenth    ;
wire    [15:0]  y_lenth    ;

camera_init_control camera_init_control_inst
(
    .clk         (sys_clk2),
    .rst_n       (sys_rst_n),
    .two_flag    (two_flag),
    .one_flag    (one_flag),

    .camera_rstn (camera_rstn),
    .x_lenth     (x_lenth),
    .y_lenth     (y_lenth)
);

endmodule
