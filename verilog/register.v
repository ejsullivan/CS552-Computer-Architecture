module register(dataOut, dataIn, clk, rst, w_en);
	output[15:0] dataOut;
	input[15:0] dataIn;
	input clk, rst, w_en;
	wire[15:0] dffIn;
	
	dff dff0(.q(dataOut[0]), .d(dffIn[0]), .clk(clk), .rst(rst));
	dff dff1(.q(dataOut[1]), .d(dffIn[1]), .clk(clk), .rst(rst));
	dff dff2(.q(dataOut[2]), .d(dffIn[2]), .clk(clk), .rst(rst));
	dff dff3(.q(dataOut[3]), .d(dffIn[3]), .clk(clk), .rst(rst));
	dff dff4(.q(dataOut[4]), .d(dffIn[4]), .clk(clk), .rst(rst));
	dff dff5(.q(dataOut[5]), .d(dffIn[5]), .clk(clk), .rst(rst));
	dff dff6(.q(dataOut[6]), .d(dffIn[6]), .clk(clk), .rst(rst));
	dff dff7(.q(dataOut[7]), .d(dffIn[7]), .clk(clk), .rst(rst));
	dff dff8(.q(dataOut[8]), .d(dffIn[8]), .clk(clk), .rst(rst));
	dff dff9(.q(dataOut[9]), .d(dffIn[9]), .clk(clk), .rst(rst));
	dff dff10(.q(dataOut[10]), .d(dffIn[10]), .clk(clk), .rst(rst));
	dff dff11(.q(dataOut[11]), .d(dffIn[11]), .clk(clk), .rst(rst));
	dff dff12(.q(dataOut[12]), .d(dffIn[12]), .clk(clk), .rst(rst));
	dff dff13(.q(dataOut[13]), .d(dffIn[13]), .clk(clk), .rst(rst));
	dff dff14(.q(dataOut[14]), .d(dffIn[14]), .clk(clk), .rst(rst));
	dff dff15(.q(dataOut[15]), .d(dffIn[15]), .clk(clk), .rst(rst));
	
	assign dffIn = w_en ? dataIn : dataOut;
	
endmodule