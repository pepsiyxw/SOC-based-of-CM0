module sd_read_photo(
    input   wire            clk             ,  //时钟信号
    input   wire            rst_n           ,  //复位信号,低电平有效

    input   wire    [23:0]  sdram_max_addr  ,  //SDRAM读写最大地址  
    input   wire    [15:0]  sd_sec_num      ,  //SD卡读扇区个数
    input   wire            rd_busy         ,  //SD卡读忙信号
    input   wire            sd_rd_val_en    ,  //SD卡读数据有效信号
    input   wire    [15:0]  sd_rd_val_data  ,  //SD卡读出的数据
    output  reg             rd_start_en     ,  //开始写SD卡数据信号
    output  reg     [31:0]  rd_sec_addr     ,  //读数据扇区地址

    output  reg             photo_wr_done   ,

    output  reg             sdram_wr_en     ,  //SDRAM写使能信号
    output  wire    [15:0]  sdram_wr_data      //SDRAM写数据
    );

parameter PHOTO_SECTION_ADDR0 = 32'd51328;//开始界面图片扇区起始地址
parameter PHOTO_SECTION_ADDR1 = 32'd46720;//第一关图片扇区起始地址
parameter PHOTO_SECTION_ADDR2 = 32'd37504;//第二关图片扇区起始地址
parameter PHOTO_SECTION_ADDR3 = 32'd42112;//第三关图片扇区起始地址
parameter PHOTO_SECTION_ADDR4 = 32'd65152;//游戏暂停图片扇区起始地址
parameter PHOTO_SECTION_ADDR5 = 32'd60544;//游戏结束图片扇区起始地址
parameter PHOTO_SECTION_ADDR6 = 32'd32896;//游戏说明界面图片扇区起始地址
parameter PHOTO_SECTION_ADDR7 = 32'd55936;//游戏通关界面图片扇区起始地址

//BMP文件首部长度=BMP文件头+信息头
parameter BMP_HEAD_NUM = 6'd54;           //BMP文件头+信息头=14+40=54

//reg define
reg     [1:0]       rd_flow_cnt      ;  //读数据流程控制计数器
reg     [15:0]      rd_sec_cnt       ;  //读扇区次数计数器
reg     [3:0]       rd_addr_sw       ;  //读两张图片切换
reg     [25:0]      delay_cnt        ;  //延时切换图片计数器

reg                   rd_busy_d0       ;  //读忙信号打拍，用来采下降沿
reg                   rd_busy_d1       ;

reg     [1:0]   val_en_cnt      ;  //SD卡数据有效计数器
reg     [15:0]  val_data_t      ;  //SD卡数据有效寄存
reg     [5:0]   bmp_head_cnt    ;  //BMP首部计数器
reg             bmp_head_flag   ;  //BMP首部标志
reg     [23:0]  rgb888_data     ;  //24位RGB888数据
reg     [23:0]  sdram_wr_cnt    ;  //SDRAM写入计数器
reg     [1:0]   sdram_flow_cnt  ;  //SDRAM写数据流程控制器计数器
reg             bmp_rd_done     ;

//wire define
wire                  neg_rd_busy      ;  //SD卡读忙信号下降沿
      
//*****************************************************
//**                    main code
//*****************************************************

assign  neg_rd_busy = rd_busy_d1 & (~rd_busy_d0);
//24位RGB888格式转成16位RGB565格式
assign  sdram_wr_data = {rgb888_data[23:19],rgb888_data[15:10],rgb888_data[7:3]};

//对rd_busy信号进行延时打拍,用于采rd_busy信号的下降沿
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        rd_busy_d0 <= 1'b0;
        rd_busy_d1 <= 1'b0;
    end
    else begin
        rd_busy_d0 <= rd_busy;
        rd_busy_d1 <= rd_busy_d0;
    end
end

reg     [3:0]   photo_number;

