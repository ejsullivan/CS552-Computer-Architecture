/* $Author: karu $ */
/* $LastChangedDate: 2009-03-04 23:09:45 -0600 (Wed, 04 Mar 2009) $ */
/* $Rev: 45 $ */
module rf_bypass (
           // Outputs
           read1data, read2data, err,
           // Inputs
           clk, rst, read1regsel, read2regsel, writeregsel, writedata, write
           );
	input clk, rst;
	input [2:0] read1regsel;
	input [2:0] read2regsel;
	input [2:0] writeregsel;
	input [15:0] writedata;
	input        write;

	output [15:0] read1data;
	output [15:0] read2data;
	wire [15:0] read1dataIntermediate;
	wire [15:0] read2dataIntermediate;
	output        err;

	// your code
	rf rf_0(
		// Outputs
		.read1data                    (read1dataIntermediate),
		.read2data                    (read2dataIntermediate),
		.err                          (err),
		// Inputs
		.clk                          (clk),
		.rst                          (rst),
		.read1regsel                  (read1regsel[2:0]),
		.read2regsel                  (read2regsel[2:0]),
		.writeregsel                  (writeregsel[2:0]),
		.writedata                    (writedata[15:0]),
		.write                        (write));
	
	assign read1data = read1regsel == writeregsel && write == 1 ? writedata : read1dataIntermediate;
	assign read2data = read2regsel == writeregsel && write == 1 ? writedata : read2dataIntermediate;

endmodule
// DUMMY LINE FOR REV CONTROL :1:
