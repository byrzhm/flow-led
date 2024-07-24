module clk_wiz (
    input clk_in,
    output reg clk_out = 0
);
    localparam MAX_COUNT = 20_000_000 - 1;
    localparam COUNT_WIDTH = $clog2(MAX_COUNT);

    reg [COUNT_WIDTH-1:0] count = 0;
    wire zero = ~(|count);

    always @(posedge clk_in) begin
        if (count < MAX_COUNT)
            count <= count + 1;
        else
            count <= 0;
    end

    always @(posedge clk_in) begin
        if (zero)
            clk_out = ~clk_out;
        else
            clk_out = clk_out;
    end

endmodule

