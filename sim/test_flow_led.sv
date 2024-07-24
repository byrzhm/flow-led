module test_flow_led();

parameter LED_NUM = 4;

reg clk;
wire [LED_NUM-1:0] led;

flow_led #(LED_NUM) dut (.clk(clk), .led(led));

integer num_mismatch = 0;

initial begin
    clk = 0;
    assert (led === 4'b0001) else begin
        $error("initial led is not 4'b0001, actual is %4b", led);
        num_mismatch = num_mismatch + 1;
    end

    @(posedge clk); #1;
    assert (led === 4'b0010) else begin
        $error("expect 4'b0010, actual is %4b", led);
        num_mismatch = num_mismatch + 1;
    end

    @(posedge clk); #1;
    assert (led === 4'b0100) else begin
        $error("expect 4'b0100, actual is %4b", led);
        num_mismatch = num_mismatch + 1;
    end

    @(posedge clk); #1;
    assert (led === 4'b1000) else begin
        $error("expect 4'b1000, actual is %4b", led);
        num_mismatch = num_mismatch + 1;
    end

    @(posedge clk); #1;
    assert (led === 4'b0001) else begin
        $error("expect 4'b0001, actual is %4b", led);
        num_mismatch = num_mismatch + 1;
    end

    if (num_mismatch === 0)
        $display("All tests passed");
    $finish;
end

always #5 clk = ~clk;

endmodule

