module claAdder16(A, B, CIN, SUM, CO);
	input[15:0] A, B;
	input CIN;
	output[15:0] SUM;
	output CO;
	wire Cout1, Cout2, Cout3;
	claAdder4bit claAdder4bit1(.A(A[3:0]), .B(B[3:0]), .SUM(SUM[3:0]), .CI(CIN), .CO(Cout1));
	claAdder4bit claAdder4bit2(.A(A[7:4]), .B(B[7:4]), .SUM(SUM[7:4]), .CI(Cout1), .CO(Cout2));
	claAdder4bit claAdder4bit3(.A(A[11:8]), .B(B[11:8]), .SUM(SUM[11:8]), .CI(Cout2), .CO(Cout3));
	claAdder4bit claAdder4bit4(.A(A[15:12]), .B(B[15:12]), .SUM(SUM[15:12]), .CI(Cout3), .CO(CO));
endmodule