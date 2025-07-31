//***********************// 三数全加器 //*******************************//

module full_adder
#(
    parameter   LENGTH  =   32       //位宽参数
)(
    input   wire    [LENGTH*2+3:0]  a   ,   //加数 a
    input   wire    [LENGTH*2+3:0]  b   ,   //加数 b
    input   wire    [LENGTH*2+3:0]  c   ,   //加数 c
    input   wire                    ci  ,   //进位输入
                                         
    output  wire    [LENGTH*2+3:0]  s   ,   //和
    output  wire                    co      //进位输出
);                                          

    assign {co, s}  = (a + c) + (b + ci)    ;   //行为级建模
    
endmodule

