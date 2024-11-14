module line_shift_ram_1bit(
    input          clock,
    input          clken,
    input          per_frame_href,
    
    input           shiftin,
    output          taps0x,
    output          taps1x
);

//reg define
reg [2:0]   clken_dly;
reg [9:0]   ram_rd_addr;
reg [9:0]   ram_rd_addr_d0;
reg [9:0]   ram_rd_addr_d1;
reg         shiftin_d0;
reg         shiftin_d1;
reg         shiftin_d2;
reg         taps0x_d0;

//*****************************************************
//**                    main code
//*****************************************************

//在数据来到时，ram地址累加
always@(posedge clock)begin
    if(per_frame_href)
        if(clken)
            ram_rd_addr <= ram_rd_addr + 1;
        else
            ram_rd_addr <= ram_rd_addr;
    else
        ram_rd_addr <= 0 ;
end

//时钟使能信号延迟三拍
always@(posedge clock) begin
    clken_dly <= {clken_dly[1:0],clken};
end


//将ram地址延迟二拍
always@(posedge clock ) begin
    ram_rd_addr_d0 <= ram_rd_addr;
    ram_rd_addr_d1 <= ram_rd_addr_d0;
end

//输入数据延迟三拍
always@(posedge clock)begin
    shiftin_d0 <= shiftin;
    shiftin_d1 <= shiftin_d0;
    shiftin_d2 <= shiftin_d1;
end

//用于存储前一行图像的RAM
bram_256_1bit bram_256_1bit_inst0
( 
    .dia    (shiftin_d2),
    .addra  (ram_rd_addr_d1),
    .wea    (clken_dly[2]),
    .clk    (clock),
    .dob    (taps0x),
    .addrb  (ram_rd_addr)
);

//用于存储前前一行图像的RAM
bram_256_1bit bram_256_1bit_inst1
( 
    .dia    (taps0x),
    .addra  (ram_rd_addr_d0),
    .wea    (clken_dly[1]),
    .clk    (clock),
    .dob    (taps1x),
    .addrb  (ram_rd_addr)
);

endmodule 