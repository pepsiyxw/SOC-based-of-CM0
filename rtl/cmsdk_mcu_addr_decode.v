module cmsdk_mcu_addr_decode #(
  // GPIO0 base address
  parameter BASEADDR_GPIO0          = 32'h4000_0000,
  // GPIO1 base address
  parameter BASEADDR_GPIO1          = 32'h4000_1000,
  // SimpleTimer base address
  parameter BASEADDR_GPIO2          = 32'h4000_2000,
  // flybird base address
  parameter BASEADDR_FLYBIRDGAME    = 32'h4000_3000,
  // SPTimer0 base address
  parameter BASEADDR_SPTIMER0       = 32'h4000_4000,
  // SPTimer1 base address
  parameter BASEADDR_SPTIMER1       = 32'h4000_5000,
  // SPTimer2 base address
  parameter BASEADDR_SPTIMER2       = 32'h4000_6000,
  // SEG bash address
  parameter BASEADDR_SEG            = 32'h4000_7000,
  // SPTimer3 base address
  parameter BASEADDR_COMMUNICATION  = 32'h4000_8000,
  // Microphone base address
  parameter BASEADDR_MICROPHONE     = 32'h4000_9000,
  // SG90 base address
  parameter BASEADDR_SG90           = 32'h4000_a000
 )
 (
    // System Address
    input   wire    [31:0]  haddr,

    output  wire            gpio0_hsel,
    output  wire            gpio1_hsel,
    output  wire            gpio2_hsel,
    output  wire            flybird_hsel,
    output  wire            SPTimer0_hsel,
    output  wire            SPTimer1_hsel,
    output  wire            SPTimer2_hsel,
    output  wire            seg_hsel,
    output  wire            Communication_hsel,
    output  wire            Microphone_hsel,
    output  wire            SG90_hsel
    );

  assign gpio0_hsel = (haddr[31:12]==
                         BASEADDR_GPIO0[31:12]);       // 0x40000000

  assign gpio1_hsel = (haddr[31:12]==
                         BASEADDR_GPIO1[31:12]);       // 0x40001000

  assign gpio2_hsel = (haddr[31:12]==
                         BASEADDR_GPIO2[31:12]);       // 0x40002000

  assign flybird_hsel = (haddr[31:12]==
                         BASEADDR_FLYBIRDGAME[31:12]);       // 0x40003000

  assign SPTimer0_hsel = (haddr[31:12]==
                         BASEADDR_SPTIMER0[31:12]);       // 0x40004000

  assign SPTimer1_hsel = (haddr[31:12]==
                         BASEADDR_SPTIMER1[31:12]);       // 0x40005000

  assign SPTimer2_hsel = (haddr[31:12]==
                         BASEADDR_SPTIMER2[31:12]);       // 0x40006000

  assign seg_hsel = (haddr[31:12]==
                         BASEADDR_SEG[31:12]);       // 0x40007000

  assign Communication_hsel = (haddr[31:12]==
                         BASEADDR_COMMUNICATION[31:12]);       // 0x40008000

  assign Microphone_hsel = (haddr[31:12]==
                         BASEADDR_MICROPHONE[31:12]);       // 0x40009000

  assign SG90_hsel = (haddr[31:12]==
                         BASEADDR_SG90[31:12]);       // 0x4000a000

endmodule