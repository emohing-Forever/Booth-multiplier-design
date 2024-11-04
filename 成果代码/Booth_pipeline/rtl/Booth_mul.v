//参考文章：   https://zhuanlan.zhihu.com/p/127164011?utm_source=wechat_timeline

//***********************// Booth-Top //*******************************//

`include "UnsignedChoose.v"
module  Booth_mul
(
    input   wire              sys_clk   ,
    input   wire              sys_rst_n ,
    input   wire   [31:0]     A         ,    //乘数 A
    input   wire   [31:0]     B         ,    //被乘数 B
    output  wire   [63:0]     P              //结果 P
);

//***********************// parameter-define //*******************************//
parameter   LENGTH  =   32  ;
integer i;

//***********************// wire-define //*******************************//

wire    [LENGTH+1:0   ]      boo_o     [0:LENGTH/2   ] ;        //booth转码输出值
wire    [LENGTH*2-1:0 ]      pp        [0:LENGTH/2-1 ] ;        //部分积
wire    [LENGTH*2+1:0 ]      pp_16th                   ;        //扩展位产生的第17个部分积分，全加器输入值

wire    [3:0          ]      pp_stg1_co                ;        //第一级压缩器进位输出进位
wire    [3:0          ]      co                        ;        //二三级压缩器以及全加器输出进位

wire    [LENGTH*2-1:0 ]      pp_stg2_m [0:3          ] ;        //第一级压缩器输出高位值，第二级压缩器输入值
wire    [LENGTH*2-1:0 ]      pp_stg2_l [0:3          ] ;        //第一级压缩器输出低位值，第二级压缩器输入值

wire    [LENGTH*2-1:0 ]      pp_stg3_m [0:1          ] ;        //第二级压缩器输出高位值，第三级压缩器输入值
wire    [LENGTH*2-1:0 ]      pp_stg3_l [0:1          ] ;        //第二级压缩器输出低位值，第三级压缩器输入值

wire    [LENGTH*2-1:0 ]      pp_stg_m_end              ;        //第三级压缩器输出高位值，全加器输入值
wire    [LENGTH*2-1:0 ]      pp_stg_l_end              ;        //第三级压缩器输出低位值，全加器输入值

wire    [LENGTH+2:0   ]      B_tr                      ;        //输入数 B 扩展

wire    [LENGTH*2+1:0 ]      P_out                     ;        //全加器输出

//first-pipeline
reg    [LENGTH*2-1:0 ]      pp_reg    [0:LENGTH/2-1 ]  ;        
reg    [LENGTH*2+1:0 ]      pp_16th_reg                ;  

//second-pipeline
reg    [LENGTH*2-1:0 ]      pp_stg2_m_reg [0:3       ] ;        
reg    [LENGTH*2-1:0 ]      pp_stg2_l_reg [0:3       ] ;        

//third-pipeline
reg    [LENGTH*2-1:0 ]      pp_stg3_m_reg [0:1       ] ;        
reg    [LENGTH*2-1:0 ]      pp_stg3_l_reg [0:1       ] ;        

//forth-pipeline      
reg    [LENGTH*2-1:0 ]      pp_stg_m_end_reg           ;        
reg    [LENGTH*2-1:0 ]      pp_stg_l_end_reg           ;        

//***********************// main-code //*******************************//

//扩展最低位置B[-1],为0

`ifdef  UNSINGED_BOOTH                                  //是否选择为无符号

assign B_tr = {2'b0, B, 1'b0};                          //最高位扩展1位0,代表无符号,再扩展一位0组成三位一组数

`else 

assign B_tr = {{2{B[LENGTH-1]}}, B, 1'b0};              //扩展两位符号位

`endif

//-----------------------// first-logic-output //-----------------------//