//循环读取SD卡中的两张图片（读完之后延时1s再读下一个）
always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
            begin
                rd_flow_cnt <= 2'd0;
                rd_addr_sw <= 4'd0;
                rd_sec_cnt <= 16'd0;
                rd_start_en <= 1'b0;
                rd_sec_addr <= 32'd0;
                bmp_rd_done <= 1'b0;
                delay_cnt <= 26'd0;
                photo_number <= 4'd0;
                photo_wr_done <= 1'b0;
            end
        else if(photo_number < 4'd8)
            begin
                rd_start_en <= 1'b0;
                bmp_rd_done <= 1'b0;
                case(rd_flow_cnt)
                    2'd0 :  begin
                                //开始读取SD卡数据
                                rd_flow_cnt <= 2'd1;
                                rd_start_en <= 1'b1;
                                rd_addr_sw <= rd_addr_sw + 1'b1;                     //读数据地址切换
                                case(rd_addr_sw)
                                    4'd0:rd_sec_addr <= PHOTO_SECTION_ADDR0;
                                    4'd1:rd_sec_addr <= PHOTO_SECTION_ADDR1;
                                    4'd2:rd_sec_addr <= PHOTO_SECTION_ADDR2;
                                    4'd3:rd_sec_addr <= PHOTO_SECTION_ADDR3;
                                    4'd4:rd_sec_addr <= PHOTO_SECTION_ADDR4;
                                    4'd5:rd_sec_addr <= PHOTO_SECTION_ADDR5;
                                    4'd6:rd_sec_addr <= PHOTO_SECTION_ADDR6;
                                    4'd7:rd_sec_addr <= PHOTO_SECTION_ADDR7;
                                    default : rd_sec_addr <= PHOTO_SECTION_ADDR0;
                                endcase
                            end
                    2'd1 :  begin
                                //读忙信号的下降沿代表读完一个扇区,开始读取下一扇区地址数据
                                if(neg_rd_busy) 
                                    begin
                                        rd_sec_cnt <= rd_sec_cnt + 1'b1;
                                        rd_sec_addr <= rd_sec_addr + 32'd1;
                                        //单张图片读完
                                        if(rd_sec_cnt == sd_sec_num - 1'b1) 
                                            begin
                                                rd_sec_cnt <= 16'd0;
                                                rd_flow_cnt <= 2'd0;
                                                bmp_rd_done <= 1'b1;
                                                photo_number <= photo_number + 4'd1;
                                            end
                                        else
                                                rd_start_en <= 1'b1;
                                    end
                            end
    /*                 2'd2 : begin
                        delay_cnt <= delay_cnt + 1'b1;                 //单张图片读完后延时1秒
                        if(delay_cnt == 26'd50_000_000 - 26'd1) begin  //50_000_000*20ns = 1s
                            delay_cnt <= 26'd0;
                            rd_flow_cnt <= 2'd0;
                        end
                    end */
                    default : ;
                endcase
            end
        else
            photo_wr_done <= 1'b1;
    end

//SD卡读取的16位数据，转成24位RGB888格式
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        val_en_cnt <= 2'd0;
        val_data_t <= 16'd0; 
        bmp_head_cnt <= 6'd0;
        sdram_wr_en <= 1'b0;
        rgb888_data <= 24'd0;
        sdram_wr_cnt <= 24'd0;
        sdram_flow_cnt <= 2'd0;
    end
    else begin
        sdram_wr_en <= 1'b0;
        case(sdram_flow_cnt)
            2'd0 : begin   //BMP首部         
                if(sd_rd_val_en) begin
                    bmp_head_cnt <= bmp_head_cnt + 1'b1;
                    if(bmp_head_cnt == BMP_HEAD_NUM[5:1] - 1'b1) begin
                        sdram_flow_cnt <= sdram_flow_cnt + 1'b1;
                        bmp_head_cnt <= 6'd0;
                    end    
                end   
            end                
            2'd1 : begin   //BMP有效数据
                if(sd_rd_val_en) begin
                    val_en_cnt <= val_en_cnt + 1'b1;
                    val_data_t <= sd_rd_val_data;                
                    if(val_en_cnt == 2'd1) begin  //3个16位数据转成2个24位数据
                        sdram_wr_en <= 1'b1;
                        rgb888_data <= {sd_rd_val_data[15:8],val_data_t[7:0],
                                       val_data_t[15:8]}; 
                    end
                    else if(val_en_cnt == 2'd2) begin
                        sdram_wr_en <= 1'b1;
                        rgb888_data <= {sd_rd_val_data[7:0],sd_rd_val_data[15:8],
                                        val_data_t[7:0]};
                        val_en_cnt <= 2'd0;
                    end   
                end     
                if(sdram_wr_en) begin
                    sdram_wr_cnt <= sdram_wr_cnt + 1'b1;
                    if(sdram_wr_cnt == sdram_max_addr - 1'b1) begin
                        sdram_wr_cnt <= 24'd0;
                        sdram_flow_cnt <= sdram_flow_cnt + 1'b1;
                    end
                end
            end
            2'd2 : begin //等待单张BMP图片读取结束
                if(bmp_rd_done)
                    sdram_flow_cnt <= 2'd0;
            end
            default :;
        endcase
    end
end

endmodule
