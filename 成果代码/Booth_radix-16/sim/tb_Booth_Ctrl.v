`timescale 1ns/1ns

module  tb_Booth_Ctrl();

parameter   LENGTH  =   8  ;

reg      [LENGTH-1:0]    a_i    ;
reg      [4:0       ]    b_i    ;
wire     [LENGTH+3:0]    bo_o   ;

integer i;

initial begin
    for (i = 0; i < 200; i = i + 1) begin
        // 设置输入数据
        a_i = $urandom_range(0, 8'hff);
        b_i = $urandom_range(0, 5'h1f );
        // 等待一些时间
        #10;

        // 打印输出结果
        $display("Input a_i  = %b", a_i )  ;
        $display("Input b_i  = %b", b_i )  ;
        $display("Input bo_o = %b", bo_o)  ;
        // 验证输出结果
    end

    // 结束仿真
    //$finish;
end

Booth_Ctrl
#(
    .LENGTH(LENGTH)
)
Booth_Ctrl_inst
(
    .a_i (a_i ) ,     
    .b_i (b_i ) ,     
    .bo_o(bo_o)     
);

endmodule