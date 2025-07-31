//***********************// booth编码 //*******************************//

//radix-16
            
module  Booth_Ctrl 
#(
    parameter   LENGTH          =   32,
    parameter   UNSINGED_BOOTH  =   1'b1
)(
    input   wire    [LENGTH-1:0     ]   a_i     ,  //乘数 A
    input   wire    [4:0            ]   b_i     ,  //被乘数 B 五位选择
    output  wire    [LENGTH+3:0     ]   bo_o     
);

    reg [LENGTH+3:0 ] bo_o_l ;
    reg [LENGTH+3:0 ] bo_o_m ;

    wire [LENGTH:0  ] a_tr   ;   //无符号乘法，扩展一位最高位0

    assign  a_tr = UNSINGED_BOOTH ? {1'b0, a_i} : {a_i[LENGTH-1], a_i};

    always @(*) begin
        case(b_i[2:0])
            3'b000:  bo_o_l =  'b0                                ;
            3'b001:  bo_o_l =  {{3{a_tr[LENGTH]}}, a_tr        }  ;
            3'b010:  bo_o_l =  {{3{a_tr[LENGTH]}}, a_tr        }  ;
            3'b011:  bo_o_l =  {{2{a_tr[LENGTH]}}, a_tr, 1'b0  }  ;
            3'b100:  bo_o_l = -{{2{a_tr[LENGTH]}}, a_tr, 1'b0  }  ;
            3'b101:  bo_o_l = -{{3{a_tr[LENGTH]}}, a_tr        }  ;
            3'b110:  bo_o_l = -{{3{a_tr[LENGTH]}}, a_tr        }  ;
            3'b111:  bo_o_l =  'b0                                ;
        endcase
    end

    always @(*) begin       
        case(b_i[4:2])
            3'b000:  bo_o_m =  'b0                                ;
            3'b001:  bo_o_m =  {a_tr[LENGTH], a_tr, 2'b0       }  ;  
            3'b010:  bo_o_m =  {a_tr[LENGTH], a_tr, 2'b0       }  ;
            3'b011:  bo_o_m =  {a_tr, 3'b0                     }  ;
            3'b100:  bo_o_m = -{a_tr, 3'b0                     }  ;
            3'b101:  bo_o_m = -{a_tr[LENGTH], a_tr, 2'b0       }  ;
            3'b110:  bo_o_m = -{a_tr[LENGTH], a_tr, 2'b0       }  ;
            3'b111:  bo_o_m =  'b0                                ;
        endcase  
    end  

    assign  bo_o = bo_o_m + bo_o_l ;

endmodule


