create_clock -name sys_clk -period 20 -waveform {0 10} [get_ports { sys_clk }]
create_clock -name clk -period 25 -waveform {0 12.5} [get_nets { clk }]
derive_pll_clocks -gen_basic_clock
