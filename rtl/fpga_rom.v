`timescale 1ns/1ns
module fpga_rom(
  // Inputs
  input  wire          CLK,
  input  wire [11:0]   ADDR,
  input  wire [31:0]   WDATA,
  input  wire [3:0]    WREN,
  input  wire          CS,

  // Outputs
  output wire [31:0]   RDATA
);

  parameter DATA_WIDTH_A = 32;
  parameter ADDR_WIDTH_A = 12;
  parameter DATA_DEPTH_A = 4096;
  parameter DATA_WIDTH_B = 32;
  parameter ADDR_WIDTH_B = 12;
  parameter DATA_DEPTH_B = 4096;
  parameter REGMODE_A    = "NONE";
  parameter WRITEMODE_A  = "NORMAL";

  // wire define
  wire    [3:0]     write_enable;
  wire              write_en;
  wire              gclk;

  EG_LOGIC_BUFG u_rom_gclk(
    .i      (CLK),
    .o      (gclk)
  );

  assign write_enable[3:0] = WREN[3:0] & {4{CS}};
  assign write_en = |WREN[3:0];

  EG_LOGIC_BRAM #(
    .DATA_WIDTH_A       (DATA_WIDTH_A),
    .ADDR_WIDTH_A       (ADDR_WIDTH_A),
    .DATA_DEPTH_A       (DATA_DEPTH_A),
    .DATA_WIDTH_B       (DATA_WIDTH_B),
    .ADDR_WIDTH_B       (ADDR_WIDTH_B),
    .DATA_DEPTH_B       (DATA_DEPTH_B),
    .BYTE_ENABLE        (8),
    .BYTE_A             (4),
    .BYTE_B             (4),
    .MODE               ("SP"),
    .REGMODE_A          (REGMODE_A),
    .WRITEMODE_A        (WRITEMODE_A),
    .RESETMODE          ("SYNC"),
    .IMPLEMENT          ("9K"),
    .DEBUGGABLE         ("NO"),
    .PACKABLE           ("NO"),
    .INIT_FILE          ("E:/_CM0_Soc/Cortex-M0/mif/image.mif"),
    .FILL_ALL           ("NONE")
  )
  fpga_rom_inst(
    .clka             (gclk),
    .clkb             (1'b0),
    .dia              (WDATA),
    .dib              ({32{1'b0}}),
    .addra            (ADDR),
    .addrb            ({12{1'b0}}),
    .cea              (CS),
    .ceb              (1'b0),
    .ocea             (1'b1),
    .oceb             (1'b0),
    .bea              (write_enable),      // 掩码写
    .beb              (4'b0),              // 掩码写
    .wea              (write_en),
    .web              (1'b0),
    .rsta             (1'b0),
    .rstb             (1'b0),
    .doa              (RDATA),
    .dob              ()
  );

endmodule