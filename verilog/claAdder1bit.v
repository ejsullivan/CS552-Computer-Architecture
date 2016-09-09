module claAdder1bit(A, B, Cin, S, G, P);
	input A, B, Cin;
	output S, G, P;
	wire n1, n2, n3, _n2, _n3, _Cout;
	xor2 AxorB(.in1(A), .in2(B), .out(n1));
	xor2 ABxorCin(.in1(n1), .in2(Cin), .out(S));
	nand2 AxorBandCin(.in1(n1), .in2(Cin), .out(n2));
	not1 notN2(.in1(n2), .out(_n2));
	nand2 AandB(.in1(A), .in2(B), .out(n3));
	not1 notN3(.in1(n3), .out(_n3));
	nor2 CoutOr(.in1(_n2), .in2(_n3), .out(_Cout));
	not1 notCout(.in1(_Cout), .out(Cout));
	
	assign G = _n3;
	assign P = n1;
endmodule
	
	