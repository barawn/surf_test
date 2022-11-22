`timescale 1ns / 1ps
// 4:3 upconversion between synchronous clock domains
// e.g. transferring 4 bits at 100 MHz to 3 bits at 133 MHz

// NGROUPS here is the number of 4 bit groupings at the slow clock.
// There are *2* outputs.
// The first is exactly as you'd expect for a gearbox: 3 bits, in the same order they
// were received, although there's an extra clock delay.
// So if you get in 000 001 010 011 (in 4 bits, 0000 0101 0011)
// you'd get out 000 001 010 011.
// The second (fast_par_o) outputs the *12-bit parallel* value, once every 4 clocks.
// fast_phase_o can be used as a clock enable on that output.
module gearbox4to3 #(parameter NGROUPS=2)(
        input slow_clk,
        input slow_clk_sync,                    // indicates the clock when slow/fast clk are aligned
        input [NGROUPS*4-1:0] slow_dat_i,       // 4-bit (per group) slow input
        
        input fast_clk,
        input fast_clk_sync,                    // indicates the clock when slow/fast clk are aligned
        output [NGROUPS*3-1:0]  fast_dat_o,     // 3-bit (per group) fast output
        output [3:0] fast_phase_o,              // what fast phase we're in 
        output [NGROUPS*12-1:0] fast_par_o      // *parallel* output (12 bits every 4 clocks)
    );
    
    // Phase tracking. Originally in the pueo_uram this was done
    // with one in a one-hot reg, and another in a counter, but that's just silly.
    // Do them both in one-hots.
    
    // slow clock has 3 phases
    reg [2:0] slow_phase = {3{1'b0}};
    // fast clock has 4 phases
    // limit fanout in case there's a lot of load on these
    (* MAX_FANOUT = 8 *)
    reg [3:0] fast_phase = {4{1'b0}};
    
    // slow_clk_sync indicates we're in phase 0, so when we reregister, it's phase 1.    
    always @(posedge slow_clk) slow_phase <= { slow_phase[1], slow_clk_sync, slow_phase[2] };
    // ditto with fast_clk_sync
    always @(posedge fast_clk) fast_phase <= { fast_phase[2], fast_phase[1], fast_clk_sync, fast_phase[0] };
    
    reg [NGROUPS*12-1:0] slowclk_data = {(NGROUPS*12-1){1'b0}};
    reg [NGROUPS*12-1:0] fastclk_data = {(NGROUPS*12-1){1'b0}};
    reg [NGROUPS*3-1:0] fastclk_rereg = {(NGROUPS*3-1){1'b0}};
    
    always @(posedge slow_clk) begin
        if (slow_phase[0]) slowclk_data[0 +: NGROUPS*4] <= slow_dat_i;
        if (slow_phase[1]) slowclk_data[NGROUPS*4 +: NGROUPS*4] <= slow_dat_i;
        if (slow_phase[2]) slowclk_data[NGROUPS*8 +: NGROUPS*4] <= slow_dat_i;
    end  
    
    always @(posedge fast_clk) begin
        if (fast_phase[2]) fastclk_data[0 +: NGROUPS*3] <= slowclk_data[0 +: NGROUPS*3];
        if (fast_phase[3]) fastclk_data[NGROUPS*3 +: NGROUPS*3] <= slowclk_data[NGROUPS*3 +: NGROUPS*3];
        if (fast_phase[0]) fastclk_data[NGROUPS*6 +: NGROUPS*3] <= slowclk_data[NGROUPS*6 +: NGROUPS*3];
        if (fast_phase[1]) fastclk_data[NGROUPS*9 +: NGROUPS*3] <= slowclk_data[NGROUPS*9 +: NGROUPS*3];
        
        // multiplex
        if (fast_phase[0]) fastclk_rereg <= fastclk_data[NGROUPS*3 +: NGROUPS*3];
        else if (fast_phase[1]) fastclk_rereg <= fastclk_data[NGROUPS*6 +: NGROUPS*3];
        else if (fast_phase[2]) fastclk_rereg <= fastclk_data[NGROUPS*9 +: NGROUPS*3];
        else if (fast_phase[3]) fastclk_rereg <= fastclk_data[0 +: NGROUPS*3];
    end        

   assign fast_dat_o = fastclk_rereg;
   assign fast_par_o = fastclk_data;
   assign fast_phase_o = fast_phase;
   
endmodule
