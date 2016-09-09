module reg_EX_MEM (
	// outputs
	instr_MEM, isHalt_MEM, MemToReg_MEM, memRead_MEM, memWrite_MEM, aluResult_MEM, writeData_MEM, isLoad,
	// outputs due to pipelining
	RegDist_MEM, RegWrite_MEM, isJAL_MEM, writeregsel_MEM, pcPlusTwo_MEM,
	// inputs
	clk, rst, memStall, isForwardingStall, memDone, isHalt_EX, MemToReg_EX, memRead_EX, memWrite_EX, aluResult_EX, writeData_EX,
	// inputs due to pipelining
	RegDist_EX, RegWrite_EX, isJAL_EX, writeregsel_EX, pcPlusTwo_EX, instr_EX, dependentLoad
	);

	// inputs
	input clk, rst, memStall, isForwardingStall, memDone, isHalt_EX, MemToReg_EX, memRead_EX, memWrite_EX;
	input [15:0] instr_EX, aluResult_EX, writeData_EX;
	// inputs due to pipelining
	input RegDist_EX, RegWrite_EX, isJAL_EX, dependentLoad;
	input [2:0] writeregsel_EX;
	input [15:0] pcPlusTwo_EX;
	// outputs
	output isHalt_MEM, MemToReg_MEM, memRead_MEM, memWrite_MEM, isLoad;
	output [15:0] instr_MEM, aluResult_MEM, writeData_MEM;
	// outputs due to pipelining
	output RegDist_MEM, RegWrite_MEM, isJAL_MEM;
	output [2:0] writeregsel_MEM;
	output [15:0] pcPlusTwo_MEM;
	wire memRead_MEM_intermediate, memWrite_MEM_intermediate, RegDist_MEM_intermediate, memRead_MEM_intermediate2, memWrite_MEM_intermediate2, RegDist_MEM_intermediate2, RegWrite_MEM_intermediate;

	assign isLoad = memRead_MEM;

	register register0(.dataOut(aluResult_MEM), .dataIn(aluResult_EX), .clk(clk), .rst(rst), .w_en(!memStall && !dependentLoad || memDone));
	register register1(.dataOut(writeData_MEM), .dataIn(writeData_EX), .clk(clk), .rst(rst), .w_en(!memStall && !dependentLoad || memDone));
	register register2(.dataOut(pcPlusTwo_MEM), .dataIn(pcPlusTwo_EX), .clk(clk), .rst(rst), .w_en(!memStall && !dependentLoad || memDone));
	register register3(.dataOut(instr_MEM), .dataIn(instr_EX), .clk(clk), .rst(rst), .w_en(!memStall && !dependentLoad || memDone));
	
	dff dff0(.q(isHalt_MEM), .d(!memStall && !dependentLoad || memDone ? isHalt_EX : isHalt_MEM), .clk(clk), .rst(rst));
	dff dff1(.q(MemToReg_MEM), .d(!memStall && !dependentLoad || memDone ? MemToReg_EX : MemToReg_MEM), .clk(clk), .rst(rst));
	dff dff2(.q(memRead_MEM), .d(!memStall && !dependentLoad || memDone ? memRead_EX : memRead_MEM), .clk(clk), .rst(rst));
	//dff dff2b(.q(memRead_MEM_intermediate2), .d(memRead_MEM_intermediate), .clk(clk), .rst(rst));
	//assign memRead_MEM = memDone ? memRead_MEM_intermediate : memRead_MEM_intermediate2;
	dff dff3(.q(memWrite_MEM), .d(!memStall && !dependentLoad || memDone ? memWrite_EX : memWrite_MEM), .clk(clk), .rst(rst));
	//dff dff3b(.q(memWrite_MEM_intermediate2), .d(memWrite_MEM_intermediate), .clk(clk), .rst(rst));
	//assign memWrite_MEM = memDone ? memWrite_MEM_intermediate : memWrite_MEM_intermediate2;
	// oscillation loop because when memDone, then memWrite_MEM goes down, so memDone never goes high

	dff dff4(.q(RegDist_MEM), .d(!memStall && !dependentLoad || memDone ? RegDist_EX : RegDist_MEM), .clk(clk), .rst(rst));
	//dff dff4b(.q(RegDist_MEM_intermediate2), .d(RegDist_MEM_intermediate), .clk(clk), .rst(rst));
	//assign RegDist_MEM = memDone ? RegDist_MEM_intermediate : RegDist_MEM_intermediate2;
	//assign RegDist_MEM = RegDist_MEM_intermediate && !memDone;
	dff dff5b(.q(memDone_flopped), .d(memDone), .clk(clk), .rst(rst));
	dff dff5(.q(RegWrite_MEM_intermediate), .d(!memStall && !dependentLoad || memDone ? RegWrite_EX : RegWrite_MEM_intermediate), .clk(clk), .rst(rst));
	//assign RegWrite_MEM = !memDone || (!memRead_MEM && !memWrite_MEM)  ? 1'b0 : RegWrite_MEM_intermediate;
	//assign RegWrite_MEM = memDone || (!memRead_MEM && !memWrite_MEM) ? RegWrite_MEM_intermediate : 1'b0;
	assign RegWrite_MEM = !memStall && !dependentLoad || memDone ? RegWrite_MEM_intermediate : RegWrite_EX && (!memStall && !dependentLoad || memDone); // don't need memDone since already flopped
	dff dff6(.q(isJAL_MEM), .d(!memStall && !dependentLoad || memDone ? isJAL_EX : isJAL_MEM), .clk(clk), .rst(rst));
	dff dff7(.q(writeregsel_MEM[0]), .d(!memStall && !dependentLoad || memDone ? writeregsel_EX[0] : writeregsel_MEM[0]), .clk(clk), .rst(rst));
	dff dff8(.q(writeregsel_MEM[1]), .d(!memStall && !dependentLoad || memDone ? writeregsel_EX[1] : writeregsel_MEM[1]), .clk(clk), .rst(rst));
	dff dff9(.q(writeregsel_MEM[2]), .d(!memStall && !dependentLoad || memDone ? writeregsel_EX[2] : writeregsel_MEM[2]), .clk(clk), .rst(rst));
	
endmodule
