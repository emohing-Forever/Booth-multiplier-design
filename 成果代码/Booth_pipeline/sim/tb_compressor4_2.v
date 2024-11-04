`timescale 1ns/1ns

module tb_compressor4_2();

parameter   LENGTH  =   32  ;

reg     [LENGTH*2-1:0]  I0  ;
reg     [LENGTH*2-1:0]  I1  ;
reg     [LENGTH*2-1:0]  I2  ;
reg     [LENGTH*2-1:0]  I3  ;
reg                     Ci  ;

wire    [LENGTH*2-1:0]  C   ;
wire    [LENGTH*2-1:0]  D   ;
wire                    Co  ;

integer i;
integer pass_count = 0;
integer fail_count = 0;

initial begin
    for (i = 0; i < 200; i = i + 1) begin
        // 设置输入数据
        I0 = {$random}                ;
        I1 = {$random}                ;
        I2 = {$random}                ;
        I3 = {$random}                ;
        Ci = $urandom_range(0, 1'b1 ) ;
        // 等待一些时间
        #10;

        // 打印输出结果
        $display("Input I0 = %b", I0);
        $display("Input I1 = %b", I1);
        $display("Input I2 = %b", I2);
        $display("Input I3 = %b", I3);
        $display("Input Ci = %b", Ci);
        $display("Output P = %b", (C*2 + D + Co*2) );
        $display("Output Pr = %b", (I0 + I1 + I2 + I3 + Ci) );
        $display("Output Co= %b", Co);

        // 验证输出结果
        if ((C*2 + D + Co*2) == (I0 + I1 + I2 + I3 + Ci)) begin
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



compressor4_2
#(
    .LENGTH(LENGTH)
)
compressor4_2_inst
(
    .I0(I0) ,
    .I1(I1) ,
    .I2(I2) ,
    .I3(I3) ,
    .Ci(Ci) ,
    .C (C) ,
    .D (D) ,
    .Co(Co)
);


endmodule