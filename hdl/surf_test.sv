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
                input sysref_n
    );
    
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

                          .mem_clk(memclk),
                          .sync_clk(syncclk),

                          .sysref_in_diff_p(sysref_p),
                          .sysref_in_diff_n(sysref_n));

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
    
    
    
    
endmodule
