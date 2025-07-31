//参考文章：   https://zhuanlan.zhihu.com/p/127164011?utm_source=wechat_timeline

//***********************// Booth-Top //*******************************//

module  Booth_mul
#(
    parameter   LENGTH          =   32  ,
    parameter   UNSINGED_BOOTH  =   1'b1
)(
    input   wire                        clk   ,
    input   wire                        rst   ,
    input   wire                        start ,
    input   wire    [LENGTH-1:0     ]   A     ,    //乘数 A
    input   wire    [LENGTH-1:0     ]   B     ,    //被乘数 B
    output  wire    [LENGTH*2-1:0   ]   P     ,    //结果 P
    output  wire                        done
);

    //***********************// wire-define //*******************************//
    genvar i;
    integer j;

    wire [LENGTH+3:0   ] boo_o     [0:LENGTH/4   ] ;        //booth转码输出值
    wire [LENGTH*2-1:0 ] pp        [0:LENGTH/4-1 ] ;        //部分积
    wire [LENGTH*2+3:0 ] pp_8th                    ;        //扩展位产生的第9个部分积分，全加器输入值

    wire [3:0          ] co                        ;        //一二级压缩器以及全加器输出进位

    wire [LENGTH*2-1:0 ] pp_stg2_m [0:1          ] ;        //第一级压缩器输出高位值，第二级压缩器输入值
    wire [LENGTH*2-1:0 ] pp_stg2_l [0:1          ] ;        //第一级压缩器输出低位值，第二级压缩器输入值

    wire [LENGTH*2-1:0 ] pp_stg_m_end              ;        //第二级压缩器输出高位值，全加器输入值
    wire [LENGTH*2-1:0 ] pp_stg_l_end              ;        //第二级压缩器输出低位值，全加器输入值

    wire [LENGTH+4:0   ] B_tr                      ;        //输入数 B 扩展

    wire [LENGTH*2+3:0 ] P_out                     ;        //全加器输出

    //first-pipeline
    reg [LENGTH*2-1:0 ] pp_stg1_reg [0:LENGTH/4-1] ;
    reg [LENGTH*2+3:0 ] pp_stg1_8th_reg            ;
    reg                 pp_stg1_done_reg           ;

    //second-pipeline
    reg [LENGTH*2-1:0 ] pp_stg2_m_reg [0:1       ] ;
    reg [LENGTH*2-1:0 ] pp_stg2_l_reg [0:1       ] ;
    reg                 pp_stg2_done_reg           ;
    //third-pipeline
    reg [LENGTH*2-1:0 ] pp_stg_end_m_reg           ;
    reg [LENGTH*2-1:0 ] pp_stg_end_l_reg           ;
    reg                 pp_stg_end_done_reg        ;

    //***********************// main-code //*******************************//

    //-----------------------// first-logic-output //-----------------------//

    //扩展最低位置B[-1],为0
    assign B_tr = UNSINGED_BOOTH ? {4'b0, B, 1'b0} : {{4{B[LENGTH-1]}}, B, 1'b0};

    //实例化 Booth_Ctrl 模块，实现转码
    generate
        for(i=0; i<LENGTH/4+1; i=i+1) begin:  Booth_Ctrl_i
            Booth_Ctrl
            #(
                .LENGTH(LENGTH),
                .UNSINGED_BOOTH(UNSINGED_BOOTH)
            ) Booth_Ctrl (
                .a_i      (A               ) ,
                .b_i      ({B_tr[i*4+:5]}  ) ,
                .bo_o     (boo_o[i]        )
            );
            if(i != 8)
                assign pp[i]   = {{(LENGTH-4-i*4){boo_o[i][LENGTH+3]}}, boo_o[i], {(i*4){1'b0}} } ;  //部分积
            else
                assign pp_8th  = {boo_o[i], {(i*4){1'b0}}                                       } ;  //扩展位所产生的第 9 个部分积
        end
    endgenerate

    //-----------------------// first-pipeline //-----------------------//
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            pp_stg1_8th_reg <= 0;
            for(j=0; j<LENGTH/4; j=j+1) begin
                pp_stg1_reg[j] <= 0;
            end
            pp_stg1_done_reg <= 0;
        end else begin
            pp_stg1_8th_reg <= pp_8th;
            for(j=0; j<LENGTH/4; j=j+1) begin
                pp_stg1_reg[j] <= pp[j];
            end
            pp_stg1_done_reg <= start;
        end
    end

    //-----------------------// second-logic-output //-----------------------//
    //实例化 4-2 压缩器，实现部分积求和
    generate
        for(i=0; i<LENGTH/4/4; i=i+1) begin: compressor4_2_level1_inst
            compressor4_2
            #(
                .LENGTH(LENGTH)
            ) compressor4_2_level1_inst (
                .I0(pp_stg1_reg[i*4 + 0]    )   ,
                .I1(pp_stg1_reg[i*4 + 1]    )   ,
                .I2(pp_stg1_reg[i*4 + 2]    )   ,
                .I3(pp_stg1_reg[i*4 + 3]    )   ,
                .Ci(1'b0                    )   ,
                .Co(co[i]                   )   ,
                .C (pp_stg2_m[i]            )   ,
                .D (pp_stg2_l[i]            )
            );
        end
    endgenerate

    //-----------------------// second-pipeline //-----------------------//
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            for(j=0; j<LENGTH/4/4; j=j+1) begin
                pp_stg2_m_reg[j] <= 0;
                pp_stg2_l_reg[j] <= 0;
            end
            pp_stg2_done_reg <= 0;
        end else begin
            for(j=0; j<LENGTH/4/4; j=j+1) begin
                pp_stg2_m_reg[j] <= pp_stg2_m[j];
                pp_stg2_l_reg[j] <= pp_stg2_l[j];
            end
            pp_stg2_done_reg <= pp_stg1_done_reg;
        end
    end

    //-----------------------// third-logic-output //-----------------------//
    //实例化 4-2 压缩器，实现部分积求和
    compressor4_2
    #(
        .LENGTH(LENGTH)
    ) compressor4_2_level2_inst (                                               //第二级压缩器
        .I0(pp_stg2_l_reg[0]                        )   ,
        .I1({pp_stg2_m_reg[0][LENGTH*2-2:0 ], 1'b0} )   ,
        .I2(pp_stg2_l_reg[1]                        )   ,
        .I3({pp_stg2_m_reg[1][LENGTH*2-2:0 ], 1'b0} )   ,
        .Ci(1'b0                                    )   ,
        .Co(co[2]                                   )   ,
        .C (pp_stg_m_end                            )   ,
        .D (pp_stg_l_end                            )
    );

    //-----------------------// third-pipeline //-----------------------//
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            pp_stg_end_m_reg <= 0;
            pp_stg_end_l_reg <= 0;
            pp_stg_end_done_reg <= 0;
        end else begin
            pp_stg_end_m_reg <= pp_stg_m_end;
            pp_stg_end_l_reg <= pp_stg_l_end;
            pp_stg_end_done_reg <= pp_stg2_done_reg;
        end
    end

    //-----------------------// forth-logic-output //-----------------------//

    full_adder                                                              //最后得到两个数，再与第 9 个部分积相加
    #(
        .LENGTH(LENGTH)
    ) full_adder_inst (
        .a ({{3{pp_stg_end_m_reg[LENGTH*2-1]}}, pp_stg_end_m_reg, 1'b0} )   ,
        .b ({{4{pp_stg_end_l_reg[LENGTH*2-1]}}, pp_stg_end_l_reg}       )   ,
        .c (pp_stg1_8th_reg                                             )   ,
        .ci(1'b0                                                        )   ,
        .s (P_out                                                       )   ,
        .co(co[3]                                                       )
    );

    assign P = P_out[LENGTH*2-1:0]  ;                                       //输出结果，位宽截取
    assign done = pp_stg_end_done_reg;

endmodule