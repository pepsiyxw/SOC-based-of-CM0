module top
(
    input   wire            sys_clk,
    input   wire            rst_n,
    input   wire            start_button,
    input   wire            restart_button,
    input   wire            move_button,
    input   wire            pause_button,
    input   wire            continue_button,
    input   wire            method_button,

    input   wire    [1:0]   gamemode        ,

    input   wire            bird1up         ,
    input   wire            bird1down       ,
    input   wire            bird1left       ,
    input   wire            bird1right      ,

    input   wire            bird2up         ,
    input   wire            bird2down       ,
    input   wire            bird2left       ,
    input   wire            bird2right      ,

    //摄像头 
    input   wire            cam_pclk        ,  //cmos 数据像素时钟
    input   wire            cam_vsync       ,  //cmos 场同步信号
    input   wire            cam_href        ,  //cmos 行同步信号
    input   wire    [7:0]   cam_data        ,  //cmos 数据  
    output  wire            cam_rst_n       ,  //cmos 复位信号，低电平有效
    output  wire            cam_pwdn        ,  //cmos 电源休眠模式选择信号
    output  wire            cam_scl         ,  //cmos SCCB_SCL线
    inout   wire            cam_sda         ,  //cmos SCCB_SDA线

    //sd卡接口
    input   wire            sd_miso,      //SD卡SPI串行输入数据信号
    output  wire            sd_clk ,      //SD卡SPI时钟信号
    output  wire            sd_cs  ,      //SD卡SPI片选信号
    output  wire            sd_mosi,      //SD卡SPI串行输出数据信号 

    //SDRAM接口
    output  wire            sdram_clk  ,  //SDRAM 时钟
    output  wire            sdram_cke  ,  //SDRAM 时钟有效
    output  wire            sdram_cs_n ,  //SDRAM 片选
    output  wire            sdram_ras_n,  //SDRAM 行有效
    output  wire            sdram_cas_n,  //SDRAM 列有效
    output  wire            sdram_we_n ,  //SDRAM 写有效
    output  wire    [1:0]   sdram_ba   ,  //SDRAM Bank地址
    output  wire    [1:0]   sdram_dqm  ,  //SDRAM 数据掩码
    output  wire    [11:0]  sdram_addr ,  //SDRAM 地址
    inout   wire    [15:0]  sdram_data ,  //SDRAM 数据

    //hdmi接口
    output  wire            tmds_clk_p ,  // TMDS 时钟通道
    output  wire            tmds_clk_n ,
    output  wire    [2:0]   tmds_data_p,  // TMDS 数据通道
    output  wire    [2:0]   tmds_data_n,

    output  wire            speaker
);

wire    Lock;
wire    clk;

test_pll test_pll_inst
(
    .refclk     (sys_clk),
    .reset      (~rst_n),
    .extlock    (Lock),
    .clk0_out   (clk)
);

AngryBird_Demo AngryBird_Demo_inst
( 

    .clk            (clk                ),
    .rst_n          (rst_n              ),
    .start_button   (start_button       ),
    .restart_button (restart_button     ),
    .move_button    (move_button        ),
    .pause_button   (/* pause_button */1'b0),
    .continue_button(/* continue_button */1'b0),
    .method_button  (/* method_button */1'b0),

    .gamemode       (/* gamemode */2'd0),
    .sobel          (11'd40             ),

    .angle          (4'd6               ),

    .bird1up        (bird1up            ),
    .bird1down      (bird1down          ),
    .bird1left      (/* bird1left */1'b0),
    .bird1right     (bird1right         ),

    .bird2up        (bird2up            ),
    .bird2down      (bird2down          ),
    .bird2left      (bird2left          ),
    .bird2right     (bird2right         ),

    //摄像头 
    .cam_pclk       (cam_pclk           ),  //cmos 数据像素时钟
    .cam_vsync      (cam_vsync          ),  //cmos 场同步信号
    .cam_href       (cam_href           ),  //cmos 行同步信号
    .cam_data       (cam_data           ),  //cmos 数据  
    .cam_rst_n      (cam_rst_n          ),  //cmos 复位信号，低电平有效
    .cam_pwdn       (cam_pwdn           ),  //cmos 电源休眠模式选择信号
    .cam_scl        (cam_scl            ),  //cmos SCCB_SCL线
    .cam_sda        (cam_sda            ),  //cmos SCCB_SDA线

    .sd_miso        (sd_miso            ),
    .sd_clk         (sd_clk             ),
    .sd_cs          (sd_cs              ),
    .sd_mosi        (sd_mosi            ),

    .sdram_clk      (sdram_clk          ),
    .sdram_cke      (sdram_cke          ),
    .sdram_cs_n     (sdram_cs_n         ),
    .sdram_ras_n    (sdram_ras_n        ),
    .sdram_cas_n    (sdram_cas_n        ),
    .sdram_we_n     (sdram_we_n         ),
    .sdram_ba       (sdram_ba           ),
    .sdram_dqm      (sdram_dqm          ),
    .sdram_addr     (sdram_addr         ),
    .sdram_data     (sdram_data         ),

    .tmds_clk_p     (tmds_clk_p         ),
    .tmds_clk_n     (tmds_clk_n         ),
    .tmds_data_p    (tmds_data_p        ),
    .tmds_data_n    (tmds_data_n        )

/*     .sel            (sel                ),
    .seg            (seg                ) */
);

endmodule
