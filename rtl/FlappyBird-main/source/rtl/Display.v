`timescale 1ns/1ns
module Display
(
    input   wire            clk                 ,
    input   wire            rst_n               ,
    input   wire    [10:0]  lcd_xpos            ,
    input   wire    [10:0]  lcd_ypos            ,

    input   wire    [6:0]   state_number        ,

    input   wire    [1:0]   gamemode            ,
    input   wire    [1:0]   pausemode           ,
    //炮弹出现的角度
    input   wire    [3:0]   angle               ,

    //准星使能
    input   wire            custom1_gun_enable  ,

    //两只鸟的速度控制
    input   wire            bird1_speed         ,
    input   wire            bird2_speed         ,

    input   wire            bird1up             ,
    input   wire            bird1down           ,
    input   wire            bird1left           ,
    input   wire            bird1right          ,

    input   wire            bird2up             ,
    input   wire            bird2down           ,
    input   wire            bird2left           ,
    input   wire            bird2right          ,

    input   wire            third_move_button   ,

    input   wire    [15:0]  background_data     ,
    input   wire            first_camera_bit    ,
    input   wire    [15:0]  second_camera_data  ,

    output  reg     [7:0]   score               ,
    output  wire    [7:0]   custom3_score       ,
    output  reg             allbird_dead        ,

    output  reg             SG90_en             ,

    output  reg     [15:0]  lcd_data            ,
    output  wire            second_signal       ,
    output  wire            third_signal        ,
    output  wire            win_signal
);

parameter   RED     =   16'hF800,
            GREEN   =   16'h07E0,
            BLUE    =   16'h001F;

//游戏界面
parameter   start_scene     = 7'b0000001;
parameter   custom1_scene   = 7'b0000010;
parameter   custom2_scene   = 7'b0000100;
parameter   custom3_scene   = 7'b0001000;
parameter   pause_scene     = 7'b0010000;
parameter   gameover_scene  = 7'b0100000;
parameter   method_scene    = 7'b1000000;
parameter   win_scene       = 7'b1111111;

//游戏模式
parameter singlebird        = 2'd0;
parameter doublebird        = 2'd1;
parameter method            = 2'd2;

//暂停模式选择
parameter continuegame      = 2'd0;
parameter quitgame          = 2'd1;
parameter pausemethod       = 2'd2;

wire        clk_driver;
assign  clk_driver = ~clk;

parameter   CNT_150hz_MAX = 19'd400000;

reg         clk_150hz_flag;
reg [18:0]  cnt_150hz;

always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        cnt_150hz <= 1'b0;
    else if(cnt_150hz == CNT_150hz_MAX - 1'b1)
        cnt_150hz <= 1'b0;
    else
        cnt_150hz <= cnt_150hz + 1'b1;

always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        clk_150hz_flag <= 1'b0;
    else if(cnt_150hz == CNT_150hz_MAX - 1'b1)
        clk_150hz_flag <= 1'b1;
    else
        clk_150hz_flag <= 1'b0;

/******************************************************************/
//第一关第三关游戏进程状态
reg             third_custom_move;

/******************************************************************/
//各个模块bram读出像素点地址创建
/******************************************************************/
wire    [15:0]  custom1_gun_rom_data;
wire    [15:0]  bird_life_rom_data;
wire    [15:0]  custom1_count_rom_data;
wire    [15:0]  custom2_bird1_rom_data;
wire    [15:0]  custom2_bird2_rom_data;
wire    [15:0]  custom3_bird1_rom_data;
wire    [15:0]  custom3_bird2_rom_data;
wire    [15:0]  singlebutton_rom_data;
wire    [15:0]  doublebutton_rom_data;
wire    [15:0]  methodbutton_rom_data;
wire    [15:0]  trianglebutton_rom_data;
wire    [15:0]  all_shell_rom_data;

/******************************************************************/
//各个模块的使能信号创建
/******************************************************************/
wire            camera_en;
wire            sobel_en;
wire            background_en;
wire            singlebutton_en;
wire            doublebutton_en;
wire            methodbutton_en;
wire            custom1_gun_en;

//第一关倒计时和生命值
wire            custom1_count1_en;
wire            custom1_count2_en;
wire            custom1_count3_en;
wire            custom1_count4_en;
wire            custom1_count5_en;
reg             custom1_count1_enable;
reg             custom1_count2_enable;
reg             custom1_count3_enable;
reg             custom1_count4_enable;
reg             custom1_count5_enable;
wire            bird1_life1_en;
wire            bird1_life2_en;
wire            bird1_life3_en;
wire            bird1_life4_en;
reg             bird1_life1_enable;
reg             bird1_life2_enable;
reg             bird1_life3_enable;
reg             bird1_life4_enable;

//第二三关生命值
wire            bird2_life1_en;
wire            bird2_life2_en;
wire            bird2_life3_en;
wire            bird2_life4_en;
reg             bird2_life1_enable;
reg             bird2_life2_enable;
reg             bird2_life3_enable;
reg             bird2_life4_enable;

wire            custom2_bird1_en;
wire            custom2_bird2_en;
wire            custom3_bird1_en;
wire            custom3_bird2_en;
wire            trianglebutton_en;
wire            angle1_shell1_en;
// wire            angle1_shell2_en;
wire            angle2_shell1_en;
// wire            angle2_shell2_en;
wire            angle3_shell1_en;
// wire            angle3_shell2_en;
wire            angle4_shell1_en;
// wire            angle4_shell2_en;
wire            angle5_shell1_en;
// wire            angle5_shell2_en;
wire            angle6_shell1_en;
// wire            angle6_shell2_en;
wire            angle7_shell1_en;
// wire            angle7_shell2_en;
wire            angle8_shell1_en;
// wire            angle8_shell2_en;

reg             camera_en_reg;
reg             sobel_en_reg;
reg             background_en_reg;
reg             singlebutton_en_reg;
reg             doublebutton_en_reg;
reg             methodbutton_en_reg;
reg             custom1_gun_en_reg;
reg             custom1_count1_en_reg;
reg             custom1_count2_en_reg;
reg             custom1_count3_en_reg;
reg             custom1_count4_en_reg;
reg             custom1_count5_en_reg;
reg             bird1_life1_en_reg;
reg             bird1_life2_en_reg;
reg             bird1_life3_en_reg;
reg             bird1_life4_en_reg;
reg             bird2_life1_en_reg;
reg             bird2_life2_en_reg;
reg             bird2_life3_en_reg;
reg             bird2_life4_en_reg;
reg             custom2_bird1_en_reg;
reg             custom2_bird2_en_reg;
reg             custom3_bird1_en_reg;
reg             custom3_bird2_en_reg;
reg             trianglebutton_en_reg;
reg             angle1_shell1_en_reg;
// reg             angle1_shell2_en_reg;
reg             angle2_shell1_en_reg;
// reg             angle2_shell2_en_reg;
reg             angle3_shell1_en_reg;
// reg             angle3_shell2_en_reg;
reg             angle4_shell1_en_reg;
// reg             angle4_shell2_en_reg;
reg             angle5_shell1_en_reg;
// reg             angle5_shell2_en_reg;
reg             angle6_shell1_en_reg;
// reg             angle6_shell2_en_reg;
reg             angle7_shell1_en_reg;
// reg             angle7_shell2_en_reg;
reg             angle8_shell1_en_reg;
// reg             angle8_shell2_en_reg;

/******************************************************************/
//各个模块的坐标创建
/******************************************************************/
parameter   singlebutton_x0 = 6'd50,
            singlebutton_y0 = 8'd153,
            doublebutton_x0 = 6'd50,
            doublebutton_y0 = 9'd303,
            methodbutton_x0 = 6'd50,
            methodbutton_y0 = 9'd453;

parameter   trianglebutton_x0 = 10'd950;

reg     [8:0]   trianglebutton_y0;

parameter   cam_x0 = 11'd0,
            cam_y0 = 11'd128;

parameter   sobel_x0 = 1'b0,
            sobel_y0 = 8'd128;

parameter   background_x0 = 1'b0,
            background_y0 = 1'b0;

parameter   custom1_gun_x0 = 9'd490,
            custom1_gun_y0 = 9'd369;

//倒计时
parameter   custom1_count1_x0 = 11'd68,
            custom1_count1_y0 = 11'd66;

parameter   custom1_count2_x0 = 11'd98,
            custom1_count2_y0 = 11'd66;

parameter   custom1_count3_x0 = 11'd128,
            custom1_count3_y0 = 11'd66;

parameter   custom1_count4_x0 = 11'd158,
            custom1_count4_y0 = 11'd66;

parameter   custom1_count5_x0 = 11'd188,
            custom1_count5_y0 = 11'd66;

//生命值
parameter   bird1_life1_x0 = 11'd68,
            bird1_life1_y0 = 11'd19;

parameter   bird1_life2_x0 = 11'd98,
            bird1_life2_y0 = 11'd19;

parameter   bird1_life3_x0 = 11'd128,
            bird1_life3_y0 = 11'd19;

parameter   bird1_life4_x0 = 11'd158,
            bird1_life4_y0 = 11'd19;

parameter   bird2_life1_x0 = 11'd68,
            bird2_life1_y0 = 11'd66;

parameter   bird2_life2_x0 = 11'd98,
            bird2_life2_y0 = 11'd66;

parameter   bird2_life3_x0 = 11'd128,
            bird2_life3_y0 = 11'd66;

parameter   bird2_life4_x0 = 11'd158,
            bird2_life4_y0 = 11'd66;

reg     [10:0]  custom2_bird1_x0,custom2_bird1_y0;
reg     [10:0]  custom2_bird2_x0,custom2_bird2_y0;
reg     [10:0]  custom3_bird1_x0,custom3_bird1_y0;
reg     [10:0]  custom3_bird2_x0,custom3_bird2_y0;

/******************************************************************/
//各个模块长宽
/******************************************************************/

//图像参数
parameter cam_length = 11'd1024;
parameter cam_width = 10'd640;
parameter sobel_length = 11'd1024;
parameter sobel_width = 10'd580;
parameter custom2_bird_length = 5'd30;
parameter custom2_bird_width = 5'd30;
parameter custom3_bird_length = 6'd45;
parameter custom3_bird_width = 6'd45;
parameter background_length = 11'd1024;
parameter background_width = 10'd768;
parameter modebutton_length = 8'd150;
parameter modebutton_width = 6'd54;
parameter trianglebutton_length = 5'd30;
parameter trianglebutton_width = 6'd33;
parameter shell_length = 6'd40;
parameter shell_width = 6'd40;
parameter custom1_gun_length = 6'd40;
parameter custom1_gun_width = 6'd40;
parameter custom1_count_length = 5'd20;
parameter custom1_count_width = 5'd20;
parameter life_length = 5'd20;
parameter life_width = 5'd20;

/******************************************************************/
//各个模块bram地址创建
/******************************************************************/

//地址
wire    [9:0]   custom2_bird1_rom_add;
wire    [9:0]   custom2_bird2_rom_add;
wire    [10:0]  custom3_bird1_rom_add;
wire    [10:0]  custom3_bird2_rom_add;
wire    [12:0]  singlebutton_rom_add;
wire    [12:0]  doublebutton_rom_add;
wire    [12:0]  methodbutton_rom_add;
wire    [9:0]   trianglebutton_rom_add;
wire    [10:0]  angle1_shell1_rom_add;
// wire    [10:0]  angle1_shell2_rom_add;
wire    [10:0]  angle2_shell1_rom_add;
// wire    [10:0]  angle2_shell2_rom_add;
wire    [10:0]  angle3_shell1_rom_add;
// wire    [10:0]  angle3_shell2_rom_add;
wire    [10:0]  angle4_shell1_rom_add;
// wire    [10:0]  angle4_shell2_rom_add;
wire    [10:0]  angle5_shell1_rom_add;
// wire    [10:0]  angle5_shell2_rom_add;
wire    [10:0]  angle6_shell1_rom_add;
// wire    [10:0]  angle6_shell2_rom_add;
wire    [10:0]  angle7_shell1_rom_add;
// wire    [10:0]  angle7_shell2_rom_add;
wire    [10:0]  angle8_shell1_rom_add;
// wire    [10:0]  angle8_shell2_rom_add;
wire    [10:0]  custom1_gun_rom_add;
wire    [9:0]   custom1_count1_rom_add;
wire    [9:0]   custom1_count2_rom_add;
wire    [9:0]   custom1_count3_rom_add;
wire    [9:0]   custom1_count4_rom_add;
wire    [9:0]   custom1_count5_rom_add;
wire    [9:0]   bird1_life1_rom_add;
wire    [9:0]   bird1_life2_rom_add;
wire    [9:0]   bird1_life3_rom_add;
wire    [9:0]   bird1_life4_rom_add;
wire    [9:0]   bird2_life1_rom_add;
wire    [9:0]   bird2_life2_rom_add;
wire    [9:0]   bird2_life3_rom_add;
wire    [9:0]   bird2_life4_rom_add;

/******************************************************************/
//各个模块ROM例化列表
/******************************************************************/
custom1_gun custom1_gun_inst
(
    .clka   (clk),
    .rsta   (!rst_n),
    .addra  (custom1_gun_rom_add),
    .doa    (custom1_gun_rom_data)
);

custom1_count custom1_count_inst
(
    .clka   (clk),
    .rsta   (!rst_n),
    .addra  (custom1_count_rom_add),
    .doa    (custom1_count_rom_data)
);

wire    [9:0]   custom1_count_rom_add;
assign  custom1_count_rom_add = custom1_count1_rom_add + custom1_count2_rom_add + custom1_count3_rom_add + custom1_count4_rom_add + custom1_count5_rom_add;

custom1_life custom1_life_inst
(
    .clka   (clk),
    .rsta   (!rst_n),
    .addra  (bird_life_rom_add),
    .doa    (bird_life_rom_data)
);

wire    [9:0]   bird_life_rom_add;
assign  bird_life_rom_add = bird1_life1_rom_add + bird1_life2_rom_add + bird1_life3_rom_add + bird1_life4_rom_add
                            +bird2_life1_rom_add + bird2_life2_rom_add + bird2_life3_rom_add + bird2_life4_rom_add;

custom1_bird1 custom1_bird1_inst
(
    .clka   (clk),
    .rsta   (!rst_n),
    .addra  (custom3_bird1_rom_add),
    .doa    (custom3_bird1_rom_data)
);

custom1_bird2 custom1_bird2_inst
(
    .clka   (clk),
    .rsta   (!rst_n),
    .addra  (custom3_bird2_rom_add),
    .doa    (custom3_bird2_rom_data)
);

custom2_bird1 custom2_bird1_inst
(
    .clka   (clk),
    .rsta   (!rst_n),
    .addra  (custom2_bird1_rom_add),
    .doa    (custom2_bird1_rom_data)
);

custom2_bird2 custom2_bird2_inst
(
    .clka   (clk),
    .rsta   (!rst_n),
    .addra  (custom2_bird2_rom_add),
    .doa    (custom2_bird2_rom_data)
);

single_mode singlebutton
(
    .clka   (clk),
    .rsta   (!rst_n),
    .addra  (singlebutton_rom_add),
    .doa    (singlebutton_rom_data)
);

double_mode doublebutton
(
    .clka   (clk),
    .rsta   (!rst_n),
    .addra  (doublebutton_rom_add),
    .doa    (doublebutton_rom_data)
);

method_mode methodbutton
(
    .clka   (clk),
    .rsta   (!rst_n),
    .addra  (methodbutton_rom_add),
    .doa    (methodbutton_rom_data)
);

triangle trianglebutton
(
    .clka   (clk),
    .rsta   (!rst_n),
    .addra  (trianglebutton_rom_add),
    .doa    (trianglebutton_rom_data)
);

custom3_shell shell
(
    .clka   (clk),
    .rsta   (!rst_n),
    .addra  (all_shell_rom_add),
    .doa    (all_shell_rom_data)
);

wire    [10:0]  all_shell_rom_add;
assign  all_shell_rom_add =     (angle1_shell1_rom_add/*  + angle1_shell2_rom_add */)
                            +   (angle2_shell1_rom_add/*  + angle2_shell2_rom_add */)
                            +   (angle3_shell1_rom_add/*  + angle3_shell2_rom_add */)
                            +   (angle4_shell1_rom_add/*  + angle4_shell2_rom_add */)
                            +   (angle5_shell1_rom_add/*  + angle5_shell2_rom_add */)
                            +   (angle6_shell1_rom_add/*  + angle6_shell2_rom_add */)
                            +   (angle7_shell1_rom_add/*  + angle7_shell2_rom_add */)
                            +   (angle8_shell1_rom_add/*  + angle8_shell2_rom_add */);

/******************************************************************/
//各个模块VGA区域使能信号
/******************************************************************/
assign camera_en = (lcd_xpos > cam_x0) && (lcd_xpos < (cam_x0 + cam_length)) && (lcd_ypos >= cam_y0) && (lcd_ypos < cam_y0 + cam_width);
assign sobel_en = (lcd_xpos >= sobel_x0) && (lcd_xpos < sobel_x0 + sobel_length) && (lcd_ypos >= sobel_y0) && (lcd_ypos < (sobel_y0 + sobel_width));
assign background_en = (lcd_xpos >= background_x0) && (lcd_xpos < (background_x0 + background_length - 2'd3)) && (lcd_ypos >= background_y0) && (lcd_ypos < (background_y0 + background_width));

assign singlebutton_en = (single_state == 1'b1) ? ((lcd_xpos >= singlebutton_x0) && (lcd_xpos < (singlebutton_x0 + modebutton_length)) && (lcd_ypos >= singlebutton_y0) && (lcd_ypos < (singlebutton_y0 + modebutton_width))) : 1'b0;
assign doublebutton_en = (double_state == 1'b1) ? ((lcd_xpos >= doublebutton_x0) && (lcd_xpos < (doublebutton_x0 + modebutton_length)) && (lcd_ypos >= doublebutton_y0) && (lcd_ypos < (doublebutton_y0 + modebutton_width))) : 1'b0;
assign methodbutton_en = (method_state == 1'b1) ? ((lcd_xpos >= methodbutton_x0) && (lcd_xpos < (methodbutton_x0 + modebutton_length)) && (lcd_ypos >= methodbutton_y0) && (lcd_ypos < (methodbutton_y0 + modebutton_width))) : 1'b0;

assign trianglebutton_en = (state_number == pause_scene) ? ((lcd_xpos >= trianglebutton_x0) && (lcd_xpos < (trianglebutton_x0 + trianglebutton_length)) && (lcd_ypos >= trianglebutton_y0) && (lcd_ypos < (trianglebutton_y0 + trianglebutton_width))) : 1'b0;

assign angle1_shell1_en = (angle1_shell1_enable == 1'b1) ? ((lcd_xpos >= angle1_shell1_x0) && (lcd_xpos < (angle1_shell1_x0 + shell_length)) && (lcd_ypos >= angle1_shell1_y0) && (lcd_ypos < (angle1_shell1_y0 + shell_width))) : 1'b0;
// assign angle1_shell2_en = (angle1_shell2_enable == 1'b1) ? ((lcd_xpos >= angle1_shell2_x0) && (lcd_xpos < (angle1_shell2_x0 + shell_length)) && (lcd_ypos >= angle1_shell2_y0) && (lcd_ypos < (angle1_shell2_y0 + shell_width))) : 1'b0;


assign angle2_shell1_en = (angle2_shell1_enable == 1'b1) ? ((lcd_xpos >= angle2_shell1_x0) && (lcd_xpos < (angle2_shell1_x0 + shell_length)) && (lcd_ypos >= angle2_shell1_y0) && (lcd_ypos < (angle2_shell1_y0 + shell_width))) : 1'b0;
// assign angle2_shell2_en = (angle2_shell2_enable == 1'b1) ? ((lcd_xpos >= angle2_shell2_x0) && (lcd_xpos < (angle2_shell2_x0 + shell_length)) && (lcd_ypos >= angle2_shell2_y0) && (lcd_ypos < (angle2_shell2_y0 + shell_width))) : 1'b0;


assign angle3_shell1_en = (angle3_shell1_enable == 1'b1) ? ((lcd_xpos >= angle3_shell1_x0) && (lcd_xpos < (angle3_shell1_x0 + shell_length)) && (lcd_ypos >= angle3_shell1_y0) && (lcd_ypos < (angle3_shell1_y0 + shell_width))) : 1'b0;
// assign angle3_shell2_en = (angle3_shell2_enable == 1'b1) ? ((lcd_xpos >= angle3_shell2_x0) && (lcd_xpos < (angle3_shell2_x0 + shell_length)) && (lcd_ypos >= angle3_shell2_y0) && (lcd_ypos < (angle3_shell2_y0 + shell_width))) : 1'b0;


assign angle4_shell1_en = (angle4_shell1_enable == 1'b1) ? ((lcd_xpos >= angle4_shell1_x0) && (lcd_xpos < (angle4_shell1_x0 + shell_length)) && (lcd_ypos >= angle4_shell1_y0) && (lcd_ypos < (angle4_shell1_y0 + shell_width))) : 1'b0;
// assign angle4_shell2_en = (angle4_shell2_enable == 1'b1) ? ((lcd_xpos >= angle4_shell2_x0) && (lcd_xpos < (angle4_shell2_x0 + shell_length)) && (lcd_ypos >= angle4_shell2_y0) && (lcd_ypos < (angle4_shell2_y0 + shell_width))) : 1'b0;


assign angle5_shell1_en = (angle5_shell1_enable == 1'b1) ? ((lcd_xpos >= angle5_shell1_x0) && (lcd_xpos < (angle5_shell1_x0 + shell_length)) && (lcd_ypos >= angle5_shell1_y0) && (lcd_ypos < (angle5_shell1_y0 + shell_width))) : 1'b0;
// assign angle5_shell2_en = (angle5_shell2_enable == 1'b1) ? ((lcd_xpos >= angle5_shell2_x0) && (lcd_xpos < (angle5_shell2_x0 + shell_length)) && (lcd_ypos >= angle5_shell2_y0) && (lcd_ypos < (angle5_shell2_y0 + shell_width))) : 1'b0;


assign angle6_shell1_en = (angle6_shell1_enable == 1'b1) ? ((lcd_xpos >= angle6_shell1_x0) && (lcd_xpos < (angle6_shell1_x0 + shell_length)) && (lcd_ypos >= angle6_shell1_y0) && (lcd_ypos < (angle6_shell1_y0 + shell_width))) : 1'b0;
// assign angle6_shell2_en = (angle6_shell2_enable == 1'b1) ? ((lcd_xpos >= angle6_shell2_x0) && (lcd_xpos < (angle6_shell2_x0 + shell_length)) && (lcd_ypos >= angle6_shell2_y0) && (lcd_ypos < (angle6_shell2_y0 + shell_width))) : 1'b0;


assign angle7_shell1_en = (angle7_shell1_enable == 1'b1) ? ((lcd_xpos >= angle7_shell1_x0) && (lcd_xpos < (angle7_shell1_x0 + shell_length)) && (lcd_ypos >= angle7_shell1_y0) && (lcd_ypos < (angle7_shell1_y0 + shell_width))) : 1'b0;
// assign angle7_shell2_en = (angle7_shell2_enable == 1'b1) ? ((lcd_xpos >= angle7_shell2_x0) && (lcd_xpos < (angle7_shell2_x0 + shell_length)) && (lcd_ypos >= angle7_shell2_y0) && (lcd_ypos < (angle7_shell2_y0 + shell_width))) : 1'b0;


assign angle8_shell1_en = (angle8_shell1_enable == 1'b1) ? ((lcd_xpos >= angle8_shell1_x0) && (lcd_xpos < (angle8_shell1_x0 + shell_length)) && (lcd_ypos >= angle8_shell1_y0) && (lcd_ypos < (angle8_shell1_y0 + shell_width))) : 1'b0;
// assign angle8_shell2_en = (angle8_shell2_enable == 1'b1) ? ((lcd_xpos >= angle8_shell2_x0) && (lcd_xpos < (angle8_shell2_x0 + shell_length)) && (lcd_ypos >= angle8_shell2_y0) && (lcd_ypos < (angle8_shell2_y0 + shell_width))) : 1'b0;


//第二关小鸟使能信号
assign custom2_bird1_en = bird1_life_number == 3'd0 ? 1'b0 : (state_number == custom2_scene) ? ((lcd_xpos >= custom2_bird1_x0) && (lcd_xpos < custom2_bird1_x0 + custom2_bird_length) && (lcd_ypos >= custom2_bird1_y0) && (lcd_ypos < custom2_bird1_y0 + custom2_bird_width)) : 1'b0;
assign custom2_bird2_en = (gamemode == doublebird) ? (bird2_life_number == 3'd0 ? 1'b0 : (state_number == custom2_scene) ? ((lcd_xpos >= custom2_bird2_x0) && (lcd_xpos < custom2_bird2_x0 + custom2_bird_length) && (lcd_ypos >= custom2_bird2_y0) && (lcd_ypos < custom2_bird2_y0 + custom2_bird_width)) : 1'b0) : 1'b0;

//第三关小鸟使能信号
assign custom3_bird1_en = bird1_life_number == 3'd0 ? 1'b0 : (state_number == custom3_scene) ? ((lcd_xpos >= custom3_bird1_x0) && (lcd_xpos < custom3_bird1_x0 + custom3_bird_length) && (lcd_ypos >= custom3_bird1_y0) && (lcd_ypos < custom3_bird1_y0 + custom3_bird_width)) : 1'b0;
assign custom3_bird2_en = (gamemode == doublebird) ? (bird2_life_number == 3'd0 ? 1'b0 : (state_number == custom3_scene) ? ((lcd_xpos >= custom3_bird2_x0) && (lcd_xpos < custom3_bird2_x0 + custom3_bird_length) && (lcd_ypos >= custom3_bird2_y0) && (lcd_ypos < custom3_bird2_y0 + custom3_bird_width)) : 1'b0) : 1'b0;

//第一关准星使能信号
assign custom1_gun_en = (custom1_gun_enable == 1'b1) ? ((lcd_xpos >= custom1_gun_x0) && (lcd_xpos < (custom1_gun_x0 + custom1_gun_length)) && (lcd_ypos >= custom1_gun_y0) && (lcd_ypos < (custom1_gun_y0 + custom1_gun_width))) : 1'b0;
assign custom1_count1_en = (custom1_count1_enable == 1'b1) ? ((lcd_xpos >= custom1_count1_x0) && (lcd_xpos < (custom1_count1_x0 + custom1_count_length)) && (lcd_ypos >= custom1_count1_y0) && (lcd_ypos < (custom1_count1_y0 + custom1_count_width))) : 1'b0;
assign custom1_count2_en = (custom1_count2_enable == 1'b1) ? ((lcd_xpos >= custom1_count2_x0) && (lcd_xpos < (custom1_count2_x0 + custom1_count_length)) && (lcd_ypos >= custom1_count2_y0) && (lcd_ypos < (custom1_count2_y0 + custom1_count_width))) : 1'b0;
assign custom1_count3_en = (custom1_count3_enable == 1'b1) ? ((lcd_xpos >= custom1_count3_x0) && (lcd_xpos < (custom1_count3_x0 + custom1_count_length)) && (lcd_ypos >= custom1_count3_y0) && (lcd_ypos < (custom1_count3_y0 + custom1_count_width))) : 1'b0;
assign custom1_count4_en = (custom1_count4_enable == 1'b1) ? ((lcd_xpos >= custom1_count4_x0) && (lcd_xpos < (custom1_count4_x0 + custom1_count_length)) && (lcd_ypos >= custom1_count4_y0) && (lcd_ypos < (custom1_count4_y0 + custom1_count_width))) : 1'b0;
assign custom1_count5_en = (custom1_count5_enable == 1'b1) ? ((lcd_xpos >= custom1_count5_x0) && (lcd_xpos < (custom1_count5_x0 + custom1_count_length)) && (lcd_ypos >= custom1_count5_y0) && (lcd_ypos < (custom1_count5_y0 + custom1_count_width))) : 1'b0;

assign bird1_life1_en = (bird1_life1_enable == 1'b1) ? ((lcd_xpos >= bird1_life1_x0) && (lcd_xpos < (bird1_life1_x0 + life_length)) && (lcd_ypos >= bird1_life1_y0) && (lcd_ypos < (bird1_life1_y0 + life_width))) : 1'b0;
assign bird1_life2_en = (bird1_life2_enable == 1'b1) ? ((lcd_xpos >= bird1_life2_x0) && (lcd_xpos < (bird1_life2_x0 + life_length)) && (lcd_ypos >= bird1_life2_y0) && (lcd_ypos < (bird1_life2_y0 + life_width))) : 1'b0;
assign bird1_life3_en = (bird1_life3_enable == 1'b1) ? ((lcd_xpos >= bird1_life3_x0) && (lcd_xpos < (bird1_life3_x0 + life_length)) && (lcd_ypos >= bird1_life3_y0) && (lcd_ypos < (bird1_life3_y0 + life_width))) : 1'b0;
assign bird1_life4_en = (bird1_life4_enable == 1'b1) ? ((lcd_xpos >= bird1_life4_x0) && (lcd_xpos < (bird1_life4_x0 + life_length)) && (lcd_ypos >= bird1_life4_y0) && (lcd_ypos < (bird1_life4_y0 + life_width))) : 1'b0;

assign bird2_life1_en = (bird2_life1_enable == 1'b1) ? ((lcd_xpos >= bird2_life1_x0) && (lcd_xpos < (bird2_life1_x0 + life_length)) && (lcd_ypos >= bird2_life1_y0) && (lcd_ypos < (bird2_life1_y0 + life_width))) : 1'b0;
assign bird2_life2_en = (bird2_life2_enable == 1'b1) ? ((lcd_xpos >= bird2_life2_x0) && (lcd_xpos < (bird2_life2_x0 + life_length)) && (lcd_ypos >= bird2_life2_y0) && (lcd_ypos < (bird2_life2_y0 + life_width))) : 1'b0;
assign bird2_life3_en = (bird2_life3_enable == 1'b1) ? ((lcd_xpos >= bird2_life3_x0) && (lcd_xpos < (bird2_life3_x0 + life_length)) && (lcd_ypos >= bird2_life3_y0) && (lcd_ypos < (bird2_life3_y0 + life_width))) : 1'b0;
assign bird2_life4_en = (bird2_life4_enable == 1'b1) ? ((lcd_xpos >= bird2_life4_x0) && (lcd_xpos < (bird2_life4_x0 + life_length)) && (lcd_ypos >= bird2_life4_y0) && (lcd_ypos < (bird2_life4_y0 + life_width))) : 1'b0;

assign custom1_gun_en = (custom1_gun_enable == 1'b1) ? ((lcd_xpos >= custom1_gun_x0) && (lcd_xpos < (custom1_gun_x0 + custom1_gun_length)) && (lcd_ypos >= custom1_gun_y0) && (lcd_ypos < (custom1_gun_y0 + custom1_gun_width))) : 1'b0;

/******************************************************************/
//游戏图片模块的bram地址
/******************************************************************/

//各个图片模块rom读取地址（在en使能的时候进行赋值，即在vga扫描到对应区域开始读rom）
assign custom2_bird1_rom_add = (custom2_bird1_en == 1'b1) ? ((lcd_xpos - custom2_bird1_x0) + (lcd_ypos - custom2_bird1_y0) * custom2_bird_length) : 10'd0;
assign custom2_bird2_rom_add = (custom2_bird2_en == 1'b1) ? ((lcd_xpos - custom2_bird2_x0) + (lcd_ypos - custom2_bird2_y0) * custom2_bird_length) : 10'd0;
assign custom3_bird1_rom_add = (custom3_bird1_en == 1'b1) ? ((lcd_xpos - custom3_bird1_x0) + (lcd_ypos - custom3_bird1_y0) * custom3_bird_length) : 11'd0;
assign custom3_bird2_rom_add = (custom3_bird2_en == 1'b1) ? ((lcd_xpos - custom3_bird2_x0) + (lcd_ypos - custom3_bird2_y0) * custom3_bird_length) : 11'd0;
assign singlebutton_rom_add = (singlebutton_en == 1'b1) ? ((lcd_xpos - singlebutton_x0) + (lcd_ypos - singlebutton_y0) * modebutton_length) : 13'd0;
assign doublebutton_rom_add = (doublebutton_en == 1'b1) ? ((lcd_xpos - doublebutton_x0) + (lcd_ypos - doublebutton_y0) * modebutton_length) : 13'd0;
assign methodbutton_rom_add = (methodbutton_en == 1'b1) ? ((lcd_xpos - methodbutton_x0) + (lcd_ypos - methodbutton_y0) * modebutton_length) : 13'd0;
assign trianglebutton_rom_add = (trianglebutton_en == 1'b1) ? ((lcd_xpos - trianglebutton_x0) + (lcd_ypos - trianglebutton_y0) * trianglebutton_length) : 10'd0;

assign angle1_shell1_rom_add = (angle1_shell1_en == 1'b1) ? ((lcd_xpos - angle1_shell1_x0) + (lcd_ypos - angle1_shell1_y0) * shell_length) : 11'd0;
// assign angle1_shell2_rom_add = (angle1_shell2_en == 1'b1) ? ((lcd_xpos - angle1_shell2_x0) + (lcd_ypos - angle1_shell2_y0) * shell_length) : 11'd0;

assign angle2_shell1_rom_add = (angle2_shell1_en == 1'b1) ? ((lcd_xpos - angle2_shell1_x0) + (lcd_ypos - angle2_shell1_y0) * shell_length) : 11'd0;
// assign angle2_shell2_rom_add = (angle2_shell2_en == 1'b1) ? ((lcd_xpos - angle2_shell2_x0) + (lcd_ypos - angle2_shell2_y0) * shell_length) : 11'd0;

assign angle3_shell1_rom_add = (angle3_shell1_en == 1'b1) ? ((lcd_xpos - angle3_shell1_x0) + (lcd_ypos - angle3_shell1_y0) * shell_length) : 11'd0;
// assign angle3_shell2_rom_add = (angle3_shell2_en == 1'b1) ? ((lcd_xpos - angle3_shell2_x0) + (lcd_ypos - angle3_shell2_y0) * shell_length) : 11'd0;

assign angle4_shell1_rom_add = (angle4_shell1_en == 1'b1) ? ((lcd_xpos - angle4_shell1_x0) + (lcd_ypos - angle4_shell1_y0) * shell_length) : 11'd0;
// assign angle4_shell2_rom_add = (angle4_shell2_en == 1'b1) ? ((lcd_xpos - angle4_shell2_x0) + (lcd_ypos - angle4_shell2_y0) * shell_length) : 11'd0;

assign angle5_shell1_rom_add = (angle5_shell1_en == 1'b1) ? ((lcd_xpos - angle5_shell1_x0) + (lcd_ypos - angle5_shell1_y0) * shell_length) : 11'd0;
// assign angle5_shell2_rom_add = (angle5_shell2_en == 1'b1) ? ((lcd_xpos - angle5_shell2_x0) + (lcd_ypos - angle5_shell2_y0) * shell_length) : 11'd0;

assign angle6_shell1_rom_add = (angle6_shell1_en == 1'b1) ? ((lcd_xpos - angle6_shell1_x0) + (lcd_ypos - angle6_shell1_y0) * shell_length) : 11'd0;
// assign angle6_shell2_rom_add = (angle6_shell2_en == 1'b1) ? ((lcd_xpos - angle6_shell2_x0) + (lcd_ypos - angle6_shell2_y0) * shell_length) : 11'd0;

assign angle7_shell1_rom_add = (angle7_shell1_en == 1'b1) ? ((lcd_xpos - angle7_shell1_x0) + (lcd_ypos - angle7_shell1_y0) * shell_length) : 11'd0;
// assign angle7_shell2_rom_add = (angle7_shell2_en == 1'b1) ? ((lcd_xpos - angle7_shell2_x0) + (lcd_ypos - angle7_shell2_y0) * shell_length) : 11'd0;

assign angle8_shell1_rom_add = (angle8_shell1_en == 1'b1) ? ((lcd_xpos - angle8_shell1_x0) + (lcd_ypos - angle8_shell1_y0) * shell_length) : 11'd0;
// assign angle8_shell2_rom_add = (angle8_shell2_en == 1'b1) ? ((lcd_xpos - angle8_shell2_x0) + (lcd_ypos - angle8_shell2_y0) * shell_length) : 11'd0;

assign custom1_gun_rom_add = (custom1_gun_en == 1'b1) ? ((lcd_xpos - custom1_gun_x0) + (lcd_ypos - custom1_gun_y0) * custom1_gun_length) : 11'd0;
assign custom1_count1_rom_add = (custom1_count1_en == 1'b1) ? ((lcd_xpos - custom1_count1_x0) + (lcd_ypos - custom1_count1_y0) * custom1_count_length) : 11'd0;
assign custom1_count2_rom_add = (custom1_count2_en == 1'b1) ? ((lcd_xpos - custom1_count2_x0) + (lcd_ypos - custom1_count2_y0) * custom1_count_length) : 11'd0;
assign custom1_count3_rom_add = (custom1_count3_en == 1'b1) ? ((lcd_xpos - custom1_count3_x0) + (lcd_ypos - custom1_count3_y0) * custom1_count_length) : 11'd0;
assign custom1_count4_rom_add = (custom1_count4_en == 1'b1) ? ((lcd_xpos - custom1_count4_x0) + (lcd_ypos - custom1_count4_y0) * custom1_count_length) : 11'd0;
assign custom1_count5_rom_add = (custom1_count5_en == 1'b1) ? ((lcd_xpos - custom1_count5_x0) + (lcd_ypos - custom1_count5_y0) * custom1_count_length) : 11'd0;

assign bird1_life1_rom_add = (bird1_life1_en == 1'b1) ? ((lcd_xpos - bird1_life1_x0) + (lcd_ypos - bird1_life1_y0) * life_length) : 11'd0;
assign bird1_life2_rom_add = (bird1_life2_en == 1'b1) ? ((lcd_xpos - bird1_life2_x0) + (lcd_ypos - bird1_life2_y0) * life_length) : 11'd0;
assign bird1_life3_rom_add = (bird1_life3_en == 1'b1) ? ((lcd_xpos - bird1_life3_x0) + (lcd_ypos - bird1_life3_y0) * life_length) : 11'd0;
assign bird1_life4_rom_add = (bird1_life4_en == 1'b1) ? ((lcd_xpos - bird1_life4_x0) + (lcd_ypos - bird1_life4_y0) * life_length) : 11'd0;

assign bird2_life1_rom_add = (bird2_life1_en == 1'b1) ? ((lcd_xpos - bird2_life1_x0) + (lcd_ypos - bird2_life1_y0) * life_length) : 11'd0;
assign bird2_life2_rom_add = (bird2_life2_en == 1'b1) ? ((lcd_xpos - bird2_life2_x0) + (lcd_ypos - bird2_life2_y0) * life_length) : 11'd0;
assign bird2_life3_rom_add = (bird2_life3_en == 1'b1) ? ((lcd_xpos - bird2_life3_x0) + (lcd_ypos - bird2_life3_y0) * life_length) : 11'd0;
assign bird2_life4_rom_add = (bird2_life4_en == 1'b1) ? ((lcd_xpos - bird2_life4_x0) + (lcd_ypos - bird2_life4_y0) * life_length) : 11'd0;

always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        begin
            camera_en_reg <= 1'b0;
            sobel_en_reg <= 1'b0;
            background_en_reg <= 1'b0;
            singlebutton_en_reg <= 1'b0;
            doublebutton_en_reg <= 1'b0;
            methodbutton_en_reg <= 1'b0;
            custom2_bird1_en_reg <= 1'b0;
            custom2_bird2_en_reg <= 1'b0;
            custom3_bird1_en_reg <= 1'b0;
            custom3_bird2_en_reg <= 1'b0;
            trianglebutton_en_reg <= 1'b0;
            angle1_shell1_en_reg <= 1'b0;
            // angle1_shell2_en_reg <= 1'b0;
            angle2_shell1_en_reg <= 1'b0;
            // angle2_shell2_en_reg <= 1'b0;
            angle3_shell1_en_reg <= 1'b0;
            // angle3_shell2_en_reg <= 1'b0;
            angle4_shell1_en_reg <= 1'b0;
            // angle4_shell2_en_reg <= 1'b0;
            angle5_shell1_en_reg <= 1'b0;
            // angle5_shell2_en_reg <= 1'b0;
            angle6_shell1_en_reg <= 1'b0;
            // angle6_shell2_en_reg <= 1'b0;
            angle7_shell1_en_reg <= 1'b0;
            // angle7_shell2_en_reg <= 1'b0;
            angle8_shell1_en_reg <= 1'b0;
            // angle8_shell2_en_reg <= 1'b0;
            custom1_gun_en_reg <= 1'b0;
            custom1_count1_en_reg <= 1'b0;
            custom1_count2_en_reg <= 1'b0;
            custom1_count3_en_reg <= 1'b0;
            custom1_count4_en_reg <= 1'b0;
            custom1_count5_en_reg <= 1'b0;
            bird1_life1_en_reg <= 1'b0;
            bird1_life2_en_reg <= 1'b0;
            bird1_life3_en_reg <= 1'b0;
            bird1_life4_en_reg <= 1'b0;
            bird2_life1_en_reg <= 1'b0;
            bird2_life2_en_reg <= 1'b0;
            bird2_life3_en_reg <= 1'b0;
            bird2_life4_en_reg <= 1'b0;
        end
    else
        begin
            camera_en_reg <= camera_en;
            sobel_en_reg <= sobel_en;
            background_en_reg <= background_en;
            singlebutton_en_reg <= singlebutton_en;
            doublebutton_en_reg <= doublebutton_en;
            methodbutton_en_reg <= methodbutton_en;
            custom2_bird1_en_reg <= custom2_bird1_en;
            custom2_bird2_en_reg <= custom2_bird2_en;
            custom3_bird1_en_reg <= custom3_bird1_en;
            custom3_bird2_en_reg <= custom3_bird2_en;
            trianglebutton_en_reg <= trianglebutton_en;
            angle1_shell1_en_reg <= angle1_shell1_en;
            // angle1_shell2_en_reg <= angle1_shell2_en;
            angle2_shell1_en_reg <= angle2_shell1_en;
            // angle2_shell2_en_reg <= angle2_shell2_en;
            angle3_shell1_en_reg <= angle3_shell1_en;
            // angle3_shell2_en_reg <= angle3_shell2_en;
            angle4_shell1_en_reg <= angle4_shell1_en;
            // angle4_shell2_en_reg <= angle4_shell2_en;
            angle5_shell1_en_reg <= angle5_shell1_en;
            // angle5_shell2_en_reg <= angle5_shell2_en;
            angle6_shell1_en_reg <= angle6_shell1_en;
            // angle6_shell2_en_reg <= angle6_shell2_en;
            angle7_shell1_en_reg <= angle7_shell1_en;
            // angle7_shell2_en_reg <= angle7_shell2_en;
            angle8_shell1_en_reg <= angle8_shell1_en;
            // angle8_shell2_en_reg <= angle8_shell2_en;
            custom1_gun_en_reg <= custom1_gun_en;
            custom1_count1_en_reg <= custom1_count1_en;
            custom1_count2_en_reg <= custom1_count2_en;
            custom1_count3_en_reg <= custom1_count3_en;
            custom1_count4_en_reg <= custom1_count4_en;
            custom1_count5_en_reg <= custom1_count5_en;
            bird1_life1_en_reg <= bird1_life1_en;
            bird1_life2_en_reg <= bird1_life2_en;
            bird1_life3_en_reg <= bird1_life3_en;
            bird1_life4_en_reg <= bird1_life4_en;
            bird2_life1_en_reg <= bird2_life1_en;
            bird2_life2_en_reg <= bird2_life2_en;
            bird2_life3_en_reg <= bird2_life3_en;
            bird2_life4_en_reg <= bird2_life4_en;
        end

/******************************************************************/
//游戏第一关倒计时
/******************************************************************/
always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        begin
            custom1_count1_enable <= 1'b0;
            custom1_count2_enable <= 1'b0;
            custom1_count3_enable <= 1'b0;
            custom1_count4_enable <= 1'b0;
            custom1_count5_enable <= 1'b0;
        end
    else if(state_number == custom1_scene)
        begin
            if(second_num > 5'd16)
                begin
                    custom1_count1_enable <= 1'b1;
                    custom1_count2_enable <= 1'b1;
                    custom1_count3_enable <= 1'b1;
                    custom1_count4_enable <= 1'b1;
                    custom1_count5_enable <= 1'b1;
                end
            else if(second_num > 5'd12)
                begin
                    custom1_count1_enable <= 1'b0;
                    custom1_count2_enable <= 1'b1;
                    custom1_count3_enable <= 1'b1;
                    custom1_count4_enable <= 1'b1;
                    custom1_count5_enable <= 1'b1;
                end
            else if(second_num > 5'd8)
                begin
                    custom1_count1_enable <= 1'b0;
                    custom1_count2_enable <= 1'b0;
                    custom1_count3_enable <= 1'b1;
                    custom1_count4_enable <= 1'b1;
                    custom1_count5_enable <= 1'b1;
                end
            else if(second_num > 5'd4)
                begin
                    custom1_count1_enable <= 1'b0;
                    custom1_count2_enable <= 1'b0;
                    custom1_count3_enable <= 1'b0;
                    custom1_count4_enable <= 1'b1;
                    custom1_count5_enable <= 1'b1;
                end
            else if(second_num > 5'd0)
                begin
                    custom1_count1_enable <= 1'b0;
                    custom1_count2_enable <= 1'b0;
                    custom1_count3_enable <= 1'b0;
                    custom1_count4_enable <= 1'b0;
                    custom1_count5_enable <= 1'b1;
                end
            else
                begin
                    custom1_count1_enable <= 1'b0;
                    custom1_count2_enable <= 1'b0;
                    custom1_count3_enable <= 1'b0;
                    custom1_count4_enable <= 1'b0;
                    custom1_count5_enable <= 1'b0;
                end
        end
    else
        begin
            custom1_count1_enable <= 1'b0;
            custom1_count2_enable <= 1'b0;
            custom1_count3_enable <= 1'b0;
            custom1_count4_enable <= 1'b0;
            custom1_count5_enable <= 1'b0;
        end

/******************************************************************/
//小鸟1生命值
/******************************************************************/
always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        begin
            bird1_life1_enable <= 1'b0;
            bird1_life2_enable <= 1'b0;
            bird1_life3_enable <= 1'b0;
            bird1_life4_enable <= 1'b0;
        end
    else if(state_number == custom1_scene || state_number == custom2_scene || state_number == custom3_scene)
        begin
            if(bird1_life_number == 3'd4)
                begin
                    bird1_life1_enable <= 1'b1;
                    bird1_life2_enable <= 1'b1;
                    bird1_life3_enable <= 1'b1;
                    bird1_life4_enable <= 1'b1;
                end
            else if(bird1_life_number == 3'd3)
                begin
                    bird1_life1_enable <= 1'b0;
                    bird1_life2_enable <= 1'b1;
                    bird1_life3_enable <= 1'b1;
                    bird1_life4_enable <= 1'b1;
                end
            else if(bird1_life_number == 3'd2)
                begin
                    bird1_life1_enable <= 1'b0;
                    bird1_life2_enable <= 1'b0;
                    bird1_life3_enable <= 1'b1;
                    bird1_life4_enable <= 1'b1;
                end
            else if(bird1_life_number == 3'd1)
                begin
                    bird1_life1_enable <= 1'b0;
                    bird1_life2_enable <= 1'b0;
                    bird1_life3_enable <= 1'b0;
                    bird1_life4_enable <= 1'b1;
                end
            else
                begin
                    bird1_life1_enable <= 1'b0;
                    bird1_life2_enable <= 1'b0;
                    bird1_life3_enable <= 1'b0;
                    bird1_life4_enable <= 1'b0;
                end
        end
    else
        begin
            bird1_life1_enable <= 1'b0;
            bird1_life2_enable <= 1'b0;
            bird1_life3_enable <= 1'b0;
            bird1_life4_enable <= 1'b0;
        end

/******************************************************************/
//第二三关小鸟2生命值
/******************************************************************/
always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        begin
            bird2_life1_enable <= 1'b0;
            bird2_life2_enable <= 1'b0;
            bird2_life3_enable <= 1'b0;
            bird2_life4_enable <= 1'b0;
        end
    else if(gamemode == doublebird)
        begin
            if(state_number == custom2_scene || state_number == custom3_scene)
                begin
                    if(bird2_life_number == 3'd4)
                        begin
                            bird2_life1_enable <= 1'b1;
                            bird2_life2_enable <= 1'b1;
                            bird2_life3_enable <= 1'b1;
                            bird2_life4_enable <= 1'b1;
                        end
                    else if(bird2_life_number == 3'd3)
                        begin
                            bird2_life1_enable <= 1'b0;
                            bird2_life2_enable <= 1'b1;
                            bird2_life3_enable <= 1'b1;
                            bird2_life4_enable <= 1'b1;
                        end
                    else if(bird2_life_number == 3'd2)
                        begin
                            bird2_life1_enable <= 1'b0;
                            bird2_life2_enable <= 1'b0;
                            bird2_life3_enable <= 1'b1;
                            bird2_life4_enable <= 1'b1;
                        end
                    else if(bird2_life_number == 3'd1)
                        begin
                            bird2_life1_enable <= 1'b0;
                            bird2_life2_enable <= 1'b0;
                            bird2_life3_enable <= 1'b0;
                            bird2_life4_enable <= 1'b1;
                        end
                    else
                        begin
                            bird2_life1_enable <= 1'b0;
                            bird2_life2_enable <= 1'b0;
                            bird2_life3_enable <= 1'b0;
                            bird2_life4_enable <= 1'b0;
                        end
                end
        end
    else
        begin
            bird2_life1_enable <= 1'b0;
            bird2_life2_enable <= 1'b0;
            bird2_life3_enable <= 1'b0;
            bird2_life4_enable <= 1'b0;
        end

/******************************************************************/
//游戏开始界面按钮的位置
/******************************************************************/
reg             single_state;
reg             double_state;
reg             method_state;

always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        begin
            single_state <= 1'b1;
            double_state <= 1'b0;
            method_state <= 1'b0;
        end
    else if(gamemode == singlebird)
        begin
            single_state <= 1'b1;
            double_state <= 1'b0;
            method_state <= 1'b0;
        end
    else if(gamemode == doublebird)
        begin
            single_state <= 1'b0;
            double_state <= 1'b1;
            method_state <= 1'b0;
        end
    else if(gamemode == method)
        begin
            single_state <= 1'b0;
            double_state <= 1'b0;
            method_state <= 1'b1;
        end

/******************************************************************/
//游戏暂停界面三角标的位置
/******************************************************************/
always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
            trianglebutton_y0 <= 9'd245;
    else if(state_number == pause_scene)
        begin
            if(pausemode == continuegame)
                    trianglebutton_y0 <= 9'd246;
            else if(pausemode == quitgame)
                    trianglebutton_y0 <= 9'd346;
            else if(pausemode == pausemethod)
                    trianglebutton_y0 <= 9'd446;
        end
    else
            trianglebutton_y0 <= 9'd245;

/******************************************************************/
//游戏第三关炸弹的位置
/******************************************************************/

wire            angle1_shell1_enable;
/* wire            angle1_shell2_enable; */
wire    [9:0]   angle1_shell1_x0;
wire    [9:0]   angle1_shell1_y0;
/* wire    [9:0]   angle1_shell2_x0;
wire    [9:0]   angle1_shell2_y0; */

wire            angle2_shell1_enable;
/* wire            angle2_shell2_enable; */
wire    [9:0]   angle2_shell1_x0;
wire    [9:0]   angle2_shell1_y0;
/* wire    [9:0]   angle2_shell2_x0;
wire    [9:0]   angle2_shell2_y0; */

wire            angle3_shell1_enable;
/* wire            angle3_shell2_enable; */
wire    [9:0]   angle3_shell1_x0;
wire    [9:0]   angle3_shell1_y0;
/* wire    [9:0]   angle3_shell2_x0;
wire    [9:0]   angle3_shell2_y0; */

wire            angle4_shell1_enable;
/* wire            angle4_shell2_enable; */
wire    [9:0]   angle4_shell1_x0;
wire    [9:0]   angle4_shell1_y0;
/* wire    [9:0]   angle4_shell2_x0;
wire    [9:0]   angle4_shell2_y0; */

wire            angle5_shell1_enable;
/* wire            angle5_shell2_enable; */
wire    [9:0]   angle5_shell1_x0;
wire    [9:0]   angle5_shell1_y0;
/* wire    [9:0]   angle5_shell2_x0;
wire    [9:0]   angle5_shell2_y0; */

wire            angle6_shell1_enable;
/* wire            angle6_shell2_enable; */
wire    [9:0]   angle6_shell1_x0;
wire    [9:0]   angle6_shell1_y0;
/* wire    [9:0]   angle6_shell2_x0;
wire    [9:0]   angle6_shell2_y0; */

wire            angle7_shell1_enable;
/* wire            angle7_shell2_enable; */
wire    [9:0]   angle7_shell1_x0;
wire    [9:0]   angle7_shell1_y0;
/* wire    [9:0]   angle7_shell2_x0;
wire    [9:0]   angle7_shell2_y0; */

wire            angle8_shell1_enable;
/* wire            angle8_shell2_enable; */
wire    [9:0]   angle8_shell1_x0;
wire    [9:0]   angle8_shell1_y0;
/* wire    [9:0]   angle8_shell2_x0;
wire    [9:0]   angle8_shell2_y0; */

shell_go shell_go_inst
(
    .clk                    (clk                    ),
    .clk_150hz_flag         (clk_150hz_flag         ),
    .rst_n                  (rst_n                  ),

    .third_custom_move      (third_custom_move      ),

    .state                  (state_number           ),
    .angle                  (angle                  ),

    .angle1_shell1_en       (angle1_shell1_enable   ),
/*     .angle1_shell2_en       (angle1_shell2_enable   ), */
    .angle1_shell1_x0       (angle1_shell1_x0       ),
    .angle1_shell1_y0       (angle1_shell1_y0       ),
/*     .angle1_shell2_x0       (angle1_shell2_x0       ),
    .angle1_shell2_y0       (angle1_shell2_y0       ), */

    .angle2_shell1_en       (angle2_shell1_enable   ),
/*     .angle2_shell2_en       (angle2_shell2_enable   ), */
    .angle2_shell1_x0       (angle2_shell1_x0       ),
    .angle2_shell1_y0       (angle2_shell1_y0       ),
/*     .angle2_shell2_x0       (angle2_shell2_x0       ),
    .angle2_shell2_y0       (angle2_shell2_y0       ), */

    .angle3_shell1_en       (angle3_shell1_enable   ),
/*     .angle3_shell2_en       (angle3_shell2_enable   ), */
    .angle3_shell1_x0       (angle3_shell1_x0       ),
    .angle3_shell1_y0       (angle3_shell1_y0       ),
/*     .angle3_shell2_x0       (angle3_shell2_x0       ),
    .angle3_shell2_y0       (angle3_shell2_y0       ), */
    
    .angle4_shell1_en       (angle4_shell1_enable   ),
/*     .angle4_shell2_en       (angle4_shell2_enable   ), */
    .angle4_shell1_x0       (angle4_shell1_x0       ),
    .angle4_shell1_y0       (angle4_shell1_y0       ),
/*     .angle4_shell2_x0       (angle4_shell2_x0       ),
    .angle4_shell2_y0       (angle4_shell2_y0       ), */

    .angle5_shell1_en       (angle5_shell1_enable   ),
/*     .angle5_shell2_en       (angle5_shell2_enable   ), */
    .angle5_shell1_x0       (angle5_shell1_x0       ),
    .angle5_shell1_y0       (angle5_shell1_y0       ),
/*     .angle5_shell2_x0       (angle5_shell2_x0       ),
    .angle5_shell2_y0       (angle5_shell2_y0       ), */

    .angle6_shell1_en       (angle6_shell1_enable   ),
/*     .angle6_shell2_en       (angle6_shell2_enable   ), */
    .angle6_shell1_x0       (angle6_shell1_x0       ),
    .angle6_shell1_y0       (angle6_shell1_y0       ),
/*     .angle6_shell2_x0       (angle6_shell2_x0       ),
    .angle6_shell2_y0       (angle6_shell2_y0       ), */

    .angle7_shell1_en       (angle7_shell1_enable   ),
/*     .angle7_shell2_en       (angle7_shell2_enable   ), */
    .angle7_shell1_x0       (angle7_shell1_x0       ),
    .angle7_shell1_y0       (angle7_shell1_y0       ),
/*     .angle7_shell2_x0       (angle7_shell2_x0       ),
    .angle7_shell2_y0       (angle7_shell2_y0       ), */
    
    .angle8_shell1_en       (angle8_shell1_enable   ),
/*     .angle8_shell2_en       (angle8_shell2_enable   ), */
    .angle8_shell1_x0       (angle8_shell1_x0       ),
    .angle8_shell1_y0       (angle8_shell1_y0       ),
/*     .angle8_shell2_x0       (angle8_shell2_x0       ),
    .angle8_shell2_y0       (angle8_shell2_y0       ), */
    
    .custom3_score          (custom3_score          )
);

/******************************************************************/
//第三关游戏进行界面的开始游戏标志信号
/******************************************************************/

always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        third_custom_move <= 1'b0;
    else
        begin
            if(third_move_button == 1'b1 && state_number == custom3_scene)
                third_custom_move <= 1'b1;
            else    if(state_number == pause_scene || state_number == custom3_scene || state_number == method_scene)
                third_custom_move <= third_custom_move;
            else
                third_custom_move <= 1'b0;
        end

//***************************************************************
//第一关小鸟获胜标志信号
//***************************************************************

parameter   ONE_SECOND_MAX = 8'd150;

//一秒计数器，周期为1s
reg [7:0]   one_second_cnt;
always@(posedge clk or negedge rst_n)
    if(!rst_n)
        one_second_cnt <= 8'd0;
    else if(state_number == custom1_scene)
        begin
            if(clk_150hz_flag == 1'b1)
                begin
                    if(one_second_cnt == ONE_SECOND_MAX - 1'b1)
                        one_second_cnt <= 8'd0;
                    else
                        one_second_cnt <= one_second_cnt + 1'b1;
                end
            else
                one_second_cnt <= one_second_cnt;
        end
    else
        one_second_cnt <= 8'd0;

reg [4:0]   second_num;
always@(posedge clk or negedge rst_n)
    if(!rst_n)
        second_num <= 5'd20;
    else if(state_number == custom1_scene)
        begin
            if(clk_150hz_flag == 1'b1 && one_second_cnt == ONE_SECOND_MAX - 1'b1)
                begin
                    if(second_num == 5'd0)
                        second_num <= second_num;
                    else
                        second_num <= second_num - 1'b1;
                end
            else
                second_num <= second_num;
        end
    else if(state_number == pause_scene || state_number == method_scene)
        second_num <= second_num;
    else
        second_num <= 5'd20;

assign  second_signal = (state_number == custom1_scene && second_num == 5'd0);

//第三关标志信号，当位于第三关时，信号拉高
reg     third_custom;
always@(posedge clk or negedge rst_n)
    if(!rst_n)
        third_custom <= 1'b0;
    else if(state_number == start_scene)
        third_custom <= 1'b0;
    else if(third_signal == 1'b1)
        third_custom <= 1'b1;
    else
        third_custom <= third_custom;

//***************************************************************
//第二关小鸟获胜标志信号
//***************************************************************

reg     custom2_bird1_win;
reg     custom2_bird2_win;

always @(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        custom2_bird1_win <= 1'b0;
    else if(clk_150hz_flag == 1'b1)
        begin
            if(state_number == custom2_scene)
                begin
                    if((custom2_bird1_x0 < (custom2_x_min + 7'd70)) && (custom2_bird1_y0 > (custom2_y_max - 4'd15)) && bird1_life_number != 3'd0)
                        custom2_bird1_win <= 1'b1;
                    else
                        custom2_bird1_win <= 1'b0;
                end
            else
                custom2_bird1_win <= 1'b0;
        end
    else
        custom2_bird1_win <= custom2_bird1_win;

always @(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        custom2_bird2_win <= 1'b0;
    else if(clk_150hz_flag == 1'b1)
        begin
            if(state_number == custom2_scene)
                begin
                    if((custom2_bird2_x0 < (custom2_x_min + 7'd70)) && (custom2_bird2_y0 > (custom2_y_max - 4'd15)) && bird2_life_number != 3'd0)
                        custom2_bird2_win <= 1'b1;
                    else
                        custom2_bird2_win <= 1'b0;
                end
            else
                custom2_bird2_win <= 1'b0;
        end
    else
        custom2_bird2_win <= custom2_bird2_win;

//进入第三关标志位，当两只小鸟都到达指定位置时，第二关获胜
assign  third_signal = (gamemode == singlebird) ? custom2_bird1_win : ((bird1_life_number == 3'd0 && custom2_bird2_win == 1'b1) || (bird2_life_number == 3'd0 && custom2_bird1_win == 1'b1) || (custom2_bird1_win == 1'b1 && custom2_bird2_win == 1'b1));

//***************************************************************
//第三关小鸟获胜标志信号
//***************************************************************

assign  win_signal = (custom3_score == 8'd20) ? 1'b1 : 1'b0;

//***************************************************************
//进入第二关的脉冲信号，用来更新小鸟坐标,与125hz时钟对齐
reg     bird_second;
always @(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        bird_second <= 1'b0;
    else if(clk_150hz_flag == 1'b1)
        bird_second <= second_signal;
    else
        bird_second <= bird_second;

reg     bird_second_reg;
always @(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        bird_second_reg <= 1'b0;
    else if(clk_150hz_flag == 1'b1)
        bird_second_reg <= bird_second;
    else
        bird_second_reg <= bird_second_reg;

wire    second_bird_xyupdate;
assign  second_bird_xyupdate = bird_second & ~bird_second_reg;

//进入第三关的脉冲信号，用来更新小鸟坐标,与125hz时钟对齐
reg     bird_third;
always @(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        bird_third <= 1'b0;
    else if(clk_150hz_flag == 1'b1)
        bird_third <= third_custom;
    else
        bird_third <= bird_third;

reg     bird_third_reg;
always @(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        bird_third_reg <= 1'b0;
    else if(clk_150hz_flag == 1'b1)
        bird_third_reg <= bird_third;
    else
        bird_third_reg <= bird_third_reg;

wire    third_bird_xyupdate;
assign  third_bird_xyupdate = bird_third & ~bird_third_reg;
//***************************************************************

//******************************************************************
//鸟在不同关卡的运动范围
parameter custom2_y_min = 11'd124;
parameter custom2_y_max = 11'd704 - custom2_bird_width;
parameter custom2_x_min = 11'd3;
parameter custom2_x_max = 11'd1020 - custom2_bird_width;

parameter custom3_y_min = 11'd96;
parameter custom3_y_max = 11'd664 - custom2_bird_width;
parameter custom3_x_min = 11'd98;
parameter custom3_x_max = 11'd924 - custom2_bird_width;

//******************************************************************
//两只鸟的飞行状态，驱动频率为125hz

//不同的飞行速度
parameter   high_speed_mode = 1'b1;
parameter   middle_speed_mode = 1'b0;

//******************************************************************
//鸟1
//第二关控制，分别控制xy坐标
always @(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        custom2_bird1_x0 <= 11'd925;
    else if(clk_150hz_flag == 1'b1)
        begin
            if(state_number == start_scene)
                    custom2_bird1_x0 <= 11'd925;
            //第二关
            else if(state_number == custom2_scene)
                begin
                    if(second_bird_xyupdate == 1'b1)
                        custom2_bird1_x0 <= 11'd925;
                    //运动范围控制
                    else if((custom2_bird1_x0 == (custom2_x_min - 1'b1)) || (custom2_bird1_x0 == (custom2_x_min - 2'd2)))
                        custom2_bird1_x0 <= custom2_bird1_x0 + 1'b1;
                    else if((custom2_bird1_x0 == (custom2_x_max + 1'b1)) || (custom2_bird1_x0 == (custom2_x_max + 2'd2)))
                        custom2_bird1_x0 <= custom2_bird1_x0 - 1'b1;
                    //运动方位与速度控制
                    else if(bird1right == 1'b1)
                        begin
                            if(bird1_speed == middle_speed_mode)
                                custom2_bird1_x0 <= custom2_bird1_x0 + 1'b1;
                            else
                                custom2_bird1_x0 <= custom2_bird1_x0 + 2'd2;
                        end
                    else if(bird1left == 1'b1)
                        begin
                            if(bird1_speed == middle_speed_mode)
                                custom2_bird1_x0 <= custom2_bird1_x0 - 1'b1;
                            else
                                custom2_bird1_x0 <= custom2_bird1_x0 - 2'd2;
                        end
                    else
                        custom2_bird1_x0 <= custom2_bird1_x0;
                end
            else
                custom2_bird1_x0 <= custom2_bird1_x0;
        end
    else
        custom2_bird1_x0 <= custom2_bird1_x0;

always @(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        custom2_bird1_y0 <= 11'd30;
    else if(clk_150hz_flag == 1'b1)
        begin
            if(state_number == start_scene)
                    custom2_bird1_y0 <= 11'd30;
            //第二关
            else if(state_number == custom2_scene)
                begin
                    if(second_bird_xyupdate == 1'b1)
                        custom2_bird1_y0 <= 11'd30;
                    //运动范围控制
                    else if((custom2_bird1_y0 == (custom2_y_min - 1'b1)) || (custom2_bird1_y0 == (custom2_y_min - 2'd2)))
                        custom2_bird1_y0 <= custom2_bird1_y0 + 1'b1;
                    else if((custom2_bird1_y0 == (custom2_y_max + 1'b1)) || (custom2_bird1_y0 == (custom2_y_max + 2'd2)))
                        custom2_bird1_y0 <= custom2_bird1_y0 - 1'b1;
                    //运动方位与速度控制
                    else if(bird1down == 1'b1)
                        begin
                            if(bird1_speed == middle_speed_mode)
                                custom2_bird1_y0 <= custom2_bird1_y0 + 1'b1;
                            else
                                custom2_bird1_y0 <= custom2_bird1_y0 + 2'd2;
                        end
                    else if(bird1up == 1'b1)
                        begin
                            if(bird1_speed == middle_speed_mode)
                                custom2_bird1_y0 <= custom2_bird1_y0 - 1'b1;
                            else
                                custom2_bird1_y0 <= custom2_bird1_y0 - 2'd2;
                        end
                    else
                        custom2_bird1_y0 <= custom2_bird1_y0;
                end
            else
                custom2_bird1_y0 <= custom2_bird1_y0;
        end
    else
        custom2_bird1_y0 <= custom2_bird1_y0;

//第三关控制，分别控制xy坐标
always @(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        custom3_bird1_x0 <= 11'd472;
    else if(clk_150hz_flag == 1'b1)
        begin
            if(state_number == start_scene)
                custom3_bird1_x0 <= 11'd472;
            else if(state_number == custom3_scene)
                begin
                    if(third_bird_xyupdate == 1'b1)
                        custom3_bird1_x0 <= 11'd472;
                    //运动范围控制
                    else if((custom3_bird1_x0 == (custom3_x_min - 1'b1)) || (custom3_bird1_x0 == (custom3_x_min - 2'd2)))
                        custom3_bird1_x0 <= custom3_bird1_x0 + 1'b1;
                    else if((custom3_bird1_x0 == (custom3_x_max + 1'b1)) || (custom3_bird1_x0 == (custom3_x_max + 2'd2)))
                        custom3_bird1_x0 <= custom3_bird1_x0 - 1'b1;
                    //运动方位与速度控制
                    else if(bird1right == 1'b1)
                        begin
                            if(bird1_speed == middle_speed_mode)
                                custom3_bird1_x0 <= custom3_bird1_x0 + 1'b1;
                            else
                                custom3_bird1_x0 <= custom3_bird1_x0 + 2'd2;
                        end
                    else if(bird1left == 1'b1)
                        begin
                            if(bird1_speed == middle_speed_mode)
                                custom3_bird1_x0 <= custom3_bird1_x0 - 1'b1;
                            else
                                custom3_bird1_x0 <= custom3_bird1_x0 - 2'd2;
                        end
                    else
                        custom3_bird1_x0 <= custom3_bird1_x0;
                end
            else
                custom3_bird1_x0 <= custom3_bird1_x0;
        end
    else
        custom3_bird1_x0 <= custom3_bird1_x0;

always @(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        custom3_bird1_y0 <= 11'd364;
    else if(clk_150hz_flag == 1'b1)
        begin
            if(state_number == start_scene)
                custom3_bird1_y0 <= 11'd364;
            else if(state_number == custom3_scene)
                begin
                    if(third_bird_xyupdate == 1'b1)
                        custom3_bird1_y0 <= 11'd364;
                    //运动范围控制
                    else if((custom3_bird1_y0 == (custom3_y_min - 1'b1)) || (custom3_bird1_y0 == (custom3_y_min - 2'd2)))
                        custom3_bird1_y0 <= custom3_bird1_y0 + 1'b1;
                    else if((custom3_bird1_y0 == (custom3_y_max + 1'b1)) || (custom3_bird1_y0 == (custom3_y_max + 2'd2)))
                        custom3_bird1_y0 <= custom3_bird1_y0 - 1'b1;
                    //运动方位与速度控制
                    else if(bird1down == 1'b1)
                        begin
                            if(bird1_speed == middle_speed_mode)
                                custom3_bird1_y0 <= custom3_bird1_y0 + 1'b1;
                            else
                                custom3_bird1_y0 <= custom3_bird1_y0 + 2'd2;
                        end
                    else if(bird1up == 1'b1)
                        begin
                            if(bird1_speed == middle_speed_mode)
                                custom3_bird1_y0 <= custom3_bird1_y0 - 1'b1;
                            else
                                custom3_bird1_y0 <= custom3_bird1_y0 - 2'd2;
                        end
                    else
                        custom3_bird1_y0 <= custom3_bird1_y0;
                end
            else
                custom3_bird1_y0 <= custom3_bird1_y0;
        end
    else
        custom3_bird1_y0 <= custom3_bird1_y0;


//******************************************************************
//鸟2
//第二关控制
always @(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        custom2_bird2_x0 <= 11'd960;
    else if(clk_150hz_flag == 1'b1)
        begin
            if(gamemode == doublebird)
                begin
                    if(state_number == start_scene)
                        custom2_bird2_x0 <= 11'd960;
                    else if(state_number == custom2_scene)
                        begin
                            if(second_bird_xyupdate == 1'b1)
                                    custom2_bird2_x0 <= 11'd960;
                            else if((custom2_bird2_x0 == (custom2_x_min - 1'b1)) || (custom2_bird2_x0 == (custom2_x_min - 2'd2)))
                                custom2_bird2_x0 <= custom2_bird2_x0 + 1'b1;
                            else if((custom2_bird2_x0 == (custom2_x_max + 1'b1)) || (custom2_bird2_x0 == (custom2_x_max + 2'd2)))
                                custom2_bird2_x0 <= custom2_bird2_x0 - 1'b1;
                            else if(bird2left == 1'b1)
                                begin
                                    if(bird2_speed == middle_speed_mode)
                                        custom2_bird2_x0 <= custom2_bird2_x0 - 1'b1;
                                    else
                                        custom2_bird2_x0 <= custom2_bird2_x0 - 2'd2;
                                end
                            else if(bird2right == 1'b1)
                                begin
                                    if(bird2_speed == middle_speed_mode)
                                        custom2_bird2_x0 <= custom2_bird2_x0 + 1'b1;
                                    else
                                        custom2_bird2_x0 <= custom2_bird2_x0 + 2'd2;
                                end
                            else
                                custom2_bird2_x0 <= custom2_bird2_x0;
                        end
                    else
                        custom2_bird2_x0 <= custom2_bird2_x0;
                end
            else
                custom2_bird2_x0 <= custom2_bird2_x0;
        end
    else
        custom2_bird2_x0 <= custom2_bird2_x0;

always @(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        custom2_bird2_y0 <= 11'd60;
    else if(clk_150hz_flag == 1'b1)
        begin
            if(gamemode == doublebird)
                begin
                    if(state_number == start_scene)
                        custom2_bird2_y0 <= 11'd60;
                    else if(state_number == custom2_scene)
                        begin
                            if(second_bird_xyupdate == 1'b1)
                                custom2_bird2_y0 <= 11'd60;
                            else if((custom2_bird2_y0 == (custom2_y_min - 1'b1)) || (custom2_bird2_y0 == (custom2_y_min - 2'd2)))
                                custom2_bird2_y0 <= custom2_bird2_y0 + 1'b1;
                            else if((custom2_bird2_y0 == (custom2_y_max + 1'b1)) || (custom2_bird2_y0 == (custom2_y_max + 2'd2)))
                                custom2_bird2_y0 <= custom2_bird2_y0 - 1'b1;
                            else if(bird2up == 1'b1)
                                begin
                                    if(bird2_speed == middle_speed_mode)
                                        custom2_bird2_y0 <= custom2_bird2_y0 - 1'b1;
                                    else
                                        custom2_bird2_y0 <= custom2_bird2_y0 - 2'd2;
                                end
                            else if(bird2down == 1'b1)
                                begin
                                    if(bird2_speed == middle_speed_mode)
                                        custom2_bird2_y0 <= custom2_bird2_y0 + 1'b1;
                                    else
                                        custom2_bird2_y0 <= custom2_bird2_y0 + 2'd2;
                                end
                            else
                                custom2_bird2_y0 <= custom2_bird2_y0;
                        end
                    else
                        custom2_bird2_y0 <= custom2_bird2_y0;
                end
            else
                custom2_bird2_y0 <= custom2_bird2_y0;
        end
    else
        custom2_bird2_y0 <= custom2_bird2_y0;

//第三关控制
always @(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        custom3_bird2_x0 <= (11'd472 + custom3_bird_length);
    else if(clk_150hz_flag == 1'b1)
        begin
            if(gamemode == doublebird)
                begin
                    if(state_number == start_scene)
                        custom3_bird2_x0 <= (11'd472 + custom3_bird_length);
                    else if(state_number == custom3_scene)
                        begin
                            if(third_bird_xyupdate == 1'b1)
                                    custom3_bird2_x0 <= (11'd472 + custom3_bird_length);
                            else if((custom3_bird2_x0 == (custom3_x_min - 1'b1)) || (custom3_bird2_x0 == (custom3_x_min - 2'd2)))
                                custom3_bird2_x0 <= custom3_bird2_x0 + 1'b1;
                            else if((custom3_bird2_x0 == (custom3_x_max + 1'b1)) || (custom3_bird2_x0 == (custom3_x_max + 2'd2)))
                                custom3_bird2_x0 <= custom3_bird2_x0 - 1'b1;
                            else if(bird2left == 1'b1)
                                begin
                                    if(bird2_speed == middle_speed_mode)
                                        custom3_bird2_x0 <= custom3_bird2_x0 - 1'b1;
                                    else
                                        custom3_bird2_x0 <= custom3_bird2_x0 - 2'd2;
                                end
                            else if(bird2right == 1'b1)
                                begin
                                    if(bird2_speed == middle_speed_mode)
                                        custom3_bird2_x0 <= custom3_bird2_x0 + 1'b1;
                                    else
                                        custom3_bird2_x0 <= custom3_bird2_x0 + 2'd2;
                                end
                            else
                                custom3_bird2_x0 <= custom3_bird2_x0;
                        end
                    else
                        custom3_bird2_x0 <= custom3_bird2_x0;
                end
            else
                custom3_bird2_x0 <= custom3_bird2_x0;
        end
    else
        custom3_bird2_x0 <= custom3_bird2_x0;

always @(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        custom3_bird2_y0 <= 11'd364;
    else if(clk_150hz_flag == 1'b1)
        begin
            if(gamemode == doublebird)
                begin
                    if(state_number == start_scene)
                        custom3_bird2_y0 <= 11'd364;
                    else if(state_number == custom3_scene)
                        begin
                            if(third_bird_xyupdate == 1'b1)
                                    custom3_bird2_y0 <= 11'd364;
                            else if((custom3_bird2_y0 == (custom3_y_min - 1'b1)) || (custom3_bird2_y0 == (custom3_y_min - 2'd2)))
                                custom3_bird2_y0 <= custom3_bird2_y0 + 1'b1;
                            else if((custom3_bird2_y0 == (custom3_y_max + 1'b1)) || (custom3_bird2_y0 == (custom3_y_max + 2'd2)))
                                custom3_bird2_y0 <= custom3_bird2_y0 - 1'b1;
                            else if(bird2up == 1'b1)
                                begin
                                    if(bird2_speed == middle_speed_mode)
                                        custom3_bird2_y0 <= custom3_bird2_y0 - 1'b1;
                                    else
                                        custom3_bird2_y0 <= custom3_bird2_y0 - 2'd2;
                                end
                            else if(bird2down == 1'b1)
                                begin
                                    if(bird2_speed == middle_speed_mode)
                                        custom3_bird2_y0 <= custom3_bird2_y0 + 1'b1;
                                    else
                                        custom3_bird2_y0 <= custom3_bird2_y0 + 2'd2;
                                end
                            else
                                custom3_bird2_y0 <= custom3_bird2_y0;
                        end
                    else
                        custom3_bird2_y0 <= custom3_bird2_y0;
                end
            else
                custom3_bird2_y0 <= custom3_bird2_y0;
        end
    else
        custom3_bird2_y0 <= custom3_bird2_y0;

/******************************************************************/
/******************************************************************/

//每帧开始于结束标志位，用于计算与小鸟重合的白点数量
reg     one_frame_end;
always@(posedge clk or negedge rst_n)
    if(!rst_n)
        one_frame_end <= 1'b0;
    else if(lcd_xpos == 12'd1000 && lcd_ypos == 12'd767)
        one_frame_end <= 1'b1;
    else
        one_frame_end <= 1'b0;

reg     one_frame_start;
always@(posedge clk or negedge rst_n)
    if(!rst_n)
        one_frame_start <= 1'b0;
    else if(lcd_xpos == 12'd100 && lcd_ypos == 12'd100)
        one_frame_start <= 1'b1;
    else
        one_frame_start <= 1'b0;

/******************************************************************/
//鸟第一关死亡判断
/******************************************************************/

//计算小鸟1触碰到障碍物点的数量
parameter CUSTOM1_DEAD_THRESHOLD = 10;
reg     [9:0]  custom1_bird_touch_number; //小鸟触碰到图中白点的数量，将其视作障碍物

always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        custom1_bird_touch_number <= 10'd0;
    else if(state_number == custom1_scene)
        begin
            if(one_frame_start == 1'b1)
                custom1_bird_touch_number <= 10'd0;
            else if((custom1_gun_en == 1'b1 && custom1_gun_rom_data != 16'h0106) && first_camera_bit == 1'b1)
                custom1_bird_touch_number <= custom1_bird_touch_number + 1'b1;
            else
                custom1_bird_touch_number <= custom1_bird_touch_number;
        end
    else
        custom1_bird_touch_number <= 10'd0;

/******************************************************************/
//鸟第二关死亡判断
/******************************************************************/

parameter CUSTOM2_DEAD_THRESHOLD = 100;     //小鸟死亡判断阈值，阈值越低，小鸟越容易死亡
//计算与小鸟重叠的白点数量，用于判断是否触碰到障碍物

//计算小鸟1触碰到障碍物点的数量
reg     [9:0]  custom2_bird1_touch_number; //小鸟触碰到图中白点的数量，将其视作障碍物
always@(posedge clk or negedge rst_n)
    if(!rst_n)
        custom2_bird1_touch_number <= 10'd0;
    else if(state_number == custom2_scene)
        begin
            if(one_frame_start == 1'b1)
                custom2_bird1_touch_number <= 10'd0;
            else if((custom2_bird1_en == 1'b1 && custom2_bird1_rom_data != 16'h0106) && (sobel_en == 1'b1 && second_camera_data == 16'hffff))
                custom2_bird1_touch_number <= custom2_bird1_touch_number + 1'b1;
            else
                custom2_bird1_touch_number <= custom2_bird1_touch_number;
        end
    else
        custom2_bird1_touch_number <= 10'd0;

//计算小鸟2触碰到障碍物点的数量
reg     [9:0]  custom2_bird2_touch_number;
always@(posedge clk or negedge rst_n)
    if(!rst_n)
        custom2_bird2_touch_number <= 10'b0;
    else if(state_number == custom2_scene)
        begin
            if(one_frame_start == 1'b1)
                custom2_bird2_touch_number <= 10'd0;
            else if((custom2_bird2_en == 1'b1 && custom2_bird2_rom_data != 16'h0106) && (sobel_en == 1'b1 && second_camera_data == 16'hffff))
                custom2_bird2_touch_number <= custom2_bird2_touch_number + 1'b1;
            else
                custom2_bird2_touch_number <= custom2_bird2_touch_number;
        end
    else
        custom2_bird2_touch_number <= 10'd0;

/******************************************************************/
//鸟第三关死亡判断
/******************************************************************/

wire        shell_en;
assign  shell_en    =   angle1_shell1_en/*  | angle1_shell2_en  */| 
                        angle2_shell1_en/*  | angle2_shell2_en  */| 
                        angle3_shell1_en/*  | angle3_shell2_en  */| 
                        angle4_shell1_en/*  | angle4_shell2_en  */| 
                        angle5_shell1_en/*  | angle5_shell2_en  */| 
                        angle6_shell1_en/*  | angle6_shell2_en  */| 
                        angle7_shell1_en/*  | angle7_shell2_en  */| 
                        angle8_shell1_en/*  | angle8_shell2_en */;

//******************************************************************************
//小鸟闪烁状态
//******************************************************************************

//小鸟生命值和状态编写
reg     [2:0]   bird1_life_number;
reg     [2:0]   bird2_life_number;
reg             bird1_state;     //0 正常状态 1 闪烁状态
reg             bird2_state;     //0 正常状态 1 闪烁状态

always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        begin
            bird1_life_number <= 3'd4;
            bird1_state <= 1'b0;
        end
    else if(state_number == start_scene)
        begin
            bird1_life_number <= 3'd4;
            bird1_state <= 1'b0;
        end
    else if(twink1_cnt == TWINK_CNT_MAX - 1'b1 && clk_150hz_flag == 1'b1)
        begin
            bird1_life_number <= bird1_life_number;
            bird1_state <= 1'b0;
        end
    else if(bird1_life_number > 1'b0)
        begin
            if(state_number == custom1_scene)
                begin
                    if(one_frame_end == 1'b1 && custom1_bird_touch_number > CUSTOM1_DEAD_THRESHOLD && bird1_state == 1'b0)
                        begin
                            bird1_life_number <= bird1_life_number - 1'b1;
                            bird1_state <= 1'b1;
                        end
                    else
                        begin
                            bird1_life_number <= bird1_life_number;
                            bird1_state <= bird1_state;
                        end
                end
            else if(state_number == custom2_scene)
                begin
                    if(one_frame_end == 1'b1 && custom2_bird1_touch_number > CUSTOM2_DEAD_THRESHOLD && bird1_state == 1'b0)
                        begin
                            bird1_life_number <= bird1_life_number - 1'b1;
                            bird1_state <= 1'b1;
                        end
                    else
                        begin
                            bird1_life_number <= bird1_life_number;
                            bird1_state <= bird1_state;
                        end
                end
            else if(state_number == custom3_scene)
                begin
                    if((custom3_bird1_en == 1'b1 && custom3_bird1_rom_data != 16'h0106) && (shell_en == 1'b1 && all_shell_rom_data != 16'h0106) && bird1_state == 1'b0)
                        begin
                            bird1_life_number <= bird1_life_number - 1'b1;
                            bird1_state <= 1'b1;
                        end
                    else
                        begin
                            bird1_life_number <= bird1_life_number;
                            bird1_state <= bird1_state;
                        end
                end
            else
                begin
                    bird1_life_number <= bird1_life_number;
                    bird1_state <= bird1_state;
                end
        end
    else
        begin
            bird1_life_number <= bird1_life_number;
            bird1_state <= bird1_state;
        end

always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        begin
            bird2_life_number <= 3'd4;
            bird2_state <= 1'b0;
        end
    else if(gamemode == doublebird)
        begin
            if(state_number == start_scene)
                begin
                    bird2_life_number <= 3'd4;
                    bird2_state <= 1'b0;
                end
            else if(twink2_cnt == TWINK_CNT_MAX - 1'b1 && clk_150hz_flag == 1'b1)
                begin
                    bird2_life_number <= bird2_life_number;
                    bird2_state <= 1'b0;
                end
            else if(bird2_life_number > 1'b0)
                begin
                    if(state_number == custom2_scene)
                        begin
                            if(one_frame_end == 1'b1 && custom2_bird2_touch_number > CUSTOM2_DEAD_THRESHOLD && bird2_state == 1'b0)
                                begin
                                    bird2_life_number <= bird2_life_number - 1'b1;
                                    bird2_state <= 1'b1;
                                end
                            else
                                begin
                                    bird2_life_number <= bird2_life_number;
                                    bird2_state <= bird2_state;
                                end
                        end
                    else if(state_number == custom3_scene)
                        begin
                            if((custom3_bird2_en == 1'b1 && custom3_bird2_rom_data != 16'h0106) && (shell_en == 1'b1 && all_shell_rom_data != 16'h0106) && bird2_state == 1'b0)
                                begin
                                    bird2_life_number <= bird2_life_number - 1'b1;
                                    bird2_state <= 1'b1;
                                end
                            else
                                begin
                                    bird2_life_number <= bird2_life_number;
                                    bird2_state <= bird2_state;
                                end
                        end
                    else
                        begin
                            bird2_life_number <= bird2_life_number;
                            bird2_state <= bird2_state;
                        end
                end
            else
                begin
                    bird2_life_number <= bird2_life_number;
                    bird2_state <= bird2_state;
                end
        end
    else
        begin
            bird2_life_number <= 3'd0;
            bird2_state <= 1'b0;
        end

//闪烁状态计时器，进入闪烁状态开始计时，当达到最大值，回到正常状态
parameter   TWINK_CNT_MAX = 280;
reg [8:0]   twink1_cnt;
reg [8:0]   twink2_cnt;
always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        twink1_cnt <= 9'd0;
    else if(bird1_state == 1'b0)
        twink1_cnt <= 9'd0;
    else
        begin
            if(clk_150hz_flag == 1'b1)
                begin
                    if(twink1_cnt == TWINK_CNT_MAX - 1'b1)
                        twink1_cnt <= 9'd0;
                    else
                        twink1_cnt <= twink1_cnt + 1'b1;
                end
            else
                twink1_cnt <= twink1_cnt;
        end

always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        twink2_cnt <= 9'd0;
    else if(gamemode == doublebird)
        begin
            if(bird2_state == 1'b0)
                twink2_cnt <= 9'd0;
            else
                begin
                    if(clk_150hz_flag == 1'b1)
                        begin
                            if(twink2_cnt == TWINK_CNT_MAX - 1'b1)
                                twink2_cnt <= 9'd0;
                            else
                                twink2_cnt <= twink2_cnt + 1'b1;
                        end
                    else
                        twink2_cnt <= twink2_cnt;
                end
        end
    else
        twink2_cnt <= 9'd0;

//不同关卡显示小鸟的图象
reg     custom1_bird1_disable;

//关卡1
always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        custom1_bird1_disable <= 1'b0;
    else if(state_number == custom1_scene)
        begin
            if((twink1_cnt > 0 && twink1_cnt <= 35) || (twink1_cnt > 70 && twink1_cnt <= 105) || (twink1_cnt > 140 && twink1_cnt <= 175) || (twink1_cnt > 210 && twink1_cnt <= 245))
                custom1_bird1_disable <= 1'b1;
            else
                custom1_bird1_disable <= 1'b0;
        end
    else
        custom1_bird1_disable <= 1'b0;

//关卡2
reg     custom2_bird1_disable;
reg     custom2_bird2_disable;

//鸟1
always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        custom2_bird1_disable <= 1'b0;
    else if(state_number == custom2_scene)
        begin
            if((twink1_cnt > 0 && twink1_cnt <= 35) || (twink1_cnt > 70 && twink1_cnt <= 105) || (twink1_cnt > 140 && twink1_cnt <= 175) || (twink1_cnt > 210 && twink1_cnt <= 245))
                custom2_bird1_disable <= 1'b1;
            else
                custom2_bird1_disable <= 1'b0;
        end
    else
        custom2_bird1_disable <= 1'b0;

//鸟2
always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        custom2_bird2_disable <= 1'b0;
    else if(gamemode == doublebird)
        begin
            if(state_number == custom2_scene)
                begin
                    if((twink2_cnt > 0 && twink2_cnt <= 35) || (twink2_cnt > 70 && twink2_cnt <= 105) || (twink2_cnt > 140 && twink2_cnt <= 175) || (twink2_cnt > 210 && twink2_cnt <= 245))
                        custom2_bird2_disable <= 1'b1;
                    else
                        custom2_bird2_disable <= 1'b0;
                end
            else
                custom2_bird2_disable <= 1'b0;
        end
    else
        custom2_bird2_disable <= 1'b0;

//关卡3
reg     custom3_bird1_disable;
reg     custom3_bird2_disable;

//鸟1
always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        custom3_bird1_disable <= 1'b0;
    else if(state_number == custom3_scene)
        begin
            if((twink1_cnt > 0 && twink1_cnt <= 35) || (twink1_cnt > 70 && twink1_cnt <= 105) || (twink1_cnt > 140 && twink1_cnt <= 175) || (twink1_cnt > 210 && twink1_cnt <= 245))
                custom3_bird1_disable <= 1'b1;
            else
                custom3_bird1_disable <= 1'b0;
        end
    else
        custom3_bird1_disable <= 1'b0;

//鸟2
always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        custom3_bird2_disable <= 1'b0;
    else if(gamemode == doublebird)
        begin
            if(state_number == custom3_scene)
                begin
                    if((twink2_cnt > 0 && twink2_cnt <= 35) || (twink2_cnt > 70 && twink2_cnt <= 105) || (twink2_cnt > 140 && twink2_cnt <= 175) || (twink2_cnt > 210 && twink2_cnt <= 245))
                        custom3_bird2_disable <= 1'b1;
                    else
                        custom3_bird2_disable <= 1'b0;
                end
            else
                custom3_bird2_disable <= 1'b0;
        end
    else
        custom3_bird2_disable <= 1'b0;

/******************************************************************/
//小鸟全部死亡信号，即进入死亡界面的信号
/******************************************************************/
always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        allbird_dead <= 1'b0;
    else if(state_number == start_scene)
        allbird_dead <= 1'b0;
    else if(gamemode == singlebird)
        begin
            if(bird1_life_number == 3'd0)
                allbird_dead <= 1'b1;
            else
                allbird_dead <= allbird_dead;
        end
    else if(gamemode == doublebird)
        begin
            if(state_number == custom1_scene)
                begin
                    if(bird1_life_number == 3'd0)
                        allbird_dead <= 1'b1;
                    else
                        allbird_dead <= allbird_dead;
                end
            else
                begin
                    if(bird1_life_number == 3'd0 && bird2_life_number == 3'd0)
                        allbird_dead <= 1'b1;
                    else
                        allbird_dead <= allbird_dead;
                end
        end
    else
        allbird_dead <= allbird_dead;

/******************************************************************/
//第二关舵机移动地图部分
/******************************************************************/
reg     [8:0]   custom2_right_edge = 9'd300;

always@(posedge clk or negedge rst_n)
    if(!rst_n)
        SG90_en <= 1'b0;
    else if(state_number == custom2_scene)
        begin
            if((bird1_life_number != 3'd0 && custom2_bird1_x0 < custom2_right_edge) || (bird2_life_number != 3'd0 && custom2_bird2_x0 < custom2_right_edge))
                SG90_en <= 1'b1;
            else
                SG90_en <= 1'b0;
        end
    else
        SG90_en <= 1'b0;

/******************************************************************/
//显示部分
/******************************************************************/

//显示
always@(posedge clk or negedge rst_n) begin
    case (state_number)
start_scene:if(!rst_n)
                lcd_data <= 16'd0;
            else if(singlebutton_en_reg)
                lcd_data <= singlebutton_rom_data;
            else if(doublebutton_en_reg)
                lcd_data <= doublebutton_rom_data;
            else if(methodbutton_en_reg)
                lcd_data <= methodbutton_rom_data;
            else if(background_en_reg)begin
                lcd_data <= background_data;
            end
            else lcd_data= 16'd0;
method_scene:if(!rst_n)
                lcd_data <= 16'd0;
            else if(background_en_reg)begin
                lcd_data <= background_data;
            end
            else lcd_data= 16'd0;
        //游戏进行
custom1_scene:if(!rst_n)
                lcd_data <= 16'd0;
            else if(custom1_gun_en_reg && custom1_gun_rom_data != 16'h0106)
                lcd_data <= custom1_gun_rom_data;
            else if(bird1_life1_en_reg && bird_life_rom_data != 16'h0106)
                lcd_data <= bird_life_rom_data;
            else if(bird1_life2_en_reg && bird_life_rom_data != 16'h0106)
                lcd_data <= bird_life_rom_data;
            else if(bird1_life3_en_reg && bird_life_rom_data != 16'h0106)
                lcd_data <= bird_life_rom_data;
            else if(bird1_life4_en_reg && bird_life_rom_data != 16'h0106)
                lcd_data <= bird_life_rom_data;
            else if(custom1_count1_en_reg && custom1_count_rom_data != 16'h0106)
                lcd_data <= custom1_count_rom_data;
            else if(custom1_count2_en_reg && custom1_count_rom_data != 16'h0106)
                lcd_data <= custom1_count_rom_data;
            else if(custom1_count3_en_reg && custom1_count_rom_data != 16'h0106)
                lcd_data <= custom1_count_rom_data;
            else if(custom1_count4_en_reg && custom1_count_rom_data != 16'h0106)
                lcd_data <= custom1_count_rom_data;
            else if(custom1_count5_en_reg && custom1_count_rom_data != 16'h0106)
                lcd_data <= custom1_count_rom_data;
            else if(background_en_reg && background_data != 16'h0106)
                lcd_data <= background_data;
            else if(camera_en_reg == 1'b1)
                begin
                    if(custom1_bird1_disable == 1'b0)
                        lcd_data <= {16{first_camera_bit}};
                    else
                        lcd_data <= 16'h0000;
                end
            else lcd_data= 16'd0;
    //第二关
custom2_scene:if(!rst_n)
                lcd_data <= 16'd0;
            else if(bird1_life1_en_reg && bird_life_rom_data != 16'h0106)
                lcd_data <= bird_life_rom_data;
            else if(bird1_life2_en_reg && bird_life_rom_data != 16'h0106)
                lcd_data <= bird_life_rom_data;
            else if(bird1_life3_en_reg && bird_life_rom_data != 16'h0106)
                lcd_data <= bird_life_rom_data;
            else if(bird1_life4_en_reg && bird_life_rom_data != 16'h0106)
                lcd_data <= bird_life_rom_data;
            else if(bird2_life1_en_reg && bird_life_rom_data != 16'h0106)
                lcd_data <= bird_life_rom_data;
            else if(bird2_life2_en_reg && bird_life_rom_data != 16'h0106)
                lcd_data <= bird_life_rom_data;
            else if(bird2_life3_en_reg && bird_life_rom_data != 16'h0106)
                lcd_data <= bird_life_rom_data;
            else if(bird2_life4_en_reg && bird_life_rom_data != 16'h0106)
                lcd_data <= bird_life_rom_data;
            else if(custom2_bird1_en_reg && custom2_bird1_rom_data != 16'h0106 && custom2_bird1_disable == 1'b0)
                lcd_data <= custom2_bird1_rom_data;
            else if(custom2_bird2_en_reg && custom2_bird2_rom_data != 16'h0106 && custom2_bird2_disable == 1'b0)
                lcd_data <= custom2_bird2_rom_data;
            else if(sobel_en_reg && second_camera_data == 16'hffff)begin
                lcd_data <= second_camera_data;
            end
            else if(background_en_reg)begin
                lcd_data <= background_data;
            end
            else lcd_data= 16'd0;
    //第三关
custom3_scene:if(!rst_n)
                lcd_data <= 16'd0;
            else if(bird1_life1_en_reg && bird_life_rom_data != 16'h0106)
                lcd_data <= bird_life_rom_data;
            else if(bird1_life2_en_reg && bird_life_rom_data != 16'h0106)
                lcd_data <= bird_life_rom_data;
            else if(bird1_life3_en_reg && bird_life_rom_data != 16'h0106)
                lcd_data <= bird_life_rom_data;
            else if(bird1_life4_en_reg && bird_life_rom_data != 16'h0106)
                lcd_data <= bird_life_rom_data;
            else if(bird2_life1_en_reg && bird_life_rom_data != 16'h0106)
                lcd_data <= bird_life_rom_data;
            else if(bird2_life2_en_reg && bird_life_rom_data != 16'h0106)
                lcd_data <= bird_life_rom_data;
            else if(bird2_life3_en_reg && bird_life_rom_data != 16'h0106)
                lcd_data <= bird_life_rom_data;
            else if(bird2_life4_en_reg && bird_life_rom_data != 16'h0106)
                lcd_data <= bird_life_rom_data;
            else if(custom3_bird1_en_reg && custom3_bird1_rom_data != 16'h0106 && custom3_bird1_disable == 1'b0)
                lcd_data <= custom3_bird1_rom_data;
            else if(custom3_bird2_en_reg && custom3_bird2_rom_data != 16'h0106 && custom3_bird2_disable == 1'b0)
                lcd_data <= custom3_bird2_rom_data;
            else if(angle1_shell1_en_reg && all_shell_rom_data != 16'h0106)
                lcd_data <= all_shell_rom_data;
/*             else if(angle1_shell2_en_reg && all_shell_rom_data != 16'h0106)
                lcd_data <= all_shell_rom_data; */
            else if(angle2_shell1_en_reg && all_shell_rom_data != 16'h0106)
                lcd_data <= all_shell_rom_data;
/*             else if(angle2_shell2_en_reg && all_shell_rom_data != 16'h0106)
                lcd_data <= all_shell_rom_data; */
            else if(angle3_shell1_en_reg && all_shell_rom_data != 16'h0106)
                lcd_data <= all_shell_rom_data;
/*             else if(angle3_shell2_en_reg && all_shell_rom_data != 16'h0106)
                lcd_data <= all_shell_rom_data; */
            else if(angle4_shell1_en_reg && all_shell_rom_data != 16'h0106)
                lcd_data <= all_shell_rom_data;
/*             else if(angle4_shell2_en_reg && all_shell_rom_data != 16'h0106)
                lcd_data <= all_shell_rom_data; */
            else if(angle5_shell1_en_reg && all_shell_rom_data != 16'h0106)
                lcd_data <= all_shell_rom_data;
/*             else if(angle5_shell2_en_reg && all_shell_rom_data != 16'h0106)
                lcd_data <= all_shell_rom_data; */
            else if(angle6_shell1_en_reg && all_shell_rom_data != 16'h0106)
                lcd_data <= all_shell_rom_data;
/*             else if(angle6_shell2_en_reg && all_shell_rom_data != 16'h0106)
                lcd_data <= all_shell_rom_data; */
            else if(angle7_shell1_en_reg && all_shell_rom_data != 16'h0106)
                lcd_data <= all_shell_rom_data;
/*             else if(angle7_shell2_en_reg && all_shell_rom_data != 16'h0106)
                lcd_data <= all_shell_rom_data; */
            else if(angle8_shell1_en_reg && all_shell_rom_data != 16'h0106)
                lcd_data <= all_shell_rom_data;
/*             else if(angle8_shell2_en_reg && all_shell_rom_data != 16'h0106)
                lcd_data <= all_shell_rom_data; */
            else if(background_en)begin
                lcd_data <= background_data;
            end
            else lcd_data= 16'd0;
win_scene:  if(!rst_n)
                lcd_data <= 16'd0;
            else if(background_en_reg)begin
                lcd_data <= background_data;
            end
            else lcd_data = 16'd0;
//暂停界面
pause_scene:if(!rst_n)
            lcd_data <= 16'd0;
            else if(trianglebutton_en_reg)
                lcd_data <= trianglebutton_rom_data;
            else if(background_en_reg)begin
                lcd_data <= background_data;
            end
            else lcd_data = 16'd0;
        //结束菜单
gameover_scene:if(!rst_n)
                lcd_data <= 16'd0;
            else if(background_en_reg)begin
                lcd_data <= background_data;
            end          
            else lcd_data= 16'd0;
        default: lcd_data <= 16'd0;
    endcase
end

endmodule
