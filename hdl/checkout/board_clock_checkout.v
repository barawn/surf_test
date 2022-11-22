// counts a test clock using the internal oscillator
// and outputs it into a VIO. The value is the number of clocks
// per millisecond (ish).
// Note that since we can't assume that testclk is actually running
// (... that's the whole point), we actually do:
//
// sysclk_millice: capture LAST count into CURRENT and output it to VIO,
//                 reset LAST count, flag testclk domain to reset and capture
//                 a new LAST_TESTCLK count, capture new LAST count when
//                 testclk domain signals completion.

module board_clock_checkout( input sysclk,
			     input sysclk_millice,
			     input testclk );

   reg [47:0] 			   current_count = {48{1'b0}};
   reg [47:0] 			   last_captured_count = {48{1'b0}};
   reg [47:0] 			   last_count_testclk = {48{1'b0}};
   
   reg                 capture_sysclk = 0;
   wire 			   capture_testclk;
   reg 				   captured_testclk = 0;   
   wire 			   captured_sysclk;

   flag_sync u_capture_sync(.in_clkA(capture_sysclk),.out_clkB(capture_testclk),.clkA(sysclk),.clkB(testclk));
   flag_sync u_captured_sync(.in_clkA(captured_testclk),.out_clkB(captured_sysclk),.clkA(testclk),.clkB(sysclk));
   (* USE_DSP48 = "YES" *)
   reg [47:0] 			   counter = {48{1'b0}};
   always @(posedge testclk) begin
      if (capture_testclk) counter <= {48{1'b0}};
      else counter <= counter + 1;
      if (capture_testclk) last_count_testclk <= counter;
      captured_testclk <= capture_testclk;      
   end
   always @(posedge sysclk) begin
     capture_sysclk <= sysclk_millice;
      if (sysclk_millice) begin
	 current_count <= last_captured_count;
	 last_captured_count <= {48{1'b0}};
      end else if (captured_sysclk) begin
	 last_captured_count <= last_count_testclk;
      end
   end   

   clock_count_vio u_vio(.clk(sysclk),.probe_in0(current_count));

endmodule // board_clock_checkout
