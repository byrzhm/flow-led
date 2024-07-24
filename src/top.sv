module top #(
    parameter LED_NUM = 4
) (
    input CLK_50MHZ_FPGA,
    output [LED_NUM-1:0] LED
);

    wire clk;
    wire [LED_NUM-1:0] led;

    clk_wiz CLK_WIZ (.clk_in(CLK_50MHZ_FPGA), .clk_out(clk));

    flow_led #(LED_NUM) FLOW_LED (.clk(clk), .led(led));

    assign LED = ~led;

endmodule
