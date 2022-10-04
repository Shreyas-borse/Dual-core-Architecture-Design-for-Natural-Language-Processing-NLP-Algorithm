// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module core (clk, norm_pmem_out, mem_in, out, inst, reset, div, sum_out_to_async_fifo, sum_in_from_other_core, mac_array_clk_en, sfp_row_clk_en, kmem_clk_en, qmem_clk_en);

parameter col = 8;
parameter bw = 8;
parameter bw_psum = 2*bw+4;
parameter pr = 16;
parameter idx = 0;

output [bw_psum*col-1:0] norm_pmem_out;//sumedhramaprasad
output [bw_psum+3:0] sum_out_to_async_fifo;
output signed [bw_psum*col-1:0] out;
wire   [bw_psum*col-1:0] pmem_out;
input  [pr*bw-1:0] mem_in;
input  clk;
input  [16:0] inst; 
input  reset;
input  div; //shreyasborse
input  mac_array_clk_en, sfp_row_clk_en, kmem_clk_en, qmem_clk_en; //sumedh
input  [bw_psum+3:0] sum_in_from_other_core;


wire  [pr*bw-1:0] mac_in;
wire  [pr*bw-1:0] kmem_out;
wire  [pr*bw-1:0] qmem_out;
wire  [bw_psum*col-1:0] pmem_in;
wire  [bw_psum*col-1:0] fifo_out;
wire signed [bw_psum*col-1:0] sfp_out;
wire  [bw_psum*col-1:0] array_out;
wire  [col-1:0] fifo_wr;
wire  ofifo_rd;
wire [3:0] qkmem_add;
wire [3:0] pmem_add;
wire [3:0] norm_pmem_add;
wire mac_array_gated_clk;
wire ofifo_gated_clk;
wire sfp_row_gated_clk;
wire kmem_gated_clk;
wire qmem_gated_clk;

wire acc;//shreyasborse
wire  qmem_rd;
wire  qmem_wr; 
wire  kmem_rd;
wire  kmem_wr; 
wire  pmem_rd;
wire  pmem_wr; 
// sumedh
wire  norm_pmem_rd;
wire  norm_pmem_wr; 

assign ofifo_rd = inst[16];
assign qkmem_add = inst[15:12];
assign pmem_add = inst[11:8];
//sumedh
assign norm_pmem_add = inst[11:8];

assign qmem_rd = inst[5];
assign qmem_wr = inst[4];
assign kmem_rd = inst[3];
assign kmem_wr = inst[2];
assign pmem_rd = inst[1];
assign pmem_wr = inst[0];
//sumedhramaprasad
assign norm_pmem_rd = inst[1];
assign norm_pmem_wr = inst[0];

assign mac_in  = inst[6] ? kmem_out : qmem_out;
assign pmem_in = fifo_out;

mac_array #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) mac_array_instance (
        .in(mac_in), 
        .clk(mac_array_gated_clk), 
        .reset(reset), 
        .inst(inst[7:6]),     
        .fifo_wr(fifo_wr),     
	.out(array_out)
);

ofifo #(.bw(bw_psum), .col(col))  ofifo_inst (
        .reset(reset),
        .clk(ofifo_gated_clk),
        .in(array_out),
        .wr(fifo_wr),
        .rd(ofifo_rd),
        .o_valid(fifo_valid),
        .out(fifo_out)
);

sram_w16 #(.sram_bit(pr*bw)) qmem_instance (
        .CLK(qmem_gated_clk),
        .D(mem_in),
        .Q(qmem_out),
        .CEN(!(qmem_rd||qmem_wr)),
        .WEN(!qmem_wr), 
        .A(qkmem_add)
);

sram_w16 #(.sram_bit(pr*bw)) kmem_instance (
        .CLK(kmem_gated_clk),
        .D(mem_in),
        .Q(kmem_out),
        .CEN(!(kmem_rd||kmem_wr)),
        .WEN(!kmem_wr), 
        .A(qkmem_add)
);

//sram_w16 #(.sram_bit(col*bw_psum)) psum_mem_instance (
        //.CLK(clk),
        //.D(pmem_in),
        //.Q(pmem_out),
        //.CEN(!(pmem_rd||pmem_wr)),
        //.WEN(!pmem_wr), 
        //.A(pmem_add)
//);

sfp_row #(.bw(bw), .bw_psum(bw_psum), .col(col)) sfp_row (
        .clk(sfp_row_gated_clk),
        .reset (reset),
        .acc(ofifo_rd),
        .div(div),
        .fifo_ext_rd(1'b0), //for singlecore 
        .sum_in(sum_in_from_other_core), //for singlecore
        .sum_out_to_async_fifo(sum_out_to_async_fifo),
        .sfp_in(fifo_out),
        .sfp_out(sfp_out)
        );//shreyasborse

sram_w16 #(.sram_bit(col*bw_psum)) norm_psum_mem_instance (
        .CLK(sfp_row_gated_clk),
        .D(sfp_out),
        .Q(norm_pmem_out),
        .CEN(!(norm_pmem_rd||norm_pmem_wr)),
        .WEN(!norm_pmem_wr), 
        .A(norm_pmem_add)
);

//clock gater for mac_array
async_clock_gater mac_array_clock_gate_inst (
    .clk (clk),
    .async_clk_en (mac_array_clk_en),
    .gated_clk (mac_array_gated_clk),
    .gated_clk_is_on ()
);

//clock gater for ofifo 
async_clock_gater ofifo_clock_gate_inst (
    .clk (clk),
    .async_clk_en ({{|fifo_wr}|ofifo_rd}),
    .gated_clk (ofifo_gated_clk),
    .gated_clk_is_on ()
);

//clock gater for sfp_row
async_clock_gater sfp_row_clock_gate_inst (
    .clk (clk),
    .async_clk_en (sfp_row_clk_en),
    .gated_clk (sfp_row_gated_clk),
    .gated_clk_is_on ()
);

//clock gater for kmem
async_clock_gater kmem_clock_gate_inst (
    .clk (clk),
    .async_clk_en (kmem_clk_en),
    .gated_clk (kmem_gated_clk),
    .gated_clk_is_on ()
);

//clock gater for qmem
async_clock_gater qmem_clock_gate_inst (
    .clk (clk),
    .async_clk_en (qmem_clk_en),
    .gated_clk (qmem_gated_clk),
    .gated_clk_is_on ()
);

  //////////// For printing purpose ////////////

  assign out = sfp_out;
  always @(posedge clk) begin
      if ((div && norm_pmem_wr) && (norm_pmem_add>0))
         $display("Core %2d: Memory write to NORM PSUM mem address %2d -> %7d %7d %7d %7d %7d %7d %7d %7d", idx, (norm_pmem_add-'d1), $signed(sfp_out[bw_psum*1-1 : bw_psum*0]), $signed(sfp_out[bw_psum*2-1 : bw_psum*1]), $signed(sfp_out[bw_psum*3-1 : bw_psum*2]), $signed(sfp_out[bw_psum*4-1 : bw_psum*3]), $signed(sfp_out[bw_psum*5-1 : bw_psum*4]), $signed(sfp_out[bw_psum*6-1 : bw_psum*5]), $signed(sfp_out[bw_psum*7-1 : bw_psum*6]), $signed(sfp_out[bw_psum*8-1 : bw_psum*7])); 
  end
endmodule
