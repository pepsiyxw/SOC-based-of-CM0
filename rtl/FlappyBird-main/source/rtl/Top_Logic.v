`timescale 1ns/1ns
//用状态机来显示不同的状态
module Top_logic
#(
    //格雷码状态编码
    parameter start_scene       = 7'b0000001,
    parameter custom1_scene     = 7'b0000010,
    parameter custom2_scene     = 7'b0000100,
    parameter custom3_scene     = 7'b0001000,
    parameter pause_scene       = 7'b0010000,
    parameter gameover_scene    = 7'b0100000,
    parameter method_scene      = 7'b1000000,
    parameter win_scene         = 7'b1111111
)
(
    input   wire            clk,
    input   wire            rst,
    input   wire            start_button,           //开始按键
    input   wire            pause_button,           //暂停按键
    input   wire            continue_button,        //继续按键
    input   wire            restart_button,         //重新开始按键
    input   wire            method_button,          //游戏玩法按键
    input   wire            cancle_button,

    input   wire            first_custom_button,
    input   wire            second_custom_button,
    input   wire            third_custom_button,
    input   wire            exit_game_button,

    input   wire            allbird_dead,

    input   wire            fourth_dead,

    input   wire            win_signal,
    input   wire            third_signal,
    input   wire            second_signal,

    output  wire            go_first_custom_flag,
    output  wire            go_second_custom_flag,
    
    output  reg     [6:0]   state_number
);

reg [6:0]   state = start_scene,next_state;

always @(posedge clk or negedge rst) begin
    if(!rst)
        state <= start_scene;
    else
        state <= next_state;
end

//开始按钮时钟对齐
reg         start_button_reg;
always @(posedge clk or negedge rst)
    if(!rst)
        start_button_reg <= 1'b0;
    else
        start_button_reg <= start_button;

//重新开始按钮时钟对齐
reg         restart_button_reg;
always @(posedge clk or negedge rst)
    if(!rst)
        restart_button_reg <= 1'b0;
    else
        restart_button_reg <= restart_button;

//暂停按钮时钟对齐
reg         pause_button_reg;
always @(posedge clk or negedge rst)
    if(!rst)
        pause_button_reg <= 1'b0;
    else
        pause_button_reg <= pause_button;

//继续按键时钟对齐
reg         continue_button_reg;
always @(posedge clk or negedge rst)
    if(!rst)
        continue_button_reg <= 1'b0;
    else
        continue_button_reg <= continue_button;

//继续按键时钟对齐
reg         method_button_reg;
always @(posedge clk or negedge rst)
    if(!rst)
        method_button_reg <= 1'b0;
    else
        method_button_reg <= method_button;

//取消按键时钟对齐
reg         cancle_button_reg;
always @(posedge clk or negedge rst)
    if(!rst)
        cancle_button_reg <= 1'b0;
    else
        cancle_button_reg <= cancle_button;

reg [1:0]   game_custom;

//直接进入第一关第二关第三关的按钮信号时钟对齐
reg         first_custom_button_reg;
always @(posedge clk or negedge rst)
    if(!rst)
        first_custom_button_reg <= 1'b0;
    else
        first_custom_button_reg <= first_custom_button;

reg         second_custom_button_reg;
always @(posedge clk or negedge rst)
    if(!rst)
        second_custom_button_reg <= 1'b0;
    else
        second_custom_button_reg <= second_custom_button;

reg         third_custom_button_reg;
always @(posedge clk or negedge rst)
    if(!rst)
        third_custom_button_reg <= 1'b0;
    else
        third_custom_button_reg <= third_custom_button;

//直接退出游戏按钮时钟信号对齐
reg         exit_game_button_reg;
always @(posedge clk or negedge rst)
    if(!rst)
        exit_game_button_reg <= 1'b0;
    else
        exit_game_button_reg <= exit_game_button;


//第一关第二关摄像头刷新信号，防止演示出现意外
reg         first_custom_button_reg_reg;
always @(posedge clk or negedge rst)
    if(!rst)
        first_custom_button_reg_reg <= 1'b0;
    else
        first_custom_button_reg_reg <= first_custom_button_reg;

assign  go_first_custom_flag = first_custom_button_reg & ~first_custom_button_reg_reg;

reg         second_custom_button_reg_reg;
always @(posedge clk or negedge rst)
    if(!rst)
        second_custom_button_reg_reg <= 1'b0;
    else
        second_custom_button_reg_reg <= second_custom_button_reg;

assign  go_second_custom_flag = second_custom_button_reg & ~second_custom_button_reg_reg;

//按钮控制状态机的切换,按钮至少持续两个时钟周期
always @(posedge clk or negedge rst)
    if(!rst)
        next_state <= start_scene;
    else
        case(state)
            start_scene:
                begin
                    if(method_button)                   next_state <= method_scene;
                    else if(start_button_reg)           next_state <= custom1_scene;
                    else if(first_custom_button_reg)    next_state <= custom1_scene;
                    else if(second_custom_button_reg)   next_state <= custom2_scene;
                    else if(third_custom_button_reg)    next_state <= custom3_scene;
                    else                                next_state <= start_scene;
                end
            method_scene:
                begin
                    if(cancle_button_reg)           next_state <= pause_scene;
                    else if(restart_button_reg)     next_state <= start_scene;
                    else if(exit_game_button_reg)   next_state <= start_scene;
                    else                            next_state <= method_scene;
                end
            custom1_scene:
                begin
                    if(allbird_dead)                next_state <= gameover_scene;
                    else if(restart_button_reg)     next_state <= start_scene;
                    else if(exit_game_button_reg)   next_state <= start_scene;
                    else if(pause_button_reg)
                        begin
                            next_state <= pause_scene;
                            game_custom <= 2'd1;
                        end
                    else if(second_signal)
                        next_state <= custom2_scene;
                    else                            next_state <= custom1_scene;
                end
            custom2_scene:
                begin
                    if(allbird_dead)                next_state <= gameover_scene;
                    else if(third_signal)           next_state <= custom3_scene;
                    else if(restart_button_reg)     next_state <= start_scene;
                    else if(exit_game_button_reg)   next_state <= start_scene;
                    else if(pause_button_reg)
                        begin
                            next_state <= pause_scene;
                            game_custom <= 2'd2;
                        end
                    else                            next_state <= custom2_scene;
                end
            custom3_scene:
                begin
                    if(allbird_dead)                next_state <= gameover_scene;
                    else if(win_signal)             next_state <= win_scene;
                    else if(restart_button_reg)     next_state <= start_scene;
                    else if(exit_game_button_reg)   next_state <= start_scene;
                    else if(pause_button_reg)
                        begin
                            next_state <= pause_scene;
                            game_custom <= 2'd3;
                        end
                    else                            next_state <= custom3_scene;
                end
            win_scene:
                begin
                    if(restart_button_reg)          next_state <= start_scene;
                    else if(exit_game_button_reg)   next_state <= start_scene;
                    else                            next_state <= win_scene;
                end
            pause_scene:
                begin
                    if(continue_button_reg)         next_state <= (game_custom == 2'd3) ? custom3_scene : (game_custom == 2'd2) ? custom2_scene : (game_custom == 2'd1) ? custom1_scene : start_scene;
                    else if(method_button_reg)      next_state <= method_scene;
                    else if(restart_button_reg)     next_state <= start_scene;
                    else if(exit_game_button_reg)   next_state <= start_scene;
                    else                            next_state <= pause_scene;
                end
            gameover_scene:
                begin
                    if(restart_button_reg)          next_state <= start_scene;
                    else if(exit_game_button_reg)   next_state <= start_scene;
                    else                            next_state <= gameover_scene;
                end
            default: next_state <= start_scene;
        endcase

always@(*)begin
    case(state)
        start_scene:    state_number <= 7'b0000001;
        custom1_scene:  state_number <= 7'b0000010;
        custom2_scene:  state_number <= 7'b0000100;
        custom3_scene:  state_number <= 7'b0001000;
        pause_scene:    state_number <= 7'b0010000;
        gameover_scene: state_number <= 7'b0100000;
        method_scene:   state_number <= 7'b1000000;
        win_scene:      state_number <= 7'b1111111;
        default:        state_number <= 7'b0000001;
    endcase
end

endmodule
