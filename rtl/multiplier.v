`timescale 1us/1ps

// This multiplier implements single carry architecture

module multiplier #(parameter n = 16)
                   (input wire [n-1:0] m,
                   input wire [n-1:0] q,
                   output wire [2 * n-1:0] sum);

    assign sum[0] = m[0] & q[0];

    wire [n-1:0] link [n-1:0];

    genvar idx;
    generate
    for (idx = 0; idx < n-1; idx = idx + 1) begin : partial_product_stage
        if (idx == 0) begin : gen_base
            base_partial_product_interpolation base_partial_product_interpolation_i(m, q[1:0], link[idx], sum[idx + 1]);
        end
        else begin : regular_gen
            partial_product_interpolation partial_product_interpolation_i(link[idx-1], m, q[idx + 1], link[idx], sum[idx + 1]);
        end
    end
    endgenerate

    assign sum[2 * n-1:n] = link[n-2];

endmodule

/* verilator lint_off DECLFILENAME */
module partial_product_interpolation #(parameter n = 16)
                                      (input wire [n-1:0] partial_product_interpolation_bit,
                                       input wire [n-1:0] m,
                                       input wire q,
                                       output wire [n-1:0] out,
                                       output wire px);

    wire [n-1:0] link;

    genvar idx;
    generate
        for (idx = 0; idx < n; idx = idx + 1) begin : adder_chain
            if (idx == 0) begin : gen_half
                half_adder half_adder_i((q & m[idx]), partial_product_interpolation_bit[idx], px, link[idx]);
            end
            else begin : gen_full
                full_adder full_adder_i((q & m[idx]), partial_product_interpolation_bit[idx], link[idx-1], out[idx-1], link[idx]);
            end
        end
    endgenerate

    assign out[n-1] = link[n-1];

endmodule

module base_partial_product_interpolation #(parameter n = 16)
                                           (input wire [n-1:0] m,
                                            input wire [1:0] q,
                                            output wire [n-1:0] out,
                                            output wire px);

    /* verilator lint_off UNOPTFLAT */
    wire [n-2:0] link;
    /* verilator lint_on UNOPTFLAT */

    genvar idx;
    generate
        for (idx = 0; idx < n; idx = idx + 1) begin : base_adder_chain
            if (idx == 0) begin : gen_first
                half_adder half_adder_i((q[1] & m[idx]), (q[0] & m[idx + 1]), px, link[idx]);
            end
            else if (idx == n-1) begin : gen_last
                half_adder half_adder_i((q[1] & m[idx]), link[idx-1], out[idx-1], out[idx]);
            end
            else begin : gen_middle
                full_adder full_adder_i((q[1] & m[idx]), (q[0] & m[idx + 1]), link[idx-1], out[idx-1], link[idx]);
            end
        end
    endgenerate

endmodule

module full_adder(input wire a,
                  input wire b,
                  input wire carry_in,
                  /* verilator lint_off UNOPTFLAT */
                  output wire sum,
                  output wire carry_out
                  /* verilator lint_off UNOPTFLAT */);

    assign sum = a ^ b ^ carry_in;
    assign carry_out = (a & b) | (a & carry_in) | (b & carry_in);

endmodule

module half_adder(input wire a,
                  input wire b,
                  output wire sum,
                  output wire carry_out);

    assign sum = a ^ b;
    assign carry_out = a & b;

endmodule
/* verilator lint_on DECLFILENAME */
