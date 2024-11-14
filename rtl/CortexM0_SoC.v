module CortexM0_SoC (
        input   wire            sys_clk         ,
        input   wire            RSTn            ,
        inout   wire            SWDIO           ,
        input   wire            SWCLK           ,
        inout   wire    [15:0]  PORTIO_GPIO0    ,
        inout   wire    [15:0]  PORTIO_GPIO1    ,
        input   wire            RXD_UART1       ,
        output  wire            TXD_UART1       ,
        input   wire            RXD_UART2       ,
        output  wire            TXD_UART2       ,

        //语音控制外部中断
        input   wire            exit_interrupt0 ,
        input   wire            exit_interrupt1 ,
        input   wire            exit_interrupt2 ,
        input   wire            exit_interrupt3 ,
        input   wire            exit_interrupt4 ,
        input   wire            exit_interrupt5 ,
        input   wire            exit_interrupt6 ,
        input   wire            exit_interrupt7 ,
        input   wire            exit_interrupt8 ,

        //左右麦克风接口
        input   wire            microphone_left ,
        input   wire            microphone_right,
        input   wire            microphone_up   ,
        input   wire            microphone_down ,

        output  wire            SG90_PWM_out    ,

        input   wire            first_custom_button ,
        input   wire            second_custom_button,
        input   wire            third_custom_button ,
        input   wire            exit_game_button    ,

        input   wire            cam_pclk        ,  //cmos 数据像素时钟
        input   wire            cam_vsync       ,  //cmos 场同步信号
        input   wire            cam_href        ,  //cmos 行同步信号
        input   wire    [7:0]   cam_data        ,  //cmos 数据  
        output  wire            cam_rst_n       ,  //cmos 复位信号，低电平有效
        output  wire            cam_pwdn        ,  //cmos 电源休眠模式选择信号
        output  wire            cam_scl         ,  //cmos SCCB_SCL线
        inout   wire            cam_sda         ,  //cmos SCCB_SDA线                         //占用16个端口

        //hdmi接口
        output  wire            tmds_clk_p      ,  // TMDS 时钟通道
        output  wire            tmds_clk_n      ,
        output  wire    [2:0]   tmds_data_p     ,  // TMDS 数据通道
        output  wire    [2:0]   tmds_data_n     ,                                           //占用8个端口

        //sd卡接口
        input   wire            sd_miso         ,      //SD卡SPI串行输入数据信号
        output  wire            sd_clk          ,      //SD卡SPI时钟信号
        output  wire            sd_cs           ,      //SD卡SPI片选信号
        output  wire            sd_mosi         ,      //SD卡SPI串行输出数据信号             //占用4个端口

        //SDRAM接口
        output  wire            sdram_clk       ,  //SDRAM 时钟
        output  wire            sdram_cke       ,  //SDRAM 时钟有效
        output  wire            sdram_cs_n      ,  //SDRAM 片选
        output  wire            sdram_ras_n     ,  //SDRAM 行有效
        output  wire            sdram_cas_n     ,  //SDRAM 列有效
        output  wire            sdram_we_n      ,  //SDRAM 写有效
        output  wire    [1:0]   sdram_ba        ,  //SDRAM Bank地址
        output  wire    [1:0]   sdram_dqm       ,  //SDRAM 数据掩码
        output  wire    [11:0]  sdram_addr      ,  //SDRAM 地址
        inout   wire    [15:0]  sdram_data      ,  //SDRAM 数据

        //通信端口
        output  wire            first_camera_clk,
        output  wire            first_rden      ,
        input   wire            first_camera_bit,
        output  wire            FPGAtwo_rst_n   ,
        
        output  wire            Servo_up        ,
        output  wire            Servo_down      ,
        output  wire            Servo_left      ,
        output  wire            Servo_right     ,
        output  wire            Servo_rst       ,
        output  wire            Servo_track_en  ,

        output  wire            fourth_rstn     ,
        output  wire            fourth_up       ,   // 32
        output  wire            fourth_left     ,   // 33
        output  wire            fourth_right        // 34
);

wire    locked;
wire    hdmi_locked;

wire    clk_50m;
wire    clk_100m;
wire    clk_100m_shift;
wire    sd_card_clk;
wire    sd_card_clk_n;
wire    hdmi_clk;
wire    hdmi_5clk;
wire    clk;

pll u_pll
(
    .refclk         (sys_clk        ),
    .reset          (~RSTn          ),
    .clk0_out       (clk_50m        ),  //摄像头驱动时钟——50Mhz
    .clk1_out       (clk_100m       ),
    .clk2_out       (clk_100m_shift ),  //sdram驱动时钟——100Mhz
    .clk3_out       (sd_card_clk    ),
    .clk4_out       (sd_card_clk_n  ),  //sd卡驱动时钟——50Mhz
    .extlock        (locked         )
);

hdmi_pll u_hdmi_pll
(
    .refclk         (sys_clk        ),
    .reset          (~RSTn          ),
    .clk0_out       (clk            ),  //系统时钟——40Mhz
    .clk1_out       (hdmi_clk       ),
    .clk2_out       (hdmi_5clk      ),  //hdmi驱动时钟——60Mhz
    .extlock        (hdmi_locked    )
);

//------------------------------------------------------------------------------
// DEBUG IOBUF 
//------------------------------------------------------------------------------

wire SWDO;
wire SWDOEN;
wire SWDI;

assign SWDI = SWDIO;
assign SWDIO = (SWDOEN) ?  SWDO : 1'bz;

//------------------------------------------------------------------------------
// Interrupt
//------------------------------------------------------------------------------

wire [31:0] IRQ;

wire RXEV;
assign RXEV = 1'b0;

//------------------------------------------------------------------------------
// AHB
//------------------------------------------------------------------------------

wire    [31:0]  HADDR;
wire    [ 2:0]  HBURST;
wire            HMASTLOCK;
wire    [ 3:0]  HPROT;
wire    [ 2:0]  HSIZE;
wire    [ 1:0]  HTRANS;
wire    [31:0]  HWDATA;
wire            HWRITE;
wire    [31:0]  HRDATA;
wire            HRESP;
wire            HMASTER;
wire            HREADY;

//------------------------------------------------------------------------------
// RESET AND DEBUG
//------------------------------------------------------------------------------

wire SYSRESETREQ;
reg cpuresetn;

always @(posedge clk or negedge RSTn)begin
        if (~RSTn) cpuresetn <= 1'b0;
        else if(locked == 1'b0 || hdmi_locked == 1'b0)   cpuresetn <= 1'b0;
        else if(SYSRESETREQ)    cpuresetn <= 1'b0;
        else cpuresetn <= 1'b1;
end

assign  FPGAtwo_rst_n = cpuresetn;
assign  fourth_rstn = cpuresetn;

wire CDBGPWRUPREQ;
reg CDBGPWRUPACK;

always @(posedge clk or negedge RSTn)begin
        if (~RSTn) CDBGPWRUPACK <= 1'b0;
        else CDBGPWRUPACK <= CDBGPWRUPREQ;
end


//------------------------------------------------------------------------------
// Instantiate Cortex-M0 processor logic level
//------------------------------------------------------------------------------

