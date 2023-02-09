`include "master.v"
`include "slave1.v"
`include "slave2.v"



`timescale 1ns/1ns



module APB_Protocol(
                 input PCLK,PRESETn,transfer,READ_WRITE,
                 input [8:0] apb_write_paddr,
		 input [7:0]apb_write_data,
		 input [8:0] apb_read_paddr,
		 output PSLVERR, 
                 output [7:0] apb_read_data_out
          );

       wire [7:0]PWDATA,PRDATA,PRDATA1,PRDATA2;
       wire [8:0]PADDR;

       wire PREADY,PREADY1,PREADY2,PENABLE,PSEL1,PSEL2,PWRITE;
    
      
     //  assign PREADY = READ_WRITE ? (apb_read_paddr[8] ? PREADY2 : PREADY1) : (apb_write_paddr[8] ? PREADY2 : PREADY1);
        assign PREADY = PADDR[8] ? PREADY2 : PREADY1 ;
        assign PRDATA = READ_WRITE ? (PADDR[8] ? PRDATA2 : PRDATA1) : 8'dx ;
       // assign PRDATA = READ_WRITE ? (apb_read_paddr[8] ? PRDATA2 : PRDATA1) : 16'dx;

       master_bridge dut_mas(
	             apb_write_paddr,
		     apb_read_paddr,
		     apb_write_data,
		     PRDATA,         
	             PRESETn,
		     PCLK,
		     READ_WRITE,
		     transfer,
		     PREADY,
	             PSEL1,
		     PSEL2,
		     PENABLE,
	             PADDR,
	             PWRITE,
	             PWDATA,
		     apb_read_data_out,
		     PSLVERR
	               ); 


      slave1 dut1(  PCLK,PRESETn, PSEL1,PENABLE,PWRITE, PADDR[7:0],PWDATA, PRDATA1, PREADY1 );

      slave2 dut2(  PCLK,PRESETn, PSEL2,PENABLE,PWRITE, PADDR[7:0],PWDATA, PRDATA2, PREADY2 );
      


endmodule


//***************MASTER************//
`timescale 1ns/1ns

module master_bridge(
	input [8:0]apb_write_paddr,apb_read_paddr,
	input [7:0] apb_write_data,PRDATA,         
	input PRESETn,PCLK,READ_WRITE,transfer,PREADY,
	output PSEL1,PSEL2,
	output reg PENABLE,
	output reg [8:0]PADDR,
	output reg PWRITE,
	output reg [7:0]PWDATA,apb_read_data_out,
	output PSLVERR ); 
       // integer i,count;
   
  reg [2:0] state, next_state;

  reg invalid_setup_error,
      setup_error,
      invalid_read_paddr,
      invalid_write_paddr,
      invalid_write_data ;
  
  localparam IDLE = 3'b001, SETUP = 3'b010, ENABLE = 3'b100 ;


  always @(posedge PCLK)
  begin
	if(!PRESETn)
		state <= IDLE;
	else
		state <= next_state; 
  end

  always @(state,transfer,PREADY)

  begin
	if(!PRESETn)
	  next_state = IDLE;
	else
          begin
             PWRITE = ~READ_WRITE;
	     case(state)
                  
		     IDLE: begin 
		              PENABLE =0;

		            if(!transfer)
	        	      next_state = IDLE ;
	                    else
			      next_state = SETUP;
	                   end

	       	SETUP:   begin
			    PENABLE =0;

			    if(READ_WRITE) 
				 //     @(posedge PCLK)
	                       begin   PADDR = apb_read_paddr; end
			    else 
			      begin   
			          //@(posedge PCLK)
                                  PADDR = apb_write_paddr;
				  PWDATA = apb_write_data;  end
			    
			    if(transfer && !PSLVERR)
			      next_state = ENABLE;
		            else
           	              next_state = IDLE;
		           end

	       	ENABLE: 
		     begin if(PSEL1 || PSEL2)
		           PENABLE =1;
			   if(transfer & !PSLVERR)
			   begin
				   if(PREADY)
				   begin
					if(!READ_WRITE)
				         begin
				          
					   next_state = SETUP; end
					else 
					   begin
					   next_state = SETUP; 
				          	   
                                           apb_read_data_out = PRDATA; 
					   end
			            end
				    else next_state = ENABLE;
		              end
		             else next_state = IDLE;
			 end
			   
		        /* if(transfer && !PREADY && READ_WRITE)
                             begin
                              //   repeat(3) @(posedge PCLK)  
                		// begin
			          //  if(!transfer)
                                    //  next_state = IDLE;
		                    //else 
                                      // begin
                                        //if(PREADY) begin
                                          //  next_state = SETUP;
                                            //apb_read_data_out = PRDATA; end
                                        //else
                                            next_state = ENABLE;
				       //end 
                                end
		            end
                       else if(transfer && PREADY && READ_WRITE )
                                 begin
			           apb_read_data_out = PRDATA; 
                                   next_state = SETUP; 
			         end
                                                    
		       else if(transfer && !PREADY && !READ_WRITE)
                                   begin
                                   //   repeat(3) @(posedge PCLK)                                          
			             //   begin
			               // if(!transfer)
                                    //     next_state = IDLE;
				      //  else begin
				        //  if(PREADY) 
					  //   next_state = SETUP;
				          //else
						  next_state = ENABLE;
				         end
			             end 
			     end  
					   
                       else if(transfer && PREADY && !READ_WRITE )
			     begin
                                   next_state = SETUP; 
                                  $strobe($time," Enable write operation"); end   */
                             
                       
                                 default: next_state = IDLE; 
               	endcase
             end
          end


 /*     always @(posedge PCLK) 
      begin
	       PWRITE = ~READ_WRITE;
	      case(state)
		      IDLE: begin
			     
			      PENABLE = 0;
		             end
		      SETUP: begin
			      PENABLE =0;
			      if(READ_WRITE) 
				//  @(posedge PCLK)
			          PADDR = apb_read_paddr;
			      else 
			         //@(posedge PCLK)
                                  PADDR = apb_write_paddr;
				  PWDATA = apb_write_data;
			     end
		      ENABLE: begin
			      PENABLE =1;
		             end
	      endcase
      end */
     assign {PSEL1,PSEL2} = ((state != IDLE) ? (PADDR[8] ? {1'b0,1'b1} : {1'b1,1'b0}) : 2'd0);

  // PSLVERR LOGIC
  
  always @(*)
       begin
        if(!PRESETn)
	    begin 
	     setup_error =0;
	     invalid_read_paddr = 0;
	     invalid_write_paddr = 0;
	     invalid_write_paddr =0 ;
	    end
        else
	 begin	
          begin
	  if(state == IDLE && next_state == ENABLE)
   		  setup_error = 1;
	  else setup_error = 0;
          end
          begin
          if((apb_write_data===8'dx) && (!READ_WRITE) && (state==SETUP || state==ENABLE))
		  invalid_write_data =1;
	  else invalid_write_data = 0;
          end
          begin
	  if((apb_read_paddr===9'dx) && READ_WRITE && (state==SETUP || state==ENABLE))
		  invalid_read_paddr = 1;
	  else  invalid_read_paddr = 0;
          end
          begin
          if((apb_write_paddr===9'dx) && (!READ_WRITE) && (state==SETUP || state==ENABLE))
		  invalid_write_paddr =1;
          else invalid_write_paddr =0;
          end
          begin
	  if(state == SETUP)
            begin
                 if(PWRITE)
                      begin
                         if(PADDR==apb_write_paddr && PWDATA==apb_write_data)
                              setup_error=1'b0;
                         else
                               setup_error=1'b1;
                       end
                 else 
                       begin
                          if (PADDR==apb_read_paddr)
                                 setup_error=1'b0;
                          else
                                 setup_error=1'b1;
                       end    
              end 
          
         else setup_error=1'b0;
         end 
       end
       invalid_setup_error = setup_error ||  invalid_read_paddr || invalid_write_data || invalid_write_paddr  ;
     end 

   assign PSLVERR =  invalid_setup_error ;

	 

 endmodule


//****************SLAVE**************//
//****************SLAVE1*************//
`timescale 1ns/1ns



