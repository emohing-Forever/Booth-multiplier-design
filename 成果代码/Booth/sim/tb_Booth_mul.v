`timescale  1ns/1ns

// `define UNSINGED_BOOTH

module  tb_Booth_mul();

`ifdef  UNSINGED_BOOTH
reg    [31:0]  A    ;
reg    [31:0]  B    ;

wire   [63:0]  P1   ;
wire   [63:0]  P    ;

`else
reg    signed [31:0]  A    ;
reg    signed [31:0]  B    ;

wire   signed [63:0]  P1   ;
wire   signed [63:0]  P    ;

`endif
integer i;
integer pass_count = 0;
integer fail_count = 0;

assign  P1 = A * B;

initial begin
    for (i = 0; i < 2000; i = i + 1) begin
        // 设置输入数据
        `ifdef  UNSINGED_BOOTH
        A = {$random} ;
        B = {$random} ;
        
        `else
        A =  $random ;
        B =  $random ;
        `endif
        // 等待一些时间
        #100;

        // 打印输出结果
        $display("Input A = %b", A);
        $display("Input B = %b",B);
        $display("Output P = %b", P);
        $display("Output P1 = %b", P1);

        // 验证输出结果
        if (P == A * B) begin
            $display("Test Passed: Output matches expected result");
            pass_count = pass_count + 1;
        end
        else begin
            $display("Test Failed: Output does not match expected result");
            fail_count = fail_count + 1;
        end
    end

    // 打印测试通过和测试失败的总数
    $display("Total Tests: %d", i);
    $display("Passed: %d", pass_count);
    $display("Failed: %d", fail_count);

    if (fail_count == 0) begin
         $display("//==================Random test all Pass!!==================//");
    end

    // 结束仿真
    //$finish;
end

Booth_mul  Booth_mul_inst
(
    .A(A    ),
    .B(B    ),
    .P(P    )
);

endmodule
