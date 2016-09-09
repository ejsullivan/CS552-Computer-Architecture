module fetch_unit(clk, rst, isFlush, isAllStall, memStall, memDone, pcNext, instr, pcPlusTwo, fetchMemErr);
	input clk, rst, isFlush, isAllStall, memStall, memDone;
	input [15:0] pcNext;
	output fetchMemErr;
	output [15:0] instr;
	output [15:0] pcPlusTwo;

	wire [15:0] instr_intermediate;
	wire [15:0] pcCurrent;
	wire [15:0] offset;
	wire [15:0] pcPlusTwoPlusOffset;
	wire [15:0] pcNotJR, instr_intermediate_flopped;

	assign fetchMemErr = 0;

	//memory2c instructionMemory(.data_out(instr_intermediate), .data_in(16'h0000), .addr(pcCurrent), .enable(1'b1), .wr(1'b0), .createdump(1'b0), .clk(clk), .rst(rst));
	dff dff0(.q(rst_flopped), .d(1'b1), .clk(clk), .rst(rst));
	mem_system instructionMemory(
   	   // Outputs
   	   .DataOut(instr_intermediate), .Done(fetchMemDone), .Stall(fetchMemStall), .CacheHit(CacheHit), .err(fetchMemErr), 
   	   // Inputs
   	   .Addr(pcCurrent), .DataIn(16'h0000), .Rd(!rst && !memStall), .Wr(1'b0), .createdump(1'b0), .clk(clk), .rst(rst)
   	);
	claAdder16 PCadder0(.A(pcCurrent), .B(16'h0002), .CIN(1'b0), .SUM(pcPlusTwo), .CO(IAlsoDontCare));

	register PC(.dataOut(pcCurrent), .dataIn(isFlush ? pcNext : (fetchMemDone && !memStall ? pcPlusTwo : pcCurrent)), .clk(clk), .rst(rst), .w_en((fetchMemDone || isFlush) && !memStall)); // when isFlush is high, it should flush even though stall is high; basically, isFlush takes priority

	register instr_intermediate_reg(.dataOut(instr_intermediate_flopped), .dataIn(instr_intermediate), .clk(clk), .rst(rst), .w_en(!memStall)); 

	//assign instr2 = rst || !fetchMemDone ? 16'h0800 : instr_intermediate;
	//assign instr = memStall ? instr_intermediate_flopped : (rst || !fetchMemDone ? 16'h0800 : instr_intermediate);
	assign instr = rst || !fetchMemDone ? 16'h0800 : instr_intermediate;
endmodule
