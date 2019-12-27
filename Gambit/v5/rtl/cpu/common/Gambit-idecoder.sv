// ============================================================================
//        __
//   \\__/ o\    (C) 2019  Robert Finch, Waterloo
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
// ============================================================================
//
`include "..\inc\Gambit-config.sv"
`include "..\inc\Gambit-defines.sv"

module idecoder(instr,predict_taken,bus);
input [51:0] instr;
input predict_taken;
output reg [`IBTOP:0] bus;

parameter TRUE = 1'b1;
parameter FALSE = 1'b0;
// Memory access sizes
parameter byt = 3'd0;
parameter word = 3'd1;

function IsAlu;
input [51:0] isn;
case(isn[6:0])
`MTx,`MFx,
`ADDIS,`ANDIS,`ORIS,
`PERM_3R,`CSR,
`ADD_3R,`ADD_RI22,`ADD_RI35,
`SUB_3R,`SUB_RI22,`SUB_RI35,
`MUL_3R,`MUL_RI22,`MUL_RI35,
`AND_3R,`AND_RI22,`AND_RI35,
`OR_3R,`OR_RI22,`OR_RI35,
`EOR_3R,`EOR_RI22,`EOR_RI35,
`ASL_3R,`ASR_3R,`ROL_3R,`ROR_3R,`LSR_3R,
`BIT_3R,`BIT_RI22,`BIT_RI35,
`CMP_3R,`CMP_RI22,`CMP_RI35,
`CMPU_3R,`CMPU_RI22,`CMPU_RI35:
	IsAlu = TRUE;
default:	IsAlu = FALSE;
endcase
endfunction

function HasConst8;
input [51:0] isn;
case(isn[6:0])
`ADD_3R,`SUB_3R,`MUL_3R,
`AND_3R,`OR_3R,`EOR_3R,
`BIT_3R,`CMP_3R,`CMPU_3R,
`ASL_3R,`ASR_3R,`ROL_3R,`ROR_3R,`LSR_3R,
`LD_D8,`ST_D8,`LDB_D8,`STB_D8:
	HasConst8 = TRUE;
default:	HasConst8 = FALSE;
endcase
endfunction

function HasConst22;
input [51:0] isn;
case(isn[6:0])
`ADD_RI22,`SUB_RI22,`MUL_RI22,
`AND_RI22,`OR_RI22,`EOR_RI22,
`BIT_RI22,`CMP_RI22,`CMPU_RI22,
`LD_D22,`ST_D22,`LDB_D22,`STB_D22:
	HasConst22 = TRUE;
default:	HasConst22 = FALSE;
endcase
endfunction

function HasConst35;
input [51:0] isn;
case(isn[6:0])
`ADD_RI35,`SUB_RI35,`MUL_RI35,
`AND_RI35,`OR_RI35,`EOR_RI35,
`BIT_RI35,`CMP_RI35,`CMPU_RI35,
`LD_D35,`ST_D35,`LDB_D35,`STB_D35:
	HasConst35 = TRUE;
default:	HasConst35 = FALSE;
endcase
endfunction

function IsMem;
input [51:0] isn;
case(isn[6:0])
`LD_D8,`LD_D22,`LD_D35,
`LDB_D8,`LDB_D22,`LDB_D35,
`ST_D8,`ST_D22,`ST_D35,
`STB_D8,`STB_D22,`STB_D35:
	IsMem = TRUE;
default:	IsMem = FALSE;
endcase
endfunction

function IsFlowCtrl;
input [51:0] isn;
case(isn[6:0])
`JAL,`JAL_RN,`BRANCH0,`BRANCH1:
	IsFlowCtrl = TRUE;
default:	IsFlowCtrl = FALSE;
endcase
endfunction

function IsCmp;
input [51:0] isn;
case(isn[6:0])
`CMP_3R,`CMP_RI22,`CMP_RI35,
`CMPU_3R,`CMPU_RI22,`CMPU_RI35:
	IsCmp = TRUE;
default:	IsCmp = FALSE;
endcase
endfunction

function IsLoad;
input [51:0] isn;
case(isn[6:0])
`LD_D8,`LD_D22,`LD_D35,
`LDB_D8,`LDB_D22,`LDB_D35:
	IsLoad = TRUE;
default:
	IsLoad = FALSE;
endcase
endfunction

function IsStore;
input [51:0] isn;
case(isn[6:0])
`ST_D8,`ST_D22,`ST_D35,
`STB_D8,`STB_D22,`STB_D35:
	IsStore = TRUE;
default:
	IsStore = FALSE;
endcase
endfunction

function [2:0] MemSize;
input [51:0] isn;
casez(isn[6:0])
`LDB_D8,`LDB_D22,`LDB_D35,`STB_D8,`STB_D22,`STB_D35:	MemSize = byt;
default:	MemSize = word;
endcase
endfunction

function IsJal;
input [51:0] isn;
IsJal = isn[21:0]==`UO_JMP;
endfunction

// Really IsPredictableBranch
// Does not include BccR's
function IsBranch;
input [51:0] insn;
reg [6:0] opcode = insn[`OPCODE];
IsBranch = opcode==`BRANCH0 || opcode==`BRANCH1;
endfunction

function IsRFW;
input [51:0] isn;
case(isn[6:0])
`NOP:	IsRFW = FALSE;
`BRANCH0,`BRANCH1:	IsRFW = FALSE;
`ST_D8,`ST_D22,`ST_D35,
`STB_D8,`STB_D22,`STB_D35:	IsRFW = FALSE;
default:	IsRFW = TRUE;
endcase
endfunction

always @*
begin
	bus <= 167'h0;
	bus[`IB_CMP] <= IsCmp(instr);
	bus[`IB_CONST] <= 
		HasConst8(instr) ? {{44{instr[24]}},instr[24:17]} :
		HasConst22(instr) ? {{30{instr[38]}},instr[38:17]} :
		{{17{instr[51]}},instr[51:17]}
		;
//	bus[`IB_CONST] <= {{58{instr[39]}},instr[39:35],instr[32:16]};
//	bus[`IB_RT]		 <= fnRd(instr,ven,vl,thrd) | {thrd,7'b0};
//	bus[`IB_RC]		 <= fnRc(instr,ven,thrd) | {thrd,7'b0};
//	bus[`IB_RA]		 <= fnRa(instr,ven,vl,thrd) | {thrd,7'b0};
//	bus[`IB_IMM]	 <= HasConst(instr);
	// IB_BT is now used to indicate when to update the branch target buffer.
	// This occurs when one of the instructions with an unknown or calculated
	// target is present.
	bus[`IB_BT]		 <= 1'b0;
	bus[`IB_ALU]   <= IsAlu(instr);
	bus[`IB_FC]		 <= IsFlowCtrl(instr);
//	bus[`IB_CANEX] <= fnCanException(instr);
	bus[`IB_LOAD]	 <= IsLoad(instr);
	bus[`IB_STORE]	<= IsStore(instr);
	bus[`IB_MEMSZ]  <= MemSize(instr);
	bus[`IB_MEM]		<= IsMem(instr);
	bus[`IB_JAL]		<= IsJal(instr);
	bus[`IB_BR]			<= IsBranch(instr);
	bus[`IB_RFW]		<= IsRFW(instr);
end

endmodule

