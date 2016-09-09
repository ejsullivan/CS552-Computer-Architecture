module reg_IF_ID (
	// outputs
	instr_ID, pcPlusTwo_ID, isDataStall,
	// inputs
	clk, rst, isAllStall, memStall, memDone, isFlush, instr_IF, pcPlusTwo_IF, 
	RegWrite_ID, RegWrite_EX, RegWrite_MEM,
	writeregsel_ID, writeregsel_EX, writeregsel_MEM
	);
	input clk, rst, isAllStall, memStall, memDone, isFlush, RegWrite_ID, RegWrite_EX, RegWrite_MEM;
	input [15:0] instr_IF, pcPlusTwo_IF;
	input [2:0] writeregsel_ID, writeregsel_EX, writeregsel_MEM;
	output [15:0] instr_ID, pcPlusTwo_ID;
	output isDataStall;
	wire [15:0] instr_ID_intermediate;
	wire ALUSrc_IF;
	//wire [2:0] writeregsel_ID;

	dff dff0(.q(isStall_nextInstruction), .d(isDataStall), .clk(clk), .rst(rst));
	//dff dff1(.q(writeregsel_ID_next[0]), .d(writeregsel_ID[0]), .clk(clk), .rst(rst));
	//dff dff2(.q(writeregsel_ID_next[1]), .d(writeregsel_ID[1]), .clk(clk), .rst(rst));
	//dff dff3(.q(writeregsel_ID_next[2]), .d(writeregsel_ID[2]), .clk(clk), .rst(rst));
	register register0(.dataOut(instr_ID_intermediate), .dataIn(isFlush ? 16'h0800 : instr_IF), .clk(clk), .rst(rst), .w_en(!isAllStall || memDone));
	register register1(.dataOut(pcPlusTwo_ID), .dataIn(pcPlusTwo_IF), .clk(clk), .rst(rst), .w_en(!isAllStall || memDone));

	//hazard_unit hazard0(
	//   // output
	//   .isDataStall(isDataStall), 
	//   // inputs
	//   .ALUSrc(ALUSrc_IF), .writeregsel_ID(writeregsel_ID), .writeregsel_EX(writeregsel_EX), .writeregsel_MEM(writeregsel_MEM), .instr(instr_IF),
	//   .RegWrite_ID(RegWrite_ID), .RegWrite_EX(RegWrite_EX), .RegWrite_MEM(RegWrite_MEM)
	//);
	assign isDataStall = 0;
/*
		instr_IF[15:12] != 4'b0000 && // nop, halt
		instr_IF[15:11] != 5'b00100 && // j
		instr_IF[15:11] != 5'b00110 && // jal
		instr_IF[15:12] != 4'b0001 && // siic, rti
		instr_IF[15:11] != 5'b11000 && // lbi
		instr_ID[15:11] == 5'b10001 && // earlier instr was a load
		(
			//instr_IF[10:8] == writeregsel_ID && RegWrite_ID || // maybe we dont need to check RegWrite_ID anymore since we know earlier instr was a load
			//ALUSrc_IF && instr_IF[7:5] == writeregsel_ID && RegWrite_ID ||
			(instr_IF[15:11] == 5'b10000 || instr_IF[15:11] == 5'b10011) && instr_IF[7:5] == instr_ID[7:5] // stall on load->store since we dont have M->M forwarding
		);
*/

	assign ALUSrc_IF = (instr_IF[15:11] == 5'b11001) || (instr_IF[15:12] == 4'b1101) || (instr_IF[15:13] == 3'b111);
	//assign instr_ID = (/*isStall_nextInstruction ||*/ isFlush) && !memStall ? 16'h0800 : instr_ID_intermediate;
	assign instr_ID = isFlush ? 16'h0800 : instr_ID_intermediate;
	/*assign writeregsel_ID = ((instr_IF[6:3] == 4'b0011) == 1) ? 3'b111 : 
			(instr_IF[15:11] == 5'b10011) ?  instr_IF[10:8] :
			(ALUSrc_ID == 1) ? instr_IF[4:2] : ((instr_IF[6:4] == 3'b010) || (instr_IF[6:4] == 3'b101) || ((instr_IF[6:4] == 3'b100) && (instr_IF[3:2] != 2'b10)) ? instr_IF[7:5] : instr_IF[10:8]);*/

	// TODO handle hazard detection unit input and control signal input
	// stall for hazard detection unit; flush for control signal flush
endmodule

