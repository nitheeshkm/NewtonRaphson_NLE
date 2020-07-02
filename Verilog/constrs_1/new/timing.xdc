set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 22.000 -name clk -waveform {0.000 11.000} -add [get_ports clk]