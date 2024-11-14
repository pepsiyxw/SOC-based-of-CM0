module shell_go
(
    input   wire            clk                     ,
    input   wire            clk_150hz_flag          ,
    input   wire            rst_n                   ,

    input   wire            third_custom_move       ,

    input   wire    [6:0]   state                   ,
    input   wire    [3:0]   angle                   ,

    input   wire    [11:0]  lcd_xpos                ,
    input   wire    [11:0]  lcd_ypos                ,

    output  reg             angle1_shell1_en        ,
/*     output  reg             angle1_shell2_en        , */
    output  reg     [9:0]   angle1_shell1_x0        ,
    output  reg     [9:0]   angle1_shell1_y0        ,
/*     output  reg     [9:0]   angle1_shell2_x0        ,
    output  reg     [9:0]   angle1_shell2_y0        , */

    output  reg             angle2_shell1_en        ,
/*     output  reg             angle2_shell2_en        , */
    output  reg     [9:0]   angle2_shell1_x0        ,
    output  reg     [9:0]   angle2_shell1_y0        ,
/*     output  reg     [9:0]   angle2_shell2_x0        ,
    output  reg     [9:0]   angle2_shell2_y0        , */

    output  reg             angle3_shell1_en        ,
/*     output  reg             angle3_shell2_en        , */
    output  reg     [9:0]   angle3_shell1_x0        ,
    output  reg     [9:0]   angle3_shell1_y0        ,
/*     output  reg     [9:0]   angle3_shell2_x0        ,
    output  reg     [9:0]   angle3_shell2_y0        , */

    output  reg             angle4_shell1_en        ,
/*     output  reg             angle4_shell2_en        , */
    output  reg     [9:0]   angle4_shell1_x0        ,
    output  reg     [9:0]   angle4_shell1_y0        ,
/*     output  reg     [9:0]   angle4_shell2_x0        ,
    output  reg     [9:0]   angle4_shell2_y0        , */

    output  reg             angle5_shell1_en        ,
/*     output  reg             angle5_shell2_en        , */
    output  reg     [9:0]   angle5_shell1_x0        ,
    output  reg     [9:0]   angle5_shell1_y0        ,
/*     output  reg     [9:0]   angle5_shell2_x0        ,
    output  reg     [9:0]   angle5_shell2_y0        , */

    output  reg             angle6_shell1_en        ,
/*     output  reg             angle6_shell2_en        , */
    output  reg     [9:0]   angle6_shell1_x0        ,
    output  reg     [9:0]   angle6_shell1_y0        ,
/*     output  reg     [9:0]   angle6_shell2_x0        ,
    output  reg     [9:0]   angle6_shell2_y0        , */

    output  reg             angle7_shell1_en        ,
/*     output  reg             angle7_shell2_en        , */
    output  reg     [9:0]   angle7_shell1_x0        ,
    output  reg     [9:0]   angle7_shell1_y0        ,
/*     output  reg     [9:0]   angle7_shell2_x0        ,
    output  reg     [9:0]   angle7_shell2_y0        , */

    output  reg             angle8_shell1_en        ,
/*     output  reg             angle8_shell2_en        , */
    output  reg     [9:0]   angle8_shell1_x0        ,
    output  reg     [9:0]   angle8_shell1_y0        ,
/*     output  reg     [9:0]   angle8_shell2_x0        ,
    output  reg     [9:0]   angle8_shell2_y0        , */
    
    output  reg     [7:0]   custom3_score
);

