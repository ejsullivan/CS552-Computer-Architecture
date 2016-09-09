module shifter (In, Cnt, ALU_Op, Out);

	input [15:0] In;
	input [3:0]  Cnt;
	input [3:0]  ALU_Op;
	output [15:0] Out;

	reg [15:0] shiftIntermediate1;
	reg [15:0] shiftIntermediate2;
	reg [15:0] shiftIntermediate3;
	reg [15:0] shiftIntermediate4;
	
	assign Out = shiftIntermediate4;
	
	always @(*)	begin
		case (ALU_Op)
			// rotate left
			4: begin
				shiftIntermediate1 = Cnt[0] == 1 ? {In[14:0], In[15]} : In;
				shiftIntermediate2 = Cnt[1] == 1 ? {shiftIntermediate1[13:0], shiftIntermediate1[15:14]} : shiftIntermediate1;
				shiftIntermediate3 = Cnt[2] == 1 ? {shiftIntermediate2[11:0], shiftIntermediate2[15:12]} : shiftIntermediate2;
				shiftIntermediate4 = Cnt[3] == 1 ? {shiftIntermediate3[7:0], shiftIntermediate3[15:8]} : shiftIntermediate3;
			end
			
			// shift left
			5: begin
				shiftIntermediate1 = Cnt[0] == 1 ? In << 1 : In;
				shiftIntermediate2 = Cnt[1] == 1 ? shiftIntermediate1 << 2 : shiftIntermediate1;
				shiftIntermediate3 = Cnt[2] == 1 ? shiftIntermediate2 << 4 : shiftIntermediate2;
				shiftIntermediate4 = Cnt[3] == 1 ? shiftIntermediate3 << 8 : shiftIntermediate3;
			end
			
			// rotate right
			6: begin
				shiftIntermediate1 = Cnt[0] == 1 ? {In[0], In[15:1]} : In;
				shiftIntermediate2 = Cnt[1] == 1 ? {shiftIntermediate1[1:0], shiftIntermediate1[15:2]} : shiftIntermediate1;
				shiftIntermediate3 = Cnt[2] == 1 ? {shiftIntermediate2[3:0], shiftIntermediate2[15:4]} : shiftIntermediate2;
				shiftIntermediate4 = Cnt[3] == 1 ? {shiftIntermediate3[7:0], shiftIntermediate3[15:8]} : shiftIntermediate3;
			end
			
			// shift right logical
			7: begin
				shiftIntermediate1 = Cnt[0] == 1 ? In >> 1 : In;
				shiftIntermediate2 = Cnt[1] == 1 ? shiftIntermediate1 >> 2 : shiftIntermediate1;
				shiftIntermediate3 = Cnt[2] == 1 ? shiftIntermediate2 >> 4 : shiftIntermediate2;
				shiftIntermediate4 = Cnt[3] == 1 ? shiftIntermediate3 >> 8 : shiftIntermediate3;
			end

		endcase
	end
	
endmodule
