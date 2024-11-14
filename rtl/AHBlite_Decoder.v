module AHBlite_Decoder
#(
    /*RAMCODE enable parameter*/
    parameter Port0_en = 1,
    /************************/

    /*WaterLight enable parameter*/
    parameter Port1_en = 1,
    /************************/

    /*RAMDATA enable parameter*/
    parameter Port2_en = 1,
    /************************/

    /*UART enable parameter*/
    parameter Port3_en=1
    /************************/
)(
    input [31:0] HADDR,

    /*RAMCODE SELECTION SIGNAL*/
    output wire P0_HSEL,

    /*RAMDATA SELECTION SIGNAL*/
    output wire P1_HSEL,

    /*AHB BASE SELECTION SIGNAL*/
    output wire P2_HSEL,

    /*APB BASE SELECTION SIGNAL*/
    output wire P3_HSEL       
);

//RAMCODE
//0x00000000-0x0000ffff
assign P0_HSEL = (HADDR[31:16]==16'h0000)? Port0_en : 1'b0;

//RAMDATA
//0X20000000-0X2000FFFF
assign P1_HSEL = (HADDR[31:16]==16'h2000)? Port1_en : 1'b0;

//AHB Bridge BASE
//0x40000000-0x4000ffff
assign P2_HSEL = (HADDR[31:16]==16'h4000)? Port2_en : 1'b0;
/***********************************/

//APB Bridge BASE
//0x50000000-0x5000ffff
assign P3_HSEL = (HADDR[31:16]==16'h5000)? Port3_en : 1'b0;

endmodule