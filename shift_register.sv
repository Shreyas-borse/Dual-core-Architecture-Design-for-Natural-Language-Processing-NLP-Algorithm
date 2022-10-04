module shift_register #(
 parameter integer WIDTH=32, 
 parameter integer NUM_OF_STAGES=2,
 parameter logic[WIDTH-1:0] RESET_VALUE=0) 
(
  input wire  clk, reset, 
  input wire  [WIDTH-1:0] d,
  output wire  [WIDTH-1:0] q
);

integer i;
 reg[WIDTH-1:0] r[NUM_OF_STAGES-1:0];

generate
 always @ (posedge clk, posedge reset) begin
  if(reset == 1) begin
    for(i=0; i<NUM_OF_STAGES; i=i+1) begin:loop1
        r[i] <= RESET_VALUE;
    end 
  end
  else begin
    r[0] <= d;
    for(i=0; i<(NUM_OF_STAGES-1); i=i+1) begin:loop2
      r[i+1] <= r[i];
    end
  end
 end
endgenerate

 assign q = (reset==1) ? RESET_VALUE : r[NUM_OF_STAGES-1];
endmodule


/*
module two_ff_synchronizer#(parameter WIDTH=2) 
(
  input logic clk, reset, 
  input logic [WIDTH-1:0] d,
  output logic [WIDTH-1:0] q
);

 logic[WIDTH-1:0] temp;
 always_ff@(posedge clk, posedge reset) begin
   if(reset == 1) begin
      temp <= 0;
      q <= 0;
   end
   else begin
     temp <= d;
     q <= temp; 
   end 
 end 
endmodule
*/

