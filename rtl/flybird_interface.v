module flybird_interface
(
    input   wire            HCLK            ,
    input   wire            HRESETn         ,
    input   wire            HSEL            ,
    input   wire    [31:0]  HADDR           ,
    input   wire    [1:0]   HTRANS          ,
    input   wire    [2:0]   HSIZE           ,
    input   wire    [3:0]   HPROT           ,
    input   wire            HWRITE          ,
    input   wire    [31:0]  HWDATA          ,
    input   wire            HREADY          ,
    output  wire            HREADYOUT       ,
    output  wire    [31:0]  HRDATA          ,
    output  wire            HRESP           ,

    output  reg             start_button    ,   // 0
                                                // 1
    output  reg             pause_button    ,   // 2
    output  reg             continue_button ,   // 3
    output  reg             restart_button  ,   // 4
    output  reg             method_button   ,   // 5
    output  reg             cancle_button   ,   // 6
    output  reg             third_move_button,  // 7

    output  reg             bird1up         ,   // 11
    output  reg             bird1down       ,   // 12
    output  reg             bird1left       ,   // 13
    output  reg             bird1right      ,   // 14

    output  reg             bird2up         ,   // 15
    output  reg             bird2down       ,   // 16
    output  reg             bird2left       ,   // 17
    output  reg             bird2right      ,   // 18

    input   wire    [6:0]   state_number    ,   // 20
    output  reg     [10:0]  sobel           ,   // 21
    input   wire    [7:0]   score           ,   // 22
    output  reg     [1:0]   gamemode        ,   // 23
    output  reg     [1:0]   pausemode       ,   // 24
    output  reg     [3:0]   angle           ,   // 25
    output  reg             bird1_speed     ,   // 26
    output  reg             bird2_speed     ,   // 27

    input   wire            photo_wr_done   ,   // 28

    input   wire            SG90_en         ,   // 29
    
    input   wire    [7:0]   custom3_score   ,   // 30
    output  reg             custom1_gun_enable, // 31

    output  reg             fourth_up       ,   // 32
    output  reg             fourth_left     ,   // 33
    output  reg             fourth_right        // 34
);

assign  HRESP = 1'b0;
assign  HREADYOUT = 1'b1;

wire    read_en;
assign  read_en = HSEL&HTRANS[1] & (~HWRITE) & HREADY;

wire    write_en;
assign  write_en = HSEL&HTRANS[1] & (HWRITE) & HREADY;

reg     rd_en_reg;
always@(posedge HCLK or negedge HRESETn)
    begin
        if(~HRESETn)
            rd_en_reg <= 1'b0;
        else if(read_en)
            rd_en_reg <= 1'b1;
        else
            rd_en_reg <= 1'b0;
    end

reg     wr_en_reg;
always@(posedge HCLK or negedge HRESETn)
    begin
        if(~HRESETn)
            wr_en_reg <= 1'b0;
        else if(write_en)
            wr_en_reg <= 1'b1;
        else
            wr_en_reg <= 1'b0;
end

reg [5:0]   addr_reg;
always@(posedge HCLK or negedge HRESETn)
    begin
        if(~HRESETn)
            addr_reg <= 6'd0;
        else if(HSEL & HREADY & HTRANS[1])
            addr_reg <= HADDR[7:2];
    end

//keil中对应变量
/* reg             reserved1;          // 7 */
reg             reserved2;          // 8
reg             reserved3;          // 9
reg             reserved4;          // 10
reg             reserved5;          // 19

reg             spare;              //备用端口


