## Clock signal 50MHZ
set_property -dict { PACKAGE_PIN U18    IOSTANDARD LVCMOS33 } [get_ports { CLK_50MHZ_FPGA }]; 
create_clock -period 20.000 -waveform {0.000 10.000} [get_ports CLK_50MHZ_FPGA]

## LEDs
set_property -dict { PACKAGE_PIN M14    IOSTANDARD LVCMOS33 } [get_ports { LED[3] }]; 
set_property -dict { PACKAGE_PIN M15    IOSTANDARD LVCMOS33 } [get_ports { LED[2] }]; 
set_property -dict { PACKAGE_PIN K16    IOSTANDARD LVCMOS33 } [get_ports { LED[1] }]; 
set_property -dict { PACKAGE_PIN J16    IOSTANDARD LVCMOS33 } [get_ports { LED[0] }]; 

