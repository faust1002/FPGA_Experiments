`timescale 1us/1ns

module test(input wire clk,
            input wire rst,
            output wire [3:0] led);

    reg [15:0] counter;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter <= 16'b0;
        end
        else begin
            counter <= counter + 1'b1;
        end
    end

    assign led = counter[3:0];

endmodule
