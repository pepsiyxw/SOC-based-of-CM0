module camera_init_control
(
    input   wire            clk,
    input   wire            rst_n,
    input   wire            two_flag,
    input   wire            one_flag,

    input   wire            camera_en,
    input   wire    [15:0]  camera_data,
    input   wire            sobel_en,
    input   wire    [15:0]  sobel_data,

    output  wire    [15:0]  sdram_wrdata,
    output  wire            sdram_wren,
    output  wire    [10:0]  h_pixel,
    output  wire    [10:0]  v_pixel,

    output  reg             camera_rstn,
    output  reg     [15:0]  x_lenth,
    output  reg     [15:0]  y_lenth
);

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

assign  sdram_wrdata = (one_state == 1'b1) ? camera_data : (two_state == 1'b1) ? sobel_data : 16'd0;
assign  sdram_wren = (one_state == 1'b1) ? camera_en : (two_state == 1'b1) ? sobel_en : 16'd0;
assign  h_pixel = (one_state == 1'b1) ? 11'd256 : (two_state == 1'b1) ? 11'd800 : 11'd256;
assign  v_pixel = (one_state == 1'b1) ? 11'd208 : (two_state == 1'b1) ? 11'd600 : 11'd208;

reg     one_flag_reg;
reg     two_flag_reg;

always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        camera_rstn <= 1'b1;
    else if(((one_flag == 1'b1 || one_flag_reg == 1'b1) && one_state != 1'b1) || ((two_flag == 1'b1 || two_flag_reg == 1'b1) && two_state != 1'b1))
        camera_rstn <= 1'b0;
    else
        camera_rstn <= 1'b1;

always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        begin
            one_flag_reg <= 1'b0;
            two_flag_reg <= 1'b0;
        end
    else
        begin
            one_flag_reg <= one_flag;
            two_flag_reg <= two_flag;
        end

always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        begin
            x_lenth <= 16'h5a_40;
            y_lenth <= 16'h5b_34;
        end
    else if(camera_rstn == 1'b0 && one_flag_reg == 1'b1)
        begin
            x_lenth <= 16'h5a_40;
            y_lenth <= 16'h5b_34;
        end
    else if(camera_rstn == 1'b0 && two_flag_reg == 1'b1)
        begin
            x_lenth <= 16'h5a_C8;
            y_lenth <= 16'h5b_96;
        end
    else
        begin
            x_lenth <= x_lenth;
            y_lenth <= y_lenth;
        end

endmodule
