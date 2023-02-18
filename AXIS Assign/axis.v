module axi_stream ( clk,reset,s_data,s_valid,s_ready,s_last,s_wen,m_data,m_valid,m_ready,m_last,m_ren);
    input  wire                clk;
    input  wire                reset;
  //master signal
    input   wire [31:0]       s_data;
    input   wire              s_valid;
    output  reg               s_ready;
    input   wire               s_last;
    input   wire                 s_wen;
  
  //slave signal 
    output reg [31:0]         m_data;
    output  reg              m_valid;
    input  wire               m_ready;
    output reg               m_last;
    input  wire               m_ren;
  reg [31:0] s_addr=0;
  reg [31:0] m_addr=0;
  
  //creating memory
  reg [31:0] mem[10:0];
  
// enabling write and read 
  always @(posedge clk) begin
    if (!reset) begin
   s_ready = 0;
   m_valid = 0;
    end 
    else begin
        if(s_wen) 
        s_ready = m_ready;
        else if (m_ren) 
        m_valid = s_valid;
    end
  end 
  
  // writing data into memory
    always @(posedge clk) begin
      if (!reset) begin
	s_data<=0;   
      end
      else begin
         if(s_wen && s_valid && s_ready) begin
           mem[s_addr] <= s_data;
           s_addr = s_addr +1;
         end   
      end
    end

//reading data from memory
    always @(posedge clk) begin
      if (!reset) begin
      m_data  <= 0;
      end
      else begin
        if(m_ren && m_valid && m_ready) begin
          m_data <= mem[m_addr];
          m_addr = m_addr +1;
        end     
      end
     end

 //Using address as a counter to get last signal high
  always@(posedge clk) begin
    if(!reset)begin
     m_addr =0;
    end
    else if(m_ren) begin
      if(m_addr == 4)
      m_last =1; 
    end
  end
endmodule
