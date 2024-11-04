`timescale 1 ns/ 1 ps

module tb_float_mul_top();

// inputs
reg             sys_clk     ;
reg             sys_rst_n   ;
reg             round_cofig ;
reg     [31:0]  float_a     ;
reg     [31:0]  float_b     ;

// outputs                                              
wire    [31:0]  float_p     ;   
wire    [1:0 ]  overflow    ;

localparam CYCLE = 8;  //128Mhz 

float_mul_top   float_mul_top_inst
(
    .float_a      ( float_a     ),
    .float_b      ( float_b     ),
    .sys_clk      ( sys_clk     ),
    .sys_rst_n    ( sys_rst_n   ),
    .round_cofig  ( round_cofig ),
    .float_p      ( float_p     ),
    .overflow     ( overflow    )
);


//========================================================= generate sys_clk
initial     begin
  sys_clk = 1'b0;
  forever
    #(CYCLE/2) sys_clk = ~sys_clk;
end  

initial     begin                                                                       
sys_rst_n = 0;
#10
//---------------
sys_rst_n = 1;
round_cofig = 0; 
float_a = 32'b0_10000001_01100110011001100110011;  //5.6
float_b = 32'b0_10000000_00001100110011001100110;  //2.1
#10  
//---------------
sys_rst_n = 1;
round_cofig = 0; 
float_a = 32'b0_01111111_01101000111101011100001; //1.41
float_b = 32'b0_10000000_00001100110011001100110; //2.1
#10 
//---------------
sys_rst_n = 1;
round_cofig = 0;
float_a = 32'b0_10000000_10011001100110011001101; //3.2
float_b = 32'b1_01111111_11001100110011001100110; //-1.8
#10
//---------------
sys_rst_n = 1;
round_cofig = 0;
float_a = 32'b0_10000000_11110001111010111000011; //3.89
float_b = 32'b1_01111111_11001100110011001100110; //-1.8
#10   
//---------------
sys_rst_n = 1;
round_cofig = 0;  
#10;
// ---------------
sys_rst_n = 1;
round_cofig = 1;
#10                     
#400 $stop(1);

end  

endmodule  
