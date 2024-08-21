`timescale 1us/1ns

module test(input wire clk,
            input wire rst,
            output wire [3:0] led);

    reg [15:0] primary_counter;
    reg [15:0] secondary_counter;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            primary_counter <= 16'd37;
            secondary_counter <= 16'd42;
        end
        else begin
            primary_counter <= primary_counter + 1'b1;
            secondary_counter <= secondary_counter + 1'b1;
        end
    end

    wire [32:0] final_result = primary_counter * secondary_counter + 1'b1;
    assign led = final_result[3:0];

endmodule