//**************************************************************************
//角度1
//角度1炮弹一使能信号
always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0 || third_custom_move == 1'b0)
        angle1_shell1_en <= 1'b0;
    else if(clk_150hz_flag == 1'b1)
        begin
            if(state == 7'b0001000)
                begin
                    if(angle == 4'd1)
                        angle1_shell1_en <= 1'b1;
                    else if(angle != 4'd1 && angle1_shell1_x0 == 7'd100)
                            angle1_shell1_en <= 1'b0;
                    else
                        angle1_shell1_en <= angle1_shell1_en;
                end
            else
                angle1_shell1_en <= 1'b0;
        end
    else
        angle1_shell1_en <= angle1_shell1_en;

/* //角度1炮弹二使能信号
always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0 || third_custom_move == 1'b0)
        angle1_shell2_en <= 1'b0;
    else if(clk_150hz_flag == 1'b1)
        begin
            if(state == 7'b0001000)
                begin
                    if(angle == 1'b1)
                        begin
                            if(angle1_shell1_x0 == 9'd494)
                                angle1_shell2_en <= 1'b1;
                            else
                                angle1_shell2_en <= angle1_shell2_en;
                        end
                    else if(angle != 4'd1 && angle1_shell2_x0 == 7'd100)
                        angle1_shell2_en <= 1'b0;
                    else
                        angle1_shell2_en <= angle1_shell2_en;
                end
            else
                angle1_shell2_en <= 1'b0;
        end
    else
        angle1_shell2_en <= angle1_shell2_en; */

always@(posedge clk or negedge rst_n)
        if(rst_n == 1'b0 || third_custom_move == 1'b0)
            begin
                angle1_shell1_x0 <= 10'd890;
                angle1_shell1_y0 <= 8'd170;
            end
        else if(clk_150hz_flag == 1'b1)
            begin
                if(angle1_shell1_en == 1'b1)
                    begin
                        if(angle1_shell1_x0 == 7'd100)
                            begin
                                angle1_shell1_x0 <= 10'd890;
                                angle1_shell1_y0 <= 8'd170;
                            end
                        else
                            begin
                                angle1_shell1_x0 <= angle1_shell1_x0 - 2'd2;
                                angle1_shell1_y0 <= angle1_shell1_y0 + 1'b1;
                            end
                    end
                else
                    begin
                        angle1_shell1_x0 <= 10'd890;
                        angle1_shell1_y0 <= 8'd170;
                    end
            end
        else
            begin
                angle1_shell1_x0 <= angle1_shell1_x0;
                angle1_shell1_y0 <= angle1_shell1_y0;
            end

/* always@(posedge clk or negedge rst_n)
        if(rst_n == 1'b0 || third_custom_move == 1'b0)
            begin
                angle1_shell2_x0 <= 10'd890;
                angle1_shell2_y0 <= 8'd170;
            end
        else if(clk_150hz_flag == 1'b1)
            begin
                if(angle1_shell2_en == 1'b1)
                    begin
                        if(angle1_shell2_x0 == 100)
                            begin
                                angle1_shell2_x0 <= 10'd890;
                                angle1_shell2_y0 <= 8'd170;
                            end
                        else
                            begin
                                angle1_shell2_x0 <= angle1_shell2_x0 - 2'd2;
                                angle1_shell2_y0 <= angle1_shell2_y0 + 1'b1;
                            end
                    end
                else
                    begin
                        angle1_shell2_x0 <= 10'd890;
                        angle1_shell2_y0 <= 8'd170;
                    end
            end
        else
            begin
                angle1_shell2_x0 <= angle1_shell2_x0;
                angle1_shell2_y0 <= angle1_shell2_y0;
            end */

//**************************************************************************
//角度2
//角度2炮弹一使能信号
always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0 || third_custom_move == 1'b0)
        angle2_shell1_en <= 1'b0;
    else if(clk_150hz_flag == 1'b1)
        begin
            if(state == 7'b0001000)
                begin
                    if(angle == 4'd2)
                        angle2_shell1_en <= 1'b1;
                    else if(angle != 4'd2 && angle2_shell1_y0 == 10'd630)
                        angle2_shell1_en <= 1'b0;
                    else
                        angle2_shell1_en <= angle2_shell1_en;
                end
            else
                angle2_shell1_en <= 1'b0;
        end
    else
        angle2_shell1_en <= angle2_shell1_en;

/* //角度2炮弹二使能信号
always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0 || third_custom_move == 1'b0)
        angle2_shell2_en <= 1'b0;
    else if(clk_150hz_flag == 1'b1)
        begin
            if(state == 7'b0001000)
                begin
                    if(angle == 4'd2)
                        begin
                            if(angle2_shell1_y0 == 9'd360)
                                angle2_shell2_en <= 1'b1;
                            else
                                angle2_shell2_en <= angle2_shell2_en;
                        end
                    else if(angle != 4'd2 && angle2_shell2_y0 == 9'd630)
                        angle2_shell2_en <= 1'b0;
                    else
                        angle2_shell2_en <= angle2_shell2_en;
                end
            else
                angle2_shell2_en <= 1'b0;
        end
    else
        angle2_shell2_en <= angle2_shell2_en; */

always@(posedge clk or negedge rst_n)
        if(rst_n == 1'b0 || third_custom_move == 1'b0)
            begin
                angle2_shell1_x0 <= 10'd680;
                angle2_shell1_y0 <= 7'd90;
            end
        else if(clk_150hz_flag == 1'b1)
            begin
                if(angle2_shell1_en == 1'b1)
                    begin
                        if(angle2_shell1_y0 == 10'd630)
                            begin
                                angle2_shell1_x0 <= 10'd680;
                                angle2_shell1_y0 <= 7'd90;
                            end
                        else
                            begin
                                angle2_shell1_x0 <= angle2_shell1_x0 - 1'b1;
                                angle2_shell1_y0 <= angle2_shell1_y0 + 2'd2;
                            end
                    end
                else
                    begin
                        angle2_shell1_x0 <= 10'd680;
                        angle2_shell1_y0 <= 7'd90;
                    end
            end
        else
            begin
                angle2_shell1_x0 <= angle2_shell1_x0;
                angle2_shell1_y0 <= angle2_shell1_y0;
            end

/* always@(posedge clk or negedge rst_n)
        if(rst_n == 1'b0 || third_custom_move == 1'b0)
            begin
                angle2_shell2_x0 <= 10'd680;
                angle2_shell2_y0 <= 7'd90;
            end
        else if(clk_150hz_flag == 1'b1)
            begin
                if(angle2_shell2_en == 1'b1)
                    begin
                        if(angle2_shell2_y0 == 630)
                            begin
                                angle2_shell2_x0 <= 10'd680;
                                angle2_shell2_y0 <= 7'd90;
                            end
                        else
                            begin
                                angle2_shell2_x0 <= angle2_shell2_x0 - 1;
                                angle2_shell2_y0 <= angle2_shell2_y0 + 2;
                            end
                    end
                else
                    begin
                        angle2_shell2_x0 <= 10'd680;
                        angle2_shell2_y0 <= 7'd90;
                    end
            end
        else
            begin
                angle2_shell2_x0 <= angle2_shell2_x0;
                angle2_shell2_y0 <= angle2_shell2_y0;
            end */

//**************************************************************************
//角度3
//角度3炮弹一使能信号
always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0 || third_custom_move == 1'b0)
        angle3_shell1_en <= 1'b0;
    else if(clk_150hz_flag == 1'b1)
        begin
            if(state == 7'b0001000)
                begin
                    if(angle == 4'd3)
                        angle3_shell1_en <= 1'b1;
                    else if(angle != 4'd3 && angle3_shell1_y0 == 10'd630)
                        angle3_shell1_en <= 1'b0;
                    else
                        angle3_shell1_en <= angle3_shell1_en;
                end
            else
                angle3_shell1_en <= 1'b0;
        end
    else
        angle3_shell1_en <= angle3_shell1_en;

/* //角度3炮弹二使能信号
always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0 || third_custom_move == 1'b0)
            angle3_shell2_en <= 1'b0;
    else if(clk_150hz_flag == 1'b1)
        begin
            if(state == 7'b0001000)
                begin
                    if(angle == 4'd3)
                        begin
                            if(angle3_shell1_y0 == 9'd360)
                                angle3_shell2_en <= 1'b1;
                            else
                                angle3_shell2_en <= angle3_shell2_en;
                        end
                    else if(angle != 4'd3 && angle3_shell2_y0 == 9'd630)
                        angle3_shell2_en <= 1'b0;
                    else
                        angle3_shell2_en <= angle3_shell2_en;
                end
            else
                angle3_shell2_en <= 1'b0;
        end
    else
        angle3_shell2_en <= angle3_shell2_en; */

always@(posedge clk or negedge rst_n)
        if(rst_n == 1'b0 || third_custom_move == 1'b0)
            begin
                angle3_shell1_x0 <= 9'd300;
                angle3_shell1_y0 <= 7'd90;
            end
        else if(clk_150hz_flag == 1'b1)
            begin
                if(angle3_shell1_en == 1'b1)
                    begin
                        if(angle3_shell1_y0 == 10'd630)
                            begin
                                angle3_shell1_x0 <= 9'd300;
                                angle3_shell1_y0 <= 7'd90;
                            end
                        else
                            begin
                                angle3_shell1_x0 <= angle3_shell1_x0 + 1'b1;
                                angle3_shell1_y0 <= angle3_shell1_y0 + 2'd2;
                            end
                    end
                else
                    begin
                        angle3_shell1_x0 <= 9'd300;
                        angle3_shell1_y0 <= 7'd90;
                    end
            end
        else
            begin
                angle3_shell1_x0 <= angle3_shell1_x0;
                angle3_shell1_y0 <= angle3_shell1_y0;
            end

/* always@(posedge clk or negedge rst_n)
        if(rst_n == 1'b0 || third_custom_move == 1'b0)
            begin
                angle3_shell2_x0 <= 9'd300;
                angle3_shell2_y0 <= 7'd90;
            end
        else if(clk_150hz_flag == 1'b1)
            begin
                if(angle3_shell2_en == 1'b1)
                    begin
                        if(angle3_shell2_y0 == 10'd630)
                            begin
                                angle3_shell2_x0 <= 9'd300;
                                angle3_shell2_y0 <= 7'd90;
                            end
                        else
                            begin
                                angle3_shell2_x0 <= angle3_shell2_x0 + 1'b1;
                                angle3_shell2_y0 <= angle3_shell2_y0 + 2'd2;
                            end
                    end
                else
                    begin
                        angle3_shell2_x0 <= 9'd300;
                        angle3_shell2_y0 <= 7'd90;
                    end
            end
        else
            begin
                angle3_shell2_x0 <= angle3_shell2_x0;
                angle3_shell2_y0 <= angle3_shell2_y0;
            end */

//**************************************************************************
//角度4
//角度4炮弹一使能信号
always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0 || third_custom_move == 1'b0)
        angle4_shell1_en <= 1'b0;
    else if(clk_150hz_flag == 1'b1)
        begin
            if(state == 7'b0001000)
                begin
                    if(angle == 4'd4)
                        angle4_shell1_en <= 1'b1;
                    else if(angle != 4'd4 && angle4_shell1_x0 == 10'd890)
                        angle4_shell1_en <= 1'b0;
                    else
                        angle4_shell1_en <= angle4_shell1_en;
                end
            else
                angle4_shell1_en <= 1'b0;
        end
    else
        angle4_shell1_en <= angle4_shell1_en;

/* //角度4炮弹二使能信号
always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0 || third_custom_move == 1'b0)
            angle4_shell2_en <= 1'b0;
    else if(clk_150hz_flag == 1'b1)
        begin
            if(state == 7'b0001000)
                begin
                    if(angle == 4'd4)
                        begin
                            if(angle4_shell1_x0 == 9'd494)
                                angle4_shell2_en <= 1'b1;
                            else
                                angle4_shell2_en <= angle4_shell2_en;
                        end
                    else if(angle != 4'd4 && angle4_shell2_x0 == 10'd890)
                        angle4_shell2_en <= 1'b0;
                    else
                        angle4_shell2_en <= angle4_shell2_en;
                end
            else
                angle4_shell2_en <= 1'b0;
        end
    else
        angle4_shell2_en <= angle4_shell2_en; */

always@(posedge clk or negedge rst_n)
        if(rst_n == 1'b0 || third_custom_move == 1'b0)
            begin
                angle4_shell1_x0 <= 7'd100;
                angle4_shell1_y0 <= 8'd160;
            end
        else if(clk_150hz_flag == 1'b1)
            begin
                if(angle4_shell1_en == 1'b1)
                    begin
                        if(angle4_shell1_x0 == 890)
                            begin
                                angle4_shell1_x0 <= 7'd100;
                                angle4_shell1_y0 <= 8'd160;
                            end
                        else
                            begin
                                angle4_shell1_x0 <= angle4_shell1_x0 + 2'd2;
                                angle4_shell1_y0 <= angle4_shell1_y0 + 1'b1;
                            end
                    end
                else
                    begin
                        angle4_shell1_x0 <= 7'd100;
                        angle4_shell1_y0 <= 8'd160;
                    end
            end
        else
            begin
                angle4_shell1_x0 <= angle4_shell1_x0;
                angle4_shell1_y0 <= angle4_shell1_y0;
            end

/* always@(posedge clk or negedge rst_n)
        if(rst_n == 1'b0 || third_custom_move == 1'b0)
            begin
                angle4_shell2_x0 <= 7'd100;
                angle4_shell2_y0 <= 8'd160;
            end
        else if(clk_150hz_flag == 1'b1)
            begin
                if(angle4_shell2_en == 1'b1)
                    begin
                        if(angle4_shell2_x0 == 10'd890)
                            begin
                                angle4_shell2_x0 <= 7'd100;
                                angle4_shell2_y0 <= 8'd160;
                            end
                        else
                            begin
                                angle4_shell2_x0 <= angle4_shell2_x0 + 2'd2;
                                angle4_shell2_y0 <= angle4_shell2_y0 + 1'b1;
                            end
                    end
                else
                    begin
                        angle4_shell2_x0 <= 7'd100;
                        angle4_shell2_y0 <= 8'd160;
                    end
            end
        else
            begin
                angle4_shell2_x0 <= angle4_shell2_x0;
                angle4_shell2_y0 <= angle4_shell2_y0;
            end */

//**************************************************************************
//角度5
//角度5炮弹一使能信号
always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0 || third_custom_move == 1'b0)
        angle5_shell1_en <= 1'b0;
    else if(clk_150hz_flag == 1'b1)
        begin
            if(state == 7'b0001000)
                begin
                    if(angle == 4'd5)
                        angle5_shell1_en <= 1'b1;
                    else if(angle != 4'd5 && angle5_shell1_x0 == 7'd100)
                        angle5_shell1_en <= 1'b0;
                    else
                        angle5_shell1_en <= angle5_shell1_en;
                end
            else
                angle5_shell1_en <= 1'b0;
        end
    else
        angle5_shell1_en <= angle5_shell1_en;

/* //角度5炮弹二使能信号
always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0 || third_custom_move == 1'b0)
            angle5_shell2_en <= 1'b0;
    else if(clk_150hz_flag == 1'b1)
        begin
            if(state == 7'b0001000)
                begin
                    if(angle == 4'd5)
                        begin
                            if(angle5_shell1_x0 == 9'd494)
                                angle5_shell2_en <= 1'b1;
                            else
                                angle5_shell2_en <= angle5_shell2_en;
                        end
                    else if(angle != 4'd5 && angle5_shell2_x0 == 10'd890)
                        angle5_shell2_en <= 1'b0;
                    else
                        angle5_shell2_en <= angle5_shell2_en;
                end
            else
                angle5_shell2_en <= 1'b0;
        end
    else
        angle5_shell2_en <= angle5_shell2_en; */

always@(posedge clk or negedge rst_n)
        if(rst_n == 1'b0 || third_custom_move == 1'b0)
            begin
                angle5_shell1_x0 <= 7'd100;
                angle5_shell1_y0 <= 10'd530;
            end
        else if(clk_150hz_flag == 1'b1)
            begin
                if(angle5_shell1_en == 1'b1)
                    begin
                        if(angle5_shell1_x0 == 10'd890)
                            begin
                                angle5_shell1_x0 <= 7'd100;
                                angle5_shell1_y0 <= 10'd530;
                            end
                        else
                            begin
                                angle5_shell1_x0 <= angle5_shell1_x0 + 2'd2;
                                angle5_shell1_y0 <= angle5_shell1_y0 - 1'b1;
                            end
                    end
                else
                    begin
                        angle5_shell1_x0 <= 7'd100;
                        angle5_shell1_y0 <= 10'd530;
                    end
            end
        else
            begin
                angle5_shell1_x0 <= angle5_shell1_x0;
                angle5_shell1_y0 <= angle5_shell1_y0;
            end

/* always@(posedge clk or negedge rst_n)
        if(rst_n == 1'b0 || third_custom_move == 1'b0)
            begin
                angle5_shell2_x0 <= 7'd100;
                angle5_shell2_y0 <= 10'd530;
            end
        else if(clk_150hz_flag == 1'b1)
            begin
                if(angle5_shell2_en == 1'b1)
                    begin
                        if(angle5_shell2_x0 == 890)
                            begin
                                angle5_shell2_x0 <= 7'd100;
                                angle5_shell2_y0 <= 10'd530;
                            end
                        else
                            begin
                                angle5_shell2_x0 <= angle5_shell2_x0 + 2'd2;
                                angle5_shell2_y0 <= angle5_shell2_y0 - 1'b1;
                            end
                    end
                else
                    begin
                        angle5_shell2_x0 <= 7'd100;
                        angle5_shell2_y0 <= 10'd530;
                    end
            end
        else
            begin
                angle5_shell2_x0 <= angle5_shell2_x0;
                angle5_shell2_y0 <= angle5_shell2_y0;
            end */

//**************************************************************************
//角度6
//角度6炮弹一使能信号
always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0 || third_custom_move == 1'b0)
        angle6_shell1_en <= 1'b0;
    else if(clk_150hz_flag == 1'b1)
        begin
            if(state == 7'b0001000)
                begin
                    if(angle == 4'd6)
                        angle6_shell1_en <= 1'b1;
                    else if(angle != 4'd6 && angle6_shell1_y0 == 7'd90)
                        angle6_shell1_en <= 1'b0;
                    else
                        angle6_shell1_en <= angle6_shell1_en;
                end
            else
                angle6_shell1_en <= 1'b0;
        end
    else
        angle6_shell1_en <= angle6_shell1_en;

/* //角度6炮弹二使能信号
always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0 || third_custom_move == 1'b0)
            angle6_shell2_en <= 1'b0;
    else if(clk_150hz_flag == 1'b1)
        begin
            if(state == 7'b0001000)
                begin
                    if(angle == 4'd6)
                        begin
                            if(angle6_shell1_y0 == 9'd360)
                                angle6_shell2_en <= 1'b1;
                            else
                                angle6_shell2_en <= angle6_shell2_en;
                        end
                    else if(angle != 4'd6 && angle6_shell2_y0 == 7'd90)
                        angle6_shell2_en <= 1'b0;
                    else
                        angle6_shell2_en <= angle6_shell2_en;
                end
            else
                angle6_shell2_en <= 1'b0;
        end
    else
        angle6_shell2_en <= angle6_shell2_en; */

always@(posedge clk or negedge rst_n)
        if(rst_n == 1'b0 || third_custom_move == 1'b0)
            begin
                angle6_shell1_x0 <= 9'd300;
                angle6_shell1_y0 <= 10'd630;
            end
        else if(clk_150hz_flag == 1'b1)
            begin
                if(angle6_shell1_en == 1'b1)
                    begin
                        if(angle6_shell1_y0 == 90)
                            begin
                                angle6_shell1_x0 <= 9'd300;
                                angle6_shell1_y0 <= 10'd630;
                            end
                        else
                            begin
                                angle6_shell1_x0 <= angle6_shell1_x0 + 1'b1;
                                angle6_shell1_y0 <= angle6_shell1_y0 - 2'd2;
                            end
                    end
                else
                    begin
                        angle6_shell1_x0 <= 9'd300;
                        angle6_shell1_y0 <= 10'd630;
                    end
            end
        else
            begin
                angle6_shell1_x0 <= angle6_shell1_x0;
                angle6_shell1_y0 <= angle6_shell1_y0;
            end

/* always@(posedge clk or negedge rst_n)
        if(rst_n == 1'b0 || third_custom_move == 1'b0)
            begin
                angle6_shell2_x0 <= 9'd300;
                angle6_shell2_y0 <= 10'd630;
            end
        else if(clk_150hz_flag == 1'b1)
            begin
                if(angle6_shell2_en == 1'b1)
                    begin
                        if(angle6_shell2_y0 == 90)
                            begin
                                angle6_shell2_x0 <= 9'd300;
                                angle6_shell2_y0 <= 10'd630;
                            end
                        else
                            begin
                                angle6_shell2_x0 <= angle6_shell2_x0 + 1'b1;
                                angle6_shell2_y0 <= angle6_shell2_y0 - 2'd2;
                            end
                    end
                else
                    begin
                        angle6_shell2_x0 <= 9'd300;
                        angle6_shell2_y0 <= 10'd630;
                    end
            end
        else
            begin
                angle6_shell2_x0 <= angle6_shell2_x0;
                angle6_shell2_y0 <= angle6_shell2_y0;
            end */

//**************************************************************************
//角度7
//角度7炮弹一使能信号
always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0 || third_custom_move == 1'b0)
        angle7_shell1_en <= 1'b0;
    else if(clk_150hz_flag == 1'b1)
        begin
            if(state == 7'b0001000)
                begin
                    if(angle == 4'd7)
                        angle7_shell1_en <= 1'b1;
                    else if(angle != 4'd7 && angle7_shell1_y0 == 7'd90)
                        angle7_shell1_en <= 1'b0;
                    else
                        angle7_shell1_en <= angle7_shell1_en;
                end
            else
                angle7_shell1_en <= 1'b0;
        end
    else
        angle7_shell1_en <= angle7_shell1_en;

/* //角度3炮弹二使能信号
always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0 || third_custom_move == 1'b0)
            angle7_shell2_en <= 1'b0;
    else if(clk_150hz_flag == 1'b1)
        begin
            if(state == 7'b0001000)
                begin
                    if(angle == 4'd7)
                        begin
                            if(angle7_shell1_y0 == 9'd360)
                                angle7_shell2_en <= 1'b1;
                            else
                                angle7_shell2_en <= angle7_shell2_en;
                        end
                    else if(angle != 4'd7 && angle7_shell2_y0 == 7'd90)
                        angle7_shell2_en <= 1'b0;
                    else
                        angle7_shell2_en <= angle7_shell2_en;
                end
            else
                angle7_shell2_en <= 1'b0;
        end
    else
        angle7_shell2_en <= angle7_shell2_en; */

always@(posedge clk or negedge rst_n)
        if(rst_n == 1'b0 || third_custom_move == 1'b0)
            begin
                angle7_shell1_x0 <= 10'd740;
                angle7_shell1_y0 <= 10'd630;
            end
        else if(clk_150hz_flag == 1'b1)
            begin
                if(angle7_shell1_en == 1'b1)
                    begin
                        if(angle7_shell1_y0 == 7'd90)
                            begin
                                angle7_shell1_x0 <= 10'd740;
                                angle7_shell1_y0 <= 10'd630;
                            end
                        else
                            begin
                                angle7_shell1_x0 <= angle7_shell1_x0 - 1'b1;
                                angle7_shell1_y0 <= angle7_shell1_y0 - 2'd2;
                            end
                    end
                else
                    begin
                        angle7_shell1_x0 <= 10'd740;
                        angle7_shell1_y0 <= 10'd630;
                    end
            end
        else
            begin
                angle7_shell1_x0 <= angle7_shell1_x0;
                angle7_shell1_y0 <= angle7_shell1_y0;
            end

/* always@(posedge clk or negedge rst_n)
        if(rst_n == 1'b0 || third_custom_move == 1'b0)
            begin
                angle7_shell2_x0 <= 10'd740;
                angle7_shell2_y0 <= 10'd630;
            end
        else if(clk_150hz_flag == 1'b1)
            begin
                if(angle7_shell2_en == 1'b1)
                    begin
                        if(angle7_shell2_y0 == 90)
                            begin
                                angle7_shell2_x0 <= 10'd740;
                                angle7_shell2_y0 <= 10'd630;
                            end
                        else
                            begin
                                angle7_shell2_x0 <= angle7_shell2_x0 - 1'b1;
                                angle7_shell2_y0 <= angle7_shell2_y0 - 2'd2;
                            end
                    end
                else
                    begin
                        angle7_shell2_x0 <= 10'd740;
                        angle7_shell2_y0 <= 10'd630;
                    end
            end
        else
            begin
                angle7_shell2_x0 <= angle7_shell2_x0;
                angle7_shell2_y0 <= angle7_shell2_y0;
            end */

//**************************************************************************
//角度8
//角度8炮弹一使能信号
always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0 || third_custom_move == 1'b0)
        angle8_shell1_en <= 1'b0;
    else if(clk_150hz_flag == 1'b1)
        begin
            if(state == 7'b0001000)
                begin
                    if(angle == 4'd8)
                        angle8_shell1_en <= 1'b1;
                    else if(angle != 4'd8 && angle8_shell1_x0 == 7'd100)
                        angle8_shell1_en <= 1'b0;
                    else
                        angle8_shell1_en <= angle8_shell1_en;
                end
            else
                angle8_shell1_en <= 1'b0;
        end
    else
        angle8_shell1_en <= angle8_shell1_en;

/* //角度8炮弹二使能信号
always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0 || third_custom_move == 1'b0)
            angle8_shell2_en <= 1'b0;
    else if(clk_150hz_flag == 1'b1)
        begin
            if(state == 7'b0001000)
                begin
                    if(angle == 4'd8)
                        begin
                            if(angle8_shell1_x0 == 9'd494)
                                angle8_shell2_en <= 1'b1;
                            else
                                angle8_shell2_en <= angle8_shell2_en;
                        end
                    else if(angle != 4'd8 && angle8_shell2_x0 == 7'd100)
                        angle8_shell2_en <= 1'b0;
                    else
                        angle8_shell2_en <= angle8_shell2_en;
                end
            else
                angle8_shell2_en <= 1'b0;
        end
    else
        angle8_shell2_en <= angle8_shell2_en; */

always@(posedge clk or negedge rst_n)
        if(rst_n == 1'b0 || third_custom_move == 1'b0)
            begin
                angle8_shell1_x0 <= 10'd900;
                angle8_shell1_y0 <= 10'd530;
            end
        else if(clk_150hz_flag == 1'b1)
            begin
                if(angle8_shell1_en == 1'b1)
                    begin
                        if(angle8_shell1_x0 == 100)
                            begin
                                angle8_shell1_x0 <= 10'd900;
                                angle8_shell1_y0 <= 10'd530;
                            end
                        else
                            begin
                                angle8_shell1_x0 <= angle8_shell1_x0 - 2'd2;
                                angle8_shell1_y0 <= angle8_shell1_y0 - 1'b1;
                            end
                    end
                else
                    begin
                        angle8_shell1_x0 <= 10'd900;
                        angle8_shell1_y0 <= 10'd530;
                    end
            end
        else
            begin
                angle8_shell1_x0 <= angle8_shell1_x0;
                angle8_shell1_y0 <= angle8_shell1_y0;
            end

/* always@(posedge clk or negedge rst_n)
        if(rst_n == 1'b0 || third_custom_move == 1'b0)
            begin
                angle8_shell2_x0 <= 10'd900;
                angle8_shell2_y0 <= 10'd530;
            end
        else if(clk_150hz_flag == 1'b1)
            begin
                if(angle8_shell2_en == 1'b1)
                    begin
                        if(angle8_shell2_x0 == 100)
                            begin
                                angle8_shell2_x0 <= 10'd900;
                                angle8_shell2_y0 <= 10'd530;
                            end
                        else
                            begin
                                angle8_shell2_x0 <= angle8_shell2_x0 - 2'd2;
                                angle8_shell2_y0 <= angle8_shell2_y0 - 1'b1;
                            end
                    end
                else
                    begin
                        angle8_shell2_x0 <= 10'd900;
                        angle8_shell2_y0 <= 10'd530;
                    end
            end
        else
            begin
                angle8_shell2_x0 <= angle8_shell2_x0;
                angle8_shell2_y0 <= angle8_shell2_y0;
            end */

wire    score_flag;
assign  score_flag  =   (angle1_shell1_x0 == 7'd100) | /* (angle1_shell2_x0 == 7'd100) |  */
                        (angle2_shell1_y0 == 10'd630) | /* (angle2_shell2_y0 == 10'd630) |  */
                        (angle3_shell1_y0 == 10'd630) | /* (angle3_shell2_y0 == 10'd630) |  */
                        (angle4_shell1_x0 == 10'd890) | /* (angle4_shell2_x0 == 10'd890) |  */
                        (angle5_shell1_x0 == 10'd890) | /* (angle5_shell2_x0 == 10'd890) |  */
                        (angle6_shell1_y0 == 7'd90)  | /* (angle6_shell2_y0 == 7'd90) |  */
                        (angle7_shell1_y0 == 7'd90)  | /* (angle7_shell2_y0 == 7'd90) |  */
                        (angle8_shell1_x0 == 7'd100)/*  | (angle8_shell2_x0 == 7'd100) */;


always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        custom3_score <= 8'd0;
    else if(clk_150hz_flag == 1'b1)
        begin
            if(state == 7'b0000001)
                custom3_score <= 8'd0;
            else if(score_flag == 1'b1)
                custom3_score <= custom3_score + 1'b1;
            else
                custom3_score <= custom3_score;
        end
    else
        custom3_score <= custom3_score;

endmodule