always@(posedge HCLK or negedge HRESETn)
    if(~HRESETn)
        begin
            start_button <= 1'b0;
            pause_button <= 1'b0;
            continue_button <= 1'b0;
            restart_button <= 1'b0;
            method_button <= 1'b0;
            cancle_button <= 1'b0;
            third_move_button <= 1'b0;
            reserved2 <= 1'b0;
            reserved3 <= 1'b0;
            reserved4 <= 1'b0;
            bird1up <= 1'b0;
            bird1down <= 1'b0;
            bird1left <= 1'b0;
            bird1right <= 1'b0;
            bird2up <= 1'b0;
            bird2down <= 1'b0;
            bird2left <= 1'b0;
            bird2right <= 1'b0;
            sobel <= 11'd0;
            gamemode <= 2'd0;
            pausemode <= 2'd0;
            angle <= 4'd1;
            bird1_speed <= 1'b0;
            bird2_speed <= 1'b0;
            custom1_gun_enable <= 1'b0;
            fourth_up <= 1'b0;
            fourth_left <= 1'b0;
            fourth_right <= 1'b0;

            spare <= 1'b0;
        end
    else if(wr_en_reg && HREADY)
        begin
            if(addr_reg == 6'd0)
                start_button <= HWDATA[0];
            else if(addr_reg == 6'd1)
                spare <= HWDATA[0];
            else if(addr_reg == 6'd2)
                pause_button <= HWDATA[0];
            else if(addr_reg == 6'd3)
                continue_button <= HWDATA[0];
            else if(addr_reg == 6'd4)
                restart_button <= HWDATA[0];
            else if(addr_reg == 6'd5)
                method_button <= HWDATA[0];
            else if(addr_reg == 6'd6)
                cancle_button <= HWDATA[0];
            else if(addr_reg == 6'd7)
                third_move_button <= HWDATA[0];
            else if(addr_reg == 6'd8)
                reserved2 <= HWDATA[0];
            else if(addr_reg == 6'd9)
                reserved3 <= HWDATA[0];
            else if(addr_reg == 6'd10)
                reserved4 <= HWDATA[0];
            else if(addr_reg == 6'd11)
                bird1up <= HWDATA[0];
            else if(addr_reg == 6'd12)
                bird1down <= HWDATA[0];
            else if(addr_reg == 6'd13)
                bird1left <= HWDATA[0];
            else if(addr_reg == 6'd14)
                bird1right <= HWDATA[0];
            else if(addr_reg == 6'd15)
                bird2up <= HWDATA[0];
            else if(addr_reg == 6'd16)
                bird2down <= HWDATA[0];
            else if(addr_reg == 6'd17)
                bird2left <= HWDATA[0];
            else if(addr_reg == 6'd18)
                bird2right <= HWDATA[0];
            else if(addr_reg == 6'd19)
                reserved5 <= HWDATA[15:0];
            else if(addr_reg == 6'd20)
                spare <= HWDATA[0];
            else if(addr_reg == 6'd21)
                sobel <= HWDATA[10:0];
            else if(addr_reg == 6'd22)
                spare <= HWDATA[0];
            else if(addr_reg == 6'd23)
                gamemode <= HWDATA[1:0];
            else if(addr_reg == 6'd24)
                pausemode <= HWDATA[1:0];
            else if(addr_reg == 6'd25)
                angle <= HWDATA[3:0];
            else if(addr_reg == 6'd26)
                bird1_speed <= HWDATA[0];
            else if(addr_reg == 6'd27)
                bird2_speed <= HWDATA[0];
            else if(addr_reg == 6'd28)
                spare <= HWDATA[0];
            else if(addr_reg == 6'd29)
                spare <= HWDATA[0];
            else if(addr_reg == 6'd30)
                spare <= HWDATA[0];
            else if(addr_reg == 6'd31)
                custom1_gun_enable <= HWDATA[0];
            else if(addr_reg == 6'd32)
                fourth_up <= HWDATA[0];
            else if(addr_reg == 6'd33)
                fourth_left <= HWDATA[0];
            else if(addr_reg == 6'd34)
                fourth_right <= HWDATA[0];
        end

assign HRDATA = (addr_reg == 6'd0) ? start_button : 
                (addr_reg == 6'd1) ? spare : 
                (addr_reg == 6'd2) ? pause_button : 
                (addr_reg == 6'd3) ? continue_button : 
                (addr_reg == 6'd4) ? restart_button : 
                (addr_reg == 6'd5) ? method_button : 
                (addr_reg == 6'd6) ? cancle_button : 
                (addr_reg == 6'd7) ? third_move_button : 
                (addr_reg == 6'd8) ? reserved2 : 
                (addr_reg == 6'd9) ? reserved3 : 
                (addr_reg == 6'd10) ? reserved4 : 
                (addr_reg == 6'd11) ? bird1up : 
                (addr_reg == 6'd12) ? bird1down : 
                (addr_reg == 6'd13) ? bird1left : 
                (addr_reg == 6'd14) ? bird1right : 
                (addr_reg == 6'd15) ? bird2up : 
                (addr_reg == 6'd16) ? bird2down : 
                (addr_reg == 6'd17) ? bird2left : 
                (addr_reg == 6'd18) ? bird2right : 
                (addr_reg == 6'd19) ? reserved5 : 
                (addr_reg == 6'd20) ? state_number : 
                (addr_reg == 6'd21) ? sobel : 
                (addr_reg == 6'd22) ? score : 
                (addr_reg == 6'd23) ? gamemode : 
                (addr_reg == 6'd24) ? pausemode : 
                (addr_reg == 6'd25) ? angle : 
                (addr_reg == 6'd26) ? bird1_speed : 
                (addr_reg == 6'd27) ? bird2_speed : 
                (addr_reg == 6'd28) ? photo_wr_done : 
                (addr_reg == 6'd29) ? SG90_en : 
                (addr_reg == 6'd30) ? custom3_score : 
                (addr_reg == 6'd31) ? custom1_gun_enable : 
                (addr_reg == 6'd32) ? fourth_up : 
                (addr_reg == 6'd33) ? fourth_left : 
                (addr_reg == 6'd34) ? fourth_right : 32'b0;

endmodule
