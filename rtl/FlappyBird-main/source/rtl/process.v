`timescale 1ns/ 1ps
module process #
(
    //分割屏幕的中间值y_middle
    parameter y_middle = 104,
    parameter total_length = 256,
    parameter total_width = 208,
    parameter threshold = 10
)
(
    input clk,
    input rst,

    input   wire    [10:0]  x_pos,
    input   wire    [10:0]  y_pos,
    input   wire    [15:0]  data_in,

    output  reg             image_bird2_up
);

//计数器
reg [14:0]  counter_up;
reg [14:0]  counter_down;

//刷新脉冲信号
reg         fresh_flag;

//分别计算图像上下部分黑点数量
always @(posedge clk or negedge rst)
    if(!rst)
        begin
            counter_up <= 1'b0;
            counter_down <= 1'b0;
        end
    else if(x_pos == 3'd5 && y_pos == 3'd5)
            begin
                counter_up <= 1'b0;
                counter_down <= 1'b0;
            end
        //上半部分的黑点
        else if((y_pos < y_middle) && (y_pos > threshold )&&(x_pos > threshold)&&( x_pos < total_length-threshold))
            begin
                if(data_in[15] == 0)
                    counter_up <= counter_up + 1'b1;
                else
                    counter_up <= counter_up;
            end
        //下半部分的黑点
        else if((y_pos > y_middle) && (y_pos < total_width-threshold)&&(x_pos > threshold)&&( x_pos < total_length-threshold))
            begin
                if(data_in[15] == 0)
                    counter_down <= counter_down + 1'b1;
                else
                    counter_down <= counter_down;
            end

//刷新计算标志位
always @(posedge clk or negedge rst)
    if(!rst)
        fresh_flag <= 1'b0;
    else if(x_pos == 9'd300 && y_pos == 9'd300)
        fresh_flag <= 1'b1;
    else
        fresh_flag <= 1'b0;

//比较上下黑点数量大小来输出小鸟飞行状态（image_bird2_up == 0是向上飞）
always @(posedge clk or negedge rst) 
    if(!rst)
        image_bird2_up <= 1'b0;
    else if((counter_up < counter_down) && fresh_flag > 1'b0)
        image_bird2_up <= 1'b0;
    else if((counter_up >= counter_down) && fresh_flag > 1'b0)
        image_bird2_up <= 1'b1;

endmodule//process