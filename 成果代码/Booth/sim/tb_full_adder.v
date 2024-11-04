`timescale 1ns/1ns   

module tb_full_adder();

parameter   LENGTH  =   32  ;

reg     [LENGTH*2+1:0]  a  ;
reg     [LENGTH*2+1:0]  b  ;
reg     [LENGTH*2+1:0]  c  ;
reg                     ci ;
                 
wire    [LENGTH*2+1:0]  s  ;
wire                    co ;

integer i;
integer pass_count = 0;
integer fail_count = 0;

initial     begin
    for(i=0; i<200; i=i+1)      begin
        a  = $urandom_range(0, 34'hffff_ffff) ;
        b  = $urandom_range(0, 34'hffff_ffff) ;        
        c  = $urandom_range(0, 34'hffff_ffff) ;
        ci = $urandom_range(0, 1'b1         ) ;
        
        #10;
        
        $display("Input  a  = %b", a  );
        $display("Input  b  = %b", b  );
        $display("Input  c  = %b", c  );
        $display("Input  ci = %b", ci );
        $display("Output s  = %b", s  );
        $display("Output co = %b", co );
        
        if((a+b+c+ci) == {co, s})   begin
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
        
full_adder
#(
    .LENGTH(LENGTH)
)
full_adder_inst
(
    .a (a ) ,
    .b (b ) ,
    .c (c ) ,
    .ci(ci) ,

    .s (s ) ,
    .co(co) 

);


endmodule