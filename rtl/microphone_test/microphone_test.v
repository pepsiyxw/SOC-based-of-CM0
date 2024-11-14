`timescale 1ns/1ns
module microphone_test();

reg     sys_clk;
reg     sys_rst_n;

always  #10 sys_clk =  ~sys_clk;

reg     microphone_left;
reg     microphone_right;

initial
    begin
        sys_clk     =   1'b1;
        sys_rst_n   <=  1'b0;
        microphone_left    <= 1'b1;
        microphone_right    <= 1'b1;
        #100
        sys_rst_n   <=  1'b1;
        #1000
        microphone_left <= 1'b0;
        #200
        microphone_left <= 1'b1;

        #100
        microphone_left <= 1'b0;
        #150
        microphone_left <= 1'b1;

        #150
        microphone_left <= 1'b0;
        #300
        microphone_left <= 1'b1;

        #150000
        microphone_right <= 1'b0;
        #200
        microphone_right <= 1'b1;

        #100
        microphone_right <= 1'b0;
        #200
        microphone_right <= 1'b1;

        #150
        microphone_right <= 1'b0;
        #200
        microphone_right <= 1'b1;


/*         microphone_left <= 1'b0;
        #200
        microphone_left <= 1'b1;

        #100
        microphone_left <= 1'b0;
        #150
        microphone_left <= 1'b1;

        #150
        microphone_left <= 1'b0;
        #300
        microphone_left <= 1'b1; */

/*         #100
        microphone_right <= 1'b0;
        #200
        microphone_right <= 1'b1;

        #150
        microphone_right <= 1'b0;
        #200
        microphone_right <= 1'b1;

        #100000
        microphone_right <= 1'b0;
        #200
        microphone_right <= 1'b1;

        #100
        microphone_right <= 1'b0;
        #200
        microphone_right <= 1'b1;

        #150
        microphone_right <= 1'b0;
        #200
        microphone_right <= 1'b1; */

/*         #150000
        microphone_left <= 1'b0;
        #200
        microphone_left <= 1'b1;

        #100
        microphone_left <= 1'b0;
        #150
        microphone_left <= 1'b1;

        #150
        microphone_left <= 1'b0;
        #300
        microphone_left <= 1'b1;

        #150000
        microphone_left <= 1'b0;
        #200
        microphone_left <= 1'b1;

        #100
        microphone_left <= 1'b0;
        #150
        microphone_left <= 1'b1;

        #150
        microphone_left <= 1'b0;
        #300
        microphone_left <= 1'b1; */

/*         #160000
        microphone_right <= 1'b0;
        #200
        microphone_right <= 1'b1;

        #100
        microphone_right <= 1'b0;
        #200
        microphone_right <= 1'b1;

        #150
        microphone_right <= 1'b0;
        #200
        microphone_right <= 1'b1;
        #150000
        microphone_right <= 1'b0;
        #200
        microphone_right <= 1'b1; */
    end

wire    [16:0]  leftfirst_state_cnt;
wire    [16:0]  rightfirst_state_cnt;

microphone_interface microphone_interface_inst
(
    .HCLK        (sys_clk),
    .HRESETn     (sys_rst_n),

    .microphone_left (microphone_left),
    .microphone_right(microphone_right),
    
    .leftfirst_state_cnt (leftfirst_state_cnt),
    .rightfirst_state_cnt(rightfirst_state_cnt)
);


endmodule
