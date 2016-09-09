module forwarding_unit(
	   // inputs
	   instr_EX, memDone, RegWrite_MEM, RegWrite_WB_intermediate_for_forwarding, write_reg_sel_MEM, write_reg_sel_WB, memRead_EX, memRead_MEM, isLoad_EX, isLoad_MEM,
	   // outputs
	   isData1BypassFromMEM, isData1BypassFromWB, isData2BypassFromMEM, isData2BypassFromWB, isForwardingStall, dependentLoad, dependentLoad1, dependentLoad2
	);

// isData1NoBypass ? read1data_EX : (isData1BypassFromMEM ? read1data_MEM : read1data_WB)
// add r1, r2, r3
// add r1, r1, r4
// add r1, r1, r2
// isData1Bypass ? (isData1BypassFromMEM ? read1data_MEM : read1data_WB) : read1data_EX

	// inputs
	input [15:0] instr_EX;
	input [2:0] write_reg_sel_MEM, write_reg_sel_WB;
	input memDone, RegWrite_MEM, RegWrite_WB_intermediate_for_forwarding, memRead_EX, memRead_MEM, isLoad_EX, isLoad_MEM;
	// outputs
	output isData1BypassFromMEM, isData1BypassFromWB, isData2BypassFromMEM, isData2BypassFromWB, isForwardingStall, dependentLoad, dependentLoad1, dependentLoad2;
	wire [2:0] read_reg_1_EX, read_reg_2_EX;

	//assign isData1Bypass = read_reg_1_EX == write_reg_sel_MEM && RegWrite_MEM || read_reg_1_EX == write_reg_sel_WB || RegWrite_WB;
	//assign isData2Bypass = read_reg_2_EX == write_reg_sel_MEM && RegWrite_MEM || read_reg_2_EX == write_reg_sel_WB || RegWrite_WB;
	assign isStore = 0;//instr_EX[15:11] == 5'b10000 || instr_EX[15:11] == 5'b10011;
	assign read_reg_1_EX = isStore ? instr_EX[7:5] : instr_EX[10:8];
	assign read_reg_2_EX = isStore ? instr_EX[10:8] : instr_EX[7:5];
	assign isData1BypassFromMEM = (read_reg_1_EX == write_reg_sel_MEM) && RegWrite_MEM;
	assign dependentLoad = ((read_reg_1_EX == write_reg_sel_MEM) && RegWrite_MEM  || (read_reg_2_EX == write_reg_sel_MEM) && RegWrite_MEM) && memRead_MEM;
	assign dependentLoad1 = (read_reg_1_EX == write_reg_sel_MEM) && RegWrite_MEM && memRead_MEM;
	assign dependentLoad2 = (read_reg_2_EX == write_reg_sel_MEM) && RegWrite_MEM && memRead_MEM;
	//assign dependentLoad = ((read_reg_1_EX == write_reg_sel_MEM) && RegWrite_MEM && isLoad_MEM) || ((read_reg_2_EX == write_reg_sel_MEM) && RegWrite_MEM && isLoad_MEM);
	assign isData1BypassFromWB = (read_reg_1_EX == write_reg_sel_WB) && RegWrite_WB_intermediate_for_forwarding;
	assign isData2BypassFromMEM = (read_reg_2_EX == write_reg_sel_MEM) && RegWrite_MEM;
	assign isData2BypassFromWB = (read_reg_2_EX == write_reg_sel_WB) && RegWrite_WB_intermediate_for_forwarding;
	assign isForwardingStall = (isData1BypassFromMEM || isData2BypassFromMEM) && memRead_MEM;
	//assign isData1BypassFromMEMwithDelay = (read_reg_1_EX == write_reg_sel_MEM) && RegWrite_MEM && memRead_MEM;
	//assign isData2BypassFromMEMwithDelay = (read_reg_2_EX == write_reg_sel_MEM) && RegWrite_MEM && memRead_MEM;

endmodule

