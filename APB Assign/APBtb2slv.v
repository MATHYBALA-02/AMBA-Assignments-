
`timescale 1ns/100ps


  module test;
 
  reg PCLK,PRESETn,transfer,READ_WRITE;
  reg [8:0]apb_write_paddr;
  reg [7:0]apb_write_data;
  reg [8:0]apb_read_paddr;
  wire [7:0]apb_read_data_out;
  wire PSLVERR;
  reg [7:0]data,expected;

  reg [7:0]mem[0:15];
  
  APB_Protocol dut_c(  PCLK,
	               PRESETn,
		       transfer,
		       READ_WRITE,
                       apb_write_paddr,
		       apb_write_data,
		       apb_read_paddr,
		       PSLVERR, 
                       apb_read_data_out
	                 );
  integer i,j;
  initial
   begin
    PCLK <= 0;
    forever #5 PCLK = ~PCLK;
   end

    initial
    begin
                                    PRESETn<=0; transfer<=0; READ_WRITE =0;
               @(posedge PCLK)      PRESETn = 1;                                     //no write address available but request for write operation
               @(posedge PCLK)      transfer = 1;
     repeat(2) @(posedge PCLK);
               @(negedge PCLK)      Write_slave1;        // write operation

   //            @(posedge PCLK);    apb_write_paddr = 9'd526;  apb_write_data = 9'd9;
    // repeat(2) @(posedge PCLK);    apb_write_paddr = 9'd22; apb_write_data = 9'd35;
     repeat(2) @(posedge PCLK);
               @(posedge PCLK)     READ_WRITE =1; PRESETn<=0; transfer<=0; 
               @(posedge PCLK)     PRESETn = 1;
     repeat(3) @(posedge PCLK)     transfer = 1;                             // no read address available but request for read operation
     repeat(2) @(posedge PCLK)     Read_slave1;                             //read operation

     repeat(3) @(posedge PCLK);   apb_read_paddr = 9'd45;                 //data not inserted in write operation but requested for read operation
     repeat(4) @(posedge PCLK);
  end

    task Write_slave1;

     begin
 	transfer =1;
	for (i = 0; i < 8; i=i+1) begin
	repeat(2)@(negedge PCLK)
        begin    
             	data = i;
		apb_write_data = 2*i;
		apb_write_paddr =  {1'b0,data};
	//	mem[i] = (2*i);
                
	 end 
	end

     end
endtask

		 
  task Read_slave1;
     

      begin 
	for (j = 0;  j< 8; j= j+1)
        begin
	repeat(2)@(negedge PCLK)
          begin  
	  data = j; 
	  apb_read_paddr = {1'b0,data};

         end
        end
      end
  endtask
  
  
  task Write_slave2;

     begin
 	transfer =1;
	for (i = 0; i < 8; i=i+1) begin
	repeat(2)@(negedge PCLK)
        begin    
             	data = i;
		apb_write_data = 2*i;
		apb_write_paddr =  {1'b0,data};
	//	mem[i] = (2*i);
                
	 end 
	end

     end
endtask

		 
  task Read_slave2;
     

      begin 
	for (j = 0;  j< 8; j= j+1)
        begin
	repeat(2)@(negedge PCLK)
          begin  
	  data = j; 
	  apb_read_paddr = {1'b0,data};

         end
        end
      end
  endtask


    
  initial
   begin
    $dumpfile("apbWaveform.vcd");
    $dumpvars;
   end

 endmodule
