// ============================================================================
//        __
//   \\__/ o\    (C) 2019-2020  Robert Finch, Waterloo
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@finitron.ca
//       ||
//
//
// This source file is free software: you can redistribute it and/or modify 
// it under the terms of the GNU Lesser General Public License as published 
// by the Free Software Foundation, either version 3 of the License, or     
// (at your option) any later version.                                      
//                                                                          
// This source file is distributed in the hope that it will be useful,      
// but WITHOUT ANY WARRANTY; without even the implied warranty of           
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            
// GNU General Public License for more details.                             
//                                                                          
// You should have received a copy of the GNU General Public License        
// along with this program.  If not, see <http://www.gnu.org/licenses/>.    
//                                                                          
//
// ============================================================================
//
`include "..\inc\Gambit-config.sv"
`include "..\inc\Gambit-defines.sv"
`include "..\inc\Gambit-types.sv"

module fpuIssue(rst, clk, ce, could_issue, fpu0_idle, fpu1_idle, iq_fpu, iq_prior_sync, iq_prior_fsync, issue0, issue1);
input rst;
input clk;
input ce;
input [`IQ_ENTRIES-1:0] could_issue;
input fpu0_idle;
input fpu1_idle;
input [`IQ_ENTRIES-1:0] iq_fpu;
input [`IQ_ENTRIES-1:0] iq_prior_sync;
input [`IQ_ENTRIES-1:0] iq_prior_fsync;
output reg [`IQ_ENTRIES-1:0] issue0;
output reg [`IQ_ENTRIES-1:0] issue1;

integer n;
reg [`IQ_ENTRIES-1:0] issue0p;
reg [`IQ_ENTRIES-1:0] issue1p;

always @*
begin
	issue0p = {`IQ_ENTRIES{1'b0}};
	issue1p = {`IQ_ENTRIES{1'b0}};
	
	if (fpu0_idle) begin
		for (n = 0; n < `IQ_ENTRIES; n = n + 1) begin
			if (could_issue[n] && iq_fpu[n]
			&& issue0p == {`IQ_ENTRIES{1'b0}}
			// If there are no valid queue entries prior it doesn't matter if there is
			// a sync.
			&& (!(iq_prior_sync[n]|iq_prior_fsync[n]))
			)
			  issue0p[n] = `TRUE;
		end
	end

	if (fpu1_idle && `NUM_ALU > 1) begin
		for (n = 0; n < `IQ_ENTRIES; n = n + 1) begin
			if (could_issue[n] && iq_fpu[n]
				&& !issue0p[n]
				&& issue1p == {`IQ_ENTRIES{1'b0}}
				&& (!(iq_prior_sync[n]|iq_prior_fsync[n]))
			)
			  issue1p[n] = `TRUE;
		end
	end
end

always @(posedge clk)
if (ce)
	issue0 <= issue0p;
always @(posedge clk)
if (ce)
	issue1 <= issue1p;

endmodule
