`timescale 1ns / 1ps
module rackbus_in(
        input smpclk,
        input parclk,
        input parclk_sync_i,        
        input rxclk,
        input rxclk_sync_i,
        
        input cin_p,
        input cin_n,
        
        output [5:0] dat_o
    );
    wire cin;    
    IBUFDS u_ibuf(.I(cin_p),.IB(cin_n),.O(cin));
    // CIN needs to pass through an IDELAY here. I just haven't done it yet.
    wire [7:0] cin_parclk;
    ISERDESE3 #( .DATA_WIDTH(8),
                 .FIFO_ENABLE("FALSE"),
                 .IS_CLK_INVERTED(1'b0),
                 .IS_CLK_B_INVERTED(1'b1),
                 .IS_RST_INVERTED(1'b0),
                 .SIM_DEVICE("ULTRASCALE_PLUS"))    
        u_iserdes( .CLK(smpclk),
                   .CLK_B(smpclk),
                   .CLKDIV(parclk),
                   .D(cin),
                   .Q(cin_parclk),
                   .RST(1'b0));
    gearbox4to3 #(.NGROUPS(2)) u_gearbox(.slow_clk(parclk),
                          .slow_clk_sync(parclk_sync_i),
                          .fast_clk(rxclk),
                          .fast_clk_sync(rxclk_sync_i),
                          .slow_dat_i(cin_parclk),
                          .fast_dat_o(dat_o));
    
endmodule
