//***********************// 4-2压缩器 //*******************************//

module  compressor4_2
#(
    parameter   LENGTH  =   32      //位宽参数
)(
    input   wire    [LENGTH*2-1:0]  I0  ,   //加数 0
    input   wire    [LENGTH*2-1:0]  I1  ,   //加数 1
    input   wire    [LENGTH*2-1:0]  I2  ,   //加数 2
    input   wire    [LENGTH*2-1:0]  I3  ,   //加数 3
    input   wire                    Ci  ,   //进位输入

    output  wire    [LENGTH*2-1:0]  C   ,   //高位数
    output  wire    [LENGTH*2-1:0]  D   ,   //低位数
    output  wire                    Co      //进位输出
);

    //***********************// wire-define //*******************************//
    wire [LENGTH*2-1:0] T   ;
    wire [LENGTH*2-1:0] T_l ;
    wire [LENGTH*2-1:0] C_o ;

    //***********************// main-code //*******************************//
    assign T   = (I0 ^ I1) ^ (I2 ^ I3)                       ;          
    assign T_l = (I0 & I1) | (I2 & I3)                       ;
    assign C_o = (I0 | I1) & (I2 | I3)                       ;

    assign C   = (T & {C_o[LENGTH*2-2:0], Ci}) | ~(T | ~T_l) ;
    assign D   = T ^ {C_o[LENGTH*2-2:0], Ci}                 ;
    assign Co  = C_o[LENGTH*2-1]                             ;


endmodule