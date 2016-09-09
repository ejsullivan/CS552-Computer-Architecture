module claUnit4bit(G, P, CIN, C);
	input [3:0] G, P;
	input CIN;
	output [3:0] C;
	
	assign C[0] = G[0] | (P[0] & CIN);
	assign C[1] = G[1] | (G[0] & P[1]) | (P[1] & P[0] & CIN);
	assign C[2] = G[2] | (G[1] & P[2]) | (G[0] & P[1] & P[2]) | (P[2] & P[1] & P[0] & CIN);
	assign C[3] = G[3] | (G[2] & P[3]) | (G[1] & P[2] & P[3]) | (G[0] & P[1] & P[2] & P[3]) | (P[0] & P[1] & P[2] & P[3] & CIN);	
endmodule