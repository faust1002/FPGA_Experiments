`timescale 1us/1ps

module signed_multiplier #(parameter int X_LENGTH = 16,
                           parameter int Y_LENGTH = 16,
                           parameter int Z_LENGTH = X_LENGTH + Y_LENGTH)
                          (input logic signed [X_LENGTH-1:0]  x,
                           input logic signed [Y_LENGTH-1:0]  y,
                           output logic signed [Z_LENGTH-1:0] z);

    always_comb begin
        z = x * y;
    end

endmodule
