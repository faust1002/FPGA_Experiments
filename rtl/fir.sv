`timescale 1us/1ps

module fir #(parameter int DATA_WIDTH   = 18,
             parameter int COEFF_WIDTH  = 18,
             parameter int NUM_TAPS     = 43,
             parameter string COEFFS_FILE = "./fir_coeffs.txt")
            (input  logic                           clk,
             input  logic                           rst_n,
             input  logic signed [DATA_WIDTH-1:0]   x,
             output logic signed [DATA_WIDTH-1:0]   y);

    localparam int OUTPUT_WIDTH = DATA_WIDTH + COEFF_WIDTH;

    logic signed [COEFF_WIDTH-1:0] COEFFS [NUM_TAPS];
    initial begin
        $readmemh(COEFFS_FILE, COEFFS);
    end

    logic signed [DATA_WIDTH-1:0]             delay_line [NUM_TAPS];
    logic signed [OUTPUT_WIDTH-1:0]           acc;
    logic signed [OUTPUT_WIDTH-1:0] products  [NUM_TAPS];

    generate
        for (genvar i = 0; i < NUM_TAPS; i++) begin : multipliers
            signed_multiplier #(.X_LENGTH(DATA_WIDTH),
                                .Y_LENGTH(COEFF_WIDTH))
            signed_multiplier_i(.x(delay_line[i]),
                                .y(COEFFS[i]),
                                .z(products[i]));
        end
    endgenerate


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
            acc += products[i];
        end
    end

    always_ff @(posedge clk) begin
        if (!rst_n) y <= '0;
        else        y <= acc[OUTPUT_WIDTH - 1 : DATA_WIDTH];
    end

endmodule
