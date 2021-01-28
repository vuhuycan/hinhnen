module bound_flasher (clk, rst_n, flick, lamp);
parameter NUM_LAMP = 16;
parameter NUM_LAMP_CODED = 4;
input clk, rst_n, flick;			
output [NUM_LAMP-1:0] lamp;
wire clk, rst_n, flick;
wire [NUM_LAMP_CODED-1:0] lamp_coded;
wire [NUM_LAMP-1:0] lamp;
wire up, down;
defparam i_lamp_behave_control.NUM_LAMP_CODED = 4;
defparam i_lamp_signal_decode.NUM_LAMP = NUM_LAMP;
lamp_behave_control i_lamp_behave_control (clk, rst_n, flick, lamp_coded, up, down);
lamp_signal_decode i_lamp_signal_decode(clk, rst_n, up, down, lamp_coded, lamp);

endmodule

module lamp_behave_control (clk, rst_n, flick, lamp_coded, up, down);
parameter NUM_LAMP_CODED = 4;
input clk, rst_n, flick;
input [NUM_LAMP_CODED-1:0] lamp_coded;
output up, down;
wire clk, rst_n, flick;
wire [NUM_LAMP_CODED-1:0] lamp_coded;
reg up, down;
reg[2:0] state, state_next;
parameter UP_0_15 		=3'd0;
parameter DOWN_15_5 	=3'd1;
parameter UP_5_10 		=3'd2;
parameter DOWN_10_0 	=3'd3;
parameter UP_0_5 		=3'd4;
parameter DOWN_5_0 	=3'd5;
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
	UP_0_15 : begin
		if (lamp_coded==4'b0) begin
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
		else if (lamp_coded==4'hf) begin
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
		if (lamp_coded==4'h5) begin
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
		if (lamp_coded==4'ha) begin
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
		if (lamp_coded==4'b0) begin
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
		if (lamp_coded==4'h5) begin
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
		if (lamp_coded==4'b0) begin
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
				
module lamp_signal_decode (clk, rst_n, up, down, lamp_coded, lamp);
parameter NUM_LAMP_CODED = 4;
parameter NUM_LAMP = 16;
input clk, rst_n, up, down;
output [NUM_LAMP_CODED-1:0] lamp_coded;				
output [NUM_LAMP-1:0] lamp;

wire clk, rst_n, up, down;
reg [NUM_LAMP_CODED-1:0] lamp_coded, lamp_coded_next;
reg [NUM_LAMP-1:0] lamp;

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		lamp_coded <= 0;
	end
	else begin
		lamp_coded <= lamp_coded_next;
	end
end

always @(up or down) lamp[0] = up | down;

always @(lamp_coded or up or down) begin
	case ({up,down})
	2'b00: begin
		lamp_coded_next = lamp_coded;
	end
	2'b01: begin
		lamp_coded_next = lamp_coded -4'b1;
	end
	2'b10: begin
		lamp_coded_next = lamp_coded +1'b1;
	end
	default: begin
		lamp_coded_next = 0;
	end
	endcase
end

always @(lamp_coded) begin
	case (lamp_coded)
	4'h0 : lamp[15:1] = 15'h_00_00;
	4'h1 : lamp[15:1] = 15'h_00_01;
	4'h2 : lamp[15:1] = 15'h_00_03;
	4'h3 : lamp[15:1] = 15'h_00_07;
	4'h4 : lamp[15:1] = 15'h_00_0f;
	4'h5 : lamp[15:1] = 15'h_00_1f;
	4'h6 : lamp[15:1] = 15'h_00_3f;
	4'h7 : lamp[15:1] = 15'h_00_7f;
	4'h8 : lamp[15:1] = 15'h_00_ff;
	4'h9 : lamp[15:1] = 15'h_01_ff;
	4'ha : lamp[15:1] = 15'h_03_ff;
	4'hb : lamp[15:1] = 15'h_07_ff;
	4'hc : lamp[15:1] = 15'h_0f_ff;
	4'hd : lamp[15:1] = 15'h_1f_ff;
	4'he : lamp[15:1] = 15'h_3f_ff;
	4'hf : lamp[15:1] = 15'h_7f_ff;
	endcase
end
/*
always @(lamp_coded) begin
	4'h0 : lamp = 16'h_00_01;
	4'h1 : lamp = 16'h_00_03;
	4'h2 : lamp = 16'h_00_07;
	4'h3 : lamp = 16'h_00_0f;
	4'h4 : lamp = 16'h_00_1f;
	4'h5 : lamp = 16'h_00_3f;
	4'h6 : lamp = 16'h_00_7f;
	4'h7 : lamp = 16'h_00_ff;
	4'h8 : lamp = 16'h_01_ff;
	4'h9 : lamp = 16'h_03_ff;
	4'ha : lamp = 16'h_07_ff;
	4'hb : lamp = 16'h_0f_ff;
	4'hc : lamp = 16'h_1f_ff;
	4'hd : lamp = 16'h_3f_ff;
	4'he : lamp = 16'h_7f_ff;
	4'hf : lamp = 16'h_ff_ff;
	end */

endmodule