//实例化 Booth_Ctrl 模块，实现转码                                
genvar k;                                               
generate    
    for(k=0; k<LENGTH/2+1; k=k+1)   begin:  Booth_Ctrl_i
        Booth_Ctrl
        #(
            .LENGTH(LENGTH)
        )
        Booth_Ctrl
        (
            .a_i       (A                                     )     ,
            .b_i       ({B_tr[k*2+2], B_tr[k*2+1], B_tr[k*2]} )     ,
            .bo_o      (boo_o[k]                              )
        );
        if(k != 16)
            assign pp[k]   = {{(LENGTH-2-k*2){boo_o[k][LENGTH+1]}}, boo_o[k], {(k*2){1'b0}} } ;  //部分积
        else
            assign pp_16th = {boo_o[k], {(k*2){1'b0}}                                       } ;  //扩展位所产生的第 17 个部分积
    end
endgenerate

//-----------------------// first-pipeline //-----------------------//
always @(posedge sys_clk or negedge sys_rst_n)  begin
    if(sys_rst_n == 1'b0)   begin
        pp_16th_reg <= 'b0;
        for(i=0; i<LENGTH/2; i=i+1)
            pp_reg[i] <= 'b0;
    end
    else    begin
        pp_16th_reg <=  pp_16th;
        for(i=0; i<LENGTH/2; i=i+1)
            pp_reg[i] <= pp[i];
    end
end 

//-----------------------// second-logic-output //-----------------------//

//实例化 4-2 压缩器，实现部分积求和
genvar j;
generate
    for(j=0; j<LENGTH/2/4; j=j+1)   begin:  compressor4_2_level1        //第一级压缩器
        compressor4_2        
        #(
            .LENGTH(LENGTH)
        )
        compressor4_2_level1_inst
        (
            .I0(pp_reg[j*4+0]     )   ,
            .I1(pp_reg[j*4+1]     )   ,
            .I2(pp_reg[j*4+2]     )   ,
            .I3(pp_reg[j*4+3]     )   ,
            .Ci(1'b0          )   ,
            .Co(pp_stg1_co[j] )   ,
            .C (pp_stg2_m[j]  )   ,
            .D (pp_stg2_l[j]  )     
        );
    end
endgenerate

//-----------------------// second-pipeline //-----------------------//
always @(posedge sys_clk or negedge sys_rst_n)  begin
    if(sys_rst_n == 1'b0)   
        for(i=0; i<LENGTH/2/4; i=i+1)
            pp_stg2_m_reg[i] <= 'b0;
    else  
        for(i=0; i<LENGTH/2/4; i=i+1)
            pp_stg2_m_reg[i] <= pp_stg2_m[i];
end 

always @(posedge sys_clk or negedge sys_rst_n)  begin
    if(sys_rst_n == 1'b0)   
        for(i=0; i<LENGTH/2/4; i=i+1)
            pp_stg2_l_reg[i] <= 'b0;
    else  
        for(i=0; i<LENGTH/2/4; i=i+1)
            pp_stg2_l_reg[i] <= pp_stg2_l[i];
end 

//-----------------------// third-logic-output //-----------------------//

compressor4_2        
#(
    .LENGTH(LENGTH)
)
compressor4_2_level2_inst_0                                             //第二级压缩器 0
(
    .I0(pp_stg2_l_reg[0]                        )   , 
    .I1({pp_stg2_m_reg[0][LENGTH*2-2:0 ], 1'b0} )   ,                       //压缩后得到两个数，高位数需要左移一位。
    .I2(pp_stg2_l_reg[1]                        )   ,                       //详请参见上方链接文章    
    .I3({pp_stg2_m_reg[1][LENGTH*2-2:0 ], 1'b0} )   ,                      
    .Ci(1'b0                                    )   ,
    .Co(co[0]                                   )   ,
    .C (pp_stg3_m[0]                            )   ,
    .D (pp_stg3_l[0]                            )   
);  

compressor4_2
#(
    .LENGTH(LENGTH)
)
compressor4_2_level2_inst_1                                             //第二级压缩器 1
(
    .I0(pp_stg2_l_reg[2]                        )   , 
    .I1({pp_stg2_m_reg[2][LENGTH*2-2:0 ], 1'b0} )   ,
    .I2(pp_stg2_l_reg[3]                        )   ,
    .I3({pp_stg2_m_reg[3][LENGTH*2-2:0 ], 1'b0} )   ,
    .Ci(1'b0                                    )   ,
    .Co(co[1]                                   )   ,
    .C (pp_stg3_m[1]                            )   ,
    .D (pp_stg3_l[1]                            )   
);  

//-----------------------// third-pipeline //-----------------------//
always @(posedge sys_clk or negedge sys_rst_n)  begin
    if(sys_rst_n == 1'b0)   begin
        pp_stg3_l_reg[0] <= 'b0;
        pp_stg3_l_reg[1] <= 'b0;
    end
    else    begin
        pp_stg3_l_reg[0] <= pp_stg3_l[0];
        pp_stg3_l_reg[1] <= pp_stg3_l[1];
    end
end 

always @(posedge sys_clk or negedge sys_rst_n)  begin
    if(sys_rst_n == 1'b0)   begin
        pp_stg3_m_reg[0] <= 'b0;
        pp_stg3_m_reg[1] <= 'b0;
    end
    else    begin
        pp_stg3_m_reg[0] <= pp_stg3_m[0];
        pp_stg3_m_reg[1] <= pp_stg3_m[1];
    end
end 

//-----------------------// forth-logic-output //-----------------------//

compressor4_2
#(
    .LENGTH(LENGTH)
)
compressor4_2_level3_inst                                               //第三级压缩器
(
    .I0(pp_stg3_l_reg[0]                        )   , 
    .I1({pp_stg3_m_reg[0][LENGTH*2-2:0 ], 1'b0} )   ,
    .I2(pp_stg3_l_reg[1]                        )   ,
    .I3({pp_stg3_m_reg[1][LENGTH*2-2:0 ], 1'b0} )   ,
    .Ci(1'b0                                    )   ,
    .Co(co[2]                                   )   ,
    .C (pp_stg_m_end                            )   ,
    .D (pp_stg_l_end                            )   
);  

//-----------------------// forth-pipeline //-----------------------//
always @(posedge sys_clk or negedge sys_rst_n)  begin
    if(sys_rst_n == 1'b0)
        pp_stg_m_end_reg <= 'b0;
    else  
        pp_stg_m_end_reg <= pp_stg_m_end;
end 

always @(posedge sys_clk or negedge sys_rst_n)  begin
    if(sys_rst_n == 1'b0)
        pp_stg_l_end_reg <= 'b0;
    else  
        pp_stg_l_end_reg <= pp_stg_l_end;
end 


//-----------------------// full-adder //-----------------------//

full_adder                                                              //最后得到两个数，再与第 17 个部分积相加
#(
    .LENGTH(LENGTH)
)
full_adder_inst
(
    .a ({pp_stg_m_end_reg[LENGTH*2-1], pp_stg_m_end_reg, 1'b0} )   ,
    .b ({{2{pp_stg_l_end_reg[LENGTH*2-1]}}, pp_stg_l_end_reg}  )   ,
    .c (pp_16th_reg                                            )   ,
    .ci(1'b0                                                   )   ,
    .s (P_out                                                  )   ,
    .co(co[3]                                                  )    
);

assign P = P_out[LENGTH*2-1:0]  ;                                       //输出结果，位宽截取            

endmodule