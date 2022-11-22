`timescale 1ns / 1ps
`include "interfaces.vh"
module surf_test(input adc0_clk_p,
                input adc0_clk_n,
                input adc1_clk_p,
                input adc1_clk_n,
                input adc2_clk_p,
                input adc2_clk_n,
                input adc3_clk_p,
                input adc3_clk_n,

                input adcA_p,
                input adcA_n,
                input adcB_p,
                input adcB_n,
                input adcC_p,
                input adcC_n,
                input adcD_p,
                input adcD_n,
                input adcE_p,
                input adcE_n,
                input adcF_p,
                input adcF_n,
                input adcG_p,
                input adcG_n,
                input adcH_p,
                input adcH_n,

                input sysref_p,
                input sysref_n,
                
                input PL_SYSREF_P,
                input PL_SYSREF_N,
                
                input RXCLK_P,
                input RXCLK_N,
                input CIN_P,
                input CIN_N
    );
    
    wire plclk;
    IBUFDS u_plclk(.I(PL_SYSREF_P),.IB(PL_SYSREF_N),.O(plclk));
    reg tog = 0;
    always @(posedge plclk) tog <= ~tog;
    single_debug u_sd(.clk(plclk),.probe0(tog));    
    
    wire rxclk;
    wire parclk;
    wire smpclk;
    wire rxsyncclk;
    
    wire rxclk_reset;
    wire rxclk_locked;
    rxclock_gen u_rxclk(.clk_in1_p(RXCLK_P),.clk_in1_n(RXCLK_N),
                        .reset(rxclk_reset),
                        .rxclk(rxclk),
                        .parclk(parclk),
                        .smpclk(smpclk),
                        .syncclk(rxsyncclk),
                        .locked(rxclk_locked));
    wire rxclk_sync;
    wire parclk_sync;
    rackbus_clk_sync u_sync(.rxclk(rxclk),
                            .parclk(parclk),
                            .syncclk(rxsyncclk),
                            .rxclk_sync_o(rxclk_sync),
                            .parclk_sync_o(parclk_sync));

    wire [5:0] input_data;
    rackbus_in u_rackbus( .smpclk(smpclk),
                          .parclk(parclk),
                          .parclk_sync_i(parclk_sync),
                          .rxclk(rxclk),
                          .rxclk_sync_i(rxclk_sync),
                          .cin_p(CIN_P),
                          .cin_n(CIN_N),
                          .dat_o(input_data));
                            
    sync_debug u_rxsync(.clk(rxclk),.probe0(rxclk_sync),.probe1(input_data));
                        
    
    wire [127:0] ma_axis_tdata;
    wire         ma_axis_tvalid;
    wire [127:0] mb_axis_tdata;
    wire         mb_axis_tvalid;
    wire [127:0] mc_axis_tdata;
    wire         mc_axis_tvalid;
    wire [127:0] md_axis_tdata;
    wire         md_axis_tvalid;
    wire [127:0] me_axis_tdata;
    wire         me_axis_tvalid;
    wire [127:0] mf_axis_tdata;
    wire         mf_axis_tvalid;
    wire [127:0] mg_axis_tdata;
    wire         mg_axis_tvalid;
    wire [127:0] mh_axis_tdata;
    wire         mh_axis_tvalid;

    wire [127:0] adc_tdata[7:0];
    assign adc_tdata[0] = ma_axis_tdata;
    assign adc_tdata[1] = mb_axis_tdata;
    assign adc_tdata[2] = mc_axis_tdata;
    assign adc_tdata[3] = md_axis_tdata;
    assign adc_tdata[4] = me_axis_tdata;
    assign adc_tdata[5] = mf_axis_tdata;
    assign adc_tdata[6] = mg_axis_tdata;
    assign adc_tdata[7] = mh_axis_tdata;


    `DEFINE_AXI4L_IF( pueo_ , 40, 32 );

    wire aclk;
    wire m_axi_aclk;
    wire m_axi_aresetn;
    wire memclk;
    wire syncclk;

    wire [15:0] smp[7:0];
    generate
        genvar s;
        for (s=0;s<8;s=s+1) begin : DV
            assign smp[s] = adc_tdata[0][16*s +: 16];
        end
    endgenerate    

    ila_0 u_ila(.clk(aclk),
                .probe0(smp[0]),
                .probe1(smp[1]),
                .probe2(smp[2]),
                .probe3(smp[3]),
                .probe4(smp[4]),
                .probe5(smp[5]),
                .probe6(smp[6]),
                .probe7(smp[7]));

    wire clk_reset;
    wire clk_locked;

    ps_base_wrapper u_ps( .adc0_clk_clk_p(adc0_clk_p),
                          .adc0_clk_clk_n(adc0_clk_n),
                          .adc1_clk_clk_p(adc1_clk_p),
                          .adc1_clk_clk_n(adc1_clk_n),
                          .adc2_clk_clk_p(adc2_clk_p),
                          .adc2_clk_clk_n(adc2_clk_n),
                          .adc3_clk_clk_p(adc3_clk_p),
                          .adc3_clk_clk_n(adc3_clk_n),

                          .adcA_in_v_p(adcA_p),
                          .adcA_in_v_n(adcA_n),
                          .adcB_in_v_p(adcB_p),
                          .adcB_in_v_n(adcB_n),

                          .adcC_in_v_p(adcC_p),
                          .adcC_in_v_n(adcC_n),
                          .adcD_in_v_p(adcD_p),
                          .adcD_in_v_n(adcD_n),

                          .adcE_in_v_p(adcE_p),
                          .adcE_in_v_n(adcE_n),
                          .adcF_in_v_p(adcF_p),
                          .adcF_in_v_n(adcF_n),

                          .adcG_in_v_p(adcG_p),
                          .adcG_in_v_n(adcG_n),
                          .adcH_in_v_p(adcH_p),
                          .adcH_in_v_n(adcH_n),

                          .ma_aclk(aclk),
                          .ma_axis_tdata(ma_axis_tdata),
                          .mb_axis_tdata(mb_axis_tdata),
                          .mc_axis_tdata(mc_axis_tdata),
                          .md_axis_tdata(md_axis_tdata),
                          .me_axis_tdata(me_axis_tdata),
                          .mf_axis_tdata(mf_axis_tdata),
                          .mg_axis_tdata(mg_axis_tdata),
                          .mh_axis_tdata(mh_axis_tdata),

                          .m_axi_aclk(m_axi_aclk),
                          .m_axi_aresetn(m_axi_aresetn),
                          `CONNECT_AXI4L_IF( m_axi_ , pueo_ ),                  

                          .reset_0(clk_reset),
                          .locked(clk_locked),

                          .mem_clk(memclk),
                          .sync_clk(syncclk),

                          .sysref_in_diff_p(sysref_p),
                          .sysref_in_diff_n(sysref_n));

    clk_reset_vio u_clkvio(.clk(m_axi_aclk),.probe_in0(clk_locked),.probe_out0(clk_reset));

    (* KEEP = "TRUE" *)
    wire [17:0] coeff_data;
    wire [7:0] coeff_address;
    wire       coeff_wr;
    wire       coeff_update;

    axi_pueo u_pueo( .s_axi_aclk(m_axi_aclk),
                     .s_axi_aresetn(m_axi_aresetn),
                     `CONNECT_AXI4L_IF( s_axi_ , pueo_ ),

                     .aclk(aclk),
                     .coeff_dat_o(coeff_data),
                     .coeff_adr_o(coeff_address),
                     .coeff_wr_o(coeff_wr),
                     .coeff_update_o(coeff_update));
    
    // 100 MHz = 100,000 to get to millis
    wire millice;
    dsp_counter_terminal_count #(.FIXED_TCOUNT("TRUE"),.FIXED_TCOUNT_VALUE(100000))
                u_millice(.clk_i(m_axi_aclk),
                          .rst_i(1'b0),
                          .count_i(1'b1),
                          .tcount_reached_o(millice));
    board_clock_checkout u_checkout(.sysclk(m_axi_aclk),
                                    .sysclk_millice(millice),
                                    .testclk(plclk));

    board_clock_checkout u_checkout_rxclk(.sysclk(m_axi_aclk),
                                          .sysclk_millice(millice),
                                          .testclk(rxclk));
    
    
    
endmodule
