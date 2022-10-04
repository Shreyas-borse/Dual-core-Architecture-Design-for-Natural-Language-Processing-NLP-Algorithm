// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 

`timescale 1ns/1ps

module fullchip_tb;

parameter total_cycle = 8;   // how many streamed Q vectors will be processed
parameter bw = 8;            // Q & K vector bit precision
parameter bw_psum = 2*bw+4;  // partial sum bit precision
parameter pr = 16;           // how many products added in each dot product 
parameter col = 8;           // how many dot product units are equipped

integer qk_file ; // file handler
integer qk_scan_file ; // file handler

integer  captured_data;
integer  weight [col*pr-1:0];
`define NULL 0

integer  K0[col-1:0][pr-1:0];//sborse
integer  K1[col-1:0][pr-1:0];//sborse
integer  Q[total_cycle-1:0][pr-1:0];
integer  result0[total_cycle-1:0][col-1:0];
integer  result1[total_cycle-1:0][col-1:0];
integer  sum[total_cycle-1:0];

integer i,j,k,t,p,q,s,u, m;

reg reset = 1;
reg clk0 = 0;
reg clk1 =0;
reg [pr*bw-1:0] mem_in0;//sborse 
reg [pr*bw-1:0] mem_in1; //sborse
reg ofifo_rd = 0;
reg div =0; //sborse
wire [16:0] inst; 
reg qmem_rd = 0;
reg qmem_wr = 0; 
reg kmem_rd = 0; 
reg kmem_wr = 0;
reg pmem_rd = 0; 
reg pmem_wr = 0; 
reg execute = 0;
reg load = 0;

reg [3:0] qkmem_add = 0;
reg [3:0] pmem_add = 0;
wire hsk_comp;
//assign acc =acc; //sborse
assign inst[16] = ofifo_rd;
assign inst[15:12] = qkmem_add;
assign inst[11:8]  = pmem_add;
assign inst[7] = execute;
assign inst[6] = load;
assign inst[5] = qmem_rd;
assign inst[4] = qmem_wr;
assign inst[3] = kmem_rd;
assign inst[2] = kmem_wr;
assign inst[1] = pmem_rd;
assign inst[0] = pmem_wr;

reg mac_array_clk_en = 0;
reg sfp_row_clk_en = 0;
reg kmem_clk_en = 1;
reg qmem_clk_en = 1;


reg signed [bw_psum-1:0] temp5b0;//sborse
reg signed [bw_psum-1:0] temp5b1;//sborse

reg signed [bw_psum-1:0] temp5b0_abs;//sborse
reg signed [bw_psum-1:0] temp5b1_abs;//sborse

reg signed [bw_psum*col-1:0] temp16b0;//sborse
reg signed [bw_psum*col-1:0] temp16b1;//sborse

reg signed [bw_psum-1:0] temp16b0_split[col];//sborse
reg signed [bw_psum-1:0] temp16b1_split[col];//sborse

reg signed [bw_psum+3:0] temp16b0_denominator=0;//sborse
reg signed [bw_psum+3:0] temp16b1_denominator=0;//sborse
reg signed [bw_psum+3:0] temp_sum=0;//sborse

wire [bw_psum*col-1 :0] norm_pmem_out0;//sborse
wire [bw_psum*col-1 :0] norm_pmem_out1;//sborse


fullchip #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) fullchip_instance (
      .reset(reset),
      .clk0(clk0),
      .clk1(clk1),
      .mem_in0(mem_in0), //sborse
      .mem_in1(mem_in1), //sborse
      .inst(inst),
      .norm_pmem_out0(norm_pmem_out0), //sborse
      .norm_pmem_out1(norm_pmem_out1), //sborse
      .div(div),
      .mac_array_clk_en (mac_array_clk_en), //sumedh
      .sfp_row_clk_en (sfp_row_clk_en),
      .kmem_clk_en (kmem_clk_en), //sumedh
      .qmem_clk_en (qmem_clk_en), //sumedh
      .hsk_comp(hsk_comp)
);


initial begin 

  $dumpfile("fullchip_tb.vcd");
  $dumpvars(0,fullchip_tb);



///// Q data txt reading /////

