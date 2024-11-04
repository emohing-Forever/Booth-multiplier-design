//***********************// booth编码 //*******************************//

//radix-4   

`include "UnsignedChoose.v"
            
module  Booth_Ctrl 
#(
    parameter   LENGTH  =   32
)
(
    input   wire    [LENGTH-1:0 ]    a_i     ,  //乘数 A
    input   wire    [2:0        ]    b_i     ,  //被乘数 B 三位选择
    output  reg     [LENGTH+1:0 ]    bo_o     
);

//***********************// main-code //*******************************//

`ifdef  UNSINGED_BOOTH
wire    [LENGTH:0]    a_tr  ;   //无符号乘法，扩展一位最高位0

assign  a_tr = {1'b0, a_i};

always @(*)     begin       //无符号
    case(b_i)
        3'b000:  bo_o =  'b0                     ;
        3'b001:  bo_o =  {a_tr[LENGTH], a_tr  }  ;
        3'b010:  bo_o =  {a_tr[LENGTH], a_tr  }  ;
        3'b011:  bo_o =  {a_tr, 1'b0          }  ;
        3'b100:  bo_o = -{a_tr, 1'b0          }  ;
        3'b101:  bo_o = -{a_tr[LENGTH], a_tr  }  ;
        3'b110:  bo_o = -{a_tr[LENGTH], a_tr  }  ;
        3'b111:  bo_o =  'b0                     ;
    endcase
end

`else       
always @(*)     begin       //有符号
    case(b_i)
        3'b000:  bo_o =  'b0                          ;
        3'b001:  bo_o =  {{2{a_i[LENGTH-1]}}, a_i  }  ;
        3'b010:  bo_o =  {{2{a_i[LENGTH-1]}}, a_i  }  ;
        3'b011:  bo_o =  {a_i[LENGTH-1], a_i, 1'b0 }  ;
        3'b100:  bo_o = -{a_i[LENGTH-1], a_i, 1'b0 }  ;
        3'b101:  bo_o = -{{2{a_i[LENGTH-1]}}, a_i  }  ;
        3'b110:  bo_o = -{{2{a_i[LENGTH-1]}}, a_i  }  ;
        3'b111:  bo_o =  'b0                          ;
    endcase
end

`endif

endmodule


