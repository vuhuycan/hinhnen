module lamp_behave_control (clk, rst_n, flick, lamp, up, down);
parameter NUM_LAMP = 16;
input clk, rst_n, flick;
input [NUM_LAMP-1:0] lamp;
output up, down;
wire clk, rst_n, flick;
wire [NUM_LAMP-1:0] lamp;
reg up, down;
reg[2:0] state, state_next;
parameter UP_0_15 =		3'd0;
parameter DOWN_15_5 =	3'd1;
parameter UP_5_10 =		3'd2;
parameter DOWN_10_0 =	3'd3;
parameter UP_0_5 =		3'd4;
parameter DOWN_5_0 =	3'd5;
always @ (posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		state <= 3'b0;
	end
	else begin
		state <= state_next;
	end
end

always @ (flick or state) begin
	case (state)
	UP_0_15: begin
		if (lamp==16'b0 & flick) begin
			up = 1'b1;
			down = 1'b0;
			state_next = state;
		end
		else if (lamp==16'hff_ff) begin
			up = 1'b0;
			down = 1'b1;
			state_next = DOWN_15_5;
		end
		else begin
			up = 1'b1;
			down = 1'b0;
			state_next = state;
		end
	end
	DOWN_15_5: begin
		if (lamp==16'h00_1f) begin
			up = 1'b1;
			down = 1'b0;
			if (flick) begin
				state_next = UP_0_15;
			end
			else begin
				state_next = UP_5_10;
			end
		end
		else begin
			up = 1'b0;
			down = 1'b1;
			state_next = state;
		end
	end
	UP_5_10: begin
		if (lamp==16'h03_ff) begin
			up = 1'b0;
			down = 1'b1;
			state_next = DOWN_10_0;
		end
		else begin
			up = 1'b1;
			down = 1'b0;
			state_next = state;
		end
	end
	DOWN_10_0: begin
		if (lamp==16'b0) begin
			up = 1'b1;
			down = 1'b0;
			if (flick) begin
				state_next = UP_5_10;
			end
			else begin
				state_next = UP_0_5;
			end
		end
		else begin
			up = 1'b0;
			down = 1'b1;
			state_next = state;
		end
	end
	UP_0_5: begin
		if (lamp==16'h00_1f) begin
			up = 1'b0;
			down = 1'b1;
			state_next = DOWN_5_0;
		end
		else begin
			up = 1'b1;
			down = 1'b0;
			state_next = state;
		end
	end
	DOWN_5_0: begin
		if (lamp==16'b0) begin
			if (flick) begin
				up = 1'b1;
				down = 1'b0;
			end
			else begin
				up = 1'b0;
				down = 1'b0;
			end
			state_next = UP_0_15;
		end
		else begin
			up = 1'b0;
			down = 1'b1;
			state_next = state;
		end
	end
	default: begin
		up = 1'bx;
		down = 1'bx;
		state_next = 1'bxxx;
	end
	endcase
end

endmodule		
				
module shift_register (clk, rst_n, up, down, lamp);
parameter NUM_LAMP = 16;
input clk, rst_n, up, down;				
output [NUM_LAMP-1:0] lamp;
wire clk, rst_n, up, down;
reg [NUM_LAMP-1:0] lamp, lamp_next;

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		lamp <= NUM_LAMP'b0;
	end
	else begin
		lamp <= lamp_next;
	end
end

always @(lamp) begin
	case ({up,down})
	2'b00: begin
		lamp_next = lamp;
	end
	2'b01: begin
		lamp_next = {1'b0,lamp[NUM_LAMP-1:1]};
	end
	2'b10: begin
		lamp_next = {lamp[NUM_LAMP-2:0],1'b1};
	end
	default: begin
		lamp_next = NUM_LAMP'b0;
	end
	endcase
end

endmodule
				
				
				
				
				
				
				
				
				