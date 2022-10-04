//`include "dual_port_ram.sv"
//`include "shift_register.sv"
module async_fifo#(
  parameter DATA_WIDTH = 24,   // width of each data element in FIFO Memory
  parameter FIFO_DEPTH = 8)   // Number of locations in FIFO Memory
(
  input  logic wr_clk, rd_clk, // Write and Read Clocks
  input  logic reset, // Common reset             
  input  logic wr_en, // write enable, if wr_en == 1, data gets written to FIFO Memory
  input  logic rd_en, // read_enable, if rd_en == 1, data gets read out from FIFO Memory
  input  logic [DATA_WIDTH-1:0] data_in,  // Input data to be written to FIFO Memory
  output logic [DATA_WIDTH-1:0] data_out, // Data read out from FIFO Memory
  output logic fifo_full, // Indicates FIFO is full and there are no locations inside FIFO memory for further writes
  output logic fifo_empty, // Indicates FIFO is empty and there are no data available inside FIFO memory for reading
  output logic fifo_almost_full, // One cycle early indication of FIFO_FULL (fifo is not full yet, it will be next cycle)
  output logic fifo_almost_empty // One cycle early indication of FIFO_EMPTY (fifo is not empty yet, it will be next cycle)
);

 // Local parameter to set address width based on FIFO DEPTH
 localparam ADDR_WIDTH = $clog2(FIFO_DEPTH);
  
 logic [ADDR_WIDTH:0] wr_ptr, wr_ptr_gray, wr_ptr_gray2, wr_ptr_binary2;
 logic [ADDR_WIDTH:0] rd_ptr, rd_ptr_gray, rd_ptr_gray2, rd_ptr_binary2;
 logic t_fifo_empty, t_fifo_full;
 
 // If reset == 1 then assign 0 to wr_ptr
 always @ (posedge wr_clk,posedge reset) begin
   // Student to add code
   if (reset)
		wr_ptr <= 0;
   else if (wr_en)
		wr_ptr <= wr_ptr + 1;
   else
		wr_ptr <= wr_ptr;
 end
 

 assign wr_ptr_gray = binary_to_gray(wr_ptr); // Student to add code
 
  
 // If reset == 1then assign 0 to rd_ptr
 always @ (posedge rd_clk,posedge reset) begin
   if (reset)
		rd_ptr <= 0;
   else if (rd_en)
		rd_ptr <= rd_ptr + 1;
   else
		rd_ptr <= rd_ptr;
 end

 assign rd_ptr_gray =  binary_to_gray(rd_ptr);
 
 assign t_fifo_empty =  (rd_ptr==wr_ptr_binary2) ? 1 : 0;


  assign fifo_almost_empty = t_fifo_empty; 

 assign t_fifo_full  =   ( (wr_ptr[ADDR_WIDTH-1:0]==rd_ptr_binary2[ADDR_WIDTH-1:0]) && (wr_ptr[ADDR_WIDTH]!=rd_ptr_binary2[ADDR_WIDTH]) ) ? 1 : 0;
   

 assign fifo_almost_full = t_fifo_full; 
	

 dual_port_ram #(
   .DATA_WIDTH(DATA_WIDTH),
   .ADDR_WIDTH(ADDR_WIDTH)) 
 fifo_memory_inst(
     // Student to add code
  .write_addr(wr_ptr[ADDR_WIDTH-1:0]),
  .read_addr(rd_ptr[ADDR_WIDTH-1:0]),
  .write_data(data_in),
  .read_data(data_out),
  .wr_en(wr_en && !fifo_full),
  .rd_en(rd_en && !fifo_empty),
  .wr_clk(wr_clk),
  .reset(reset)

 );
 
  
 shift_register #(
  .WIDTH(ADDR_WIDTH+1), 
  .NUM_OF_STAGES(2)) 
 wr_ptr_synchronizer_inst(
  .clk(rd_clk),
  .reset(reset),
  .d(wr_ptr_gray),
  .q(wr_ptr_gray2)
 );

 assign wr_ptr_binary2 = gray_to_binary(wr_ptr_gray2); 

 shift_register #(
  .WIDTH(ADDR_WIDTH+1), 
  .NUM_OF_STAGES(2)) 
 rd_ptr_synchronizer_inst(
  .clk(wr_clk),
  .reset(reset),
  .d(rd_ptr_gray),
  .q(rd_ptr_gray2)
 );
 

 assign rd_ptr_binary2 = gray_to_binary(rd_ptr_gray2); 

 shift_register #(
  .WIDTH(1), 
  .NUM_OF_STAGES(1),   // Note : Here 2-FF synchronizer is not the intent. Only 1 cycle delayed version of t_fifo_empty is created. Hence NUM_OF_STAGES is '1' 
  .RESET_VALUE(1))  // Note : RESET_VALUE is set to '1', since by default out of reset, FIFO is in empty state.
 fifo_empty_inst(
  .clk(rd_clk),
  .reset(reset),
  .d(t_fifo_empty),
  .q(fifo_empty)
 );
 
 
 shift_register #(
  .WIDTH(1), 
  .NUM_OF_STAGES(1),    
  .RESET_VALUE(0))  // Note : RESET_VALUE is set to '1', since by default out of reset, FIFO is in empty state.
 fifo_full_inst(
  .clk(wr_clk),
  .reset(reset),
  .d(t_fifo_full),
  .q(fifo_full)
 );
 
 integer i;

 // function to convert binary to gray function
 function automatic [ADDR_WIDTH:0] binary_to_gray(logic [ADDR_WIDTH:0] value);
   begin 
     binary_to_gray[ADDR_WIDTH] = value[ADDR_WIDTH];
     for(i=ADDR_WIDTH; i>0; i = i - 1)
       binary_to_gray[i-1] = value[i] ^ value[i - 1];
    end
 endfunction

 // function to convert gray to binary  
 function logic[ADDR_WIDTH:0] gray_to_binary(logic[ADDR_WIDTH:0] value);
  begin 
     logic[ADDR_WIDTH:0] l_binary_value;
     l_binary_value[ADDR_WIDTH] = value[ADDR_WIDTH];
     for(i=ADDR_WIDTH; i>0; i = i - 1) begin
      l_binary_value[i-1] = value[i-1] ^ l_binary_value[i];
     end
     gray_to_binary = l_binary_value;
  end
 endfunction
 
endmodule



