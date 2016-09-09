module statereg(state, nxt_state, clk, rst);

	output [3:0] state;
	input [3:0] nxt_state;
	input clk, rst;
	
	dff dff0(.q(state[0]), .d(nxt_state[0]), .clk(clk), .rst(rst));
	dff dff1(.q(state[1]), .d(nxt_state[1]), .clk(clk), .rst(rst));
	dff dff2(.q(state[2]), .d(nxt_state[2]), .clk(clk), .rst(rst));
	dff dff3(.q(state[3]), .d(nxt_state[3]), .clk(clk), .rst(rst));
	
endmodule
