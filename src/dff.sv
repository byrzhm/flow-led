module dff #(
    parameter INIT = 0
) (
    input clk,
    input rst,
    input d,
    output reg q
);

    initial q = INIT;

    always @(posedge clk) begin
        if (rst) 
            q <= INIT;
        else
            q <= d;
    end

endmodule

