module memory_unit(clk, rst, aluResult, writeData, halt, memRead, memWrite, data_out);
	input clk, rst, halt, memRead, memWrite;
	input[15:0] aluResult, writeData;
	output [15:0] data_out;
	wire memReadorWrite;

	memory2c dataMemory(.data_out(data_out), .data_in(writeData), .addr(aluResult), .enable(memReadorWrite), .wr(memWrite), .createdump(halt), .clk(clk), .rst(rst));

	assign memReadorWrite = memWrite | memRead;

endmodule
