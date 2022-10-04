// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module fullchip (clk0, clk1, mem_in0, mem_in1, inst, reset, norm_pmem_out0, norm_pmem_out1, out0, out1, div,hsk_comp, mac_array_clk_en, sfp_row_clk_en, kmem_clk_en, qmem_clk_en);

parameter col = 8;
parameter bw = 8;
parameter bw_psum = 2*bw+4;
parameter pr = 16;

input  clk0, clk1; 
input  [pr*bw-1:0] mem_in0;//sborse 
input  [pr*bw-1:0] mem_in1;//sborse
input  [16:0] inst; 
input  reset;
input  div;
input  mac_array_clk_en, sfp_row_clk_en, kmem_clk_en, qmem_clk_en; //sumedh
output [bw_psum*col-1:0] norm_pmem_out0; // sumedhramaprasad
output [bw_psum*col-1:0] norm_pmem_out1; // sumedhramaprasad
output signed [bw_psum*col-1:0] out0;
output signed [bw_psum*col-1:0] out1;
output reg hsk_comp;

wire [bw_psum+3:0] sum_in_to_core0, sum_in_to_core1;
wire [bw_psum+3:0] sum_out_to_core0, sum_out_to_core1;
reg fifo0_wr, fifo0_rd, fifo1_wr, fifo1_rd;


core #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr), .idx(0)) core_instance0 (
      .reset(reset), 
      .clk(clk0), 
      .mem_in(mem_in0), 
      .inst(inst),
      .div(div), //sborse
      .norm_pmem_out(norm_pmem_out0),
      .out(out0),
      .sum_in_from_other_core (sum_in_to_core0),
      .sum_out_to_async_fifo (sum_out_to_core1),
      .mac_array_clk_en (mac_array_clk_en), //sumedh
      .sfp_row_clk_en (sfp_row_clk_en), //sumedh
      .kmem_clk_en (kmem_clk_en), //sumedh
      .qmem_clk_en (qmem_clk_en) //sumedh
);

core #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr), .idx(1)) core_instance1 (
      .reset(reset), 
      .clk(clk1), 
      .mem_in(mem_in1), 
      .inst(inst),
      .div(div), //sborse
      .norm_pmem_out(norm_pmem_out1),
      .out(out1),
      .sum_in_from_other_core (sum_in_to_core1),
      .sum_out_to_async_fifo (sum_out_to_core0),
      .mac_array_clk_en (mac_array_clk_en), //sumedh
      .sfp_row_clk_en (sfp_row_clk_en), //sumedh
      .kmem_clk_en (kmem_clk_en), //sumedh
      .qmem_clk_en (qmem_clk_en) //sumedh
);

async_fifo fifo_instance0_core0_to_core1 (
  .wr_clk  (clk0), 
  .rd_clk  (clk1),
  .reset  (reset),
  .wr_en  (fifo0_wr),
  .rd_en  (div),
  .data_in  (sum_out_to_core1),
  .data_out  (sum_in_to_core1),
  .fifo_full  (o_af0_0to1_full),
  .fifo_empty  (o_af0_0to1_empty),
  .fifo_almost_full  (/*OPEN*/),
  .fifo_almost_empty  (/*OPEN*/)
);

async_fifo fifo_instance1_core1_to_core0 (
  .wr_clk  (clk1), 
  .rd_clk  (clk0),
  .reset  (reset),
  .wr_en  (fifo1_wr),
  .rd_en  (div),
  .data_in  (sum_out_to_core0),
  .data_out  (sum_in_to_core0),
  .fifo_full  (o_af1_1to0_full),
  .fifo_empty  (o_af1_1to0_empty),
  .fifo_almost_full  (/*OPEN*/),
  .fifo_almost_empty  (/*OPEN*/)
);

always @ (posedge clk0) begin
    if (inst[16]) //acc command
        fifo0_wr <= 1;
    else
        fifo0_wr <= 0;
end

always @ (posedge clk1) begin
    if (inst[16]) //acc command
        fifo1_wr <= 1;
    else
        fifo1_wr <= 0;
end

always @(*)
begin
    if (reset) 
        hsk_comp <=0;
    else if(o_af0_0to1_full && o_af1_1to0_full)
        hsk_comp <=1;
end

// clockgating


endmodule
