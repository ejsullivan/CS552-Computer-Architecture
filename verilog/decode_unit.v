module decode_unit(
	   // inputs
	   clk, rst, instr, pcPlusTwo, writeback_data, RegDist_WB, RegWrite_WB, writeregsel_WB, memStall, memDone,
	   // outputs
	   isHalt, isJump, isIType1, isSignExtend, isJR, isBranch, MemToReg, MemRead, MemWrite, ALU_Op, ALUSrc, read1data, read2data, Branch_Op, err, RegDist_ID, RegWrite_ID, isJAL_ID, writeregsel_ID
	);
	// inputs (regular)
	input clk, rst, memDone, memStall;
	input [15:0] instr, pcPlusTwo, writeback_data;
	// inputs due to pipelining
	input RegDist_WB, RegWrite_WB;
	input [2:0] writeregsel_WB;
	// outputs (regular)
	output isHalt, isJump, isIType1, isSignExtend, isJR, isBranch, MemToReg, MemRead, MemWrite, ALUSrc, err;
	output [3:0] ALU_Op;
	output [1:0] Branch_Op;
	output [15:0] read1data, read2data;
	// outputs due to pipelining
	output RegDist_ID, RegWrite_ID, isJAL_ID;
	output [2:0] writeregsel_ID;
	// wires
	wire isNotHaltIntermediate;	
	wire [15:0] writedata;

	rf_bypass regFile0(
           .read1data(read1data), .read2data(read2data), .err(err),
           .clk(clk), .rst(rst), .read1regsel(instr[10:8]), .read2regsel(instr[7:5]), .writeregsel(writeregsel_WB), .writedata(writedata), .write(RegWrite_WB)
           );

	control_unit controlUnit0(
	   .inst({instr[15:11], instr[1:0]}), .isNotHalt(isNotHaltIntermediate), .isJump(isJump), .isIType1(isIType1), .isSignExtend(isSignExtend), .isJR(isJR), .isJAL(isJAL_ID),
	   .isBranch(isBranch), .MemToReg(MemToReg), .MemRead(MemRead), .MemWrite(MemWrite), .ALU_Op(ALU_Op),  .Branch_Op(Branch_Op), .ALUSrc(ALUSrc), .RegWrite(RegWrite_ID), .RegDist(RegDist_ID)
	   );

	dff dff0(.q(rst1), .d(rst), .clk(clk), .rst(1'b0));
	dff dff1(.q(rst2), .d(rst1), .clk(clk), .rst(1'b0));

	assign writeregsel_ID = (isJAL_ID == 1) ? 3'b111 : 
			(instr[15:11] == 5'b10011) ?  instr[10:8] :
			(RegDist_ID == 1) ? instr[4:2] : (isIType1 ? instr[7:5] : instr[10:8]);
	assign writedata = writeback_data; // TODO this was changed to 0003 : 0009 but yet it was still writing -1, which was writeback_data
	assign isHalt = ~rst && ~rst2 && ~isNotHaltIntermediate; // update if changing back to isNotHalt

endmodule
