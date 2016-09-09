module writeback_unit(
	   // inputs
	   aluResult, writeData, MemToReg, isJAL_WB, pcPlusTwo_WB,
	   // outputs
	   writeback_data
	);
	input MemToReg, isJAL_WB;
	input[15:0] aluResult, writeData, pcPlusTwo_WB;
	output [15:0] writeback_data;

	assign writeback_data = isJAL_WB ? pcPlusTwo_WB : (MemToReg ? writeData : aluResult); // this determines the value the testbench will write to register

endmodule
