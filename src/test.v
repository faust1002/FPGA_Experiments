module test(input wire clk,
            input wire rst,
            output wire [3:0] led);

    reg [31:0] counter;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter <= 32'b0;
        end
        else begin
            counter <= counter + 1'b1;
        end
    end

    assign led = counter[31:27];

endmodule
