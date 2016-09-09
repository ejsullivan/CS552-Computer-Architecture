module hazard_unit(
	   // outputs
	   isStall, 
	   // inputs
	   ALUSrc, writeregsel_ID, writeregsel_EX, writeregsel_MEM, instr,
	   RegWrite_ID, RegWrite_EX, RegWrite_MEM
	);
	
	input ALUSrc, RegWrite_ID, RegWrite_EX, RegWrite_MEM; // ALUSrc is ALUSrc_IF
	input [2:0] writeregsel_ID, writeregsel_EX, writeregsel_MEM;
	input [15:0] instr; // instr is instr_IF

	output isStall;

	assign isStall = 
		instr[15:12] != 4'b0000 && // nop, halt
		instr[15:11] != 5'b00100 && // j
		instr[15:11] != 5'b00110 && // jal
		instr[15:12] != 4'b0001 && // siic, rti
		instr[15:11] != 5'b11000 && // lbi
		(
				(instr[10:8] == writeregsel_ID && RegWrite_ID || // will fix btr0 by waiting for regWrite signal to clear // ok now since input from ID stage // not using writeregsel_ID because we don't want add r1, r1, r1 to stall if it's first instruction
				instr[10:8] == writeregsel_MEM && RegWrite_MEM) ||
			(ALUSrc || instr[15:11] == 5'b10000 || instr[15:11] == 5'b10011) && // Rtype or store or storeUpper (STU)
				(instr[7:5] == writeregsel_ID && RegWrite_ID ||
				instr[7:5] == writeregsel_MEM && RegWrite_MEM)
		);

/* try opposite
		(instr[10:8] == writeregsel_ID || instr[10:8] == writeregsel_EX  || instr[10:8] == writeregsel_MEM) && (instr[15:13] == 3'b010 || instr[15:14] == 2'b10 || instr[15:14] == 2'b11)
		instr[15:12] != 4'b0000 && // nop, halt
		instr[15:11] != 5'b00100 && // j
		instr[15:11] != 5'b00110 && // jal
		instr[15:12] != 4'b0001 && // sic, rti
		instr[15:11] != 5'b11000 && // lbi
		(
				(instr[10:8] == writeregsel_ID || // ok now since input from ID stage // not using writeregsel_ID because we don't want add r1, r1, r1 to stall if it's first instruction
				instr[10:8] == writeregsel_EX  ||
				instr[10:8] == writeregsel_MEM) ||
			ALUSrc && 
				(instr[7:5] == writeregsel_ID ||
				instr[7:5] == writeregsel_EX ||
				instr[7:5] == writeregsel_MEM)
		);
*/
	// TODO: fix slbi. we want it to stall, but not to stall indefinitely
endmodule
