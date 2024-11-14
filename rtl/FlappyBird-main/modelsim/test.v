`timescale  1ns/1ns

module test();

reg     clk;
reg     rst_n;

wire    hsync;
wire    vsync;
wire    [15:0]  vga_rgb;

initial
    begin
        clk = 1'b1;
        rst_n <= 1'b0;
        #20
        rst_n <= 1'b1;
    end

always #10 clk = ~clk;

top top_inst
(
    .clk            (clk),
    .rst_n          (rst_n),
    .key2           (1'b0),
    .key3           (1'b0),
    .move_button    (1'b0),
    .pause_button   (1'b0),
    .continue_button(1'b0),

    .cam_pclk    (),
    .cam_xclk    (),
    .cam_href    (),
    .cam_vsync   (),
    .cam_pwdn    (),
    .cam_rst     (),
    .cam_soic    (),
    .cam_soid    (),
    .cam_data    (),

    .hsync  (hsync),
    .vsync  (vsync),
    .vga_rgb(vga_rgb)
);

endmodule