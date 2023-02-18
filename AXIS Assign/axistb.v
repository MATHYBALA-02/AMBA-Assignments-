`timescale 1ns/100ps
module axis_fifo_tb;
//parameters

parameter DATA_WIDTH = 8;
parameter ADDR_DEPTH = 4;

//inputs and outputs

reg m_aclk;
reg m_areset_n;
reg[DATA_WIDTH-1:0] m_data;
reg m_valid;
wire m_ready;
reg m_last;

reg s_aclk;
reg s_areset_n;
wire[DATA_WIDTH-1:0] s_data;
wire s_valid;
reg s_ready;
wire s_last;


initial begin
$dumpfile("waves_fifo.vcd");
	$dumpvars;
end


axis_fifo dut(
.m_aclk(m_aclk),
.m_areset_n(m_areset_n),
.m_data(m_data),
.m_valid(m_valid),
.m_ready(m_ready),
.m_last(m_last),
.s_aclk(s_aclk),
.s_areset_n(s_areset_n),
.s_ready(s_ready),
.s_valid(s_valid),
.s_last(s_last),
.s_data(s_data));

task write();
begin
m_data = $random;
m_valid=1;


#5;
m_valid=0;


end
endtask


task read();
begin
s_ready =1;

#5

s_ready = 0;

end
endtask


initial begin

m_aclk=0;
s_aclk=0;
forever #5 m_aclk = ~m_aclk;
forever #5 s_aclk = ~s_aclk;
end

initial begin

m_areset_n = 1;
s_areset_n = 1;


repeat(8)begin
write();
end
m_last=1;

repeat(8) 
begin
read();
end

$finish;

end
endmodule

