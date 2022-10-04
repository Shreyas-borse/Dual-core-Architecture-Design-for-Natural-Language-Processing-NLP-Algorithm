// Simple Dual-port Single Clock Block RAM with Synchronous Read 
module dual_port_ram #(
   parameter DATA_WIDTH=32, parameter ADDR_WIDTH=32)
(
   input wire  wr_clk, reset,
   input wire  wr_en,
   input wire [DATA_WIDTH-1:0] write_data, 
   input wire [ADDR_WIDTH-1:0] write_addr,
 
   input wire  rd_en, 
   input wire [ADDR_WIDTH-1:0] read_addr,
   output wire [DATA_WIDTH-1:0] read_data);
 
   // Two dimensional memory array 
   reg[DATA_WIDTH-1:0] mem[2**ADDR_WIDTH-1:0];

   // Synchronous write
integer i;
generate
   always @ (posedge wr_clk, posedge reset) begin 
    if(reset) begin
      for(i=0; i<(2**ADDR_WIDTH); i=i+1) begin
        mem[i] <= 0;
      end 
    end 
    else begin
      if(wr_en) mem[write_addr]  <= write_data; 
    end
   end  
endgenerate

   // Asynchronous read
   //assign read_data = (rd_en == 1) ? mem[read_addr] : 0;
   assign read_data = mem[read_addr];
endmodule
