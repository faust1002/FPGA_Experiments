module test_tb;

    reg clk, rst;
    wire [3:0] led;

    test uut(.clk(clk),
             .rst(rst),
             .led(led));

    initial begin
        $dumpfile("test_tb.vcd");
        $dumpvars(0, uut);
    end

    initial begin
        clk <= 1'b0;
        rst <= 1'b1;
        #10
        rst <= 1'b0;
        #2000 $finish;
    end

    always #10 clk <= ~clk;

endmodule
