module AngryBird_Demo(
//游戏内容接口
    input   wire            sys_rst_n           ,
    input   wire            third_move_button   ,
    input   wire            pause_button        ,
    input   wire            continue_button     ,
    input   wire            start_button        ,
    input   wire            restart_button      ,
    input   wire            method_button       ,
    input   wire            cancle_button       ,

    input   wire            first_custom_button ,
    input   wire            second_custom_button,
    input   wire            third_custom_button ,
    input   wire            exit_game_button    ,

    input   wire            clk_50m             ,
    input   wire            clk_100m            ,
    input   wire            clk_100m_shift      ,
    input   wire            sd_card_clk         ,
    input   wire            sd_card_clk_n       ,

    input   wire            hdmi_clk            ,
    input   wire            hdmi_5clk           ,

    input   wire            bird1up             ,
    input   wire            bird1down           ,
    input   wire            bird1left           ,
    input   wire            bird1right          ,

    input   wire            bird2up             ,
    input   wire            bird2down           ,
    input   wire            bird2left           ,
    input   wire            bird2right          ,

    input   wire    [1:0]   gamemode            ,
    input   wire    [1:0]   pausemode           ,
    input   wire            custom1_gun_enable  ,
    input   wire    [3:0]   angle               ,
    input   wire            bird1_speed         ,
    input   wire            bird2_speed         ,

    input   wire    [10:0]  sobel               ,

    output  wire    [6:0]   state_number        ,
    output  wire    [7:0]   score               ,
    output  wire    [7:0]   custom3_score       ,
    
    output  wire            photo_wr_done       ,

    output  wire            SG90_en             ,

    //摄像头 
    input   wire            cam_pclk            ,  //cmos 数据像素时钟
    input   wire            cam_vsync           ,  //cmos 场同步信号
    input   wire            cam_href            ,  //cmos 行同步信号
    input   wire    [7:0]   cam_data            ,  //cmos 数据  
    output  wire            cam_rst_n           ,  //cmos 复位信号，低电平有效
    output  wire            cam_pwdn            ,  //cmos 电源休眠模式选择信号
    output  wire            cam_scl             ,  //cmos SCCB_SCL线
    inout   wire            cam_sda             ,  //cmos SCCB_SDA线

    //sd卡接口
    input   wire            sd_miso             ,      //SD卡SPI串行输入数据信号
    output  wire            sd_clk              ,      //SD卡SPI时钟信号
    output  wire            sd_cs               ,      //SD卡SPI片选信号
    output  wire            sd_mosi             ,      //SD卡SPI串行输出数据信号 

    //hdmi接口
    output  wire            tmds_clk_p          ,  // TMDS 时钟通道
    output  wire            tmds_clk_n          ,
    output  wire    [2:0]   tmds_data_p         ,  // TMDS 数据通道
    output  wire    [2:0]   tmds_data_n         ,

    //SDRAM接口
    output  wire            sdram_clk           ,  //SDRAM 时钟
    output  wire            sdram_cke           ,  //SDRAM 时钟有效
    output  wire            sdram_cs_n          ,  //SDRAM 片选
    output  wire            sdram_ras_n         ,  //SDRAM 行有效
    output  wire            sdram_cas_n         ,  //SDRAM 列有效
    output  wire            sdram_we_n          ,  //SDRAM 写有效
    output  wire    [1:0]   sdram_ba            ,  //SDRAM Bank地址
    output  wire    [1:0]   sdram_dqm           ,  //SDRAM 数据掩码
    output  wire    [11:0]  sdram_addr          ,  //SDRAM 地址
    inout   wire    [15:0]  sdram_data          ,  //SDRAM 数据

    //通信端口
    output  wire            first_camera_clk    ,
    output  wire            first_rden          ,
    input   wire            first_camera_bit    
);

//游戏界面
parameter   start_scene       = 7'b0000001;
parameter   custom1_scene     = 7'b0000010;
parameter   custom2_scene     = 7'b0000100;
parameter   custom3_scene     = 7'b0001000;
parameter   pause_scene       = 7'b0010000;
parameter   gameover_scene    = 7'b0100000;
parameter   method_scene      = 7'b1000000;
parameter   win_scene         = 7'b1111111;

wire            allbird_dead;

wire            camera_wrreq;
wire            camera_wclk;
wire    [15:0]  camera_wrdat;
wire    [19:0]  camera_addr;

