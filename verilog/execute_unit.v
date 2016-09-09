module execute_unit(
	// outputs
	aluResult, isTaken, pcNext,
	// inputs
	clk, rst, hadBypass, isAllStall, memDone, instr, read1data, read2data, ALU_Op, ALUSrc, Branch_Op, isJump, isIType1, isSignExtend, isJR, isBranch, pcPlusTwo_EX
	);

	input [15:0] instr, read1data, read2data, pcPlusTwo_EX;
	input [3:0] ALU_Op;
	input [1:0] Branch_Op;
	input clk, rst, hadBypass, isAllStall, memDone, ALUSrc, isJump, isIType1, isSignExtend, isJR, isBranch;
	output isTaken;
	output [15:0] aluResult, pcNext;
	wire isTaken, isAllStall_flopped, memDone_flopped;
	wire [15:0] ALU_Operand1, ALU_Operand2, iTypeWire, offset, pcNotJR, pcPlusTwoPlusOffset, aluResult_intermediate, aluResult_flopped;

	alu execute0(
	   .A(ALU_Operand1), .B(ALU_Operand2), .ALU_Op(ALU_Op), .Branch_Op(Branch_Op), .Out(aluResult_intermediate), .isTaken(isTaken)
	   );

	claAdder16 PCadder1(.A(pcPlusTwo_EX), .B(offset), .CIN(1'b0), .SUM(pcPlusTwoPlusOffset), .CO(IDontCare));

	register register1(.dataOut(aluResult_flopped), .dataIn(aluResult_intermediate), .clk(clk), .rst(rst), .w_en(hadBypass));
	assign aluResult = aluResult_intermediate;//!isAllStall_flopped || memDone_flopped ? aluResult_intermediate : aluResult_flopped;
	assign ALU_Operand1 = read1data;
	assign ALU_Operand2 = (ALUSrc == 1) ? read2data : iTypeWire;

	assign iTypeWire = isIType1 ? {{11{instr[4] & isSignExtend}}, instr[4:0]} : {{8{instr[7] & isSignExtend}}, instr[7:0]};
	assign offset = isBranch ? iTypeWire : {{5{instr[10]}}, instr[10:0]}; // if not branch, then possibly jump
	assign pcNotJR = (isJump || (isBranch && isTaken)) ? pcPlusTwoPlusOffset : pcPlusTwo_EX;
	assign pcNext = isJR ? aluResult : pcNotJR;
	dff dff0(.q(isAllStall_flopped), .d(isAllStall), .clk(clk), .rst(rst));
	dff dff1(.q(memDone_flopped), .d(memDone), .clk(clk), .rst(rst));

endmodule

