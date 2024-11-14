module vip(
    input   wire    [10:0]  sobel,

    input   wire            clk,
    input   wire            rst_n,

    //图像处理前的数据接口
    input   wire            pre_frame_vsync,
    input   wire            pre_frame_hsync,
    input   wire            pre_frame_de,
    input   wire    [15:0]  pre_rgb,

    //经过颜色识别处理的二值化图象
    output  wire    [15:0]  color_binary,
    output  wire            color_binary_clken,

    //输出的sobel边缘检测图象
    output  wire            post0_frame_clken,
    output  wire            post0_img_Bit,

    //腐蚀后的图象
    output  wire            post1_frame_clken,
    output  wire            post1_img_Bit,

    //膨胀后的图象
    output  wire            post_frame_vsync,
    output  wire            post_frame_hsync,
    output  wire            post_frame_clken,
    output  wire            post_img_Bit
);

//wire define
wire                    pe_frame_vsync;
wire                    pe_frame_href;
wire                    pe_frame_clken;
wire    [7:0]           img_y;
wire    [7:0]           img_cb;
wire    [7:0]           img_cr;

wire                    post0_frame_vsync;
wire                    post0_frame_hsync;

wire                    post1_frame_vsync;
wire                    post1_frame_hsync;

//*****************************************************
//**                    main code
//*****************************************************
VIP_RGB888_YCbCr444 VIP_RGB888_YCbCr444_inst
(
    .clk                    (clk),
    .rst_n                  (rst_n),

    .per_frame_vsync        (pre_frame_vsync),
    .per_frame_href         (pre_frame_hsync),
    .per_frame_clken        (pre_frame_de),
    .per_img_red            ({pre_rgb[15:11],pre_rgb[15:13]}),
    .per_img_green          ({pre_rgb[10:5],pre_rgb[10:9]}),
    .per_img_blue           ({pre_rgb[4:0],pre_rgb[4:2]}),

    .post_frame_vsync       (pe_frame_vsync),
    .post_frame_href        (pe_frame_href),
    .post_frame_clken       (pe_frame_clken),
    .post_img_Y             (img_y),
    .post_img_Cb            (img_cb),
    .post_img_Cr            (img_cr)
);

wire    [23:0]  post_img_YCbCr;
assign  post_img_YCbCr = {img_y,img_cb,img_cr};

threshold_binary
#(
    .DW         (24),
    .Y_TH       (93),
    .Y_TL       (00),
    .CB_TH      (160),
    .CB_TL      (50),
    .CR_TH      (160),
    .CR_TL      (50)
)
u_threshold_binary
(
    .pixelclk     (clk                      ),
    .reset_n      (rst_n                    ),
    .i_ycbcr      (post_img_YCbCr           ),
    .i_hsync      (pe_frame_vsync           ),
    .i_vsync      (pe_frame_href            ),
    .i_de         (pe_frame_clken           ),

    .o_binary     (color_binary             ),
    .o_hsync      (),
    .o_vsync      (),
    .o_de         (color_binary_clken       )
);

wire    [10:0]   sobel;

vip_sobel_edge_detector u_vip_sobel_edge_detector
(
    .sobel                  (sobel),

    .clk                    (clk),
    .rst_n                  (rst_n),

    //处理前数据
    .per_frame_vsync        (pe_frame_vsync),
    .per_frame_href         (pe_frame_href),
    .per_frame_clken        (pe_frame_clken),
    .per_img_y              (img_y),

    //处理后的数据
    .post_frame_vsync       (post0_frame_vsync),
    .post_frame_href        (post0_frame_hsync),
    .post_frame_clken       (post0_frame_clken),
    .post_img_bit           (post0_img_Bit)
);

VIP_Bit_Erosion_Detector u_VIP_Bit_Erosion_Detector
(
    .clk                    (clk),
    .rst_n                  (rst_n),

    //Image data prepred to be processd
    .per_frame_vsync        (post0_frame_vsync),
    .per_frame_href         (post0_frame_hsync),
    .per_frame_clken        (post0_frame_clken),
    .per_img_Bit            (post0_img_Bit),

    //Image data has been processd
    .post_frame_vsync       (post1_frame_vsync),
    .post_frame_href        (post1_frame_hsync),
    .post_frame_clken       (post1_frame_clken),
    .post_img_Bit           (post1_img_Bit)
);

VIP_Bit_Dilation_Detector u_VIP_Bit_Dilation_Detector
(
    .clk                    (clk),
    .rst_n                  (rst_n),

    //Image data prepred to be processd
    .per_frame_vsync        (post1_frame_vsync),
    .per_frame_href         (post1_frame_hsync),
    .per_frame_clken        (post1_frame_clken),
    .per_img_Bit            (post1_img_Bit),

    //Image data has been processd
    .post_frame_vsync       (post_frame_vsync),
    .post_frame_href        (post_frame_hsync),
    .post_frame_clken       (post_frame_clken),
    .post_img_Bit           (post_img_Bit)
);

endmodule