assign  first_camera_clk = hdmi_clk;
assign  fourth_clk = hdmi_clk;

/* wire            first_rden; */
wire            second_rden;
wire            all_photo_en;
wire    [11:0]  hcnt;
wire    [11:0]  vcnt;
wire    [10:0]  lcd_xpos;
wire    [10:0]  lcd_ypos;
wire    [23:0]  lcd_data;

//VGA driver timing
hdmi_top u_hdmi_top
(
    .hdmi_clk       (hdmi_clk                   ),
    .hdmi_5clk      (hdmi_5clk                  ),
    .sys_rst_n      (sys_rst_n & photo_wr_done  ),
    //用户接口
    .lcd_data       (lcd_data                   ),
    .second_rden    (second_rden                ),
    .first_rden     (first_rden                 ),
    .lcd_xpos       (lcd_xpos                   ),     //像素点横坐标
    .lcd_ypos       (lcd_ypos                   ),     //像素点纵坐标
    .hcnt           (hcnt                       ),
    .vcnt           (vcnt                       ),
    .all_ack        (all_photo_en               ),
    //HDMI接口
    .tmds_clk_p     (tmds_clk_p                 ),   //TMDS 时钟通道
    .tmds_clk_n     (tmds_clk_n                 ),
    .tmds_data_p    (tmds_data_p                ),  //TMDS 数据通道
    .tmds_data_n    (tmds_data_n                )
);

parameter  SDRAM_MAX_ADDR = 23'd786432;//1024*768
parameter  SD_SEC_NUM = 4609;

wire            sd_rd_start_en  ;  //开始写SD卡数据信号
wire    [31:0]  sd_rd_sec_addr  ;  //读数据扇区地址
wire            sd_rd_busy      ;  //读忙信号
wire            sd_rd_val_en    ;  //数据读取有效使能信号
wire    [15:0]  sd_rd_val_data  ;  //读数据
wire            sd_init_done    ;  //SD卡初始化完成信号
wire            sdram_wr_en     ;  //SDRAM控制器模块写使能
wire    [15:0]  sdram_wr_data   ;  //SDRAM控制器模块写数据
wire            sys_init_done   ;  //系统初始化完成

assign  sys_init_done = sd_init_done & sdram_init_done;

//写完一张图片拉高一次
/* wire    photo_wr_done; */

sd_read_photo u_sd_read_photo
(
    .clk                (sd_card_clk),

    //系统初始化完成之后,再开始从SD卡中读取图片
    .rst_n              (sys_rst_n & sd_init_done),
    .sdram_max_addr     (SDRAM_MAX_ADDR),
    .sd_sec_num         (SD_SEC_NUM), 
    .rd_busy            (sd_rd_busy),
    .sd_rd_val_en       (sd_rd_val_en),
    .sd_rd_val_data     (sd_rd_val_data),
    .rd_start_en        (sd_rd_start_en),
    .rd_sec_addr        (sd_rd_sec_addr),


    .photo_wr_done      (photo_wr_done),

    .sdram_wr_en        (sdram_wr_en),
    .sdram_wr_data      (sdram_wr_data)
);

wire    wr_busy;
wire    wr_req;