module slave1(
         input PCLK,PRESETn,
         input PSEL,PENABLE,PWRITE,
         input [7:0]PADDR,PWDATA,
        output [7:0]PRDATA1,
        output reg PREADY );
    
     reg [7:0]reg_addr;
     reg [7:0] mem [0:63];

    assign PRDATA1 =  mem[reg_addr];

    always @(*)
       begin
         if(!PRESETn)
              PREADY = 0;
          else
	  if(PSEL && !PENABLE && !PWRITE)
	     begin PREADY = 0; end
	         
	  else if(PSEL && PENABLE && !PWRITE)
	     begin  PREADY = 1;
                    reg_addr =  PADDR; 
	       end
          else if(PSEL && !PENABLE && PWRITE)
	     begin  PREADY = 0; end

	  else if(PSEL && PENABLE && PWRITE)
	     begin  PREADY = 1;
	            mem[PADDR] = PWDATA; end

           else PREADY = 0;
        end
endmodule


//****************SLAVE**************//
//****************SLAVE2*************//

`timescale 1ns/1ns



module slave2(
         input PCLK,PRESETn,
         input PSEL,PENABLE,PWRITE,
         input [7:0]PADDR,PWDATA,
        output [7:0]PRDATA2,
        output reg PREADY );
    
     reg [7:0]reg_addr;

     reg [7:0] mem2 [0:63];

    assign PRDATA2 =  mem2[reg_addr];



    always @(*)
       begin
         if(!PRESETn)
              PREADY = 0;
          else
	  if(PSEL && !PENABLE && !PWRITE)
	     begin PREADY = 0; end
	         
	  else if(PSEL && PENABLE && !PWRITE)
	     begin  PREADY = 1;
                    reg_addr =  PADDR; 
	       end
          else if(PSEL && !PENABLE && PWRITE)
	     begin  PREADY = 0; end

	  else if(PSEL && PENABLE && PWRITE)
	     begin  PREADY = 1;
	            mem2[PADDR] = PWDATA; end

           else PREADY = 0;
        end
endmodule
