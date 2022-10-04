// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
// HW5 ShreyasBorse PID A59009564. 
module mac_16in (out, a, b, clk, reset);

parameter bw = 8;
parameter bw_psum = 2*bw+4;
parameter pr = 16; // parallel factor: number of inputs = 64

output [bw_psum-1:0] out;
input  [pr*bw-1:0] a;
input  [pr*bw-1:0] b;
input  clk, reset;

reg [2*bw-1:0] q0 ,q1, q2, q3, q4, q5, q6, q7, q8, q9, q10, q11, q12, q13, q14, q15;
reg [bw_psum-1:0] out_sub_0_3, out_sub_4_7, out_sub_8_11, out_sub_12_15;

wire		[2*bw-1:0]	product0	;
wire		[2*bw-1:0]	product1	;
wire		[2*bw-1:0]	product2	;
wire		[2*bw-1:0]	product3	;
wire		[2*bw-1:0]	product4	;
wire		[2*bw-1:0]	product5	;
wire		[2*bw-1:0]	product6	;
wire		[2*bw-1:0]	product7	;
wire		[2*bw-1:0]	product8	;
wire	    [2*bw-1:0]	product9	;
wire		[2*bw-1:0]	product10	;
wire		[2*bw-1:0]	product11	;
wire		[2*bw-1:0]	product12	;
wire		[2*bw-1:0]	product13	;
wire		[2*bw-1:0]	product14	;
wire		[2*bw-1:0]	product15	;


genvar i;


assign	product0	=	{{(bw){a[bw*	1	-1]}},	a[bw*	1	-1:bw*	0	]}	*	{{(bw){b[bw*	1	-1]}},	b[bw*	1	-1:	bw*	0	]};
assign	product1	=	{{(bw){a[bw*	2	-1]}},	a[bw*	2	-1:bw*	1	]}	*	{{(bw){b[bw*	2	-1]}},	b[bw*	2	-1:	bw*	1	]};
assign	product2	=	{{(bw){a[bw*	3	-1]}},	a[bw*	3	-1:bw*	2	]}	*	{{(bw){b[bw*	3	-1]}},	b[bw*	3	-1:	bw*	2	]};
assign	product3	=	{{(bw){a[bw*	4	-1]}},	a[bw*	4	-1:bw*	3	]}	*	{{(bw){b[bw*	4	-1]}},	b[bw*	4	-1:	bw*	3	]};
assign	product4	=	{{(bw){a[bw*	5	-1]}},	a[bw*	5	-1:bw*	4	]}	*	{{(bw){b[bw*	5	-1]}},	b[bw*	5	-1:	bw*	4	]};
assign	product5	=	{{(bw){a[bw*	6	-1]}},	a[bw*	6	-1:bw*	5	]}	*	{{(bw){b[bw*	6	-1]}},	b[bw*	6	-1:	bw*	5	]};
assign	product6	=	{{(bw){a[bw*	7	-1]}},	a[bw*	7	-1:bw*	6	]}	*	{{(bw){b[bw*	7	-1]}},	b[bw*	7	-1:	bw*	6	]};
assign	product7	=	{{(bw){a[bw*	8	-1]}},	a[bw*	8	-1:bw*	7	]}	*	{{(bw){b[bw*	8	-1]}},	b[bw*	8	-1:	bw*	7	]};
assign	product8	=	{{(bw){a[bw*	9	-1]}},	a[bw*	9	-1:bw*	8	]}	*	{{(bw){b[bw*	9	-1]}},	b[bw*	9	-1:	bw*	8	]};
assign	product9	=	{{(bw){a[bw*	10	-1]}},	a[bw*	10	-1:bw*	9	]}	*	{{(bw){b[bw*	10	-1]}},	b[bw*	10	-1:	bw*	9	]};
assign	product10	=	{{(bw){a[bw*	11	-1]}},	a[bw*	11	-1:bw*	10	]}	*	{{(bw){b[bw*	11	-1]}},	b[bw*	11	-1:	bw*	10	]};
assign	product11	=	{{(bw){a[bw*	12	-1]}},	a[bw*	12	-1:bw*	11	]}	*	{{(bw){b[bw*	12	-1]}},	b[bw*	12	-1:	bw*	11	]};
assign	product12	=	{{(bw){a[bw*	13	-1]}},	a[bw*	13	-1:bw*	12	]}	*	{{(bw){b[bw*	13	-1]}},	b[bw*	13	-1:	bw*	12	]};
assign	product13	=	{{(bw){a[bw*	14	-1]}},	a[bw*	14	-1:bw*	13	]}	*	{{(bw){b[bw*	14	-1]}},	b[bw*	14	-1:	bw*	13	]};
assign	product14	=	{{(bw){a[bw*	15	-1]}},	a[bw*	15	-1:bw*	14	]}	*	{{(bw){b[bw*	15	-1]}},	b[bw*	15	-1:	bw*	14	]};
assign	product15	=	{{(bw){a[bw*	16	-1]}},	a[bw*	16	-1:bw*	15	]}	*	{{(bw){b[bw*	16	-1]}},	b[bw*	16	-1:	bw*	15	]};

always@(posedge clk, posedge reset)
begin
    if (reset) begin
	    q0              <= 0;
	    q1              <= 0;
	    q2              <= 0;
	    q3              <= 0;
	    q4              <= 0;
	    q5              <= 0;
	    q6              <= 0;
	    q7              <= 0;
	    q8              <= 0;
	    q9              <= 0;
	    q10             <= 0;
	    q11             <= 0;
	    q12             <= 0;
	    q13             <= 0;
	    q14             <= 0;
	    q15             <= 0;
        out_sub_0_3     <= 0;
        out_sub_4_7     <= 0;
        out_sub_8_11    <= 0;
        out_sub_12_15   <= 0;
    end
    else begin
	    q0              <= product0;
	    q1              <= product1;
	    q2              <= product2;
	    q3              <= product3;
	    q4              <= product4;
	    q5              <= product5;
	    q6              <= product6;
	    q7              <= product7;
	    q8              <= product8;
	    q9              <= product9;
	    q10             <= product10;
	    q11             <= product11;
	    q12             <= product12;
	    q13             <= product13;
	    q14             <= product14;
	    q15             <= product15;
        out_sub_0_3     <= {{(4){q0[2*bw-1]}},q0}     + {{(4){q1[2*bw-1]}},q1}    + {{(4){q2[2*bw-1]}},q2}    + {{(4){q3[2*bw-1]}},q3};
        out_sub_4_7     <= {{(4){q4[2*bw-1]}},q4}     + {{(4){q5[2*bw-1]}},q5}    + {{(4){q6[2*bw-1]}},q6}    + {{(4){q7[2*bw-1]}},q7};
        out_sub_8_11    <= {{(4){q8[2*bw-1]}},q8}     + {{(4){q9[2*bw-1]}},q9}    + {{(4){q10[2*bw-1]}},q10}  + {{(4){q11[2*bw-1]}},q11};
        out_sub_12_15   <= {{(4){q12[2*bw-1]}},q12}   + {{(4){q13[2*bw-1]}},q13}  + {{(4){q14[2*bw-1]}},q14}  + {{(4){q15[2*bw-1]}},q15};
    end
end

assign out = 
                {{(4){out_sub_0_3[bw_psum-1]}}  , out_sub_0_3}
	        +	{{(4){out_sub_4_7[bw_psum-1]}}  , out_sub_4_7}
	        +	{{(4){out_sub_8_11[bw_psum-1]}} , out_sub_8_11}
	        +	{{(4){out_sub_12_15[bw_psum-1]}}, out_sub_12_15};

endmodule
