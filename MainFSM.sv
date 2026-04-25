module mainFSM(
    input  logic        clk, reset,
    input  logic [6:0]  op,
    output logic [1:0]  alusrca, alusrcb,
    output logic [1:0]  resultsrc,
    output logic        adrsrc,
    output logic [1:0]  aluop,
    output logic        irwrite, pcupdate,
    output logic        regwrite, memwrite,
    output logic        branch
);
logic [3:0] state, state_next;

always_ff @(posedge clk, posedge reset)
    if (reset) state <= 4'd0;  
    else       state <= state_next;
	always_comb begin
    case(state)
        4'd0: state_next = 4'd1;  
        4'd1: case(op)           
			7'b0000011: state_next = 4'd2 ; // lw
			7'b0100011: state_next = 4'd2 ; // sw
			7'b0110011: state_next = 4'd6 ; // R
			7'b0010011: state_next = 4'd8 ; // I
			7'b1101111: state_next = 4'd9 ; // jal
			7'b1100011: state_next = 4'd10; // beq
			default:	state_next = 4'd0 ;
        endcase
		4'd2: case(op)
			7'b0000011: state_next = 4'd3 ;
			7'b0100011: state_next = 4'd5 ;
			default: 	state_next = 4'd0 ;
			endcase
		4'd3: state_next = 4'd4;
		4'd4: state_next = 4'd0;
		4'd5: state_next = 4'd0;
		4'd6: state_next = 4'd7;
		4'd7: state_next = 4'd0;
		4'd8: state_next = 4'd7;
		4'd9: state_next = 4'd7;
		4'd10:state_next = 4'd0;
		default: state_next = 4'd0;
    endcase
end
always_comb begin
    {alusrca, alusrcb, resultsrc, adrsrc, aluop,
     irwrite, pcupdate, regwrite, memwrite, branch} = '0;
    
        case(state)
            4'd0: begin  // Fetch
                irwrite   = 1'b1;
                pcupdate  = 1'b1;
                alusrca   = 2'b00;
                alusrcb   = 2'b10;
                aluop     = 2'b00;
                resultsrc = 2'b10;
            end
            4'd1: begin  // Decode
                alusrca = 2'b01;
                alusrcb = 2'b01;
                aluop   = 2'b00;
            end
            4'd2: begin  // MemAdr
                alusrca = 2'b10;
                alusrcb = 2'b01;
                aluop   = 2'b00;
            end
            4'd3: begin  // MemRead
                resultsrc = 2'b00;
                adrsrc    = 1'b1;
            end
            4'd4: begin  // MemWB
                resultsrc = 2'b01;
                regwrite  = 1'b1;
            end
            4'd5: begin  // MemWrite
                resultsrc = 2'b00;
                adrsrc    = 1'b1;
                memwrite  = 1'b1;
            end
            4'd6: begin  // ExecuteR
                alusrca = 2'b10;
                alusrcb = 2'b00;
                aluop   = 2'b10;
            end
            4'd7: begin  // ALUWB
                resultsrc = 2'b00;
                regwrite  = 1'b1;
            end
            4'd8: begin  // ExecuteI
                alusrca = 2'b10;
                alusrcb = 2'b01;
                aluop   = 2'b10;
            end
            4'd9: begin  // JAL
                alusrca   = 2'b01;
                alusrcb   = 2'b10;
                aluop     = 2'b00;
                resultsrc = 2'b00;
                pcupdate  = 1'b1;
            end
            4'd10: begin  // BEQ
                alusrca   = 2'b10;
                alusrcb   = 2'b00;
                aluop     = 2'b01;
                resultsrc = 2'b00;
                branch    = 1'b1;
            end
        endcase
    end
endmodule