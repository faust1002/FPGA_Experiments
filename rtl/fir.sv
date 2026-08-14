`timescale 1us/1ps

module fir #(parameter int DATA_WIDTH   = 16,
             parameter int COEFF_WIDTH  = 16,
             parameter int NUM_TAPS     = 9,
             parameter int OUTPUT_WIDTH = DATA_WIDTH + COEFF_WIDTH + $clog2(NUM_TAPS))
            (input  logic                           clk,
             input  logic                           rst_n,
             input  logic signed [DATA_WIDTH-1:0]   x,
             output logic signed [OUTPUT_WIDTH-1:0] y);

    // Dummy FIR coefficients, will be replaced with readmemf later on
    localparam signed [COEFF_WIDTH-1:0] COEFFS [NUM_TAPS] = '{
        16'sh0100,
        16'sh0200,
        16'sh0400,
        16'sh0800,
        16'sh1000,
        16'sh0800,
        16'sh0400,
        16'sh0200,
        16'sh0100
    };

    logic signed [DATA_WIDTH-1:0]             delay_line [NUM_TAPS];
    logic signed [OUTPUT_WIDTH-1:0]           acc;
    logic signed [DATA_WIDTH+COEFF_WIDTH-1:0] products   [NUM_TAPS];

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            for (int i = 0; i < NUM_TAPS; i++)
                delay_line[i] <= '0;
        end else begin
            delay_line[0] <= x;
            for (int i = 1; i < NUM_TAPS; i++)
                delay_line[i] <= delay_line[i-1];
        end
    end

    always_comb begin
        acc = '0;
        for (int i = 0; i < NUM_TAPS; i++) begin
            products[i] = delay_line[i] * COEFFS[i];
            acc += OUTPUT_WIDTH'(products[i]);
        end
    end

    always_ff @(posedge clk) begin
        if (!rst_n) y <= '0;
        else        y <= acc;
    end

endmodule
