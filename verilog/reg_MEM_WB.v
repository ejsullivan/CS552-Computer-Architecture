module reg_MEM_WB (
	// outputs
	instr_WB, MemToReg_WB, aluResult_WB, writeData_WB,
	// outputs due to pipelining
	RegDist_WB, RegWrite_WB, isJAL_WB, writeregsel_WB, pcPlusTwo_WB, RegWrite_WB_intermediate_for_forwarding, 
	// inputs
	clk, rst, MemToReg_MEM, aluResult_MEM, writeData_MEM,
	// inputs due to pipelining
	RegDist_MEM, RegWrite_MEM, isJAL_MEM, writeregsel_MEM, pcPlusTwo_MEM, instr_MEM, isAllStall, memDone, isData1BypassFromWB, isData2BypassFromWB, memStall
	);

	// inputs
	input clk, rst, MemToReg_MEM, isAllStall, memDone, isData1BypassFromWB, isData2BypassFromWB, memStall;
	input [15:0] instr_MEM, aluResult_MEM, writeData_MEM;
	// inputs due to pipelining
	input RegDist_MEM, RegWrite_MEM, isJAL_MEM;
	input [2:0] writeregsel_MEM;
	input [15:0] pcPlusTwo_MEM;
	// outputs
	output MemToReg_WB;
	output [15:0] aluResult_WB, writeData_WB;
	// outputs due to pipelining
	output RegDist_WB, RegWrite_WB, isJAL_WB, RegWrite_WB_intermediate_for_forwarding;
	output [2:0] writeregsel_WB;
	output [15:0] instr_WB, pcPlusTwo_WB;
	
	register register0(.dataOut(aluResult_WB), .dataIn(aluResult_MEM), .clk(clk), .rst(rst), .w_en(!memStall || memDone));
	register register1(.dataOut(writeData_WB), .dataIn(writeData_MEM), .clk(clk), .rst(rst), .w_en(!memStall || memDone));
	register register2(.dataOut(pcPlusTwo_WB), .dataIn(pcPlusTwo_MEM), .clk(clk), .rst(rst), .w_en(!memStall || memDone));
	register register3(.dataOut(instr_WB), .dataIn(instr_MEM), .clk(clk), .rst(rst), .w_en(!memStall || memDone)); // TODO not sure why it doesnt have  || memDone

	dff dff0(.q(MemToReg_WB), .d(!memStall || memDone ? MemToReg_MEM : MemToReg_WB), .clk(clk), .rst(rst));

	dff dff1(.q(RegDist_WB), .d(!memStall || memDone ? RegDist_MEM : RegDist_WB), .clk(clk), .rst(rst));
	dff dff2(.q(RegWrite_WB), .d(!memStall || memDone ? RegWrite_MEM : RegWrite_WB && (!memStall || memDone)), .clk(clk), .rst(rst));
	dff dff2b(.q(RegWrite_WB_intermediate_for_forwarding), .d(!memStall || memDone ? RegWrite_MEM : RegWrite_WB_intermediate_for_forwarding), .clk(clk), .rst(rst));
	dff dff3(.q(isJAL_WB), .d(!memStall || memDone ? isJAL_MEM : isJAL_WB), .clk(clk), .rst(rst));
	dff dff4(.q(writeregsel_WB[0]), .d(!memStall || memDone ? writeregsel_MEM[0] : writeregsel_WB[0]), .clk(clk), .rst(rst));
	dff dff5(.q(writeregsel_WB[1]), .d(!memStall || memDone ? writeregsel_MEM[1] : writeregsel_WB[1]), .clk(clk), .rst(rst));
	dff dff6(.q(writeregsel_WB[2]), .d(!memStall || memDone ? writeregsel_MEM[2] : writeregsel_WB[2]), .clk(clk), .rst(rst));

endmodule
