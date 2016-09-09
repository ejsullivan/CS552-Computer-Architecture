/* $Author: karu $ */
/* $LastChangedDate: 2009-03-04 23:09:45 -0600 (Wed, 04 Mar 2009) $ */
/* $Rev: 45 $ */
module rf (
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
	output        err;

	// your code
	//NOTE: could use a better decoder implementation to save on area.
	wire [15:0] registerOutputs[7:0];
	register register0(.dataOut(registerOutputs[0]), .dataIn(writedata), .clk(clk), .rst(rst), .w_en(write & writeregsel == 0));
	register register1(.dataOut(registerOutputs[1]), .dataIn(writedata), .clk(clk), .rst(rst), .w_en(write & writeregsel == 1));
	register register2(.dataOut(registerOutputs[2]), .dataIn(writedata), .clk(clk), .rst(rst), .w_en(write & writeregsel == 2));
	register register3(.dataOut(registerOutputs[3]), .dataIn(writedata), .clk(clk), .rst(rst), .w_en(write & writeregsel == 3));
	register register4(.dataOut(registerOutputs[4]), .dataIn(writedata), .clk(clk), .rst(rst), .w_en(write & writeregsel == 4));
	register register5(.dataOut(registerOutputs[5]), .dataIn(writedata), .clk(clk), .rst(rst), .w_en(write & writeregsel == 5));
	register register6(.dataOut(registerOutputs[6]), .dataIn(writedata), .clk(clk), .rst(rst), .w_en(write & writeregsel == 6));
	register register7(.dataOut(registerOutputs[7]), .dataIn(writedata), .clk(clk), .rst(rst), .w_en(write & writeregsel == 7));
   
	assign read1data = 
		read1regsel == 0 ? registerOutputs[0] :
		read1regsel == 1 ? registerOutputs[1] :
		read1regsel == 2 ? registerOutputs[2] :
		read1regsel == 3 ? registerOutputs[3] :
		read1regsel == 4 ? registerOutputs[4] :
		read1regsel == 5 ? registerOutputs[5] :
		read1regsel == 6 ? registerOutputs[6] :
		registerOutputs[7];

	assign read2data = 
		read2regsel == 0 ? registerOutputs[0] :
		read2regsel == 1 ? registerOutputs[1] :
		read2regsel == 2 ? registerOutputs[2] :
		read2regsel == 3 ? registerOutputs[3] :
		read2regsel == 4 ? registerOutputs[4] :
		read2regsel == 5 ? registerOutputs[5] :
		read2regsel == 6 ? registerOutputs[6] :
		registerOutputs[7];

	assign err = 0;
endmodule
// DUMMY LINE FOR REV CONTROL :1:
