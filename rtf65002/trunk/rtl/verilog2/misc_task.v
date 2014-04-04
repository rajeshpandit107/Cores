
task inc_sp;
begin
	if (m816) begin
		radr <= {spage[31:24],8'h00,sp_inc[15:2]};
		radr2LSB <= sp_inc[1:0];
		sp <= sp_inc;
	end
	else begin
		radr <= {spage[31:16],8'h01,sp_inc[7:2]};
		radr2LSB <= sp_inc[1:0];
		sp <= {8'h1,sp_inc[7:0]};
	end
end
endtask

task tsk_push;
input [5:0] SW8;
input [5:0] SW16;
begin
	if (m816) begin
		radr <= {spage[31:24],8'h00,sp[15:2]};
		radr2LSB <= sp[1:0];
		wadr <= {spage[31:24],8'h00,sp[15:2]};
		wadr2LSB <= sp[1:0];
		if (m16) begin
			store_what <= SW16;
			sp <= sp_dec2;
		end
		else begin
			store_what <= SW8;
			sp <= sp_dec;
		end
	end
	else begin
		radr <= {spage[31:16],8'h01,sp[7:2]};
		radr2LSB <= sp[1:0];
		wadr <= {spage[31:16],8'h01,sp[7:2]};
		wadr2LSB <= sp[1:0];
		store_what <= SW8;
		sp <= sp_dec;
	end
	state <= STORE1;
end
endtask