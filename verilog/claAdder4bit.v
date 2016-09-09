module claAdder4bit(A, B, SUM, CI, CO);
	input[3:0] A, B;
	input CI;
	output[3:0] SUM;
	output CO;
	wire [3:0] G, P, C;
	claUnit4bit claUnit(.G(G), .P(P), .CIN(CI), .C(C));
	
	claAdder1bit claAdder1bit1(.A(A[0]), .B(B[0]), .Cin(CI), .S(SUM[0]), .G(G[0]), .P(P[0]));
	claAdder1bit claAdder1bit2(.A(A[1]), .B(B[1]), .Cin(C[0]), .S(SUM[1]), .G(G[1]), .P(P[1]));
	claAdder1bit claAdder1bit3(.A(A[2]), .B(B[2]), .Cin(C[1]), .S(SUM[2]), .G(G[2]), .P(P[2]));
	claAdder1bit claAdder1bit4(.A(A[3]), .B(B[3]), .Cin(C[2]), .S(SUM[3]), .G(G[3]), .P(P[3]));
	
	assign CO = C[3];
	
endmodule