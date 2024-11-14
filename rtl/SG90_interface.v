module  SG90_interface
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
    
    output  reg             SG90_PWM_out
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

reg [1:0]   addr_reg;
always@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn)
        addr_reg <= 2'd0;
    else if(HSEL & HREADY & HTRANS[1])
        addr_reg <= HADDR[3:2];
end

parameter   CNT_MAX = 750000;

reg [19:0]  CRR;        // 0
reg         ENABLE;     // 1

always@(posedge HCLK or negedge HRESETn)
    if(~HRESETn) 
        begin
            CRR   <= 20'd0;
            ENABLE <= 1'b0;
        end 
    else if(wr_en_reg && HREADY) 
        begin
            if(addr_reg == 2'd0)
                CRR   <= HWDATA[19:0];
            else if(addr_reg == 2'd1)
                ENABLE <= HWDATA[0];
        end

reg [19:0]  value;      //定时器计数值

always@(posedge HCLK or negedge HRESETn)
    if(~HRESETn)
        value <= 20'd0;
    else if(ENABLE == 1'b1)
        begin
            if(value == CNT_MAX - 1'b1)
                value <= 20'd0;
            else 
                value <= value + 1'b1;
        end
    else
        value <= 20'd0;

always@(posedge HCLK or negedge HRESETn)
    if(~HRESETn)
        SG90_PWM_out <= 1'b0;
    else if(ENABLE == 1'b1)
        begin
            if(value < CRR)
                SG90_PWM_out <= 1'b1;
            else
                SG90_PWM_out <= 1'b0;
        end
    else
        SG90_PWM_out <= 1'b0;

assign HRDATA = (addr_reg == 2'd0) ? {12'd0,CRR} : (addr_reg == 2'd1) ? {31'd0,ENABLE} : 32'd0;

endmodule
