/* $Author: karu $ */
/* $LastChangedDate: 2009-04-24 09:28:13 -0500 (Fri, 24 Apr 2009) $ */
/* $Rev: 77 $ */

module mem_system(/*AUTOARG*/
   // Outputs
   DataOut, Done, Stall, CacheHit, err, 
   // Inputs
   Addr, DataIn, Rd, Wr, createdump, clk, rst
   );
   
   input [15:0] Addr;
   input [15:0] DataIn;
   input        Rd;
   input        Wr;
   input        createdump;
   input        clk;
   input        rst;
   
   output [15:0] DataOut;
   output Done;
   output Stall;
   output CacheHit;
   output err;

   wire [15:0] mem_data_out, data_out0, data_out2, mem_addr;//, DataOutIntermediate;
   wire [4:0] tag_out0, tag_out2;
   wire [3:0] mem_busy;
   wire [3:0] state;
   wire [2:0] AddrOffset;
   wire [2:0] AddrOffsetDelayed;
   wire isStallInState;
   wire enable0, enable2;

   reg [3:0] nxt_state;
   reg Done, canHit, returnToRead, nxt_isStallInState, CacheHit, isFromMem, isWriteback, comp0, comp2, write0, write2, victimwayIn, isCache0Victimized;
   reg [2:0] AddrOffsetIntermediate;

   localparam IDLE          = 4'b0000; // 0
   localparam COMPARE_READ  = 4'b0001; // 1
   localparam STALL0 = 4'b0010; // 2
   localparam STALL1 = 4'b0011; // 3
   localparam STALL2 = 4'b0100; // 4
   localparam STALL3 = 4'b0101; // 5
   localparam COMPARE_WRITE = 4'b0110; // 6
   localparam ACCESS_READ   = 4'b0111; // 7
   localparam WRITE_BACK0   = 4'b1000; // 8 change line 89ish if you update this
   localparam WRITE_BACK1   = 4'b1001; // 9
   localparam WRITE_BACK2   = 4'b1010; // 10/a
   localparam WRITE_BACK3   = 4'b1011; // 11/b
   localparam ALLOCATE0     = 4'b1100; // 12/c
   localparam ALLOCATE1     = 4'b1101; // 13/d
   localparam ALLOCATE2     = 4'b1110; // 14/e
   localparam ALLOCATE3     = 4'b1111; // 15/f

   /* data_mem = 1, inst_mem = 0 *
    * needed for cache parameter */
   parameter mem_type = 0;
   cache #(0 + mem_type) c0(// Outputs
                          .tag_out              (tag_out0),
                          .data_out             (data_out0),
                          .hit                  (hit0),
                          .dirty                (dirty0),
                          .valid                (valid0),
                          .err                  (err0),
                          // Inputs
                          .enable               (enable0),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
                          .tag_in               (Addr[15:11]),
                          .index                (Addr[10:3]),
                          .offset               (isFromMem ? AddrOffsetDelayed : AddrOffset),
                          .data_in              (isFromMem ? mem_data_out : DataIn),
                          .comp                 (comp0),
                          .write                (write0),
                          .valid_in             (isCache0Victimized));
   cache #(2 + mem_type) c1(// Outputs
                          .tag_out              (tag_out2),
                          .data_out             (data_out2),
                          .hit                  (hit2),
                          .dirty                (dirty2),
                          .valid                (valid2),
                          .err                  (err2),
                          // Inputs
                          .enable               (enable2),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
                          .tag_in               (Addr[15:11]),
                          .index                (Addr[10:3]),
                          .offset               (isFromMem ? AddrOffsetDelayed : AddrOffset),
                          .data_in              (isFromMem ? mem_data_out : DataIn),
                          .comp                 (comp2),
                          .write                (write2),
                          .valid_in             (!isCache0Victimized));

   four_bank_mem mem(// Outputs
                     .data_out          (mem_data_out),
                     .stall             (mem_stall),
                     .busy              (mem_busy),
                     .err               (mem_err),
                     // Inputs
                     .clk               (clk),
                     .rst               (rst),
                     .createdump        (createdump),
                     .addr              (mem_addr),
                     .data_in           (isCache0Victimized ? data_out0 : data_out2), // since you do not write directly from reg to memory, data_in always comes from cache
                     .wr                (nxt_state[3:2] == 2'b10), // this was our error of why it skipped index 0 for busy, was state isntead of nxt_state. OK since all WRITE_BACK stages have the same [3:2]
                     .rd                (nxt_state[3:2] == 2'b11)); // read if accessWrite (not used anymore) or allocate
   
   // your code here
   // register register0(.dataOut(DataOut), .dataIn(data_out0), .clk(clk), .rst(rst), .w_en(hit0 && valid0));
   // assign DataOutIntermediate = (hit0 && valid0) ? data_out0 : 16'h0000;
   // assign DataOut = state == IDLE  || CacheHit ? data_out0 : 16'h0000;//hit0 && valid0 ? data_out0 : DataIn;
   // assign DataOut = state == IDLE  || ((state == COMPARE_READ || state == COMPARE_WRITE) && (hit0 && valid0 || hit2 && valid2)) ? data_out0 : 16'h0000;//hit0 && valid0 ? data_out0 : DataIn;
   assign DataOut = (state == COMPARE_READ || state == COMPARE_WRITE) ? ((hit0 && valid0) ? data_out0 :  ((hit2 && valid2) ? data_out2 : 16'h0000)) : 16'h0000;//hit0 && valid0 ? data_out0 : DataIn;
   assign Stall = nxt_state != IDLE || state != IDLE; // mem_stall;
   assign err = (err0 || err2 || mem_err) && (Rd || Wr);
   assign AddrOffset = comp0 || comp2 ? Addr[2:0] : AddrOffsetIntermediate;
   assign mem_addr = {(isWriteback ? {(isCache0Victimized ? tag_out0 : tag_out2), Addr[10:3]} : Addr[15:3]), AddrOffset}; // isWriteback ? {tag_out0, Addr[10:3], AddrOffset} : {Addr[15:3], AddrOffset};
   statereg statereg0(.state(state), .nxt_state(nxt_state), .clk(clk), .rst(rst));
   dff dff0(.q(isStallInState), .d(nxt_isStallInState), .clk(clk), .rst(rst));

   dff dff1(.q(AddrOffsetDelayed[0]), .d(AddrOffset[0]), .clk(clk), .rst(rst));
   dff dff2(.q(AddrOffsetDelayed[1]), .d(AddrOffset[1]), .clk(clk), .rst(rst));
   dff dff3(.q(AddrOffsetDelayed[2]), .d(AddrOffset[2]), .clk(clk), .rst(rst));

   dff dff4(.q(victimway), .d(victimwayIn), .clk(clk), .rst(rst));

   always @(*) begin
      Done = 0;
      CacheHit = 0;
      nxt_state = IDLE;
      isFromMem = 0;
      comp0 = 0;
      comp2 = 0;
      write0 = 0;
      write2 = 0;
      AddrOffsetIntermediate = 0;
      isWriteback = 0;
      victimwayIn = 0;
      casex(state)
         IDLE: begin
            //Done = Rd ? 0 : (Wr ? 0 : 1);
            nxt_state = Rd ? COMPARE_READ :
                        Wr ? COMPARE_WRITE :
                             IDLE;
            comp0 = (Rd || Wr) ? 1 : 0;
            comp2 = (Rd || Wr) ? 1 : 0;
            write0 = Wr ? 1 : 0;
            write2 = Wr ? 1 : 0;
            AddrOffsetIntermediate = (hit0 && valid0 || hit2 && valid2) ? Addr[2:0] : 0;
            canHit = 1;
            nxt_isStallInState = 1;
            victimwayIn = victimway;
         end
         COMPARE_READ: begin
            Done = (hit0 && valid0 || hit2 && valid2) ? 1 : 0;
            CacheHit = (canHit && (hit0 && valid0 || hit2 && valid2)) ? 1 : 0;
            nxt_state = (hit0 && valid0  || hit2 && valid2) ? IDLE : (mem_busy[0] ? COMPARE_READ : ACCESS_READ);
            comp0 = (hit0 && valid0) ? 0 : (mem_busy[0] ? 1 : 0);
            comp2 = (hit2 && valid2) ? 0 : (mem_busy[0] ? 1 : 0);
            //write0 = 0; // so just use default
            AddrOffsetIntermediate = (hit0 && valid0 || hit2 && valid2) ? Addr[2:0] : 0;
            isFromMem = (hit0 && valid0 || hit2 && valid2) ? 0 : 1; // dont think this is needed 
            returnToRead = 1;
            victimwayIn = (hit0 && valid0 || hit2 && valid2) ? !victimway : victimway;
         end
         COMPARE_WRITE: begin
            Done = (hit0 && valid0 || hit2 && valid2) ? 1 : 0;
            CacheHit = (canHit && (hit0 && valid0 || hit2 && valid2)) ? 1 : 0;
            nxt_state = (hit0 && valid0 || hit2 && valid2) ? IDLE : ACCESS_READ;
            returnToRead = 0;
            // comp0 = 0; // just use default
            // write0 = 0; // just use default
            victimwayIn = (hit0 && valid0 || hit2 && valid2) ? !victimway : victimway;
         end
         ACCESS_READ: begin
            isCache0Victimized = !valid0 && !valid2 ? 1 :
                                 !valid0 && valid2 ? 1 :
                                 valid0 && !valid2 ? 0 :
                                 victimway;
            nxt_state = mem_stall ? ACCESS_READ : isCache0Victimized ? (dirty0 && valid0 ? WRITE_BACK0 : ALLOCATE0) : (dirty2 && valid2 ? WRITE_BACK0 : ALLOCATE0);
            comp0 = mem_stall ? 0 : (dirty0 ? 0 : 0); // mem_busy[0] || dirty0 ? 0 : 0;
            write0 = mem_stall ? 0 : (dirty0 ? 0 : 1); // mem_busy[0] || dirty0 ? 0 : 1;
            comp2 = mem_stall ? 0 : (dirty2 ? 0 : 0); // mem_busy[0] || dirty0 ? 0 : 0;
            write2 = mem_stall ? 0 : (dirty2 ? 0 : 1); // mem_busy[0] || dirty0 ? 0 : 1;
            isWriteback = mem_stall ? 0 : isCache0Victimized ? (dirty0 && valid0 ? 1 : 0) : (dirty2 && valid2 ? 1 : 0);
            victimwayIn = victimway;
         end
         WRITE_BACK0: begin
            nxt_state = mem_stall ? WRITE_BACK0 : WRITE_BACK1;
            comp0 = 0;
            comp2 = 0;
            write0 = 0;
            write2 = 0;
            AddrOffsetIntermediate = 2;
            isWriteback = 1;
            victimwayIn = victimway;
         end
         WRITE_BACK1: begin
            nxt_state = mem_stall ? WRITE_BACK1 : WRITE_BACK2;
            comp0 = 0;
            comp2 = 0;
            write0 = 0;
            write2 = 0;
            AddrOffsetIntermediate = 4;
            isWriteback = 1;
            victimwayIn = victimway;
         end
         WRITE_BACK2: begin
            nxt_state = mem_stall ? WRITE_BACK2 : WRITE_BACK3;
            comp0 = 0;
            comp2 = 0;
            write0 = 0;
            write2 = 0;
            AddrOffsetIntermediate = 6;
            isWriteback = 1;
            victimwayIn = victimway;
         end
         WRITE_BACK3: begin
            nxt_state = mem_stall ? WRITE_BACK3 : ALLOCATE0;
            comp0 = mem_stall ? 0 : 0;
            comp2 = mem_stall ? 0 : 0;
            write0 = mem_stall ? 0 : 1;
            write2 = mem_stall ? 0 : 1;
            isFromMem = mem_stall ? 0 : 1;
            isWriteback = mem_stall ? 1 : 0;
            victimwayIn = victimway;
         end
         ALLOCATE0: begin
            nxt_state = mem_stall ? ALLOCATE0 : STALL0;
            comp0 = 0;
            comp2 = 0;
            write0 = mem_stall ? 1 : 0;
            write2 = mem_stall ? 1 : 0;
            isFromMem = 1;
            victimwayIn = victimway;
         end
         STALL0: begin
            nxt_state = ALLOCATE1;
            comp0 = 0;
            comp2 = 0;
            write0 = 1;
            write2 = 1;
            AddrOffsetIntermediate = 2;
            isFromMem = 1;
            victimwayIn = victimway;
         end
         ALLOCATE1: begin
            nxt_state = mem_stall ? ALLOCATE1 : STALL1;
            comp0 = 0;
            comp2 = 0;
            write0 = mem_stall ? 1 : 0;
            write2 = mem_stall ? 1 : 0;
            AddrOffsetIntermediate = 2;
            isFromMem = 1;
            victimwayIn = victimway;
         end
         STALL1: begin
            nxt_state = ALLOCATE2;
            comp0 = 0;
            comp2 = 0;
            write0 = 1;
            write2 = 1;
            AddrOffsetIntermediate = 4;
            isFromMem = 1;
            victimwayIn = victimway;
         end
         ALLOCATE2: begin
            nxt_state = mem_stall ? ALLOCATE2 : STALL2;
            comp0 = 0;
            comp2 = 0;
            write0 = mem_stall ? 1 : 0;
            write2 = mem_stall ? 1 : 0;
            AddrOffsetIntermediate = 4;
            isFromMem = 1;
            victimwayIn = victimway;
         end
         STALL2: begin
            nxt_state = ALLOCATE3;
            comp0 = 0;
            comp2 = 0;
            write0 = 1;
            write2 = 1;
            AddrOffsetIntermediate = 6;
            isFromMem = 1;
            victimwayIn = victimway;
         end
         ALLOCATE3: begin
            nxt_state = mem_stall ? ALLOCATE3 : STALL3;
            comp0 = 0;
            comp2 = 0;
            write0 = mem_stall ? 1 : 0;
            write2 = mem_stall ? 1 : 0;
            AddrOffsetIntermediate = 6;
            canHit = 0;
            isFromMem = 1;
            victimwayIn = victimway;
         end
         STALL3: begin
            nxt_state = isStallInState ? STALL3 : (returnToRead ? COMPARE_READ : COMPARE_WRITE);
            comp0 = isStallInState ? 0 : 1;
            comp2 = isStallInState ? 0 : 1;
            write0 = isStallInState ? 1 : (returnToRead ? 0 : 1);
            write2 = isStallInState ? 1 : (returnToRead ? 0 : 1);
            isFromMem = isStallInState ? 1 : 0;
            nxt_isStallInState = 0;
            victimwayIn = victimway;
            //nxt_state = returnToRead ? COMPARE_READ : COMPARE_WRITE;
            //comp0 = 1;
            //write0 = returnToRead ? 0 : 1;
         end
      endcase
   end

   assign enable0 = state == IDLE || state == COMPARE_READ || state == COMPARE_WRITE || state == ACCESS_READ || isCache0Victimized; // TODO compare valid tags
   assign enable2 = state == IDLE || state == COMPARE_READ || state == COMPARE_WRITE || state == ACCESS_READ || !isCache0Victimized;

endmodule // mem_system

   


// DUMMY LINE FOR REV CONTROL :9:
