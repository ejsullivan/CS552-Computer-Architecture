module alu (A, B, ALU_Op, Branch_Op, Out, isTaken);

	input [15:0] A;
	input [15:0] B;
	input [3:0] ALU_Op;
	input [1:0] Branch_Op;
	output [15:0] Out;
	output isTaken;
	
	wire [15:0] intermediateA;
	wire [15:0] sum, shiftResult;
	wire cin;
	wire isCO;
	reg [15:0] intermediateOut;
	reg isTaken;
	
	claAdder16 adder(.A(intermediateA), .B(B), .CIN(cin), .SUM(sum), .CO(isCO));
	shifter shift(.In(A), .Cnt(B[3:0]), .ALU_Op(ALU_Op), .Out(shiftResult));
	
	assign intermediateA = cin ? ~A : A;
	assign Out = intermediateOut;
	assign cin = (ALU_Op == 1) || (ALU_Op == 9) || (ALU_Op == 10) || (ALU_Op == 11); 
		// be careful, might mess things up if NOT (0 or 1)

	always @(*) begin
		case(ALU_Op)
			0: intermediateOut = sum;		// add
			1: intermediateOut = sum;		// sub
			2: intermediateOut = A ^ B;		// xor
			3: intermediateOut = A & ~B;		// andn
			4: intermediateOut = shiftResult;	// rol
			5: intermediateOut = shiftResult;	// sll
			6: intermediateOut = shiftResult;	// ror
			7: intermediateOut = shiftResult;	// srl
			8: intermediateOut = {A[0], A[1], A[2], A[3], A[4], A[5], A[6], A[7], A[8], A[9], A[10], A[11], A[12], A[13], A[14], A[15]}; // btr
			9: intermediateOut = (A == B);		// seq
			10: intermediateOut = A[15] == B[15] ? sum[15] == 0 && A != B : // slt	// if both same sign
						A[15] == 0 && B[15] == 1 ? 0 :			// elseif A is pos and B is neg
						1; 						// else A is neg and B is pos
				// checking sum[15] == 0 only works if both are same signed. So do additional comparison based on whether signs are the same
			11: intermediateOut = A[15] == B[15] ? sum[15] == 0 :	// sle	// if both same sign
						A[15] == 0 && B[15] == 1 ? 0 :		// elseif A is pos and B is neg
						1; 					// else A is neg and B is pos
			12: intermediateOut = (isCO == 1);	// sco
			13: intermediateOut = B;		// lbi
			14: intermediateOut = (A << 8) | B[7:0];// slbi
			default: intermediateOut = 16'hffff; 
		endcase
	end

	always @(*) begin
		case(Branch_Op)
			0: isTaken = A == 0;
			1: isTaken = A != 0;
			2: isTaken = A[15] == 1;
			3: isTaken = A[15] == 0;
			default: isTaken = 0; 
		endcase
	end
	
endmodule