//SD卡顶层控制模块
sd_ctrl u_sd_ctrl
(
    .sys_clk            (sd_card_clk),
    .sys_clk_shift      (sd_card_clk_n),
    .sys_rst_n          (sys_rst_n),
    //SD卡接口
    .sd_miso            (sd_miso),
    .sd_clk             (sd_clk),
    .sd_cs_n            (sd_cs),
    .sd_mosi            (sd_mosi),
    //用户写SD卡接口
    .wr_en              (1'b0),        //不需要写入数据,写入接口赋值为0
    .wr_addr            (32'b0),
    .wr_data            (16'b0),
    .wr_busy            (),
    .wr_req             (),
    //用户读SD卡接口
    .rd_en              (sd_rd_start_en),
    .rd_addr            (sd_rd_sec_addr),
    .rd_busy            (sd_rd_busy),
    .rd_data_en         (sd_rd_val_en),
    .rd_data            (sd_rd_val_data),

    .init_end           (sd_init_done)
);

wire            sdram_init_done;  //SDRAM初始化完成
wire    [15:0]  sd_card_photo;

assign  sdram_dqm = 2'b0;

wire    sdram_wr_rst;
wire    sdram_rd_rst;
wire    sdram_all_rst_n;
assign  sdram_wr_rst = ~sys_rst_n | photo_wr_done;
assign  sdram_rd_rst = ~sys_rst_n | ~sdram_rst_n;
assign  sdram_all_rst_n = sys_rst_n & sdram_rst_n;

//SDRAM 控制器顶层模块,封装成FIFO接口
//SDRAM 控制器地址组成: {bank_addr[1:0],row_addr[12:0],col_addr[8:0]}
etr_sdram_top u_sdram_top
(
    .sys_clk                (clk_100m),             // sdram 控制器参考时钟
    .clk_out                (clk_100m_shift),       // 用于输出的相位偏移时钟
    .sys_rst_n              (sdram_all_rst_n),      // 系统复位，低电平有效

    //用户写端口
    .wr_fifo_wr_clk         (sd_card_clk),          // 写端口FIFO: 写时钟
    .wr_fifo_wr_req         (sdram_wr_en),          // 写端口FIFO: 写使能
    .wr_fifo_wr_data        (sdram_wr_data),        // 写端口FIFO: 写数据
    .sdram_wr_b_addr        (23'd0),                // 写SDRAM的起始地址
    .sdram_wr_e_addr        (23'd6291456),          // 写SDRAM的结束地址
    .wr_burst_len           (10'd512),              // 写SDRAM时的数据突发长度
    .wr_rst                 (sdram_wr_rst),         // 写端口复位: 复位写地址,清空写FIFO
    //所有图片写入sdram完成，拉高sdram写端口复位，锁定端口

    //用户读端口
    .rd_fifo_rd_clk         (hdmi_clk),             // 读端口FIFO: 读时钟
    .rd_fifo_rd_req         (sdram_rden),           // 读端口FIFO: 读使能
    .sdram_rd_b_addr        (sdram_rd_b_addr),      // 读SDRAM的起始地址
    .sdram_rd_e_addr        (sdram_rd_e_addr),      // 读SDRAM的结束地址
    .rd_burst_len           (10'd512),              // 从SDRAM中读数据时的突发长度
    .rd_rst                 (sdram_rd_rst),         // 读端口复位: 复位读地址,清空读FIFO
    .rd_fifo_rd_data        (sd_card_photo),        // 读端口FIFO: 读数据

     //用户控制端口
    .read_valid             (1'b1),                 // SDRAM 读使能
    .pingpang_en            (1'b0),
    .init_end               (sdram_init_done),      // SDRAM 初始化完成标志

    //SDRAM 芯片接口
    .sdram_clk              (sdram_clk),            // SDRAM 芯片时钟
    .sdram_cke              (sdram_cke),            // SDRAM 时钟有效
    .sdram_cs_n             (sdram_cs_n),           // SDRAM 片选
    .sdram_ras_n            (sdram_ras_n),          // SDRAM 行有效
    .sdram_cas_n            (sdram_cas_n),          // SDRAM 列有效
    .sdram_we_n             (sdram_we_n),           // SDRAM 写有效
    .sdram_ba               (sdram_ba),             // SDRAM Bank地址
    .sdram_addr             (sdram_addr),           // SDRAM 行/列地址
    .sdram_dq               (sdram_data)            // SDRAM 数据
);

wire    [22:0]  sdram_rd_b_addr;
wire    [22:0]  sdram_rd_e_addr;
wire            sdram_rden;
wire            sdram_rst_n;

sdcard_rd_synchro rd_synchro_inst
(
    .hdmi_clk        (hdmi_clk),
    .sys_rst_n       (sys_rst_n & photo_wr_done),

    .hcnt            (hcnt),
    .vcnt            (vcnt),
    .state           (state_number),
    .all_photo_en    (all_photo_en),

    .sdram_rst_n     (sdram_rst_n),
    .sdram_rden      (sdram_rden),
    .sdram_rd_b_addr (sdram_rd_b_addr),
    .sdram_rd_e_addr (sdram_rd_e_addr)
);

wire            second_signal;
wire            third_signal;
wire            win_signal;
wire            fourth_win;

Display u2_Display
(
// Input
    .third_move_button      (third_move_button      ),
    .state_number           (state_number           ),
    .clk                    (hdmi_clk               ),
    .rst_n                  (sys_rst_n              ),
    .lcd_xpos               (lcd_xpos               ),
    .lcd_ypos               (lcd_ypos               ),
    .background_data        (sd_card_photo          ),
    .first_camera_bit       (first_camera_bit       ),
    .second_camera_data     (second_camera_data     ),

    .gamemode               (gamemode               ),
    .pausemode              (pausemode              ),
    .angle                  (angle                  ),
    .custom1_gun_enable     (custom1_gun_enable     ),
    .bird1_speed            (bird1_speed            ),
    .bird2_speed            (bird2_speed            ),

    .bird1up                (bird1up                ),
    .bird1down              (bird1down              ),
    .bird1left              (bird1left              ),
    .bird1right             (bird1right             ),

    .bird2up                (bird2up                ),
    .bird2down              (bird2down              ),
    .bird2left              (bird2left              ),
    .bird2right             (bird2right             ),

// Output
    .SG90_en                (SG90_en                ),

    .lcd_data               (lcd_data               ),
    .allbird_dead           (allbird_dead           ),
    .score                  (score                  ),
    .custom3_score          (custom3_score          ),
    .second_signal          (second_signal          ),
    .third_signal           (third_signal           ),
    .win_signal             (win_signal             )
);

wire    go_first_custom_flag;
wire    go_second_custom_flag;

Top_logic u3_Top_Logic
(
    //Input
    .clk                    (hdmi_clk               ),
    .rst                    (sys_rst_n              ),
    .start_button           (start_button           ),
    .pause_button           (pause_button           ),
    .continue_button        (continue_button        ),
    .restart_button         (restart_button         ),
    .method_button          (method_button          ),
    .cancle_button          (cancle_button          ),
    
    .first_custom_button    (first_custom_button    ),
    .second_custom_button   (second_custom_button   ),
    .third_custom_button    (third_custom_button    ),
    .exit_game_button       (exit_game_button       ),
    
    .allbird_dead           (allbird_dead           ),
    .fourth_dead            (fourth_dead            ),
    .second_signal          (second_signal          ),
    .third_signal           (third_signal           ),
    .win_signal             (win_signal             ),
    //output
    .go_first_custom_flag   (go_first_custom_flag   ),
    .go_second_custom_flag  (go_second_custom_flag  ),
    .state_number           (state_number           )
    );


/******************************************************************************/
/******************************************************************************/
/******************************************************************************/
parameter SLAVE_ADDR    = 7'h3c          ; //OV5640的器件地址7'h3c
parameter BIT_CTRL      = 1'b1           ; //OV5640的字节地址为16位  0:8位 1:16位
parameter CLK_FREQ      = 27'd50_000_000 ; //i2c_dri模块的驱动时钟频率 
parameter I2C_FREQ      = 18'd250_000    ; //I2C的SCL时钟频率,不超过400KHz

assign  cam_pwdn  = 1'b0;
assign  cam_rst_n = sys_rst_n;

wire            i2c_exec        ;  //I2C触发执行信号
wire    [23:0]  i2c_data        ;  //I2C要配置的地址与数据(高8位地址,低8位数据)          
wire            i2c_done        ;  //I2C寄存器配置完成信号
wire            i2c_dri_clk     ;  //I2C操作时钟
wire    [7:0]   i2c_data_r      ;  //I2C读出的数据
wire            i2c_rh_wl       ;  //I2C读写控制信号
wire            cam_init_done   ;  //摄像头初始化完成

//I2C配置模块
i2c_ov5640_rgb565_cfg u_i2c_cfg
(
    .clk                (i2c_dri_clk            ),
    .rst_n              (sys_rst_n              ),

    .i2c_exec           (i2c_exec               ),
    .i2c_data           (i2c_data               ),
    .i2c_rh_wl          (i2c_rh_wl              ),  //I2C读写控制信号
    .i2c_done           (i2c_done               ),
    .i2c_data_r         (i2c_data_r             ),

    .total_h_pixel      (13'd2570               ),  //水平总像素大小
    .total_v_pixel      (13'd980                ),  //垂直总像素大小

    .init_done          (cam_init_done          )
);

//I2C驱动模块
i2c_dri
#(
    .SLAVE_ADDR         (SLAVE_ADDR             ),  //参数传递
    .CLK_FREQ           (CLK_FREQ               ),
    .I2C_FREQ           (I2C_FREQ               )
)
u_i2c_dr
(
    .clk                (clk_50m                ),
    .rst_n              (sys_rst_n              ),

    .i2c_exec           (i2c_exec               ),
    .bit_ctrl           (BIT_CTRL               ),
    .i2c_rh_wl          (i2c_rh_wl              ),  //固定为0，只用到了IIC驱动的写操作   
    .i2c_addr           (i2c_data[23:8]         ),
    .i2c_data_w         (i2c_data[7:0]          ),
    .i2c_data_r         (i2c_data_r             ),
    .i2c_done           (i2c_done               ),
    .scl                (cam_scl                ),
    .sda                (cam_sda                ),
    .dri_clk            (i2c_dri_clk            )   //I2C操作时钟
    );

wire        camera_vsync;
wire        camera_href;

//CMOS图像数据采集模块
cmos_capture_data u_cmos_capture_data
(
    //系统初始化完成之后再开始采集数据
    .rst_n              (sys_rst_n & cam_init_done),

    .cam_pclk           (cam_pclk),
    .cam_vsync          (cam_vsync),
    .cam_href           (cam_href),
    .cam_data           (cam_data),
    
    .cmos_frame_vsync   (camera_vsync),
    .cmos_frame_href    (camera_href),
    .cmos_frame_valid   (camera_wrreq),      //数据有效使能信号
    .cmos_frame_data    (camera_wrdat)       //有效数据 
);
/******************************************************************************/
/******************************************************************************/
/******************************************************************************/

wire            color_binary_clken;
wire    [15:0]  color_binary;

wire            Sobel_clken;
wire            Sobel_bit;

wire            Erosion_clken;
wire            Erosion_bit;

wire            Dilation_clken;
wire            Dilation_bit;

wire    [15:0]  Dilation_data;
assign  Dilation_data = {16{Dilation_bit}};

vip sobel_edge
(
    .sobel                  (sobel),

    .clk                    (cam_pclk),
    .rst_n                  (sys_rst_n),

    //图像处理前的数据接口
    .pre_frame_vsync        (camera_vsync),
    .pre_frame_hsync        (camera_href),
    .pre_frame_de           (camera_wrreq),
    .pre_rgb                (camera_wrdat),

    //经过颜色识别处理的二值化图象
    .color_binary           (color_binary),
    .color_binary_clken     (color_binary_clken),

    //输出的sobel边缘检测图象
    .post0_frame_clken      (Sobel_clken),
    .post0_img_Bit          (Sobel_bit),

    //腐蚀后的图象
    .post1_frame_clken      (Erosion_clken),
    .post1_img_Bit          (Erosion_bit),

    //膨胀后的图象
    .post_frame_vsync       (),
    .post_frame_hsync       (),
    .post_frame_clken       (Dilation_clken),
    .post_img_Bit           (Dilation_bit)
);

wire    [15:0]      second_camera_data;

Sdram_Control_4Port Sdram_Control_4Port_inst
(
           //   HOST Side
           .CTRL_CLK             (clk_100m),
           .SDRAM_CLK            (clk_100m_shift),
           .RESET_N              (sys_rst_n),
           //   FIFO Write Side 1
           .WR1_DATA             (Dilation_data),
           .WR1                  (Dilation_clken),
           .WR1_ADDR             (1'b0),
           .WR1_MAX_ADDR         (23'd655360),
           .WR1_LENGTH           (10'd256),
           .WR1_LOAD             (~sys_rst_n),
           .WR1_CLK              (cam_pclk),
           .WR1_FULL             (),
           .WR1_USE              (),
           //   FIFO Write Side 2
           .WR2_DATA             (),
           .WR2                  (),
           .WR2_ADDR             (),
           .WR2_MAX_ADDR         (),
           .WR2_LENGTH           (),
           .WR2_LOAD             (),
           .WR2_CLK              (),
           .WR2_FULL             (),
           .WR2_USE              (),
           //   FIFO Read Side 1
           .RD1_DATA             (second_camera_data),
           .RD1                  (second_rden),
           .RD1_ADDR             (1'b0),
           .RD1_MAX_ADDR         (23'd655360),
           .RD1_LENGTH           (10'd256),
           .RD1_LOAD             (~sys_rst_n),
           .RD1_CLK              (hdmi_clk),
           .RD1_EMPTY            (),
           .RD1_USE              (),
           //   FIFO Read Side 2
           .RD2_DATA             (),
           .RD2                  (),
           .RD2_ADDR             (),
           .RD2_MAX_ADDR         (),
           .RD2_LENGTH           (),
           .RD2_LOAD             (),
           .RD2_CLK              (),
           .RD2_EMPTY            (),
           .RD2_USE              ()
       );

endmodule
