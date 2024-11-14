module  communication_interface
(
    input   wire            HCLK,
    input   wire            HRESETn,
    input   wire            HSEL,
    input   wire    [31:0]  HADDR,
    input   wire    [1:0]   HTRANS,
    input   wire    [2:0]   HSIZE,
    input   wire    [3:0]   HPROT,
    input   wire            HWRITE,
    input   wire    [31:0]  HWDATA,
    input   wire            HREADY,
    output  wire            HREADYOUT,
    output  wire    [31:0]  HRDATA,
    output  wire            HRESP,
    
    output  reg             Servo_up,
    output  reg             Servo_down,
    output  reg             Servo_left,
    output  reg             Servo_right,
    output  reg             Servo_rst,
    output  reg             Servo_track_en
);

assign HRESP = 1'b0;
assign HREADYOUT = 1'b1;

wire read_en;
assign read_en=HSEL&HTRANS[1]&(~HWRITE)&HREADY;

wire write_en;
assign write_en=HSEL&HTRANS[1]&(HWRITE)&HREADY;

reg rd_en_reg;
always@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        rd_en_reg <= 1'b0;
    else if(read_en)
        rd_en_reg <= 1'b1;
    else
        rd_en_reg <= 1'b0;
end

reg wr_en_reg;
always@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        wr_en_reg <= 1'b0;
    else if(write_en)
        wr_en_reg <= 1'b1;
    else
        wr_en_reg <= 1'b0;
end

reg [2:0]   addr_reg;
always@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        addr_reg <= 2'd0;
    else if(HSEL & HREADY & HTRANS[1])
        addr_reg <= HADDR[4:2];
end

always@(posedge HCLK or negedge HRESETn)
    if(~HRESETn) 
        begin
            Servo_up <= 1'b0;
            Servo_down <= 1'b0;
            Servo_left <= 1'b0;
            Servo_right <= 1'b0;
            Servo_rst <= 1'b0;
        end 
    else if(wr_en_reg && HREADY) 
        begin
            if(addr_reg == 3'd0)
                Servo_up <= HWDATA[0];
            else if(addr_reg == 3'd1)
                Servo_down <= HWDATA[0];
            else if(addr_reg == 3'd2)
                Servo_left <= HWDATA[0];
            else if(addr_reg == 3'd3)
                Servo_right <= HWDATA[0];
            else if(addr_reg == 3'd4)
                Servo_rst <= HWDATA[0];
            else if(addr_reg == 3'd5)
                Servo_track_en <= HWDATA[0];
        end

assign HRDATA = (addr_reg == 3'd0) ? {31'd0,Servo_up} : 
                (addr_reg == 3'd1) ? {31'd0,Servo_down} : 
                (addr_reg == 3'd2) ? {31'd0,Servo_left} : 
                (addr_reg == 3'd3) ? {31'd0,Servo_right} : 
                (addr_reg == 3'd4) ? {31'd0,Servo_rst} : 
                (addr_reg == 3'd5) ? {31'd0,Servo_track_en} : 32'd0;

endmodule
