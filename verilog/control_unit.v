module control_unit(inst, isNotHalt, isJump, isIType1, isSignExtend, isJR, isJAL, isBranch, MemToReg, MemRead, MemWrite, ALU_Op, Branch_Op, ALUSrc, RegWrite, RegDist);
	input [6:0] inst;
	output isNotHalt, isJump, isIType1, isSignExtend, isJR, isJAL, isBranch,
		 MemToReg, MemRead, MemWrite, ALUSrc, RegWrite, RegDist;
	output [3:0] ALU_Op;
	output [1:0] Branch_Op;
	wire isRType;

	assign isNotHalt = (inst[6:2] != 6'b000000);

	assign isJump = (inst[6:4] == 3'b001);

	assign isIType1 = (inst[6:4] == 3'b010) || (inst[6:4] == 3'b101) || ((inst[6:4] == 3'b100) && (inst[3:2] != 2'b10));

	assign isSignExtend = ~(inst[6:2] == 5'b01010 || inst[6:2] == 5'b01011 || inst[6:2] == 5'b10010); // ~(xori, andni, slbi)

	assign isJR = ({inst[6:4], inst[2]} == 4'b0011);

	assign isJAL = (inst[6:3] == 4'b0011);

	assign isBranch = (inst[6:4] == 3'b011);

	assign MemToReg = (inst[6:2] == 5'b10001);

	assign MemRead = MemToReg;

	assign MemWrite = (inst[6:2] == 5'b10000 || inst[6:2] == 5'b10011);

	assign ALU_Op = (inst[6:2] == 5'b01000) || (inst == 7'b1101100) || (inst[6:3] == 4'b1000) || (inst[6:2] == 5'b10011) || (inst[6:2] == 5'b00101) || (inst[6:2] == 5'b00111) ? 0 :
			// add or addi or st or ld or stu or jr or jalr
			(inst[6:2] == 5'b01001) || (inst == 7'b1101101) ? 1 :	// sub
			(inst[6:2] == 5'b01010) || (inst == 7'b1101110) ? 2 :	// xor
			(inst[6:2] == 5'b01011) || (inst == 7'b1101111) ? 3 :	// andn
			(inst[6:2] == 5'b10100) || (inst == 7'b1101000) ? 4 :	// rol
			(inst[6:2] == 5'b10101) || (inst == 7'b1101001) ? 5 :	// sll
			(inst[6:2] == 5'b10110) || (inst == 7'b1101010) ? 6 :	// ror
			(inst[6:2] == 5'b10111) || (inst == 7'b1101011) ? 7 :	// srl
			(inst[6:2] == 5'b11001) ? 8 :				// btr
			(inst[6:2] == 5'b11100) ? 9 :				// seq
			(inst[6:2] == 5'b11101) ? 10 :				// slt
			(inst[6:2] == 5'b11110) ? 11 :				// sle
			(inst[6:2] == 5'b11111) ? 12 :				// sco
			(inst[6:2] == 5'b11000) ? 13 :				// lbi
			(inst[6:2] == 5'b10010) ? 14 :				// slbi
			4'b1111;						// default
	
	assign Branch_Op = (inst[6:2] == 5'b01101) ? 1 :			// bnez
			(inst[6:2] == 5'b01110) ? 2 :				// bltz
			(inst[6:2] == 5'b01111) ? 3 :				// bgez
			0;							// beqz

	assign isRType = (inst[6:2] == 5'b11001) || (inst[6:3] == 4'b1101) || (inst[6:4] == 3'b111);

	assign ALUSrc = isRType;

	assign RegWrite = (isIType1 && inst[6:2] != 5'b10000) || isRType || (inst[6:2] == 5'b11000) || (inst[6:2] == 5'b10010) || (inst[6:3] == 4'b0011);

	assign RegDist = isRType;

endmodule
