module reg_ID_EX (
	// outputs
	pcPlusTwo_EX, instr_EX, read1data_EX, read2data_EX, ALU_Op_EX, ALUSrc_EX,
	memRead_EX, memWrite_EX, MemToReg_EX, isHalt_EX, Branch_Op_EX, isJump_EX, 
	isIType1_EX, isSignExtend_EX, isJR_EX, isBranch_EX,
	// outputs due to pipelining
	RegDist_EX, RegWrite_EX, isJAL_EX, writeregsel_EX,
	// inputs
	clk, rst, isAllStall, isDataStall, memStall, memDone, pcPlusTwo_ID, instr_ID, read1data_ID, read2data_ID, ALU_Op_ID, ALUSrc_ID,
	memRead_ID, memWrite_ID, MemToReg_ID, isHalt_ID, Branch_Op_ID, isJump_ID, 
	isIType1_ID, isSignExtend_ID, isJR_ID, isBranch_ID, dependentLoad,
	// inputs due to pipelining
	RegDist_ID, RegWrite_ID, isJAL_ID, isFlush, writeregsel_ID
	);

	// inputs
	input clk, rst, isAllStall, isDataStall, memStall, memDone, ALUSrc_ID, memRead_ID, memWrite_ID, MemToReg_ID, isHalt_ID, isJump_ID, isIType1_ID, isSignExtend_ID, isJR_ID, isBranch_ID, dependentLoad;
	input [15:0] pcPlusTwo_ID, instr_ID, read1data_ID, read2data_ID;
	input [3:0] ALU_Op_ID;
	input [1:0] Branch_Op_ID;
	// inputs due to pipelining
	input RegDist_ID, RegWrite_ID, isJAL_ID, isFlush;
	input [2:0] writeregsel_ID;
	// outputs
	output ALUSrc_EX, memRead_EX, memWrite_EX, MemToReg_EX, isHalt_EX, isJump_EX, isIType1_EX, isSignExtend_EX, isJR_EX, isBranch_EX;
	output [15:0] pcPlusTwo_EX, instr_EX, read1data_EX, read2data_EX;
	output [3:0] ALU_Op_EX;
	output [1:0] Branch_Op_EX;
	// outputs due to pipelining
	output RegDist_EX, RegWrite_EX, isJAL_EX;
	output [2:0] writeregsel_EX;

	wire [15:0] instr_EX_intermediate;

	register register0(.dataOut(instr_EX), .dataIn(instr_ID), .clk(clk), .rst(rst), .w_en(!isAllStall || memDone));
	//assign instr_EX = memStall ? 16'h0800 : instr_EX_intermediate; // isDataStall ? 16'h0800 : instr_EX_intermediate // if you change this line back, then update lines 46 and 50 as well
	register register1(.dataOut(pcPlusTwo_EX), .dataIn(pcPlusTwo_ID), .clk(clk), .rst(rst), .w_en(!isAllStall || memDone));
	register register2(.dataOut(read1data_EX), .dataIn(read1data_ID), .clk(clk), .rst(rst), .w_en(!isAllStall || memDone));
	register register3(.dataOut(read2data_EX), .dataIn(read2data_ID), .clk(clk), .rst(rst), .w_en(!isAllStall || memDone));
	
	register register4(
	   .dataOut({isHalt_EX, memRead_EX_interemediate, memWrite_EX_intermediate, MemToReg_EX, ALUSrc_EX, isJump_EX, isIType1_EX, isSignExtend_EX, isJR_EX, isBranch_EX, ALU_Op_EX, Branch_Op_EX}), 
	   .dataIn({isFlush ? 1'b0 : isHalt_ID, memRead_ID, isFlush ? 1'b0 : memWrite_ID, MemToReg_ID, ALUSrc_ID, isJump_ID, isIType1_ID, isSignExtend_ID, isJR_ID, isBranch_ID, ALU_Op_ID, Branch_Op_ID}), 
	   .clk(clk), .rst(rst), .w_en(!isAllStall || memDone)
	);
	assign memWrite_EX = /*memStall || */isFlush && !isJAL_EX ? 1'b0 : memWrite_EX_intermediate; // do not clobber if JAL because JAL do need to write back to reg // TODO add in isFlush for JAL
	assign memRead_EX = /*memStall ? 1'b0 : */memRead_EX_interemediate;

	dff dff1(.q(RegDist_EX), .d(!isAllStall || memDone ? RegDist_ID : RegDist_EX), .clk(clk), .rst(rst));
	dff dff2(.q(RegWrite_EX_intermediate) , .d(!isAllStall || memDone ? (isFlush ? 1'b0 : RegWrite_ID) : RegWrite_EX_intermediate), .clk(clk), .rst(rst));
	assign RegWrite_EX = /*memStall || */isFlush && !isJAL_EX ? 1'b0 : RegWrite_EX_intermediate; // do not clobber if JAL because JAL do need to write back to reg // TODO add in isFlush for JAL
	dff dff3(.q(isJAL_EX), .d(!isAllStall && !dependentLoad || memDone ? isJAL_ID : isJAL_EX), .clk(clk), .rst(rst));
	dff dff4(.q(writeregsel_EX[0]), .d(!isAllStall || memDone ? writeregsel_ID[0] : writeregsel_EX[0]), .clk(clk), .rst(rst));
	dff dff5(.q(writeregsel_EX[1]), .d(!isAllStall || memDone ? writeregsel_ID[1] : writeregsel_EX[1]), .clk(clk), .rst(rst));
	dff dff6(.q(writeregsel_EX[2]), .d(!isAllStall || memDone ? writeregsel_ID[2] : writeregsel_EX[2]), .clk(clk), .rst(rst));
	dff dff7(.q(memStall_flopped), .d(memStall), .clk(clk), .rst(rst));
	dff dff8(.q(memDone_flopped), .d(memDone), .clk(clk), .rst(rst));
	
endmodule

