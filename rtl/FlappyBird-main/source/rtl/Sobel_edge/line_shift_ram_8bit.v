module line_shift_ram_8bit(
    input          clock,
    input          clken,
    input          per_frame_href,
    
    input   [7:0]  shiftin,
    output  [7:0]  taps0x,
    output  [7:0]  taps1x
);

//reg define
reg  [2:0]  clken_dly;
reg  [9:0]  ram_rd_addr;
reg  [9:0]  ram_rd_addr_d0;
reg  [9:0]  ram_rd_addr_d1;
reg  [7:0]  shiftin_d0;
reg  [7:0]  shiftin_d1;
reg  [7:0]  shiftin_d2;
reg  [7:0]  taps0x_d0;

//*****************************************************
//**                    main code
//*****************************************************

//在数据来到时，ram地址累加
always@(posedge clock)begin
    if(per_frame_href)
        if(clken)
            ram_rd_addr <= ram_rd_addr + 1 ;
        else
            ram_rd_addr <= ram_rd_addr ;
    else
        ram_rd_addr <= 0 ;
end

//时钟使能信号延迟三拍
always@(posedge clock) begin
    clken_dly <= { clken_dly[1:0] , clken };
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

/* //用于存储前一行图像的RAM
bram_256_8bit  u_ram_2048x8_0(
    .dia        (shiftin_d2),     //在延迟的第三个时钟周期，当前行的数据写入RAM0
    .clka       (clock),
    .clkb       (clock),
    .addra      (ram_rd_addr_d1),
    .addrb      (ram_rd_addr),
    .cea        (clken_dly[2]),
    .dob        (taps0x)          //延迟一个时钟周期，输出RAM0中前一行图像的数据
);   */

//用于存储前一行图像的RAM
bram_256_8bit bram_256_8bit_inst0
( 
    .dia    (shiftin_d2),
    .addra  (ram_rd_addr_d1),
    .wea    (clken_dly[2]),
    .clk    (clock),
    .dob    (taps0x),
    .addrb  (ram_rd_addr)
);

/* //用于存储前前一行图像的RAM
bram_256_8bit  u_ram_2048x8_1(
    .dia        (taps0x),         //在延迟的第二个时钟周期，将前一行图像的数据写入RAM1
    .clka       (clock),
    .clkb       (clock),
    .addra      (ram_rd_addr_d0),
    .cea        (clken_dly[1]),
    
    .addrb      (ram_rd_addr),
    .dob        (taps1x)           //延迟一个时钟周期，输出RAM1中前前一行图像的数据
);  */

bram_256_8bit bram_256_8bit_inst1
( 
    .dia    (taps0x),
    .addra  (ram_rd_addr_d0),
    .wea    (clken_dly[1]),
    .clk    (clock),
    .dob    (taps1x),
    .addrb  (ram_rd_addr)
);

endmodule 