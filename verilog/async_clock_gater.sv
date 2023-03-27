module async_clock_gater (
input wire clk, async_clk_en,
output wire gated_clk, 
output reg gated_clk_is_on
);

reg clk_en_sync, clk_en_ff1, clk_en_latch;
wire inv_clk;

//2FF synchronizer
always @ (posedge clk)
begin
	clk_en_ff1  <= async_clk_en;
	clk_en_sync <= clk_en_ff1;
	gated_clk_is_on <= clk_en_latch;
end

assign inv_clk = ~clk;

always @ (*)
begin
	if (inv_clk)
		clk_en_latch = async_clk_en;
end

assign gated_clk = clk & clk_en_latch;

endmodule