$display("##### Q data txt reading #####");


  qk_file = $fopen("qdata.txt", "r");

  //// To get rid of first 3 lines in data file ////
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);


  for (q=0; q<total_cycle; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
          qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
          Q[q][j] = captured_data;
          //$display("%d\n", K[q][j]);
    end
  end
/////////////////////////////////




  for (q=0; q<2; q=q+1) begin
    #0.5 clk0 = 1'b0; #0.2 clk1 = 1'b0;   
    #0.5 clk0 = 1'b1; #0.2 clk1 = 1'b1;
  end




///// K data0 txt reading /////
//sborse
$display("##### K data0 txt reading #####");

  for (q=0; q<10; q=q+1) begin
    #0.5 clk0 = 1'b0;#0.2 clk1 = 1'b0;   
    #0.5 clk0 = 1'b1;#0.2 clk1 = 1'b1;   
  end

  qk_file = $fopen("kdata_core0.txt", "r");

  //// To get rid of first 4 lines in data file ////
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);




  for (q=0; q<col; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
          qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
          K0[q][j] = captured_data;
          //$display("##### %d\n", K[q][j]);
    end
  end
/////////////////////////////////

//sborse
///// K data1 txt reading /////

$display("##### K data1 txt reading #####");

  for (q=0; q<10; q=q+1) begin
    #0.5 clk0 = 1'b0;#0.2 clk1 = 1'b0;   
    #0.5 clk0 = 1'b1;#0.2 clk1 = 1'b1;   
  end
  reset = 0;

  qk_file = $fopen("kdata_core1.txt", "r");

  //// To get rid of first 4 lines in data file ////
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);




  for (q=0; q<col; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
          qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
          K1[q][j] = captured_data;
          //$display("##### %d\n", K[q][j]);
    end
  end

/////////////// Estimated result printing /////////////////


$display("\n##### Estimated multiplication result (TESTBENCH) #####");

  for (t=0; t<total_cycle; t=t+1) begin
     for (q=0; q<col; q=q+1) begin
       result0[t][q] = 0;
       result1[t][q] = 0;
     end
  end

     $display("INDEX: \t\t\t COL0, \t  COL1,\t   COL2,    COL3,    COL4,    COL5,    COL6,    COL7");
     //$display("INDEX: \t\t\t COL0, \t  COL1,\t   COL2,    COL3,    COL4,    COL5,    COL6,    COL7,  SUM_CORE  TOTAL_SUM");
  for (t=0; t<total_cycle; t=t+1) begin
     temp16b0_denominator = 0;
     temp16b1_denominator = 0;
     temp_sum = 0;
     for (q=0; q<col; q=q+1) begin
         for (k=0; k<pr; k=k+1) begin
            result0[t][q] = result0[t][q] + Q[t][k] * K0[q][k];
            result1[t][q] = result1[t][q] + Q[t][k] * K1[q][k];
         end

         temp5b0 = result0[t][q];
         temp5b1 = result1[t][q];

         temp5b0_abs = temp5b0[bw_psum-1] ? -temp5b0 : temp5b0;
         temp5b1_abs = temp5b1[bw_psum-1] ? -temp5b1 : temp5b1;

         temp16b0 = {temp16b0[139:0], temp5b0};
         temp16b1 = {temp16b1[139:0], temp5b1};

         temp16b0_split[col-1-q] = temp5b0;
         temp16b0_denominator = temp16b0_denominator + temp5b0_abs;

         temp16b1_split[col-1-q] = temp5b1;
         temp16b1_denominator = temp16b1_denominator + temp5b1_abs;

         //$display("%d", temp16b0_split[q]);
     end

     temp_sum = temp16b1_denominator + temp16b0_denominator;

     $display("CORE 0: prd @cycle%2d: %d  %d  %d  %d  %d  %d  %d  %d", t, $signed({temp16b0_split[0]/$signed(temp_sum[bw_psum+3:7])}), $signed({temp16b0_split[1]/$signed(temp_sum[bw_psum+3:7])}), $signed({temp16b0_split[2]/$signed(temp_sum[bw_psum+3:7])}), $signed({temp16b0_split[3]/$signed(temp_sum[bw_psum+3:7])}), $signed({temp16b0_split[4]/$signed(temp_sum[bw_psum+3:7])}), $signed({temp16b0_split[5]/$signed(temp_sum[bw_psum+3:7])}), $signed({temp16b0_split[6]/$signed(temp_sum[bw_psum+3:7])}), $signed({temp16b0_split[7]/$signed(temp_sum[bw_psum+3:7])})/*, temp16b0_denominator, temp_sum*/);

     $display("CORE 1: prd @cycle%2d: %d  %d  %d  %d  %d  %d  %d  %d", t, $signed({temp16b1_split[0]/$signed(temp_sum[bw_psum+3:7])}), $signed({temp16b1_split[1]/$signed(temp_sum[bw_psum+3:7])}), $signed({temp16b1_split[2]/$signed(temp_sum[bw_psum+3:7])}), $signed({temp16b1_split[3]/$signed(temp_sum[bw_psum+3:7])}), $signed({temp16b1_split[4]/$signed(temp_sum[bw_psum+3:7])}), $signed({temp16b1_split[5]/$signed(temp_sum[bw_psum+3:7])}), $signed({temp16b1_split[6]/$signed(temp_sum[bw_psum+3:7])}), $signed({temp16b1_split[7]/$signed(temp_sum[bw_psum+3:7])})/*, temp16b0_denominator, temp_sum*/);

  end

//////////////////////////////////////////////

  reset = 0;

///// Qmem writing  /////

$display("\n##### Qmem writing  #####");

  for (q=0; q<total_cycle; q=q+1) begin

    #0.5 clk0 = 1'b0;#0.2 clk1 = 1'b0;  
    qmem_wr = 1;  if (q>0) qkmem_add = qkmem_add + 1; 
    
    mem_in0[1*bw-1:0*bw] = Q[q][0];
    mem_in0[2*bw-1:1*bw] = Q[q][1];
    mem_in0[3*bw-1:2*bw] = Q[q][2];
    mem_in0[4*bw-1:3*bw] = Q[q][3];
    mem_in0[5*bw-1:4*bw] = Q[q][4];
    mem_in0[6*bw-1:5*bw] = Q[q][5];
    mem_in0[7*bw-1:6*bw] = Q[q][6];
    mem_in0[8*bw-1:7*bw] = Q[q][7];
    mem_in0[9*bw-1:8*bw] = Q[q][8];
    mem_in0[10*bw-1:9*bw] = Q[q][9];
    mem_in0[11*bw-1:10*bw] = Q[q][10];
    mem_in0[12*bw-1:11*bw] = Q[q][11];
    mem_in0[13*bw-1:12*bw] = Q[q][12];
    mem_in0[14*bw-1:13*bw] = Q[q][13];
    mem_in0[15*bw-1:14*bw] = Q[q][14];
    mem_in0[16*bw-1:15*bw] = Q[q][15];

    mem_in1[1*bw-1:0*bw] = Q[q][0];
    mem_in1[2*bw-1:1*bw] = Q[q][1];
    mem_in1[3*bw-1:2*bw] = Q[q][2];
    mem_in1[4*bw-1:3*bw] = Q[q][3];
    mem_in1[5*bw-1:4*bw] = Q[q][4];
    mem_in1[6*bw-1:5*bw] = Q[q][5];
    mem_in1[7*bw-1:6*bw] = Q[q][6];
    mem_in1[8*bw-1:7*bw] = Q[q][7];
    mem_in1[9*bw-1:8*bw] = Q[q][8];
    mem_in1[10*bw-1:9*bw] = Q[q][9];
    mem_in1[11*bw-1:10*bw] = Q[q][10];
    mem_in1[12*bw-1:11*bw] = Q[q][11];
    mem_in1[13*bw-1:12*bw] = Q[q][12];
    mem_in1[14*bw-1:13*bw] = Q[q][13];
    mem_in1[15*bw-1:14*bw] = Q[q][14];
    mem_in1[16*bw-1:15*bw] = Q[q][15];

    #0.5 clk0 = 1'b1;#0.2 clk1 = 1'b1;  

  end


  #0.5 clk0 = 1'b0;#0.2 clk1 = 1'b0;  
  qmem_wr = 0; 
  qkmem_add = 0;
  qmem_clk_en = 0;
  #0.5 clk0 = 1'b1;#0.2 clk1 = 1'b1;  
///////////////////////////////////////////

///// Kmem0 and Kmem1 writing  /////

$display("##### Kmem0 and Kmem1 writing #####");

  for (q=0; q<col; q=q+1) begin

    #0.5 clk0 = 1'b0;#0.2 clk1 = 1'b0;  
    kmem_wr = 1; if (q>0) qkmem_add = qkmem_add + 1; 
    
    mem_in0[1*bw-1:0*bw] = K0[q][0];
    mem_in0[2*bw-1:1*bw] = K0[q][1];
    mem_in0[3*bw-1:2*bw] = K0[q][2];
    mem_in0[4*bw-1:3*bw] = K0[q][3];
    mem_in0[5*bw-1:4*bw] = K0[q][4];
    mem_in0[6*bw-1:5*bw] = K0[q][5];
    mem_in0[7*bw-1:6*bw] = K0[q][6];
    mem_in0[8*bw-1:7*bw] = K0[q][7];
    mem_in0[9*bw-1:8*bw] = K0[q][8];
    mem_in0[10*bw-1:9*bw] = K0[q][9];
    mem_in0[11*bw-1:10*bw] = K0[q][10];
    mem_in0[12*bw-1:11*bw] = K0[q][11];
    mem_in0[13*bw-1:12*bw] = K0[q][12];
    mem_in0[14*bw-1:13*bw] = K0[q][13];
    mem_in0[15*bw-1:14*bw] = K0[q][14];
    mem_in0[16*bw-1:15*bw] = K0[q][15];


    mem_in1[1*bw-1:0*bw] = K1[q][0];
    mem_in1[2*bw-1:1*bw] = K1[q][1];
    mem_in1[3*bw-1:2*bw] = K1[q][2];
    mem_in1[4*bw-1:3*bw] = K1[q][3];
    mem_in1[5*bw-1:4*bw] = K1[q][4];
    mem_in1[6*bw-1:5*bw] = K1[q][5];
    mem_in1[7*bw-1:6*bw] = K1[q][6];
    mem_in1[8*bw-1:7*bw] = K1[q][7];
    mem_in1[9*bw-1:8*bw] = K1[q][8];
    mem_in1[10*bw-1:9*bw] = K1[q][9];
    mem_in1[11*bw-1:10*bw] = K1[q][10];
    mem_in1[12*bw-1:11*bw] = K1[q][11];
    mem_in1[13*bw-1:12*bw] = K1[q][12];
    mem_in1[14*bw-1:13*bw] = K1[q][13];
    mem_in1[15*bw-1:14*bw] = K1[q][14];
    mem_in1[16*bw-1:15*bw] = K1[q][15];

    #0.5 clk0 = 1'b1;#0.2 clk1 = 1'b1;  

  end

  #0.5 clk0 = 1'b0;#0.2 clk1 = 1'b0;  
  kmem_wr = 0;  
  qkmem_add = 0;
  kmem_clk_en = 0;
  #0.5 clk0 = 1'b1;#0.2 clk1 = 1'b1;  
  mac_array_clk_en = 1;
///////////////////////////////////////////
//sborse

  for (q=0; q<2; q=q+1) begin
    #0.5 clk0 = 1'b0;#0.2 clk1 = 1'b0;  
    #0.5 clk0 = 1'b1;#0.2 clk1 = 1'b1;   
  end




/////  K data loading  /////
  kmem_clk_en = 1;
$display("##### K data loading to processor #####");

  for (q=0; q<col+1; q=q+1) begin
    #0.5 clk0 = 1'b0;#0.2 clk1 = 1'b0;  
    load = 1; 
    if (q==1) kmem_rd = 1;
    if (q>1) begin
       qkmem_add = qkmem_add + 1;
    end

    #0.5 clk0 = 1'b1;#0.2 clk1 = 1'b1;  
  end

  #0.5 clk0 = 1'b0;#0.2 clk1 = 1'b0;  
  kmem_rd = 0; qkmem_add = 0;
  kmem_clk_en = 0;
  #0.5 clk0 = 1'b1;#0.2 clk1 = 1'b1;  

  #0.5 clk0 = 1'b0;#0.2 clk1 = 1'b0;  
  load = 0; 
  #0.5 clk0 = 1'b1;#0.2 clk1 = 1'b1;  

///////////////////////////////////////////

 for (q=0; q<10; q=q+1) begin
    #0.5 clk0 = 1'b0;#0.2 clk1 = 1'b0;   
    #0.5 clk0 = 1'b1;#0.2 clk1 = 1'b1;   
 end





  qmem_clk_en = 1;
///// execution  /////
$display("##### execute #####");

  for (q=0; q<total_cycle+2; q=q+1) begin
    #0.5 clk0 = 1'b0;#0.2 clk1 = 1'b0;  
    execute = 1; 
    qmem_rd = 1;

    if (q>0) begin
       qkmem_add = qkmem_add + 1;
    end

    #0.5 clk0 = 1'b1;#0.2 clk1 = 1'b1;  
  end

  #0.5 clk0 = 1'b0;#0.2 clk1 = 1'b0;  
  qmem_rd = 0; qkmem_add = 0; execute = 0;
  #0.5 clk0 = 1'b1;#0.2 clk1 = 1'b1;  


///////////////////////////////////////////

 for (q=0; q<8; q=q+1) begin
    #0.5 clk0 = 1'b0;#0.2 clk1 = 1'b0;;  
    #0.5 clk0 = 1'b1;#0.2 clk1 = 1'b1;;   
 end

 mac_array_clk_en = 0;
 qmem_clk_en = 0;
 sfp_row_clk_en = 1; 

////////////// output fifo rd and wb to psum mem ///////////////////

$display("##### move ofifo to pmem #####");

  for (q=0; q<total_cycle*2; q=q+1) begin
    #0.5 clk0 = 1'b0;#0.2 clk1 = 1'b0;  

	  if(q%2 == 1)
        ofifo_rd = 1; 
	  else
        ofifo_rd = 0; 


    #0.5 clk0 = 1'b1;#0.2 clk1 = 1'b1;  
  end

  #0.5 clk0 = 1'b0;#0.2 clk1 = 1'b0;  
  //pmem_wr = 0; pmem_add = 0; 
  ofifo_rd = 0;
  //acc =0;//sborse
  #0.5 clk0 = 1'b1;#0.2 clk1 = 1'b1;  

////////////////////div for sfp (MCP-2 for divider); writeback to norm_psum_mem ///////////////////////

//  #0.5 clk0 = 1'b0;#0.2 clk1 = 1'b0;  

$display("\nINDEX: \t\t\t\t\t\t\t COL0, \t COL1,\t COL2,   COL3,   COL4,   COL5,   COL6,   COL7");
$display("##### Dual Core Simulation Result #####");

  for (i = 0; i<4; i=i+1) begin
	#0.5 clk0 = 1'b0;#0.2 clk1 = 1'b0;
	#0.5 clk0 = 1'b1;#0.2 clk1 = 1'b1; end
    
  for (i=1; i<1+total_cycle*7; i=i+1) begin
	#0.5 clk0 = 1'b0;#0.2 clk1 = 1'b0;
    pmem_wr = 1; 
         //$display("Memory write to NORM_PSUM mem add %x %x ", pmem_add, norm_pmem_out); 
	  if(i%6 == 0) begin
		  div =1;
          //$display("Counter %d ", i); 
            if (i>7) begin
               pmem_add = pmem_add + 1;
            end
	  end
	  else begin
		  div =0;
	  end
	#0.5 clk0 = 1'b1;#0.2 clk1 = 1'b1;
  end

  #0.5 clk0 = 1'b0;#0.2 clk1 = 1'b0;  
  #0.5 clk0 = 1'b1;#0.2 clk1 = 1'b1;
  #0.5 clk0 = 1'b0;#0.2 clk1 = 1'b0;  
  div =0;
  pmem_wr = 0; 

  $display("###############-----END-----#############");
  #10 $finish;

end

endmodule




