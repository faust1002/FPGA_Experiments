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
    for (idx = 0; idx < n-1; idx = idx + 1) begin
        if (idx == 0)
            base_partial_product_interpolation base_partial_product_interpolation_i(m, q[1:0], link[idx], sum[idx + 1]);
        else
            partial_product_interpolation partial_product_interpolation_i(link[idx-1], m, q[idx + 1], link[idx], sum[idx + 1]);
    end
    endgenerate

    assign sum[2 * n-1:n] = link[n-2];

endmodule

module partial_product_interpolation #(parameter n = 16)
                                      (input wire [n-1:0] partial_product_interpolation_bit,
                                       input wire [n-1:0] m,
                                       input wire q,
                                       output wire [n-1:0] out,
                                       output wire px);

    wire [n-1:0] link;

    genvar idx;
    generate
        for (idx = 0; idx < n; idx = idx + 1) begin
            if (idx == 0)
                half_adder half_adder_i((q & m[idx]), partial_product_interpolation_bit[idx], px, link[idx]);
            else
                full_adder full_adder_i((q & m[idx]), partial_product_interpolation_bit[idx], link[idx-1], out[idx-1], link[idx]);
        end
    endgenerate

    assign out[n-1] = link[n-1];

endmodule

module base_partial_product_interpolation #(parameter n = 16)
                                           (input wire [n-1:0] m,
                                            input wire [1:0] q,
                                            output wire [n-1:0] out,
                                            output wire px);

    wire [n-1:0] link;

    genvar idx;
    generate
        for (idx = 0; idx < n; idx = idx + 1) begin
            if (idx == 0)
                half_adder half_adder_i((q[1] & m[idx]), (q[0] & m[idx + 1]), px, link[idx]);
            else if (idx == n-1)
                half_adder half_adder_i((q[1] & m[idx]), link[idx-1], out[idx-1], out[idx]);
            else
                full_adder full_adder_i((q[1] & m[idx]), (q[0] & m[idx + 1]), link[idx-1], out[idx-1], link[idx]);
        end
    endgenerate

endmodule

module full_adder(input wire a,
                  input wire b,
                  input wire carry_in,
                  output wire sum,
                  output wire carry_out);

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