cortexm0ds_logic u_logic (

        // System inputs
        .FCLK           (clk),           //FREE running clock 
        .SCLK           (clk),           //system clock
        .HCLK           (clk),           //AHB clock
        .DCLK           (clk),           //Debug clock
        .PORESETn       (RSTn),          //Power on reset
        .HRESETn        (cpuresetn),     //AHB and System reset
        .DBGRESETn      (RSTn),          //Debug Reset
        .RSTBYPASS      (1'b0),          //Reset bypass
        .SE             (1'b0),          // dummy scan enable port for synthesis

        // Power management inputs
        .SLEEPHOLDREQn  (1'b1),          // Sleep extension request from PMU
        .WICENREQ       (1'b0),          // WIC enable request from PMU
        .CDBGPWRUPACK   (CDBGPWRUPACK),  // Debug Power Up ACK from PMU

        // Power management outputs
        .CDBGPWRUPREQ   (CDBGPWRUPREQ),
        .SYSRESETREQ    (SYSRESETREQ),

        // System bus
        .HADDR          (HADDR[31:0]),
        .HTRANS         (HTRANS[1:0]),
        .HSIZE          (HSIZE[2:0]),
        .HBURST         (HBURST[2:0]),
        .HPROT          (HPROT[3:0]),
        .HMASTER        (HMASTER),
        .HMASTLOCK      (HMASTLOCK),
        .HWRITE         (HWRITE),
        .HWDATA         (HWDATA[31:0]),
        .HRDATA         (HRDATA[31:0]),
        .HREADY         (HREADY),
        .HRESP          (HRESP),

        // Interrupts
        .IRQ            (IRQ),          //Interrupt
        .NMI            (1'b0),         //Watch dog interrupt
        .IRQLATENCY     (8'h0),
        .ECOREVNUM      (28'h0),

        // Systick
        .STCLKEN        (1'b0),
        .STCALIB        (26'h0),

        // Debug - JTAG or Serial wire
        // Inputs
        .nTRST          (1'b1),
        .SWDITMS        (SWDI),
        .SWCLKTCK       (SWCLK),
        .TDI            (1'b0),
        // Outputs
        .SWDO           (SWDO),
        .SWDOEN         (SWDOEN),

        .DBGRESTART     (1'b0),

        // Event communication
        .RXEV           (RXEV),         // Generate event when a DMA operation completed.
        .EDBGRQ         (1'b0)          // multi-core synchronous halt request
);

//------------------------------------------------------------------------------
// AHBlite Interconncet
//------------------------------------------------------------------------------

wire            HSEL_P0;
wire    [31:0]  HADDR_P0;
wire    [2:0]   HBURST_P0;
wire            HMASTLOCK_P0;
wire    [3:0]   HPROT_P0;
wire    [2:0]   HSIZE_P0;
wire    [1:0]   HTRANS_P0;
wire    [31:0]  HWDATA_P0;
wire            HWRITE_P0;
wire            HREADY_P0;
wire            HREADYOUT_P0;
wire    [31:0]  HRDATA_P0;
wire            HRESP_P0;

wire            HSEL_P1;
wire    [31:0]  HADDR_P1;
wire    [2:0]   HBURST_P1;
wire            HMASTLOCK_P1;
wire    [3:0]   HPROT_P1;
wire    [2:0]   HSIZE_P1;
wire    [1:0]   HTRANS_P1;
wire    [31:0]  HWDATA_P1;
wire            HWRITE_P1;
wire            HREADY_P1;
wire            HREADYOUT_P1;
wire    [31:0]  HRDATA_P1;
wire            HRESP_P1;

wire            HSEL_P2;
wire    [31:0]  HADDR_P2;
wire    [2:0]   HBURST_P2;
wire            HMASTLOCK_P2;
wire    [3:0]   HPROT_P2;
wire    [2:0]   HSIZE_P2;
wire    [1:0]   HTRANS_P2;
wire    [31:0]  HWDATA_P2;
wire            HWRITE_P2;
wire            HREADY_P2;
wire            HREADYOUT_P2;
wire    [31:0]  HRDATA_P2;
wire            HRESP_P2;

wire            HSEL_P3;
wire    [31:0]  HADDR_P3;
wire    [2:0]   HBURST_P3;
wire            HMASTLOCK_P3;
wire    [3:0]   HPROT_P3;
wire    [2:0]   HSIZE_P3;
wire    [1:0]   HTRANS_P3;
wire    [31:0]  HWDATA_P3;
wire            HWRITE_P3;
wire            HREADY_P3;
wire            HREADYOUT_P3;
wire    [31:0]  HRDATA_P3;
wire            HRESP_P3;

AHBlite_Interconnect Interconncet(
        .HCLK           (clk),
        .HRESETn        (cpuresetn),

        // CORE SIDE
        .HADDR          (HADDR),
        .HTRANS         (HTRANS),
        .HSIZE          (HSIZE),
        .HBURST         (HBURST),
        .HPROT          (HPROT),
        .HMASTLOCK      (HMASTLOCK),
        .HWRITE         (HWRITE),
        .HWDATA         (HWDATA),
        .HRDATA         (HRDATA),
        .HREADY         (HREADY),
        .HRESP          (HRESP),

        // P0
        .HSEL_P0        (HSEL_P0),
        .HADDR_P0       (HADDR_P0),
        .HBURST_P0      (HBURST_P0),
        .HMASTLOCK_P0   (HMASTLOCK_P0),
        .HPROT_P0       (HPROT_P0),
        .HSIZE_P0       (HSIZE_P0),
        .HTRANS_P0      (HTRANS_P0),
        .HWDATA_P0      (HWDATA_P0),
        .HWRITE_P0      (HWRITE_P0),
        .HREADY_P0      (HREADY_P0),
        .HREADYOUT_P0   (HREADYOUT_P0),
        .HRDATA_P0      (HRDATA_P0),
        .HRESP_P0       (HRESP_P0),

        // P1
        .HSEL_P1        (HSEL_P1),
        .HADDR_P1       (HADDR_P1),
        .HBURST_P1      (HBURST_P1),
        .HMASTLOCK_P1   (HMASTLOCK_P1),
        .HPROT_P1       (HPROT_P1),
        .HSIZE_P1       (HSIZE_P1),
        .HTRANS_P1      (HTRANS_P1),
        .HWDATA_P1      (HWDATA_P1),
        .HWRITE_P1      (HWRITE_P1),
        .HREADY_P1      (HREADY_P1),
        .HREADYOUT_P1   (HREADYOUT_P1),
        .HRDATA_P1      (HRDATA_P1),
        .HRESP_P1       (HRESP_P1),

        // P2
        .HSEL_P2        (HSEL_P2),
        .HADDR_P2       (HADDR_P2),
        .HBURST_P2      (HBURST_P2),
        .HMASTLOCK_P2   (HMASTLOCK_P2),
        .HPROT_P2       (HPROT_P2),
        .HSIZE_P2       (HSIZE_P2),
        .HTRANS_P2      (HTRANS_P2),
        .HWDATA_P2      (HWDATA_P2),
        .HWRITE_P2      (HWRITE_P2),
        .HREADY_P2      (HREADY_P2),
        .HREADYOUT_P2   (HREADYOUT_P2),
        .HRDATA_P2      (HRDATA_P2),
        .HRESP_P2       (HRESP_P2),

        // P3
        .HSEL_P3        (HSEL_P3),
        .HADDR_P3       (HADDR_P3),
        .HBURST_P3      (HBURST_P3),
        .HMASTLOCK_P3   (HMASTLOCK_P3),
        .HPROT_P3       (HPROT_P3),
        .HSIZE_P3       (HSIZE_P3),
        .HTRANS_P3      (HTRANS_P3),
        .HWDATA_P3      (HWDATA_P3),
        .HWRITE_P3      (HWRITE_P3),
        .HREADY_P3      (HREADY_P3),
        .HREADYOUT_P3   (HREADYOUT_P3),
        .HRDATA_P3      (HRDATA_P3),
        .HRESP_P3       (HRESP_P3)
);

//------------------------------------------------------------------------------
// AHB RAMCODE 0x00000000-0x0000ffff
//------------------------------------------------------------------------------

wire [31:0] ROM_RDATA;
wire [31:0] ROM_WDATA;
wire [11:0] ROM_ADDR;
wire [3:0]  ROM_WRITE;
wire        ROMCS;

cmsdk_ahb_to_sram
#(
    .AW(14)
)
(
    .HCLK     (clk),            // system bus clock
    .HRESETn  (cpuresetn),      // system bus reset
    .HSEL     (HSEL_P0),        // AHB peripheral select
    .HREADY   (HREADY_P0),      // AHB ready input
    .HTRANS   (HTRANS_P0),      // AHB transfer type
    .HSIZE    (HSIZE_P0),       // AHB hsize
    .HWRITE   (HWRITE_P0),      // AHB hwrite
    .HADDR    (HADDR_P0),       // AHB address bus
    .HWDATA   (HWDATA_P0),      // AHB write data bus
    .HREADYOUT(HREADYOUT_P0),   // AHB ready output to S->M mux
    .HRESP    (HRESP_P0),       // AHB response
    .HRDATA   (HRDATA_P0),      // AHB read data bus

    .SRAMRDATA(ROM_RDATA),      // SRAM Read Data
    .SRAMADDR (ROM_ADDR),       // SRAM address
    .SRAMWEN  (ROM_WRITE),      // SRAM write enable (active high)
    .SRAMWDATA(ROM_WDATA),      // SRAM write data
    .SRAMCS   (ROMCS)
);

fpga_rom ROM
(
    // Inputs
    .CLK  (clk),
    .ADDR (ROM_ADDR),
    .WDATA(ROM_WDATA),
    .WREN (ROM_WRITE),
    .CS   (ROMCS),

    // Outputs
    .RDATA(ROM_RDATA)
);

//------------------------------------------------------------------------------
// AHB RAMDATA 0X20000000-0X2000FFFF
//------------------------------------------------------------------------------

wire [31:0] RAM_RDATA;
wire [31:0] RAM_WDATA;
wire [11:0] RAM_ADDR;
wire [3:0]  RAM_WRITE;
wire        RAMCS;

cmsdk_ahb_to_sram
#(
    .AW(14)
)
(
    .HCLK     (clk),      // system bus clock
    .HRESETn  (cpuresetn),   // system bus reset
    .HSEL     (HSEL_P1),      // AHB peripheral select
    .HREADY   (HREADY_P1),    // AHB ready input
    .HTRANS   (HTRANS_P1),    // AHB transfer type
    .HSIZE    (HSIZE_P1),     // AHB hsize
    .HWRITE   (HWRITE_P1),    // AHB hwrite
    .HADDR    (HADDR_P1),     // AHB address bus
    .HWDATA   (HWDATA_P1),    // AHB write data bus
    .HREADYOUT(HREADYOUT_P1), // AHB ready output to S->M mux
    .HRESP    (HRESP_P1),     // AHB response
    .HRDATA   (HRDATA_P1),    // AHB read data bus

    .SRAMRDATA(RAM_RDATA), // SRAM Read Data
    .SRAMADDR (RAM_ADDR),  // SRAM address
    .SRAMWEN  (RAM_WRITE),   // SRAM write enable (active high)
    .SRAMWDATA(RAM_WDATA), // SRAM write data
    .SRAMCS   (RAMCS)
);

fpga_ram RAM
(
    // Inputs
    .CLK  (clk),
    .ADDR (RAM_ADDR),
    .WDATA(RAM_WDATA),
    .WREN (RAM_WRITE),
    .CS   (RAMCS),

    // Outputs
    .RDATA(RAM_RDATA)
);

//------------------------------------------------------------------------------
// AHB Bridge 0x40000000-0x4000ffff
//------------------------------------------------------------------------------

wire    gpio0_hsel;
wire    gpio1_hsel;
/* wire    gpio2_hsel; */
wire    flybird_hsel;
wire    SPTimer0_hsel;
wire    SPTimer1_hsel;
/* wire    SPTimer2_hsel; */
wire    seg_hsel;
wire    Communication_hsel;
wire    Microphone_hsel;
wire    SG90_hsel;

cmsdk_mcu_addr_decode #(
  .BASEADDR_GPIO0           (32'h4000_0000),
  .BASEADDR_GPIO1           (32'h4000_1000),
  .BASEADDR_GPIO2           (32'h4000_2000),
  .BASEADDR_FLYBIRDGAME     (32'h4000_3000),
  .BASEADDR_SPTIMER0        (32'h4000_4000),
  .BASEADDR_SPTIMER1        (32'h4000_5000),
  .BASEADDR_SPTIMER2        (32'h4000_6000),
  .BASEADDR_SEG             (32'h4000_7000),
  .BASEADDR_COMMUNICATION   (32'h4000_8000),
  .BASEADDR_MICROPHONE      (32'h4000_9000),
  .BASEADDR_SG90            (32'h4000_a000)
 )
 cmsdk_mcu_addr_decode_inst
 (
    .haddr              (HADDR_P2),

    .gpio0_hsel         (gpio0_hsel),
    .gpio1_hsel         (gpio1_hsel),
    .gpio2_hsel         (/* gpio2_hsel */),
    .flybird_hsel       (flybird_hsel),
    .SPTimer0_hsel      (SPTimer0_hsel),
    .SPTimer1_hsel      (SPTimer1_hsel),
    .SPTimer2_hsel      (/* SPTimer2_hsel */),
    .seg_hsel           (/* seg_hsel */),
    .Communication_hsel (Communication_hsel),
    .Microphone_hsel    (Microphone_hsel),
    .SG90_hsel          (SG90_hsel)
    );

wire            HREADYOUT_GPIO0;
wire            HRESP_GPIO0;
wire    [31:0]  HRDATA_GPIO0;

wire            HREADYOUT_GPIO1;
wire            HRESP_GPIO1;
wire    [31:0]  HRDATA_GPIO1;

/* wire            HREADYOUT_GPIO2;
wire            HRESP_GPIO2;
wire    [31:0]  HRDATA_GPIO2; */

wire            HREADYOUT_FLYBIRD;
wire            HRESP_FLYBIRD;
wire    [31:0]  HRDATA_FLYBIRD;

wire            HREADYOUT_SPTIMER0;
wire            HRESP_SPTIMER0;
wire    [31:0]  HRDATA_SPTIMER0;

wire            HREADYOUT_SPTIMER1;
wire            HRESP_SPTIMER1;
wire    [31:0]  HRDATA_SPTIMER1;

/* wire            HREADYOUT_SPTIMER2;
wire            HRESP_SPTIMER2;
wire    [31:0]  HRDATA_SPTIMER2; */

/* wire            HREADYOUT_SEG;
wire            HRESP_SEG;
wire    [31:0]  HRDATA_SEG; */

/* wire            HREADYOUT_SPTIMER3;
wire            HRESP_SPTIMER3;
wire    [31:0]  HRDATA_SPTIMER3; */

wire            HREADYOUT_COMMUNICATION;
wire            HRESP_COMMUNICATION;
wire    [31:0]  HRDATA_COMMUNICATION;

wire            HREADYOUT_MICROPHONE;
wire            HRESP_MICROPHONE;
wire    [31:0]  HRDATA_MICROPHONE;

wire            HREADYOUT_SG90;
wire            HRESP_SG90;
wire    [31:0]  HRDATA_SG90;

cmsdk_ahb_slave_mux #(
  .PORT0_ENABLE(1),
  .PORT1_ENABLE(1),
  .PORT2_ENABLE(0),
  .PORT3_ENABLE(1),
  .PORT4_ENABLE(1),
  .PORT5_ENABLE(1),
  .PORT6_ENABLE(0),
  .PORT7_ENABLE(0),
  .PORT8_ENABLE(1),
  .PORT9_ENABLE(1),
  .PORT10_ENABLE(1),

  .DW(32)
 )
 cmsdk_ahb_slave_mux_inst
 (
        .HCLK         (clk),
        .HRESETn      (cpuresetn),
  
        .HSEL0        (gpio0_hsel),         // HSEL for AHB Slave #0
        .HREADYOUT0   (HREADYOUT_GPIO0),    // HREADY for Slave connection #0
        .HRESP0       (HRESP_GPIO0),        // HRESP  for slave connection #0
        .HRDATA0      (HRDATA_GPIO0),       // HRDATA for slave connection #0
  
        .HSEL1        (gpio1_hsel),         // HSEL for AHB Slave #1
        .HREADYOUT1   (HREADYOUT_GPIO1),    // HREADY for Slave connection #1
        .HRESP1       (HRESP_GPIO1),        // HRESP  for slave connection #1
        .HRDATA1      (HRDATA_GPIO1),       // HRDATA for slave connection #1
  
        .HSEL2        (/* gpio2_hsel */1'b0),         // HSEL for AHB Slave #2
        .HREADYOUT2   (/* HREADYOUT_GPIO2 */1'b0),    // HREADY for Slave connection #2
        .HRESP2       (/* HRESP_GPIO2 */1'b0),        // HRESP  for slave connection #2
        .HRDATA2      (/* HRDATA_GPIO2 */32'd0),       // HRDATA for slave connection #2
  
        .HSEL3        (flybird_hsel),       // HSEL for AHB Slave #3
        .HREADYOUT3   (HREADYOUT_FLYBIRD),  // HREADY for Slave connection #3
        .HRESP3       (HRESP_FLYBIRD),      // HRESP  for slave connection #3
        .HRDATA3      (HRDATA_FLYBIRD),     // HRDATA for slave connection #3
  
        .HSEL4        (SPTimer0_hsel),      // HSEL for AHB Slave #4
        .HREADYOUT4   (HREADYOUT_SPTIMER0), // HREADY for Slave connection #4
        .HRESP4       (HRESP_SPTIMER0),     // HRESP  for slave connection #4
        .HRDATA4      (HRDATA_SPTIMER0),    // HRDATA for slave connection #4
  
        .HSEL5        (SPTimer1_hsel),      // HSEL for AHB Slave #5
        .HREADYOUT5   (HREADYOUT_SPTIMER1), // HREADY for Slave connection #5
        .HRESP5       (HRESP_SPTIMER1),     // HRESP  for slave connection #5
        .HRDATA5      (HRDATA_SPTIMER1),    // HRDATA for slave connection #5
  
        .HSEL6        (/* SPTimer2_hsel */1'b0),      // HSEL for AHB Slave #6
        .HREADYOUT6   (/* HREADYOUT_SPTIMER2 */1'b0), // HREADY for Slave connection #6
        .HRESP6       (/* HRESP_SPTIMER2 */1'b0),     // HRESP  for slave connection #6
        .HRDATA6      (/* HRDATA_SPTIMER2 */32'd0),    // HRDATA for slave connection #6
  
        .HSEL7        (/* seg_hsel */1'b0),           // HSEL for AHB Slave #7
        .HREADYOUT7   (/* HREADYOUT_SEG */1'b0),      // HREADY for Slave connection #7
        .HRESP7       (/* HRESP_SEG */1'b0),          // HRESP  for slave connection #7
        .HRDATA7      (/* HRDATA_SEG */32'd0),         // HRDATA for slave connection #7

        .HSEL8        (Communication_hsel),          // HSEL for AHB Slave #8
        .HREADYOUT8   (HREADYOUT_COMMUNICATION),     // HREADY for Slave connection #8
        .HRESP8       (HRESP_COMMUNICATION),         // HRESP  for slave connection #8
        .HRDATA8      (HRDATA_COMMUNICATION),        // HRDATA for slave connection #8
  
        .HSEL9        (Microphone_hsel),        // HSEL for AHB Slave #9
        .HREADYOUT9   (HREADYOUT_MICROPHONE),   // HREADY for Slave connection #9
        .HRESP9       (HRESP_MICROPHONE),       // HRESP  for slave connection #9
        .HRDATA9      (HRDATA_MICROPHONE),      // HRDATA for slave connection #9

        .HSEL10       (SG90_hsel),              // HSEL for AHB Slave #10
        .HREADYOUT10  (HREADYOUT_SG90),         // HREADY for Slave connection #10
        .HRESP10      (HRESP_SG90),             // HRESP  for slave connection #10
        .HRDATA10     (HRDATA_SG90),            // HRDATA for slave connection #10
  
        .HREADY       (HREADY_P2),     // Bus ready
        .HREADYOUT    (HREADYOUT_P2),  // HREADY output to AHB master and AHB slaves
        .HRESP        (HRESP_P2),      // HRESP to AHB master
        .HRDATA       (HRDATA_P2)   // Read data to AHB master
  );

//------------------------------------------------------------------------------
// GPIO0 0x40000000
//------------------------------------------------------------------------------

wire    [15:0]  GPIOINT_GPIO0;
wire            COMBINT_GPIO0;
wire    [15:0]  PORTIN_GPIO0;
wire    [15:0]  PORTOUT_GPIO0;
wire    [15:0]  PORTEN_GPIO0;
wire    [15:0]  PORTFUNC_GPIO0;

cmsdk_ahb_gpio GPIO0
(// AHB Inputs
   .HCLK             (clk),      // system bus clock
   .HRESETn          (cpuresetn),   // system bus reset
   .FCLK             (clk),      // system bus clock
   .HSEL             (gpio0_hsel),      // AHB peripheral select
   .HREADY           (HREADY_P2),    // AHB ready input
   .HTRANS           (HTRANS_P2),    // AHB transfer type
   .HSIZE            (HSIZE_P2),     // AHB hsize
   .HWRITE           (HWRITE_P2),    // AHB hwrite
   .HADDR            (HADDR_P2[11:0]),     // AHB address bus
   .HWDATA           (HWDATA_P2),    // AHB write data bus

   .ECOREVNUM        (4'b0000),  // Engineering-change-order revision bits

   .PORTIN           (PORTIN_GPIO0),     // GPIO Interface input


   .HREADYOUT        (HREADYOUT_GPIO0), // AHB ready output to S->M mux
   .HRESP            (HRESP_GPIO0),     // AHB response
   .HRDATA           (HRDATA_GPIO0),

   .PORTOUT          (PORTOUT_GPIO0),    // GPIO output
   .PORTEN           (PORTEN_GPIO0),     // GPIO output enable
   .PORTFUNC         (PORTFUNC_GPIO0),

   .GPIOINT          (GPIOINT_GPIO0),    // Interrupt output for each pin
   .COMBINT          (COMBINT_GPIO0));   // Combined interrupt

assign PORTIN_GPIO0 = PORTIO_GPIO0;
assign PORTIO_GPIO0[0 ] = PORTEN_GPIO0[0 ] ? PORTOUT_GPIO0[0 ]:1'bz;
assign PORTIO_GPIO0[1 ] = PORTEN_GPIO0[1 ] ? PORTOUT_GPIO0[1 ]:1'bz;
assign PORTIO_GPIO0[2 ] = PORTEN_GPIO0[2 ] ? PORTOUT_GPIO0[2 ]:1'bz;
assign PORTIO_GPIO0[3 ] = PORTEN_GPIO0[3 ] ? PORTOUT_GPIO0[3 ]:1'bz;
assign PORTIO_GPIO0[4 ] = PORTEN_GPIO0[4 ] ? PORTOUT_GPIO0[4 ]:1'bz;
assign PORTIO_GPIO0[5 ] = PORTEN_GPIO0[5 ] ? PORTOUT_GPIO0[5 ]:1'bz;
assign PORTIO_GPIO0[6 ] = PORTEN_GPIO0[6 ] ? PORTOUT_GPIO0[6 ]:1'bz;
assign PORTIO_GPIO0[7 ] = PORTEN_GPIO0[7 ] ? PORTOUT_GPIO0[7 ]:1'bz;
assign PORTIO_GPIO0[8 ] = PORTEN_GPIO0[8 ] ? PORTOUT_GPIO0[8 ]:1'bz;
assign PORTIO_GPIO0[9 ] = PORTEN_GPIO0[9 ] ? PORTOUT_GPIO0[9 ]:1'bz;
assign PORTIO_GPIO0[10] = PORTEN_GPIO0[10] ? PORTOUT_GPIO0[10]:1'bz;
assign PORTIO_GPIO0[11] = PORTEN_GPIO0[11] ? PORTOUT_GPIO0[11]:1'bz;
assign PORTIO_GPIO0[12] = PORTEN_GPIO0[12] ? PORTOUT_GPIO0[12]:1'bz;
assign PORTIO_GPIO0[13] = PORTEN_GPIO0[13] ? PORTOUT_GPIO0[13]:1'bz;
assign PORTIO_GPIO0[14] = PORTEN_GPIO0[14] ? PORTOUT_GPIO0[14]:1'bz;
assign PORTIO_GPIO0[15] = PORTEN_GPIO0[15] ? PORTOUT_GPIO0[15]:1'bz;

//------------------------------------------------------------------------------
// GPIO1 0x40001000
//------------------------------------------------------------------------------

wire    [15:0]  GPIOINT_GPIO1;
wire            COMBINT_GPIO1;
wire    [15:0]  PORTIN_GPIO1;
wire    [15:0]  PORTOUT_GPIO1;
wire    [15:0]  PORTEN_GPIO1;
wire    [15:0]  PORTFUNC_GPIO1;

cmsdk_ahb_gpio GPIO1
  (// AHB Inputs
   .HCLK             (clk),      // system bus clock
   .HRESETn          (cpuresetn),   // system bus reset
   .FCLK             (clk),      // system bus clock
   .HSEL             (gpio1_hsel),      // AHB peripheral select
   .HREADY           (HREADY_P2),    // AHB ready input
   .HTRANS           (HTRANS_P2),    // AHB transfer type
   .HSIZE            (HSIZE_P2),     // AHB hsize
   .HWRITE           (HWRITE_P2),    // AHB hwrite
   .HADDR            (HADDR_P2[11:0]),     // AHB address bus
   .HWDATA           (HWDATA_P2),    // AHB write data bus

   .ECOREVNUM        (4'b0000),  // Engineering-change-order revision bits

   .PORTIN           (PORTIN_GPIO1),     // GPIO Interface input

   .HREADYOUT        (HREADYOUT_GPIO1), // AHB ready output to S->M mux
   .HRESP            (HRESP_GPIO1),     // AHB response
   .HRDATA           (HRDATA_GPIO1),

   .PORTOUT          (PORTOUT_GPIO1),    // GPIO output
   .PORTEN           (PORTEN_GPIO1),     // GPIO output enable
   .PORTFUNC         (PORTFUNC_GPIO1),

   .GPIOINT          (GPIOINT_GPIO1),    // Interrupt output for each pin
   .COMBINT          (COMBINT_GPIO1));   // Combined interrupt

assign PORTIN_GPIO1 = PORTIO_GPIO1;
assign PORTIO_GPIO1[0 ] = PORTEN_GPIO1[0 ] ? PORTOUT_GPIO1[0 ]:1'bz;
assign PORTIO_GPIO1[1 ] = PORTEN_GPIO1[1 ] ? PORTOUT_GPIO1[1 ]:1'bz;
assign PORTIO_GPIO1[2 ] = PORTEN_GPIO1[2 ] ? PORTOUT_GPIO1[2 ]:1'bz;
assign PORTIO_GPIO1[3 ] = PORTEN_GPIO1[3 ] ? PORTOUT_GPIO1[3 ]:1'bz;
assign PORTIO_GPIO1[4 ] = PORTEN_GPIO1[4 ] ? PORTOUT_GPIO1[4 ]:1'bz;
assign PORTIO_GPIO1[5 ] = PORTEN_GPIO1[5 ] ? PORTOUT_GPIO1[5 ]:1'bz;
assign PORTIO_GPIO1[6 ] = PORTEN_GPIO1[6 ] ? PORTOUT_GPIO1[6 ]:1'bz;
assign PORTIO_GPIO1[7 ] = PORTEN_GPIO1[7 ] ? PORTOUT_GPIO1[7 ]:1'bz;
assign PORTIO_GPIO1[8 ] = PORTEN_GPIO1[8 ] ? PORTOUT_GPIO1[8 ]:1'bz;
assign PORTIO_GPIO1[9 ] = PORTEN_GPIO1[9 ] ? PORTOUT_GPIO1[9 ]:1'bz;
assign PORTIO_GPIO1[10] = PORTEN_GPIO1[10] ? PORTOUT_GPIO1[10]:1'bz;
assign PORTIO_GPIO1[11] = PORTEN_GPIO1[11] ? PORTOUT_GPIO1[11]:1'bz;
assign PORTIO_GPIO1[12] = PORTEN_GPIO1[12] ? PORTOUT_GPIO1[12]:1'bz;
assign PORTIO_GPIO1[13] = PORTEN_GPIO1[13] ? PORTOUT_GPIO1[13]:1'bz;
assign PORTIO_GPIO1[14] = PORTEN_GPIO1[14] ? PORTOUT_GPIO1[14]:1'bz;
assign PORTIO_GPIO1[15] = PORTEN_GPIO1[15] ? PORTOUT_GPIO1[15]:1'bz;

//------------------------------------------------------------------------------
// GPIO2 0x40002000
//------------------------------------------------------------------------------

/* wire    [15:0]  GPIOINT_GPIO2;
wire            COMBINT_GPIO2;
wire    [15:0]  PORTIN_GPIO2;
wire    [15:0]  PORTOUT_GPIO2;
wire    [15:0]  PORTEN_GPIO2;
wire    [15:0]  PORTFUNC_GPIO2;

cmsdk_ahb_gpio GPIO2
  (// AHB Inputs
   .HCLK             (clk),      // system bus clock
   .HRESETn          (cpuresetn),   // system bus reset
   .FCLK             (clk),      // system bus clock
   .HSEL             (gpio2_hsel),      // AHB peripheral select
   .HREADY           (HREADY_P2),    // AHB ready input
   .HTRANS           (HTRANS_P2),    // AHB transfer type
   .HSIZE            (HSIZE_P2),     // AHB hsize
   .HWRITE           (HWRITE_P2),    // AHB hwrite
   .HADDR            (HADDR_P2[11:0]),     // AHB address bus
   .HWDATA           (HWDATA_P2),    // AHB write data bus

   .ECOREVNUM        (4'b0000),  // Engineering-change-order revision bits

   .PORTIN           (PORTIN_GPIO2),     // GPIO Interface input

   .HREADYOUT        (HREADYOUT_GPIO2), // AHB ready output to S->M mux
   .HRESP            (HRESP_GPIO2),     // AHB response
   .HRDATA           (HRDATA_GPIO2),

   .PORTOUT          (PORTOUT_GPIO2),    // GPIO output
   .PORTEN           (PORTEN_GPIO2),     // GPIO output enable
   .PORTFUNC         (PORTFUNC_GPIO2),

   .GPIOINT          (GPIOINT_GPIO2),    // Interrupt output for each pin
   .COMBINT          (COMBINT_GPIO2));   // Combined interrupt

assign PORTIN_GPIO2 = PORTIO_GPIO2;
assign PORTIO_GPIO2[0 ] = PORTEN_GPIO2[0 ] ? PORTOUT_GPIO2[0 ]:1'bz;
assign PORTIO_GPIO2[1 ] = PORTEN_GPIO2[1 ] ? PORTOUT_GPIO2[1 ]:1'bz;
assign PORTIO_GPIO2[2 ] = PORTEN_GPIO2[2 ] ? PORTOUT_GPIO2[2 ]:1'bz;
assign PORTIO_GPIO2[3 ] = PORTEN_GPIO2[3 ] ? PORTOUT_GPIO2[3 ]:1'bz;
assign PORTIO_GPIO2[4 ] = PORTEN_GPIO2[4 ] ? PORTOUT_GPIO2[4 ]:1'bz;
assign PORTIO_GPIO2[5 ] = PORTEN_GPIO2[5 ] ? PORTOUT_GPIO2[5 ]:1'bz;
assign PORTIO_GPIO2[6 ] = PORTEN_GPIO2[6 ] ? PORTOUT_GPIO2[6 ]:1'bz;
assign PORTIO_GPIO2[7 ] = PORTEN_GPIO2[7 ] ? PORTOUT_GPIO2[7 ]:1'bz;
assign PORTIO_GPIO2[8 ] = PORTEN_GPIO2[8 ] ? PORTOUT_GPIO2[8 ]:1'bz;
assign PORTIO_GPIO2[9 ] = PORTEN_GPIO2[9 ] ? PORTOUT_GPIO2[9 ]:1'bz;
assign PORTIO_GPIO2[10] = PORTEN_GPIO2[10] ? PORTOUT_GPIO2[10]:1'bz;
assign PORTIO_GPIO2[11] = PORTEN_GPIO2[11] ? PORTOUT_GPIO2[11]:1'bz;
assign PORTIO_GPIO2[12] = PORTEN_GPIO2[12] ? PORTOUT_GPIO2[12]:1'bz;
assign PORTIO_GPIO2[13] = PORTEN_GPIO2[13] ? PORTOUT_GPIO2[13]:1'bz;
assign PORTIO_GPIO2[14] = PORTEN_GPIO2[14] ? PORTOUT_GPIO2[14]:1'bz;
assign PORTIO_GPIO2[15] = PORTEN_GPIO2[15] ? PORTOUT_GPIO2[15]:1'bz; */

//------------------------------------------------------------------------------
// FLYBIRDGAME 0x40003000
//------------------------------------------------------------------------------
wire            start_button    ;   // 0
wire            first_move_button     ;   // 1
wire            pause_button    ;   // 2
wire            continue_button ;   // 3
wire            restart_button  ;   // 4
wire            method_button   ;   // 5
wire            cancle_button   ;   // 6
wire            third_move_button;  // 7

wire            bird1up         ;   // 11
wire            bird1down       ;   // 12
wire            bird1left       ;   // 13
wire            bird1right      ;   // 14

wire            bird2up         ;   // 15
wire            bird2down       ;   // 16
wire            bird2left       ;   // 17
wire            bird2right      ;   // 18

wire    [15:0]  binary          ;   // 19
wire    [6:0]   state_number    ;   // 20
wire    [10:0]  sobel           ;   // 21
wire    [7:0]   score           ;   // 22
wire    [1:0]   gamemode        ;   // 23
wire    [1:0]   pausemode       ;   // 24
wire    [3:0]   angle           ;   // 25
wire            bird1_speed     ;   // 26
wire            bird2_speed     ;   // 27

wire            photo_wr_done   ;   // 28

wire            SG90_en         ;   // 29

wire    [7:0]   custom3_score   ;   // 30
wire            custom1_gun_enable; // 31

flybird_interface   flybird_interface_inst
(
    .HCLK               (clk                ),
    .HRESETn            (cpuresetn          ),
    .HSEL               (flybird_hsel       ),
    .HADDR              (HADDR_P2           ),
    .HTRANS             (HTRANS_P2          ),
    .HSIZE              (HSIZE_P2           ),
    .HPROT              (HPROT_P2           ),
    .HWRITE             (HWRITE_P2          ),
    .HWDATA             (HWDATA_P2          ),
    .HREADY             (HREADY_P2          ),
    .HREADYOUT          (HREADYOUT_FLYBIRD  ),
    .HRDATA             (HRDATA_FLYBIRD     ),
    .HRESP              (HRESP_FLYBIRD      ),

    .start_button       (start_button       ),   // 0
                                                 // 1
    .pause_button       (pause_button       ),   // 2
    .continue_button    (continue_button    ),   // 3
    .restart_button     (restart_button     ),   // 4
    .method_button      (method_button      ),   // 5
    .cancle_button      (cancle_button      ),   // 6
    .third_move_button  (third_move_button  ),   // 7
    
    .bird1up            (bird1up            ),   // 11
    .bird1down          (bird1down          ),   // 12
    .bird1left          (bird1left          ),   // 13
    .bird1right         (bird1right         ),   // 14

    .bird2up            (bird2up            ),   // 15
    .bird2down          (bird2down          ),   // 16
    .bird2left          (bird2left          ),   // 17
    .bird2right         (bird2right         ),   // 18

    .state_number       (state_number       ),   // 20
    .sobel              (sobel              ),   // 21
    .score              (score              ),   // 22
    .gamemode           (gamemode           ),   // 23
    .pausemode          (pausemode          ),   // 24
    .angle              (angle              ),   // 25
    .bird1_speed        (bird1_speed        ),   // 26
    .bird2_speed        (bird2_speed        ),   // 27

    .photo_wr_done      (photo_wr_done      ),   // 28

    .SG90_en            (SG90_en            ),   // 29
    .custom3_score      (custom3_score      ),   // 30
    .custom1_gun_enable (custom1_gun_enable ),   // 31

    .fourth_up          (fourth_up          ),   // 32
    .fourth_left        (fourth_left        ),   // 33
    .fourth_right       (fourth_right       )    // 34
);

AngryBird_Demo  AngryBird_Demo_inst
( 
//游戏内容接口
    .sys_rst_n              (cpuresetn              ),
    .start_button           (start_button           ),
    .restart_button         (restart_button         ),
    .pause_button           (pause_button           ),
    .continue_button        (continue_button        ),
    .method_button          (method_button          ),
    .cancle_button          (cancle_button          ),
    .third_move_button      (third_move_button      ),

    .first_custom_button    (~first_custom_button    /* 1'b0 */),
    .second_custom_button   (~second_custom_button   /* 1'b0 */),
    .third_custom_button    (~third_custom_button    /* 1'b0 */),
    .exit_game_button       (~exit_game_button       /* 1'b0 */),

    .clk_50m                (clk_50m                ),
    .clk_100m               (clk_100m               ),
    .clk_100m_shift         (clk_100m_shift         ),
    .sd_card_clk            (sd_card_clk            ),
    .sd_card_clk_n          (sd_card_clk_n          ),

    .hdmi_clk               (hdmi_clk               ),
    .hdmi_5clk              (hdmi_5clk              ),

    .bird1up                (bird1up                ),
    .bird1down              (bird1down              ),
    .bird1left              (bird1left              ),
    .bird1right             (bird1right             ),

    .bird2up                (bird2up                ),
    .bird2down              (bird2down              ),
    .bird2left              (bird2left              ),
    .bird2right             (bird2right             ),

    .gamemode               (gamemode               ),
    .pausemode              (pausemode              ),

    .custom1_gun_enable     (custom1_gun_enable     ),
    .angle                  (angle                  ),
    .bird1_speed            (bird1_speed            ),
    .bird2_speed            (bird2_speed            ),

    .sobel                  (sobel                  ),

    .state_number           (state_number           ),
    .score                  (score                  ),
    .custom3_score          (custom3_score          ),
    .photo_wr_done          (photo_wr_done          ),

    .SG90_en                (SG90_en                ),

//硬件外设接口
    .cam_pclk               (cam_pclk               ),
    .cam_vsync              (cam_vsync              ),
    .cam_href               (cam_href               ),
    .cam_data               (cam_data               ),
    .cam_rst_n              (cam_rst_n              ),
    .cam_pwdn               (cam_pwdn               ),
    .cam_scl                (cam_scl                ),
    .cam_sda                (cam_sda                ),

    .sd_miso                (sd_miso                ),
    .sd_clk                 (sd_clk                 ),
    .sd_cs                  (sd_cs                  ),
    .sd_mosi                (sd_mosi                ),

    .sdram_clk              (sdram_clk              ),
    .sdram_cke              (sdram_cke              ),
    .sdram_cs_n             (sdram_cs_n             ),
    .sdram_ras_n            (sdram_ras_n            ),
    .sdram_cas_n            (sdram_cas_n            ),
    .sdram_we_n             (sdram_we_n             ),
    .sdram_ba               (sdram_ba               ),
    .sdram_dqm              (sdram_dqm              ),
    .sdram_addr             (sdram_addr             ),
    .sdram_data             (sdram_data             ),

    .tmds_clk_p             (tmds_clk_p             ),
    .tmds_clk_n             (tmds_clk_n             ),
    .tmds_data_p            (tmds_data_p            ),
    .tmds_data_n            (tmds_data_n            ),

    .first_camera_clk       (first_camera_clk       ),
    .first_rden             (first_rden             ),
    .first_camera_bit       (first_camera_bit       )
);


//------------------------------------------------------------------------------
// SPTIMER0 0x40004000
//------------------------------------------------------------------------------

wire        TIMERINT_sptimer0;

AHBlite_Timer SPTimer0(
    .HCLK       (clk),
    .HRESETn    (cpuresetn),
    .HSEL       (SPTimer0_hsel),
    .HADDR      (HADDR_P2),
    .HTRANS     (HTRANS_P2),
    .HSIZE      (HSIZE_P2),
    .HPROT      (HPROT_P2),
    .HWRITE     (HWRITE_P2),
    .HWDATA     (HWDATA_P2),
    .HREADY     (HREADY_P2),
    .HREADYOUT  (HREADYOUT_SPTIMER0),
    .HRDATA     (HRDATA_SPTIMER0),
    .HRESP      (HRESP_SPTIMER0),
    .timer_irq  (TIMERINT_sptimer0)
);

//------------------------------------------------------------------------------
// SPTIMER1 0x40005000
//------------------------------------------------------------------------------

wire        TIMERINT_sptimer1;

AHBlite_Timer SPTimer1(
    .HCLK       (clk),
    .HRESETn    (cpuresetn),
    .HSEL       (SPTimer1_hsel),
    .HADDR      (HADDR_P2),
    .HTRANS     (HTRANS_P2),
    .HSIZE      (HSIZE_P2),
    .HPROT      (HPROT_P2),
    .HWRITE     (HWRITE_P2),
    .HWDATA     (HWDATA_P2),
    .HREADY     (HREADY_P2),
    .HREADYOUT  (HREADYOUT_SPTIMER1),
    .HRDATA     (HRDATA_SPTIMER1),
    .HRESP      (HRESP_SPTIMER1),
    .timer_irq  (TIMERINT_sptimer1)
);

//------------------------------------------------------------------------------
// SPTIMER2 0x40006000
//------------------------------------------------------------------------------

/* wire        TIMERINT_sptimer2;

AHBlite_Timer SPTimer2(
    .HCLK       (clk),
    .HRESETn    (cpuresetn),
    .HSEL       (SPTimer2_hsel),
    .HADDR      (HADDR_P2),
    .HTRANS     (HTRANS_P2),
    .HSIZE      (HSIZE_P2),
    .HPROT      (HPROT_P2),
    .HWRITE     (HWRITE_P2),
    .HWDATA     (HWDATA_P2),
    .HREADY     (HREADY_P2),
    .HREADYOUT  (HREADYOUT_SPTIMER2),
    .HRDATA     (HRDATA_SPTIMER2),
    .HRESP      (HRESP_SPTIMER2),
    .timer_irq  (TIMERINT_sptimer2)
); */

//------------------------------------------------------------------------------
// SEG 0x40007000
//------------------------------------------------------------------------------

/* AHBlite_SEG SEG(
    .HCLK           (clk),
    .HRESETn        (cpuresetn),
    .HSEL           (seg_hsel),
    .HADDR          (HADDR_P2),
    .HTRANS         (HTRANS_P2),
    .HSIZE          (HSIZE_P2),
    .HPROT          (HPROT_P2),
    .HWRITE         (HWRITE_P2),
    .HWDATA         (HWDATA_P2),
    .HREADY         (HREADY_P2),
    .HREADYOUT      (HREADYOUT_SEG),
    .HRDATA         (HRDATA_SEG),
    .HRESP          (HRESP_SEG),
     
    .seg            (seg),        //段选 高有效
    .sel            (sel)        //位选 低有效
); */

//------------------------------------------------------------------------------
// COMMUNICATION 0x40008000
//------------------------------------------------------------------------------

communication_interface communication
(
    .HCLK           (clk),
    .HRESETn        (cpuresetn),
    .HSEL           (Communication_hsel),
    .HADDR          (HADDR_P2),
    .HTRANS         (HTRANS_P2),
    .HSIZE          (HSIZE_P2),
    .HPROT          (HPROT_P2),
    .HWRITE         (HWRITE_P2),
    .HWDATA         (HWDATA_P2),
    .HREADY         (HREADY_P2),
    .HREADYOUT      (HREADYOUT_COMMUNICATION),
    .HRDATA         (HRDATA_COMMUNICATION),
    .HRESP          (HRESP_COMMUNICATION),

    .Servo_up       (Servo_up),
    .Servo_down     (Servo_down),
    .Servo_left     (Servo_left),
    .Servo_right    (Servo_right),
    .Servo_rst      (Servo_rst),
    .Servo_track_en (Servo_track_en)
);

//------------------------------------------------------------------------------
// MICROPHONE 0x40009000
//------------------------------------------------------------------------------

microphone_interface
(
    .HCLK        (clk),
    .HRESETn     (cpuresetn),
    .HSEL        (Microphone_hsel),
    .HADDR       (HADDR_P2),
    .HTRANS      (HTRANS_P2),
    .HSIZE       (HSIZE_P2),
    .HPROT       (HPROT_P2),
    .HWRITE      (HWRITE_P2),
    .HWDATA      (HWDATA_P2),
    .HREADY      (HREADY_P2),
    .HREADYOUT   (HREADYOUT_MICROPHONE),
    .HRDATA      (HRDATA_MICROPHONE),
    .HRESP       (HRESP_MICROPHONE),

    .microphone_left    (microphone_left),
    .microphone_right   (microphone_right),
    .microphone_up      (microphone_up),
    .microphone_down    (microphone_down)
);

//------------------------------------------------------------------------------
// SG90 0x4000a000
//------------------------------------------------------------------------------

SG90_interface SG90_interface_inst
(
    .HCLK        (clk),
    .HRESETn     (cpuresetn),
    .HSEL        (SG90_hsel),
    .HADDR       (HADDR_P2),
    .HTRANS      (HTRANS_P2),
    .HSIZE       (HSIZE_P2),
    .HPROT       (HPROT_P2),
    .HWRITE      (HWRITE_P2),
    .HWDATA      (HWDATA_P2),
    .HREADY      (HREADY_P2),
    .HREADYOUT   (HREADYOUT_SG90),
    .HRDATA      (HRDATA_SG90),
    .HRESP       (HRESP_SG90),
    
    .SG90_PWM_out(SG90_PWM_out)
);

//------------------------------------------------------------------------------
// APB Bridge 0x50000000
//------------------------------------------------------------------------------

wire    [15:0] PADDR  ;
wire           PENABLE;
wire           PWRITE ;
wire     [3:0] PSTRB  ;
wire     [2:0] PPROT  ;
wire    [31:0] PWDATA ;
wire           PSEL   ;
wire    [31:0] PRDATA ;
wire           PREADY ;
wire           PSLVERR;

cmsdk_ahb_to_apb APBbridge
(
        .HCLK          (clk),               // Clock
        .HRESETn       (cpuresetn),         // Reset
        .PCLKEN        (1'b1),              // APB clock enable signal

        .HSEL          (HSEL_P3),           // Device select
        .HADDR         (HADDR_P3[15:0]),    // Address
        .HTRANS        (HTRANS_P3),         // Transfer control
        .HSIZE         (HSIZE_P3),          // Transfer size
        .HPROT         (HPROT_P3),          // Protection control
        .HWRITE        (HWRITE_P3),         // Write control
        .HREADY        (HREADY_P3),         // Transfer phase done
        .HWDATA        (HWDATA_P3),         // Write data

        .HREADYOUT     (HREADYOUT_P3),      // Device ready
        .HRDATA        (HRDATA_P3),         // Read data output
        .HRESP         (HRESP_P3),          // Device response
                                            // APB Output
        .PADDR         (PADDR),             // APB Address
        .PENABLE       (PENABLE),           // APB Enable
        .PWRITE        (PWRITE),            // APB Write
        .PSTRB         (PSTRB),             // APB Byte Strobe
        .PPROT         (PPROT),             // APB Prot
        .PWDATA        (PWDATA),            // APB write data
        .PSEL          (PSEL),              // APB Select

        .APBACTIVE     (),                  // APB bus is active, for clock gating
                                            // of APB bus

                                            // APB Input
        .PRDATA        (PRDATA),            // Read data for each APB slave
        .PREADY        (PREADY),            // Ready for each APB slave
        .PSLVERR       (PSLVERR)
);                                          // Error state for each APB slave

/* wire        PSEL0_TIMER0;
wire [31:0] PRDATA_TIMER0;
wire        PREADY_TIMER0;
wire        PSLVERR_TIMER0;

wire        PSEL1_TIMER1;
wire [31:0] PRDATA_TIMER1;
wire        PREADY_TIMER1;
wire        PSLVERR_TIMER1; */

/* wire        PSEL4_UART0;
wire [31:0] PRDATA_UART0;
wire        PREADY_UART0;
wire        PSLVERR_UART0; */

wire        PSEL5_UART1;
wire [31:0] PRDATA_UART1;
wire        PREADY_UART1;
wire        PSLVERR_UART1;

wire        PSEL6_UART2;
wire [31:0] PRDATA_UART2;
wire        PREADY_UART2;
wire        PSLVERR_UART2;

cmsdk_apb_slave_mux #(
  // Parameters to enable/disable ports
  .PORT0_ENABLE (0),
  .PORT1_ENABLE (0),
  .PORT2_ENABLE (0),
  .PORT3_ENABLE (0),
  .PORT4_ENABLE (0),
  .PORT5_ENABLE (1),
  .PORT6_ENABLE (1),
  .PORT7_ENABLE (0),
  .PORT8_ENABLE (0),
  .PORT9_ENABLE (0),
  .PORT10_ENABLE(0),
  .PORT11_ENABLE(0),
  .PORT12_ENABLE(0),
  .PORT13_ENABLE(0),
  .PORT14_ENABLE(0),
  .PORT15_ENABLE(0))
 slave_mux
 (
// --------------------------------------------------------------------------
// Port Definitions
// --------------------------------------------------------------------------
        .DECODE4BIT    (PADDR[15:12]),
        .PSEL          (PSEL),
//0x50000000
        .PSEL0         (/* PSEL0_TIMER0 */),
        .PREADY0       (/* PREADY_TIMER0 */1'b0),
        .PRDATA0       (/* PRDATA_TIMER0 */32'b0),
        .PSLVERR0      (/* PSLVERR_TIMER0 */1'b0),
//0x50001000
        .PSEL1         (/* PSEL1_TIMER1 */),
        .PREADY1       (/* PREADY_TIMER1 */1'b0),
        .PRDATA1       (/* PRDATA_TIMER1 */32'b0),
        .PSLVERR1      (/* PSLVERR_TIMER1 */1'b0),
//0x50002000
        .PSEL2         (),
        .PREADY2       (1'b0),
        .PRDATA2       (32'b0),
        .PSLVERR2      (1'b0),
//0x50003000
        .PSEL3         (),
        .PREADY3       (1'b0),
        .PRDATA3       (32'b0),
        .PSLVERR3      (1'b0),
//0x50004000
        .PSEL4         (/* PSEL4_UART0 */),
        .PREADY4       (/* PREADY_UART0 */),
        .PRDATA4       (/* PRDATA_UART0 */),
        .PSLVERR4      (/* PSLVERR_UART0 */),
//0x50005000
        .PSEL5         (PSEL5_UART1),
        .PREADY5       (PREADY_UART1),
        .PRDATA5       (PRDATA_UART1),
        .PSLVERR5      (PSLVERR_UART1),
//0x50006000
        .PSEL6         (PSEL6_UART2),
        .PREADY6       (PREADY_UART2),
        .PRDATA6       (PRDATA_UART2),
        .PSLVERR6      (PSLVERR_UART2),
//0x50007000
        .PSEL7         (),
        .PREADY7       (1'b0),
        .PRDATA7       (32'b0),
        .PSLVERR7      (1'b0),
//0x50008000
        .PSEL8         (),
        .PREADY8       (1'b0),
        .PRDATA8       (32'b0),
        .PSLVERR8      (1'b0),
//0x50009000
        .PSEL9         (),
        .PREADY9       (1'b0),
        .PRDATA9       (32'b0),
        .PSLVERR9      (1'b0),
//0x5000a000
        .PSEL10        (),
        .PREADY10      (1'b0),
        .PRDATA10      (32'b0),
        .PSLVERR10     (1'b0),
//0x5000b000
        .PSEL11        (),
        .PREADY11      (1'b0),
        .PRDATA11      (32'b0),
        .PSLVERR11     (1'b0),
//0x5000c000
        .PSEL12        (),
        .PREADY12      (1'b0),
        .PRDATA12      (32'b0),
        .PSLVERR12     (1'b0),
//0x5000d000
        .PSEL13        (),
        .PREADY13      (1'b0),
        .PRDATA13      (32'b0),
        .PSLVERR13     (1'b0),
//0x5000e000
        .PSEL14        (),
        .PREADY14      (1'b0),
        .PRDATA14      (32'b0),
        .PSLVERR14     (1'b0),
//0x5000f000
        .PSEL15        (),
        .PREADY15      (1'b0),
        .PRDATA15      (32'b0),
        .PSLVERR15     (1'b0),

        .PREADY        (PREADY),
        .PRDATA        (PRDATA),
        .PSLVERR       (PSLVERR));

//------------------------------------------------------------------------------
// TIMER0 0x50000000
//------------------------------------------------------------------------------

/* wire            TIMERINT_timer0;

cmsdk_apb_timer Timer0(
        .PCLK       (clk),    // PCLK for timer operation
        .PCLKG      (clk),   // Gated clock
        .PRESETn    (cpuresetn), // Reset
        
        .PSEL       (PSEL0_TIMER0),    // Device select
        .PADDR      (PADDR[11:2]),   // Address
        .PENABLE    (PENABLE), // Transfer control
        .PWRITE     (PWRITE),  // Write control
        .PWDATA     (PWDATA),  // Write data
        
        .ECOREVNUM  (4'b0),// Engineering-change-order revision bits
        
        .PRDATA     (PRDATA_TIMER0),  // Read data
        .PREADY     (PREADY_TIMER0),  // Device ready
        .PSLVERR    (PSLVERR_TIMER0), // Device error response
        
        .EXTIN      (1'b0),   // External input
        
        .TIMERINT   (TIMERINT_timer0)    ); // Timer interrupt output */
        
//------------------------------------------------------------------------------
// TIMER1 0x50001000
//------------------------------------------------------------------------------

/* wire            TIMERINT_timer1;

cmsdk_apb_timer Timer1(
        .PCLK       (clk),    // PCLK for timer operation
        .PCLKG      (clk),   // Gated clock
        .PRESETn    (cpuresetn), // Reset
        
        .PSEL       (PSEL1_TIMER1),    // Device select
        .PADDR      (PADDR[11:2]),   // Address
        .PENABLE    (PENABLE), // Transfer control
        .PWRITE     (PWRITE),  // Write control
        .PWDATA     (PWDATA),  // Write data
        
        .ECOREVNUM  (4'b0),// Engineering-change-order revision bits
        
        .PRDATA     (PRDATA_TIMER1),  // Read data
        .PREADY     (PREADY_TIMER1),  // Device ready
        .PSLVERR    (PSLVERR_TIMER1), // Device error response
        
        .EXTIN      (1'b0),   // External input
        
        .TIMERINT   (TIMERINT_timer1)    ); // Timer interrupt output */

//------------------------------------------------------------------------------
// UART0 0x50004000
//------------------------------------------------------------------------------
/* wire        TXEN_UART0;
wire        BAUDTICK_UART0;
wire        TXINT_UART0;
wire        RXINT_UART0;
wire        TXOVRINT_UART0;
wire        RXOVRINT_UART0;
wire        UARTINT_UART0;

cmsdk_apb_uart UART0(
// --------------------------------------------------------------------------
// Port Definitions
// --------------------------------------------------------------------------
        .PCLK           (sys_clk),     // Clock
        .PCLKG          (sys_clk),    // Gated Clock
        .PRESETn        (cpuresetn),  // Reset

        .PSEL           (PSEL4_UART0),     // Device select
        .PADDR          (PADDR[11:2]),    // Address
        .PENABLE        (PENABLE),  // Transfer control
        .PWRITE         (PWRITE),   // Write control
        .PWDATA         (PWDATA),   // Write data

        .ECOREVNUM      (4'b0),// Engineering-change-order revision bits

        .PRDATA         (PRDATA_UART0),   // Read data
        .PREADY         (PREADY_UART0),   // Device ready
        .PSLVERR        (PSLVERR_UART0),  // Device error response

        .RXD            (RXD_UART0),      // Serial input
        .TXD            (TXD_UART0),      // Transmit data output
        .TXEN           (TXEN_UART0),     // Transmit enabled
        .BAUDTICK       (BAUDTICK_UART0), // Baud rate (x16) Tick

        .TXINT          (TXINT_UART0),    // Transmit Interrupt
        .RXINT          (RXINT_UART0),    // Receive Interrupt
        .TXOVRINT       (TXOVRINT_UART0), // Transmit overrun Interrupt
        .RXOVRINT       (RXOVRINT_UART0), // Receive overrun Interrupt
        .UARTINT        (UARTINT_UART0)); // Combined interrupt */

//------------------------------------------------------------------------------
// UART1 0x50005000
//------------------------------------------------------------------------------
wire        TXEN_UART1;
wire        BAUDTICK_UART1;
wire        TXINT_UART1;
wire        RXINT_UART1;
wire        TXOVRINT_UART1;
wire        RXOVRINT_UART1;
wire        UARTINT_UART1;

cmsdk_apb_uart UART1(
// --------------------------------------------------------------------------
// Port Definitions
// --------------------------------------------------------------------------
        .PCLK           (clk),     // Clock
        .PCLKG          (clk),    // Gated Clock
        .PRESETn        (cpuresetn),  // Reset

        .PSEL           (PSEL5_UART1),     // Device select
        .PADDR          (PADDR[11:2]),    // Address
        .PENABLE        (PENABLE),  // Transfer control
        .PWRITE         (PWRITE),   // Write control
        .PWDATA         (PWDATA),   // Write data

        .ECOREVNUM      (4'b0),// Engineering-change-order revision bits

        .PRDATA         (PRDATA_UART1),   // Read data
        .PREADY         (PREADY_UART1),   // Device ready
        .PSLVERR        (PSLVERR_UART1),  // Device error response

        .RXD            (RXD_UART1),      // Serial input
        .TXD            (TXD_UART1),      // Transmit data output
        .TXEN           (TXEN_UART1),     // Transmit enabled
        .BAUDTICK       (BAUDTICK_UART1), // Baud rate (x16) Tick

        .TXINT          (TXINT_UART1),    // Transmit Interrupt
        .RXINT          (RXINT_UART1),    // Receive Interrupt
        .TXOVRINT       (TXOVRINT_UART1), // Transmit overrun Interrupt
        .RXOVRINT       (RXOVRINT_UART1), // Receive overrun Interrupt
        .UARTINT        (UARTINT_UART1)); // Combined interrupt

//------------------------------------------------------------------------------
// UART2 0x50006000
//------------------------------------------------------------------------------
wire        TXEN_UART2;
wire        BAUDTICK_UART2;
wire        TXINT_UART2;
wire        RXINT_UART2;
wire        TXOVRINT_UART2;
wire        RXOVRINT_UART2;
wire        UARTINT_UART2;

cmsdk_apb_uart UART2(
// --------------------------------------------------------------------------
// Port Definitions
// --------------------------------------------------------------------------
        .PCLK           (clk),              // Clock
        .PCLKG          (clk),              // Gated Clock
        .PRESETn        (cpuresetn),        // Reset

        .PSEL           (PSEL6_UART2),      // Device select
        .PADDR          (PADDR[11:2]),      // Address
        .PENABLE        (PENABLE),          // Transfer control
        .PWRITE         (PWRITE),           // Write control
        .PWDATA         (PWDATA),           // Write data

        .ECOREVNUM      (4'b0),// Engineering-change-order revision bits

        .PRDATA         (PRDATA_UART2),     // Read data
        .PREADY         (PREADY_UART2),     // Device ready
        .PSLVERR        (PSLVERR_UART2),    // Device error response

        .RXD            (RXD_UART2),        // Serial input
        .TXD            (TXD_UART2),        // Transmit data output
        .TXEN           (TXEN_UART2),       // Transmit enabled
        .BAUDTICK       (BAUDTICK_UART2),   // Baud rate (x16) Tick

        .TXINT          (TXINT_UART2),      // Transmit Interrupt
        .RXINT          (RXINT_UART2),      // Receive Interrupt
        .TXOVRINT       (TXOVRINT_UART2),   // Transmit overrun Interrupt
        .RXOVRINT       (RXOVRINT_UART2),   // Receive overrun Interrupt
        .UARTINT        (UARTINT_UART2));   // Combined interrupt

assign IRQ = {14'b0,1'b0,exit_interrupt8,exit_interrupt7,exit_interrupt6,exit_interrupt5,exit_interrupt4,exit_interrupt3,exit_interrupt2,exit_interrupt1,exit_interrupt0,TIMERINT_sptimer1,TIMERINT_sptimer0,TXINT_UART2,RXINT_UART2,TXINT_UART1,RXINT_UART1,/* TXINT_UART0 */1'b0,/* RXINT_UART0 */1'b0};

endmodule
