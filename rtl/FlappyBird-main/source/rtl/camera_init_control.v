module camera_init_control
(
    input   wire            clk,
    input   wire            rst_n,
    input   wire            two_flag,
    input   wire            one_flag,
    input   wire            go_first_custom_flag,
    input   wire            go_second_custom_flag,

    input   wire            camera_en,
    input   wire    [15:0]  camera_data,
    input   wire            sobel_en,
    input   wire    [15:0]  sobel_data,

    output  wire    [15:0]  sdram_wrdata,
    output  wire            sdram_wren,
    output  wire    [22:0]  sdram_max_addr,

    output  reg             camera_rstn,
    output  reg             custom
);

reg     one_state;
reg     two_state;

always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        one_state <= 1'b1;
    else if(two_flag == 1'b1 || go_second_custom_flag == 1'b1)
        one_state <= 1'b0;
    else if(one_flag == 1'b1 || go_first_custom_flag == 1'b1)
        one_state <= 1'b1;
    else
        one_state <= one_state;

always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        two_state <= 1'b0;
    else if(one_flag == 1'b1 || go_first_custom_flag == 1'b1)
        two_state <= 1'b0;
    else if(two_flag == 1'b1 || go_second_custom_flag == 1'b1)
        two_state <= 1'b1;
    else
        two_state <= two_state;

assign  sdram_wrdata = (one_state == 1'b1) ? camera_data : (two_state == 1'b1) ? sobel_data : 16'd0;
assign  sdram_wren = (one_state == 1'b1) ? camera_en : (two_state == 1'b1) ? sobel_en : 16'd0;
assign  sdram_max_addr = (one_state == 1'b1) ? 23'd53248 : (two_state == 1'b1) ? 23'd655360 : 23'd53248;


always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        camera_rstn <= 1'b1;
    else if(((one_flag == 1'b1 || one_flag_reg == 1'b1) && one_state != 1'b1) || ((two_flag == 1'b1 || two_flag_reg == 1'b1) && two_state != 1'b1) || 
                (go_first_custom_flag == 1'b1 || go_first_custom_flag_reg == 1'b1) || (go_second_custom_flag == 1'b1 || go_second_custom_flag_reg == 1'b1))
        camera_rstn <= 1'b0;
    else
        camera_rstn <= 1'b1;

reg     one_flag_reg;
reg     two_flag_reg;

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

reg     go_first_custom_flag_reg;
reg     go_second_custom_flag_reg;

always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        begin
            go_first_custom_flag_reg <= 1'b0;
            go_second_custom_flag_reg <= 1'b0;
        end
    else
        begin
            go_first_custom_flag_reg <= go_first_custom_flag;
            go_second_custom_flag_reg <= go_second_custom_flag;
        end

always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        custom <= 1'b1;
    else if(camera_rstn == 1'b0 && (one_flag_reg == 1'b1 || go_first_custom_flag_reg == 1'b1))
        custom <= 1'b1;
    else if(camera_rstn == 1'b0 && (two_flag_reg == 1'b1 || go_second_custom_flag_reg == 1'b1))
        custom <= 1'b0;
    else
        custom <= custom;

endmodule
