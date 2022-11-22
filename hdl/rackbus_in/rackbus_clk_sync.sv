`timescale 1ns / 1ps
// RXCLK is 4x SYNCCLK
// PARCLK is 3x SYNCCLK
module rackbus_clk_sync(
        input rxclk,
        input parclk,
        input syncclk,
        output rxclk_sync_o,
        output parclk_sync_o
    );

    (* ASYNC_REG = "TRUE" *)
    reg [3:0] rxclk_sync = {4{1'b0}};
    (* ASYNC_REG = "TRUE" *)
    reg [2:0] parclk_sync = {3{1'b0}};

    // phase track registers
    reg [3:0] rxclk_phase = {4{1'b0}};
    reg [2:0] parclk_phase = {3{1'b0}};

    // buffered phase track registers
    reg [3:0] rxclk_phase_buf = {4{1'b0}};
    reg [2:0] parclk_phase_buf = {3{1'b0}};
    
    // this is the indicator
    reg syncclk_toggle = 0;
    always @(posedge syncclk) syncclk_toggle <= ~syncclk_toggle;
    // RXCLK phase track
    always @(posedge rxclk) begin
        rxclk_sync <= { rxclk_sync[2:0], syncclk_toggle };
        if (rxclk_sync[2] && !rxclk_sync[3]) rxclk_phase <= 4'b0001;
        else rxclk_phase <= {rxclk_phase[2:0],rxclk_phase[3]};
        
        rxclk_phase_buf <= {rxclk_phase_buf[2:0], rxclk_phase[0]};
    end
    always @(posedge parclk) begin
        parclk_sync <= { parclk_sync[1:0], syncclk_toggle };
        if (parclk_sync[1] && !parclk_sync[2]) parclk_phase <= 3'b001;
        else parclk_phase <= {parclk_phase[1:0], parclk_phase[2]};
        
        parclk_phase_buf <= { parclk_phase_buf[1:0], parclk_phase[0] };
    
    end
    
    assign rxclk_sync_o = rxclk_phase_buf[0];
    assign parclk_sync_o = parclk_phase_buf[0];  
endmodule
