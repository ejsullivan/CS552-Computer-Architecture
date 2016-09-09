/* $Author: karu $ */
/* $LastChangedDate: 2009-03-04 23:09:45 -0600 (Wed, 04 Mar 2009) $ */
/* $Rev: 45 $ */
module proc (/*AUTOARG*/
	// Outputs
	err, 
	// Inputs
	clk, rst
	);

	input clk;
	input rst;

	output err;

	// None of the above lines can be modified

	// OR all the err ouputs for every sub-module and assign it as this
	// err output

	// As desribed in the homeworks, use the err signal to trap corner
	// cases that you think are illegal in your statemachines


	/* your code here */
	wire [15:0] instr_IF, instr_ID, instr_EX, instr_MEM, instr_WB, pcNext, pcPlusTwo_IF, pcPlusTwo_ID, pcPlusTwo_EX, pcPlusTwo_MEM, pcPlusTwo_WB, /*iTypeWire,*/ read1data_ID, read1data_EX;
	wire [15:0] read2data_ID, read2data_EX, aluResult_EX, aluResult_MEM, aluResult_WB, writeback_data, data_out, writeData_MEM, writeData_WB;
	wire [3:0] ALU_Op_ID, ALU_Op_EX;
	wire [1:0] Branch_Op_ID, Branch_Op_EX;
	wire [2:0] writeregsel_ID, writeregsel_EX, writeregsel_MEM, writeregsel_WB;
	wire regWrite, memRxout, notdonem, memWxout, haltxout, RegWrite_WB, memRead_MEM, memWrite_MEM, isHalt_MEM, isTaken_EX, memDone;
	// connections to pbench
	wire [2:0] DstwithJmout;
	wire [15:0] wData, data1out, data2out, readData;

	assign regWrite = RegWrite_WB;
	assign DstwithJmout = writeregsel_WB;
	assign wData = writeback_data;
	assign memRxout = memRead_MEM;
	assign notdonem = !memDone;
	assign memWxout = memWrite_MEM;
	assign data1out = aluResult_MEM;
	assign data2out = writeData_MEM;
	assign readData = data_out;
	assign haltxout = isHalt_MEM;

	// handle initial flush signal 
	/*dff dff0(.q(rst1), .d(rst), .clk(clk), .rst(1'b0));
	dff dff1(.q(rst2), .d(rst1), .clk(clk), .rst(1'b0));
	dff dff2(.q(rst3), .d(rst2), .clk(clk), .rst(1'b0));
	assign isFlush = ~rst && ~rst3 && (isJump_EX | (isBranch_EX & isTaken_EX) | isJR_EX);*/
	wire isJump_EX, isBranch_EX, isJR_EX, isDataStall, memStall, isAllStall, decodeErr, memErr, isForwardingStall, isLoad_EX, isLoad_MEM, dependentLoad, fetchMemErr;
	assign isFlush = isJump_EX | (isBranch_EX & isTaken_EX) | isJR_EX; // Should include isJAL but that is given from the isJump wire
	assign isAllStall = isDataStall || memStall || isForwardingStall || dependentLoad;
	assign err = decodeErr || memErr || fetchMemErr;
	

	fetch_unit fetch0(
	   // inputs
	   .clk(clk), .rst(rst), .isFlush(isFlush), .isAllStall(isAllStall), .pcNext(pcNext), .memStall(memStall), .memDone(memDone), 
	   // outputs
	   .instr(instr_IF), .pcPlusTwo(pcPlusTwo_IF), .fetchMemErr(fetchMemErr)
	   );

	reg_IF_ID reg_IF_ID0(
	   // outputs
	   .instr_ID(instr_ID), .pcPlusTwo_ID(pcPlusTwo_ID), .isDataStall(isDataStall), 
	   // inputs
	   .clk(clk), .rst(rst), .isAllStall(isAllStall), .memStall(memStall), .memDone(memDone), .isFlush(isFlush), .instr_IF(instr_IF), .pcPlusTwo_IF(pcPlusTwo_IF), 
	   .RegWrite_ID(RegWrite_ID), .RegWrite_EX(RegWrite_EX), .RegWrite_MEM(RegWrite_MEM),
	   .writeregsel_ID(writeregsel_ID), .writeregsel_EX(writeregsel_EX), .writeregsel_MEM(writeregsel_MEM)
	);

   	decode_unit decode0(
	   // inputs
	   .clk(clk), .rst(rst), .instr(instr_ID), .pcPlusTwo(pcPlusTwo_ID), .writeback_data(writeback_data), .RegDist_WB(RegDist_WB),
	   .RegWrite_WB(RegWrite_WB), .writeregsel_WB(writeregsel_WB), .memStall(memStall), .memDone(memDone),
	   // outputs
	   .isHalt(isHalt_ID), .isJump(isJump_ID), .isIType1(isIType1_ID), .isSignExtend(isSignExtend_ID), .isJR(isJR_ID), 
	   .isBranch(isBranch_ID), .MemToReg(MemToReg_ID), .MemRead(memRead_ID), .MemWrite(memWrite_ID), .ALU_Op(ALU_Op_ID), .ALUSrc(ALUSrc_ID), 
	   .read1data(read1data_ID), .read2data(read2data_ID), .Branch_Op(Branch_Op_ID), .RegDist_ID(RegDist_ID), .RegWrite_ID(RegWrite_ID), 
	   .isJAL_ID(isJAL_ID), .writeregsel_ID(writeregsel_ID), .err(decodeErr)
	);

	reg_ID_EX reg_ID_EX0(
	   // outputs
	   .pcPlusTwo_EX(pcPlusTwo_EX), .instr_EX(instr_EX), .read1data_EX(read1data_EX), .read2data_EX(read2data_EX), .ALU_Op_EX(ALU_Op_EX), .ALUSrc_EX(ALUSrc_EX),
	   .memRead_EX(memRead_EX), .memWrite_EX(memWrite_EX), .MemToReg_EX(MemToReg_EX), .isHalt_EX(isHalt_EX), .Branch_Op_EX(Branch_Op_EX), .isJump_EX(isJump_EX), 
	   .isIType1_EX(isIType1_EX), .isSignExtend_EX(isSignExtend_EX), .isJR_EX(isJR_EX), .isBranch_EX(isBranch_EX),
	   .RegDist_EX(RegDist_EX), .RegWrite_EX(RegWrite_EX), .isJAL_EX(isJAL_EX), .writeregsel_EX(writeregsel_EX),
	   // inputs
	   .clk(clk), .rst(rst), .isAllStall(isAllStall), .isDataStall(isDataStall), .memStall(memStall), .memDone(memDone), .pcPlusTwo_ID(pcPlusTwo_ID), .instr_ID(instr_ID), .read1data_ID(read1data_ID), .read2data_ID(read2data_ID), .ALU_Op_ID(ALU_Op_ID), .ALUSrc_ID(ALUSrc_ID),
	   .memRead_ID(memRead_ID), .memWrite_ID(memWrite_ID), .MemToReg_ID(MemToReg_ID), .isHalt_ID(isHalt_ID), .Branch_Op_ID(Branch_Op_ID), .isJump_ID(isJump_ID), 
	   .isIType1_ID(isIType1_ID), .isSignExtend_ID(isSignExtend_ID), .isJR_ID(isJR_ID), .isBranch_ID(isBranch_ID),
	   .RegDist_ID(RegDist_ID), .RegWrite_ID(RegWrite_ID), .isJAL_ID(isJAL_ID), .isFlush(isFlush), .writeregsel_ID(writeregsel_ID), .dependentLoad(dependentLoad)
	);

	execute_unit execute0(
	   // outputs
	   .aluResult(aluResult_EX), .isTaken(isTaken_EX), .pcNext(pcNext),
	   // inputs
	   .clk(clk), .rst(rst), .hadBypass(dependentLoad1 || isData1BypassFromMEM || isData1BypassFromWB), .isAllStall(isAllStall), .memDone(memDone), .instr(instr_EX), 
	   .read1data(dependentLoad1 ? data_out : (isData1BypassFromMEM ? aluResult_MEM : (isData1BypassFromWB ? writeback_data : read1data_EX))), // was orginally .read1data(isData1BypassFromMEM ? aluResult_MEM : (isData1BypassFromWB ? writeback_data : read1data_EX)),
	   .read2data(dependentLoad2 ? data_out : (isData2BypassFromMEM ? aluResult_MEM : (isData2BypassFromWB ? writeback_data : read2data_EX))), 
	   .ALU_Op(ALU_Op_EX), .ALUSrc(ALUSrc_EX), .Branch_Op(Branch_Op_EX), .isJump(isJump_EX), .isIType1(isIType1_EX), 
	   .isSignExtend(isSignExtend_EX), .isJR(isJR_EX), .isBranch(isBranch_EX), .pcPlusTwo_EX(pcPlusTwo_EX)
	);

	reg_EX_MEM reg_EX_MEM0(
	   // outputs
	   .instr_MEM(instr_MEM), .isHalt_MEM(isHalt_MEM), .MemToReg_MEM(MemToReg_MEM), .memRead_MEM(memRead_MEM), .memWrite_MEM(memWrite_MEM), .aluResult_MEM(aluResult_MEM), .writeData_MEM(writeData_MEM), .isLoad(isLoad),
	   .RegDist_MEM(RegDist_MEM), .RegWrite_MEM(RegWrite_MEM), .isJAL_MEM(isJAL_MEM), .writeregsel_MEM(writeregsel_MEM), .pcPlusTwo_MEM(pcPlusTwo_MEM), 
	   // inputs
	   .clk(clk), .rst(rst), .memStall(memStall), .isForwardingStall(isForwardingStall), .memDone(memDone), .isHalt_EX(isHalt_EX), .MemToReg_EX(MemToReg_EX), .memRead_EX(memRead_EX), .memWrite_EX(memWrite_EX), .aluResult_EX(aluResult_EX),
	   .writeData_EX(dependentLoad2 ? data_out : (isData2BypassFromMEM ? aluResult_MEM : (isData2BypassFromWB ? writeback_data : read2data_EX))), .RegDist_EX(RegDist_EX), .RegWrite_EX(RegWrite_EX), 
	   .isJAL_EX(isJAL_EX), .writeregsel_EX(writeregsel_EX), .pcPlusTwo_EX(pcPlusTwo_EX), .instr_EX(instr_EX), .dependentLoad(dependentLoad)
	);

	/*
	memory_unit memory0(
	   // inputs
	   .clk(clk), .rst(rst), .aluResult(aluResult_MEM), .writeData(writeData_MEM), .halt(isHalt_MEM), .memRead(memRead_MEM), .memWrite(memWrite_MEM), 
	   // outputs
	   .data_out(data_out)
	);
	*/

	
	mem_system memory0(
   	   // Outputs
   	   .DataOut(data_out), .Done(memDone), .Stall(memStall), .CacheHit(CacheHit), .err(memErr), 
   	   // Inputs
   	   .Addr(aluResult_MEM), .DataIn(writeData_MEM), .Rd(memRead_MEM), .Wr(memWrite_MEM), .createdump(isHalt_MEM), .clk(clk), .rst(rst)
   	);
	
	
	/*
	stallmem memory0(
   	   // Outputs
   	   .DataOut(data_out), .Done(memDone), .Stall(memStall), .CacheHit(CacheHit), .err(memErr), 
   	   // Inputs
   	   .Addr(aluResult_MEM), .DataIn(writeData_MEM), .Rd(memRead_MEM), .Wr(memWrite_MEM), .createdump(isHalt_MEM), .clk(clk), .rst(rst)
	);
	*/

	reg_MEM_WB reg_MEM_WB0(
	   // outputs
	   .instr_WB(instr_WB), .MemToReg_WB(MemToReg_WB), .aluResult_WB(aluResult_WB), .writeData_WB(writeData_WB),
	   .RegDist_WB(RegDist_WB), .RegWrite_WB(RegWrite_WB), .isJAL_WB(isJAL_WB), .writeregsel_WB(writeregsel_WB), .pcPlusTwo_WB(pcPlusTwo_WB), .RegWrite_WB_intermediate_for_forwarding(RegWrite_WB_intermediate_for_forwarding),
	   // inputs
	   .clk(clk), .rst(rst), .memStall(memStall), .isAllStall(isAllStall), .memDone(memDone), .MemToReg_MEM(MemToReg_MEM), .aluResult_MEM(aluResult_MEM), .writeData_MEM(data_out),
	   .RegDist_MEM(RegDist_MEM), .RegWrite_MEM(RegWrite_MEM), .isJAL_MEM(isJAL_MEM), .writeregsel_MEM(writeregsel_MEM), .pcPlusTwo_MEM(pcPlusTwo_MEM), .instr_MEM(instr_MEM), .isData1BypassFromWB(isData1BypassFromWB), .isData2BypassFromWB(isData2BypassFromWB)
	);

	writeback_unit writeback0(
	   // inputs
	   .aluResult(aluResult_WB), .writeData(writeData_WB), .MemToReg(MemToReg_WB), .isJAL_WB(isJAL_WB), .pcPlusTwo_WB(pcPlusTwo_WB), 
	   // outputs
	   .writeback_data(writeback_data)
	);

	assign isLoad_EX = memRead_EX;
	assign isLoad_MEM = memRead_MEM;
	forwarding_unit forwarding0(
	   // inputs
	   .instr_EX(instr_EX), .memDone(memDone_flopped), .RegWrite_MEM(RegWrite_MEM), .RegWrite_WB_intermediate_for_forwarding(RegWrite_WB_intermediate_for_forwarding), .write_reg_sel_MEM(writeregsel_MEM), .write_reg_sel_WB(writeregsel_WB), .memRead_EX(memRead_EX), .memRead_MEM(memRead_MEM), .isLoad_EX(isLoad_EX), .isLoad_MEM(isLoad_MEM),
	   // outputs
	   .isData1BypassFromMEM(isData1BypassFromMEM), .isData1BypassFromWB(isData1BypassFromWB), .isData2BypassFromMEM(isData2BypassFromMEM), .isData2BypassFromWB(isData2BypassFromWB), .isForwardingStall(isForwardingStall),
	   .dependentLoad(dependentLoad), .dependentLoad1(dependentLoad1), .dependentLoad2(dependentLoad2)
	);

	dff dff8(.q(memDone_flopped), .d(memDone), .clk(clk), .rst(rst));

endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:







