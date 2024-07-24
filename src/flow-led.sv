module flow_led #(
    parameter LED_NUM = 4
) (
    input clk,
    output [LED_NUM-1:0] led
);

    wire [LED_NUM-1:0] q;
    dff #(.INIT(1'b1)) DFF0 (.clk(clk), .rst(1'b0), .d(q[LED_NUM-1]), .q(q[0]));

    genvar i;
    generate
        for (i = 1; i < LED_NUM; i = i + 1) begin
            dff DFF_i (.clk(clk), .rst(1'b0), .d(q[i-1]), .q(q[i]));
        end
    endgenerate

    assign led = q;

endmodule

