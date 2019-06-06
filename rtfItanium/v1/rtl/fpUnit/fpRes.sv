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
module fpRes(clk, a, o);
parameter WID = 128;
localparam MSB = WID-1;
localparam EMSB = WID==128 ? 14 :
                  WID==96 ? 14 :
                  WID==80 ? 14 :
                  WID==64 ? 10 :
				  WID==52 ? 10 :
				  WID==48 ? 11 :
				  WID==44 ? 10 :
				  WID==42 ? 10 :
				  WID==40 ?  9 :
				  WID==32 ?  7 :
				  WID==24 ?  6 : 4;
localparam FMSB = WID==128 ? 111 :
                  WID==96 ? 79 :
                  WID==80 ? 63 :
                  WID==64 ? 51 :
				  WID==52 ? 39 :
				  WID==48 ? 34 :
				  WID==44 ? 31 :
				  WID==42 ? 29 :
				  WID==40 ? 28 :
				  WID==32 ? 22 :
				  WID==24 ? 15 : 9;
input clk;
input [WID-1:0] a;
output [WID-1:0] o;

// This table encodes two endpoints k0, k1 of a piece-wise linear
// approximation to the reciprocal in the range [1.0,2.0).
(* ram_style="block" *)
reg [31:0] k01 [0:1023];
initial begin
k01[0] = 32'hfffeffc1;
k01[1] = 32'hffbfff41;
k01[2] = 32'hff7ffec2;
k01[3] = 32'hff3ffe43;
k01[4] = 32'hfefffdc4;
k01[5] = 32'hfec0fd46;
k01[6] = 32'hfe81fcc8;
k01[7] = 32'hfe42fc4b;
k01[8] = 32'hfe02fbce;
k01[9] = 32'hfdc4fb51;
k01[10] = 32'hfd85fad5;
k01[11] = 32'hfd46fa59;
k01[12] = 32'hfd07f9dd;
k01[13] = 32'hfcc9f962;
k01[14] = 32'hfc8bf8e7;
k01[15] = 32'hfc4cf86d;
k01[16] = 32'hfc0ef7f2;
k01[17] = 32'hfbd0f779;
k01[18] = 32'hfb92f6ff;
k01[19] = 32'hfb55f686;
k01[20] = 32'hfb17f60d;
k01[21] = 32'hfad9f595;
k01[22] = 32'hfa9cf51d;
k01[23] = 32'hfa5ff4a5;
k01[24] = 32'hfa22f42e;
k01[25] = 32'hf9e5f3b7;
k01[26] = 32'hf9a8f340;
k01[27] = 32'hf96bf2c9;
k01[28] = 32'hf92ef253;
k01[29] = 32'hf8f2f1de;
k01[30] = 32'hf8b5f168;
k01[31] = 32'hf879f0f3;
k01[32] = 32'hf83df07e;
k01[33] = 32'hf800f00a;
k01[34] = 32'hf7c4ef96;
k01[35] = 32'hf789ef22;
k01[36] = 32'hf74deeaf;
k01[37] = 32'hf711ee3c;
k01[38] = 32'hf6d6edc9;
k01[39] = 32'hf69aed57;
k01[40] = 32'hf65fece5;
k01[41] = 32'hf624ec73;
k01[42] = 32'hf5e8ec01;
k01[43] = 32'hf5adeb90;
k01[44] = 32'hf573eb1f;
k01[45] = 32'hf538eaaf;
k01[46] = 32'hf4fdea3f;
k01[47] = 32'hf4c2e9cf;
k01[48] = 32'hf488e95f;
k01[49] = 32'hf44ee8f0;
k01[50] = 32'hf413e881;
k01[51] = 32'hf3d9e812;
k01[52] = 32'hf39fe7a4;
k01[53] = 32'hf365e736;
k01[54] = 32'hf32ce6c8;
k01[55] = 32'hf2f2e65b;
k01[56] = 32'hf2b8e5ee;
k01[57] = 32'hf27fe581;
k01[58] = 32'hf245e515;
k01[59] = 32'hf20ce4a8;
k01[60] = 32'hf1d3e43c;
k01[61] = 32'hf19ae3d1;
k01[62] = 32'hf161e366;
k01[63] = 32'hf128e2fb;
k01[64] = 32'hf0efe290;
k01[65] = 32'hf0b7e225;
k01[66] = 32'hf07ee1bb;
k01[67] = 32'hf046e151;
k01[68] = 32'hf00de0e8;
k01[69] = 32'hefd5e07f;
k01[70] = 32'hef9de016;
k01[71] = 32'hef65dfad;
k01[72] = 32'hef2ddf45;
k01[73] = 32'heef5dedd;
k01[74] = 32'heebede75;
k01[75] = 32'hee86de0d;
k01[76] = 32'hee4fdda6;
k01[77] = 32'hee17dd3f;
k01[78] = 32'hede0dcd8;
k01[79] = 32'heda9dc72;
k01[80] = 32'hed72dc0c;
k01[81] = 32'hed3adba6;
k01[82] = 32'hed04db40;
k01[83] = 32'heccddadb;
k01[84] = 32'hec96da76;
k01[85] = 32'hec5fda11;
k01[86] = 32'hec29d9ad;
k01[87] = 32'hebf3d948;
k01[88] = 32'hebbcd8e4;
k01[89] = 32'heb86d881;
k01[90] = 32'heb50d81d;
k01[91] = 32'heb1ad7ba;
k01[92] = 32'heae4d757;
k01[93] = 32'heaaed6f5;
k01[94] = 32'hea78d692;
k01[95] = 32'hea43d630;
k01[96] = 32'hea0dd5ce;
k01[97] = 32'he9d8d56d;
k01[98] = 32'he9a2d50c;
k01[99] = 32'he96dd4aa;
k01[100] = 32'he938d44a;
k01[101] = 32'he903d3e9;
k01[102] = 32'he8ced389;
k01[103] = 32'he899d329;
k01[104] = 32'he864d2c9;
k01[105] = 32'he82fd26a;
k01[106] = 32'he7fbd20a;
k01[107] = 32'he7c6d1ab;
k01[108] = 32'he792d14d;
k01[109] = 32'he75ed0ee;
k01[110] = 32'he729d090;
k01[111] = 32'he6f5d032;
k01[112] = 32'he6c1cfd4;
k01[113] = 32'he68dcf77;
k01[114] = 32'he659cf19;
k01[115] = 32'he626cebc;
k01[116] = 32'he5f2ce60;
k01[117] = 32'he5bece03;
k01[118] = 32'he58bcda7;
k01[119] = 32'he557cd4b;
k01[120] = 32'he524ccef;
k01[121] = 32'he4f1cc93;
k01[122] = 32'he4becc38;
k01[123] = 32'he48bcbdd;
k01[124] = 32'he458cb82;
k01[125] = 32'he425cb28;
k01[126] = 32'he3f2cacd;
k01[127] = 32'he3bfca73;
k01[128] = 32'he38dca19;
k01[129] = 32'he35ac9bf;
k01[130] = 32'he328c966;
k01[131] = 32'he2f5c90d;
k01[132] = 32'he2c3c8b4;
k01[133] = 32'he291c85b;
k01[134] = 32'he25fc803;
k01[135] = 32'he22dc7aa;
k01[136] = 32'he1fbc752;
k01[137] = 32'he1c9c6fa;
k01[138] = 32'he197c6a3;
k01[139] = 32'he166c64b;
k01[140] = 32'he134c5f4;
k01[141] = 32'he103c59d;
k01[142] = 32'he0d1c547;
k01[143] = 32'he0a0c4f0;
k01[144] = 32'he06fc49a;
k01[145] = 32'he03ec444;
k01[146] = 32'he00cc3ee;
k01[147] = 32'hdfdcc399;
k01[148] = 32'hdfabc343;
k01[149] = 32'hdf7ac2ee;
k01[150] = 32'hdf49c299;
k01[151] = 32'hdf18c244;
k01[152] = 32'hdee8c1f0;
k01[153] = 32'hdeb7c19c;
k01[154] = 32'hde87c147;
k01[155] = 32'hde57c0f4;
k01[156] = 32'hde26c0a0;
k01[157] = 32'hddf6c04d;
k01[158] = 32'hddc6bff9;
k01[159] = 32'hdd96bfa6;
k01[160] = 32'hdd66bf53;
k01[161] = 32'hdd36bf01;
k01[162] = 32'hdd07beaf;
k01[163] = 32'hdcd7be5c;
k01[164] = 32'hdca7be0a;
k01[165] = 32'hdc78bdb9;
k01[166] = 32'hdc48bd67;
k01[167] = 32'hdc19bd16;
k01[168] = 32'hdbeabcc5;
k01[169] = 32'hdbbbbc74;
k01[170] = 32'hdb8cbc23;
k01[171] = 32'hdb5dbbd2;
k01[172] = 32'hdb2ebb82;
k01[173] = 32'hdaffbb32;
k01[174] = 32'hdad0bae2;
k01[175] = 32'hdaa1ba92;
k01[176] = 32'hda73ba43;
k01[177] = 32'hda44b9f3;
k01[178] = 32'hda15b9a4;
k01[179] = 32'hd9e7b955;
k01[180] = 32'hd9b9b906;
k01[181] = 32'hd98ab8b8;
k01[182] = 32'hd95cb86a;
k01[183] = 32'hd92eb81b;
k01[184] = 32'hd900b7cd;
k01[185] = 32'hd8d2b780;
k01[186] = 32'hd8a4b732;
k01[187] = 32'hd877b6e5;
k01[188] = 32'hd849b697;
k01[189] = 32'hd81bb64a;
k01[190] = 32'hd7eeb5fe;
k01[191] = 32'hd7c0b5b1;
k01[192] = 32'hd793b565;
k01[193] = 32'hd765b518;
k01[194] = 32'hd738b4cc;
k01[195] = 32'hd70bb480;
k01[196] = 32'hd6deb435;
k01[197] = 32'hd6b1b3e9;
k01[198] = 32'hd684b39e;
k01[199] = 32'hd657b353;
k01[200] = 32'hd62ab308;
k01[201] = 32'hd5fdb2bd;
k01[202] = 32'hd5d1b272;
k01[203] = 32'hd5a4b228;
k01[204] = 32'hd577b1de;
k01[205] = 32'hd54bb194;
k01[206] = 32'hd51fb14a;
k01[207] = 32'hd4f2b100;
k01[208] = 32'hd4c6b0b7;
k01[209] = 32'hd49ab06d;
k01[210] = 32'hd46eb024;
k01[211] = 32'hd442afdb;
k01[212] = 32'hd416af93;
k01[213] = 32'hd3eaaf4a;
k01[214] = 32'hd3beaf02;
k01[215] = 32'hd392aeb9;
k01[216] = 32'hd367ae71;
k01[217] = 32'hd33bae29;
k01[218] = 32'hd30fade2;
k01[219] = 32'hd2e4ad9a;
k01[220] = 32'hd2b9ad53;
k01[221] = 32'hd28dad0b;
k01[222] = 32'hd262acc4;
k01[223] = 32'hd237ac7d;
k01[224] = 32'hd20cac37;
k01[225] = 32'hd1e1abf0;
k01[226] = 32'hd1b6abaa;
k01[227] = 32'hd18bab64;
k01[228] = 32'hd160ab1e;
k01[229] = 32'hd135aad8;
k01[230] = 32'hd10aaa92;
k01[231] = 32'hd0e0aa4c;
k01[232] = 32'hd0b5aa07;
k01[233] = 32'hd08ba9c2;
k01[234] = 32'hd060a97d;
k01[235] = 32'hd036a938;
k01[236] = 32'hd00ba8f3;
k01[237] = 32'hcfe1a8af;
k01[238] = 32'hcfb7a86a;
k01[239] = 32'hcf8da826;
k01[240] = 32'hcf63a7e2;
k01[241] = 32'hcf39a79e;
k01[242] = 32'hcf0fa75a;
k01[243] = 32'hcee5a717;
k01[244] = 32'hcebba6d3;
k01[245] = 32'hce92a690;
k01[246] = 32'hce68a64d;
k01[247] = 32'hce3fa60a;
k01[248] = 32'hce15a5c7;
k01[249] = 32'hcdeca585;
k01[250] = 32'hcdc2a542;
k01[251] = 32'hcd99a500;
k01[252] = 32'hcd70a4be;
k01[253] = 32'hcd46a47c;
k01[254] = 32'hcd1da43a;
k01[255] = 32'hccf4a3f8;
k01[256] = 32'hcccba3b7;
k01[257] = 32'hcca2a375;
k01[258] = 32'hcc79a334;
k01[259] = 32'hcc51a2f3;
k01[260] = 32'hcc28a2b2;
k01[261] = 32'hcbffa271;
k01[262] = 32'hcbd7a231;
k01[263] = 32'hcbaea1f0;
k01[264] = 32'hcb86a1b0;
k01[265] = 32'hcb5da170;
k01[266] = 32'hcb35a130;
k01[267] = 32'hcb0da0f0;
k01[268] = 32'hcae4a0b0;
k01[269] = 32'hcabca071;
k01[270] = 32'hca94a031;
k01[271] = 32'hca6c9ff2;
k01[272] = 32'hca449fb3;
k01[273] = 32'hca1c9f74;
k01[274] = 32'hc9f49f35;
k01[275] = 32'hc9cc9ef6;
k01[276] = 32'hc9a59eb8;
k01[277] = 32'hc97d9e79;
k01[278] = 32'hc9559e3b;
k01[279] = 32'hc92e9dfd;
k01[280] = 32'hc9069dbf;
k01[281] = 32'hc8df9d81;
k01[282] = 32'hc8b89d43;
k01[283] = 32'hc8909d06;
k01[284] = 32'hc8699cc8;
k01[285] = 32'hc8429c8b;
k01[286] = 32'hc81b9c4e;
k01[287] = 32'hc7f49c11;
k01[288] = 32'hc7cd9bd4;
k01[289] = 32'hc7a69b97;
k01[290] = 32'hc77f9b5b;
k01[291] = 32'hc7589b1e;
k01[292] = 32'hc7319ae2;
k01[293] = 32'hc70a9aa6;
k01[294] = 32'hc6e49a6a;
k01[295] = 32'hc6bd9a2e;
k01[296] = 32'hc69799f2;
k01[297] = 32'hc67099b7;
k01[298] = 32'hc64a997b;
k01[299] = 32'hc6239940;
k01[300] = 32'hc5fd9905;
k01[301] = 32'hc5d798c9;
k01[302] = 32'hc5b0988e;
k01[303] = 32'hc58a9854;
k01[304] = 32'hc5649819;
k01[305] = 32'hc53e97de;
k01[306] = 32'hc51897a4;
k01[307] = 32'hc4f2976a;
k01[308] = 32'hc4cd9730;
k01[309] = 32'hc4a796f6;
k01[310] = 32'hc48196bc;
k01[311] = 32'hc45b9682;
k01[312] = 32'hc4369648;
k01[313] = 32'hc410960f;
k01[314] = 32'hc3eb95d5;
k01[315] = 32'hc3c5959c;
k01[316] = 32'hc3a09563;
k01[317] = 32'hc37a952a;
k01[318] = 32'hc35594f1;
k01[319] = 32'hc33094b8;
k01[320] = 32'hc30b9480;
k01[321] = 32'hc2e69447;
k01[322] = 32'hc2c0940f;
k01[323] = 32'hc29b93d7;
k01[324] = 32'hc277939f;
k01[325] = 32'hc2529367;
k01[326] = 32'hc22d932f;
k01[327] = 32'hc20892f7;
k01[328] = 32'hc1e392bf;
k01[329] = 32'hc1bf9288;
k01[330] = 32'hc19a9251;
k01[331] = 32'hc1759219;
k01[332] = 32'hc15191e2;
k01[333] = 32'hc12c91ab;
k01[334] = 32'hc1089174;
k01[335] = 32'hc0e4913e;
k01[336] = 32'hc0bf9107;
k01[337] = 32'hc09b90d0;
k01[338] = 32'hc077909a;
k01[339] = 32'hc0539064;
k01[340] = 32'hc02f902e;
k01[341] = 32'hc00a8ff8;
k01[342] = 32'hbfe78fc2;
k01[343] = 32'hbfc38f8c;
k01[344] = 32'hbf9f8f56;
k01[345] = 32'hbf7b8f21;
k01[346] = 32'hbf578eeb;
k01[347] = 32'hbf338eb6;
k01[348] = 32'hbf108e81;
k01[349] = 32'hbeec8e4b;
k01[350] = 32'hbec88e16;
k01[351] = 32'hbea58de2;
k01[352] = 32'hbe818dad;
k01[353] = 32'hbe5e8d78;
k01[354] = 32'hbe3b8d44;
k01[355] = 32'hbe178d0f;
k01[356] = 32'hbdf48cdb;
k01[357] = 32'hbdd18ca7;
k01[358] = 32'hbdae8c73;
k01[359] = 32'hbd8b8c3f;
k01[360] = 32'hbd688c0b;
k01[361] = 32'hbd458bd7;
k01[362] = 32'hbd228ba4;
k01[363] = 32'hbcff8b70;
k01[364] = 32'hbcdc8b3d;
k01[365] = 32'hbcb98b09;
k01[366] = 32'hbc968ad6;
k01[367] = 32'hbc748aa3;
k01[368] = 32'hbc518a70;
k01[369] = 32'hbc2e8a3d;
k01[370] = 32'hbc0c8a0b;
k01[371] = 32'hbbe989d8;
k01[372] = 32'hbbc789a5;
k01[373] = 32'hbba48973;
k01[374] = 32'hbb828941;
k01[375] = 32'hbb60890f;
k01[376] = 32'hbb3d88dc;
k01[377] = 32'hbb1b88aa;
k01[378] = 32'hbaf98879;
k01[379] = 32'hbad78847;
k01[380] = 32'hbab58815;
k01[381] = 32'hba9387e4;
k01[382] = 32'hba7187b2;
k01[383] = 32'hba4f8781;
k01[384] = 32'hba2d8750;
k01[385] = 32'hba0b871e;
k01[386] = 32'hb9e986ed;
k01[387] = 32'hb9c886bc;
k01[388] = 32'hb9a6868c;
k01[389] = 32'hb984865b;
k01[390] = 32'hb963862a;
k01[391] = 32'hb94185fa;
k01[392] = 32'hb92085c9;
k01[393] = 32'hb8fe8599;
k01[394] = 32'hb8dd8569;
k01[395] = 32'hb8bc8539;
k01[396] = 32'hb89a8509;
k01[397] = 32'hb87984d9;
k01[398] = 32'hb85884a9;
k01[399] = 32'hb8378479;
k01[400] = 32'hb816844a;
k01[401] = 32'hb7f4841a;
k01[402] = 32'hb7d383eb;
k01[403] = 32'hb7b283bc;
k01[404] = 32'hb791838c;
k01[405] = 32'hb771835d;
k01[406] = 32'hb750832e;
k01[407] = 32'hb72f82ff;
k01[408] = 32'hb70e82d1;
k01[409] = 32'hb6ee82a2;
k01[410] = 32'hb6cd8273;
k01[411] = 32'hb6ac8245;
k01[412] = 32'hb68c8216;
k01[413] = 32'hb66b81e8;
k01[414] = 32'hb64b81ba;
k01[415] = 32'hb62a818c;
k01[416] = 32'hb60a815e;
k01[417] = 32'hb5ea8130;
k01[418] = 32'hb5c98102;
k01[419] = 32'hb5a980d4;
k01[420] = 32'hb58980a7;
k01[421] = 32'hb5698079;
k01[422] = 32'hb548804c;
k01[423] = 32'hb528801e;
k01[424] = 32'hb5087ff1;
k01[425] = 32'hb4e87fc4;
k01[426] = 32'hb4c87f97;
k01[427] = 32'hb4a97f6a;
k01[428] = 32'hb4897f3d;
k01[429] = 32'hb4697f10;
k01[430] = 32'hb4497ee3;
k01[431] = 32'hb4297eb7;
k01[432] = 32'hb40a7e8a;
k01[433] = 32'hb3ea7e5e;
k01[434] = 32'hb3cb7e31;
k01[435] = 32'hb3ab7e05;
k01[436] = 32'hb38b7dd9;
k01[437] = 32'hb36c7dad;
k01[438] = 32'hb34d7d81;
k01[439] = 32'hb32d7d55;
k01[440] = 32'hb30e7d29;
k01[441] = 32'hb2ef7cfd;
k01[442] = 32'hb2cf7cd2;
k01[443] = 32'hb2b07ca6;
k01[444] = 32'hb2917c7b;
k01[445] = 32'hb2727c4f;
k01[446] = 32'hb2537c24;
k01[447] = 32'hb2347bf9;
k01[448] = 32'hb2157bce;
k01[449] = 32'hb1f67ba3;
k01[450] = 32'hb1d77b78;
k01[451] = 32'hb1b87b4d;
k01[452] = 32'hb1997b22;
k01[453] = 32'hb17a7af8;
k01[454] = 32'hb15c7acd;
k01[455] = 32'hb13d7aa3;
k01[456] = 32'hb11e7a78;
k01[457] = 32'hb1007a4e;
k01[458] = 32'hb0e17a24;
k01[459] = 32'hb0c379fa;
k01[460] = 32'hb0a479d0;
k01[461] = 32'hb08679a6;
k01[462] = 32'hb067797c;
k01[463] = 32'hb0497952;
k01[464] = 32'hb02b7928;
k01[465] = 32'hb00c78ff;
k01[466] = 32'hafee78d5;
k01[467] = 32'hafd078ac;
k01[468] = 32'hafb27882;
k01[469] = 32'haf937859;
k01[470] = 32'haf757830;
k01[471] = 32'haf577807;
k01[472] = 32'haf3977de;
k01[473] = 32'haf1b77b5;
k01[474] = 32'haefd778c;
k01[475] = 32'haee07763;
k01[476] = 32'haec2773a;
k01[477] = 32'haea47712;
k01[478] = 32'hae8676e9;
k01[479] = 32'hae6876c0;
k01[480] = 32'hae4b7698;
k01[481] = 32'hae2d7670;
k01[482] = 32'hae0f7648;
k01[483] = 32'hadf2761f;
k01[484] = 32'hadd475f7;
k01[485] = 32'hadb775cf;
k01[486] = 32'had9975a7;
k01[487] = 32'had7c7580;
k01[488] = 32'had5f7558;
k01[489] = 32'had417530;
k01[490] = 32'had247508;
k01[491] = 32'had0774e1;
k01[492] = 32'hacea74b9;
k01[493] = 32'haccc7492;
k01[494] = 32'hacaf746b;
k01[495] = 32'hac927444;
k01[496] = 32'hac75741c;
k01[497] = 32'hac5873f5;
k01[498] = 32'hac3b73ce;
k01[499] = 32'hac1e73a8;
k01[500] = 32'hac017381;
k01[501] = 32'habe4735a;
k01[502] = 32'habc77333;
k01[503] = 32'habab730d;
k01[504] = 32'hab8e72e6;
k01[505] = 32'hab7172c0;
k01[506] = 32'hab547299;
k01[507] = 32'hab387273;
k01[508] = 32'hab1b724d;
k01[509] = 32'haaff7227;
k01[510] = 32'haae27201;
k01[511] = 32'haac671db;
k01[512] = 32'haaa971b5;
k01[513] = 32'haa8d718f;
k01[514] = 32'haa707169;
k01[515] = 32'haa547143;
k01[516] = 32'haa38711e;
k01[517] = 32'haa1b70f8;
k01[518] = 32'ha9ff70d3;
k01[519] = 32'ha9e370ad;
k01[520] = 32'ha9c77088;
k01[521] = 32'ha9ab7063;
k01[522] = 32'ha98f703d;
k01[523] = 32'ha9727018;
k01[524] = 32'ha9566ff3;
k01[525] = 32'ha93a6fce;
k01[526] = 32'ha91f6fa9;
k01[527] = 32'ha9036f85;
k01[528] = 32'ha8e76f60;
k01[529] = 32'ha8cb6f3b;
k01[530] = 32'ha8af6f16;
k01[531] = 32'ha8936ef2;
k01[532] = 32'ha8786ecd;
k01[533] = 32'ha85c6ea9;
k01[534] = 32'ha8406e85;
k01[535] = 32'ha8256e60;
k01[536] = 32'ha8096e3c;
k01[537] = 32'ha7ed6e18;
k01[538] = 32'ha7d26df4;
k01[539] = 32'ha7b66dd0;
k01[540] = 32'ha79b6dac;
k01[541] = 32'ha7806d88;
k01[542] = 32'ha7646d64;
k01[543] = 32'ha7496d41;
k01[544] = 32'ha72e6d1d;
k01[545] = 32'ha7126cf9;
k01[546] = 32'ha6f76cd6;
k01[547] = 32'ha6dc6cb3;
k01[548] = 32'ha6c16c8f;
k01[549] = 32'ha6a56c6c;
k01[550] = 32'ha68a6c49;
k01[551] = 32'ha66f6c25;
k01[552] = 32'ha6546c02;
k01[553] = 32'ha6396bdf;
k01[554] = 32'ha61e6bbc;
k01[555] = 32'ha6036b99;
k01[556] = 32'ha5e86b77;
k01[557] = 32'ha5ce6b54;
k01[558] = 32'ha5b36b31;
k01[559] = 32'ha5986b0e;
k01[560] = 32'ha57d6aec;
k01[561] = 32'ha5626ac9;
k01[562] = 32'ha5486aa7;
k01[563] = 32'ha52d6a84;
k01[564] = 32'ha5126a62;
k01[565] = 32'ha4f86a40;
k01[566] = 32'ha4dd6a1e;
k01[567] = 32'ha4c369fc;
k01[568] = 32'ha4a869d9;
k01[569] = 32'ha48e69b7;
k01[570] = 32'ha4736996;
k01[571] = 32'ha4596974;
k01[572] = 32'ha43f6952;
k01[573] = 32'ha4246930;
k01[574] = 32'ha40a690e;
k01[575] = 32'ha3f068ed;
k01[576] = 32'ha3d668cb;
k01[577] = 32'ha3bb68aa;
k01[578] = 32'ha3a16888;
k01[579] = 32'ha3876867;
k01[580] = 32'ha36d6846;
k01[581] = 32'ha3536824;
k01[582] = 32'ha3396803;
k01[583] = 32'ha31f67e2;
k01[584] = 32'ha30567c1;
k01[585] = 32'ha2eb67a0;
k01[586] = 32'ha2d1677f;
k01[587] = 32'ha2b7675e;
k01[588] = 32'ha29d673d;
k01[589] = 32'ha283671d;
k01[590] = 32'ha26a66fc;
k01[591] = 32'ha25066db;
k01[592] = 32'ha23666bb;
k01[593] = 32'ha21d669a;
k01[594] = 32'ha203667a;
k01[595] = 32'ha1e9665a;
k01[596] = 32'ha1d06639;
k01[597] = 32'ha1b66619;
k01[598] = 32'ha19d65f9;
k01[599] = 32'ha18365d9;
k01[600] = 32'ha16a65b8;
k01[601] = 32'ha1506598;
k01[602] = 32'ha1376578;
k01[603] = 32'ha11d6559;
k01[604] = 32'ha1046539;
k01[605] = 32'ha0eb6519;
k01[606] = 32'ha0d264f9;
k01[607] = 32'ha0b864d9;
k01[608] = 32'ha09f64ba;
k01[609] = 32'ha086649a;
k01[610] = 32'ha06d647b;
k01[611] = 32'ha054645b;
k01[612] = 32'ha03b643c;
k01[613] = 32'ha022641d;
k01[614] = 32'ha00863fd;
k01[615] = 32'h9ff063de;
k01[616] = 32'h9fd763bf;
k01[617] = 32'h9fbe63a0;
k01[618] = 32'h9fa56381;
k01[619] = 32'h9f8c6362;
k01[620] = 32'h9f736343;
k01[621] = 32'h9f5a6324;
k01[622] = 32'h9f416305;
k01[623] = 32'h9f2962e6;
k01[624] = 32'h9f1062c8;
k01[625] = 32'h9ef762a9;
k01[626] = 32'h9edf628b;
k01[627] = 32'h9ec6626c;
k01[628] = 32'h9ead624e;
k01[629] = 32'h9e95622f;
k01[630] = 32'h9e7c6211;
k01[631] = 32'h9e6461f2;
k01[632] = 32'h9e4b61d4;
k01[633] = 32'h9e3361b6;
k01[634] = 32'h9e1a6198;
k01[635] = 32'h9e02617a;
k01[636] = 32'h9dea615c;
k01[637] = 32'h9dd1613e;
k01[638] = 32'h9db96120;
k01[639] = 32'h9da16102;
k01[640] = 32'h9d8860e4;
k01[641] = 32'h9d7060c6;
k01[642] = 32'h9d5860a8;
k01[643] = 32'h9d40608b;
k01[644] = 32'h9d28606d;
k01[645] = 32'h9d106050;
k01[646] = 32'h9cf76032;
k01[647] = 32'h9cdf6015;
k01[648] = 32'h9cc75ff7;
k01[649] = 32'h9caf5fda;
k01[650] = 32'h9c975fbd;
k01[651] = 32'h9c7f5f9f;
k01[652] = 32'h9c685f82;
k01[653] = 32'h9c505f65;
k01[654] = 32'h9c385f48;
k01[655] = 32'h9c205f2b;
k01[656] = 32'h9c085f0e;
k01[657] = 32'h9bf05ef1;
k01[658] = 32'h9bd95ed4;
k01[659] = 32'h9bc15eb7;
k01[660] = 32'h9ba95e9a;
k01[661] = 32'h9b925e7e;
k01[662] = 32'h9b7a5e61;
k01[663] = 32'h9b625e44;
k01[664] = 32'h9b4b5e28;
k01[665] = 32'h9b335e0b;
k01[666] = 32'h9b1c5def;
k01[667] = 32'h9b045dd2;
k01[668] = 32'h9aed5db6;
k01[669] = 32'h9ad65d9a;
k01[670] = 32'h9abe5d7d;
k01[671] = 32'h9aa75d61;
k01[672] = 32'h9a8f5d45;
k01[673] = 32'h9a785d29;
k01[674] = 32'h9a615d0d;
k01[675] = 32'h9a4a5cf1;
k01[676] = 32'h9a325cd5;
k01[677] = 32'h9a1b5cb9;
k01[678] = 32'h9a045c9d;
k01[679] = 32'h99ed5c81;
k01[680] = 32'h99d65c65;
k01[681] = 32'h99bf5c4a;
k01[682] = 32'h99a75c2e;
k01[683] = 32'h99905c12;
k01[684] = 32'h99795bf7;
k01[685] = 32'h99625bdb;
k01[686] = 32'h994b5bc0;
k01[687] = 32'h99355ba4;
k01[688] = 32'h991e5b89;
k01[689] = 32'h99075b6e;
k01[690] = 32'h98f05b52;
k01[691] = 32'h98d95b37;
k01[692] = 32'h98c25b1c;
k01[693] = 32'h98ab5b01;
k01[694] = 32'h98955ae6;
k01[695] = 32'h987e5acb;
k01[696] = 32'h98675ab0;
k01[697] = 32'h98515a95;
k01[698] = 32'h983a5a7a;
k01[699] = 32'h98235a5f;
k01[700] = 32'h980d5a44;
k01[701] = 32'h97f65a29;
k01[702] = 32'h97e05a0f;
k01[703] = 32'h97c959f4;
k01[704] = 32'h97b359d9;
k01[705] = 32'h979c59bf;
k01[706] = 32'h978659a4;
k01[707] = 32'h976f598a;
k01[708] = 32'h9759596f;
k01[709] = 32'h97435955;
k01[710] = 32'h972c593a;
k01[711] = 32'h97165920;
k01[712] = 32'h97005906;
k01[713] = 32'h96e958ec;
k01[714] = 32'h96d358d1;
k01[715] = 32'h96bd58b7;
k01[716] = 32'h96a7589d;
k01[717] = 32'h96915883;
k01[718] = 32'h967b5869;
k01[719] = 32'h9664584f;
k01[720] = 32'h964e5835;
k01[721] = 32'h9638581b;
k01[722] = 32'h96225802;
k01[723] = 32'h960c57e8;
k01[724] = 32'h95f657ce;
k01[725] = 32'h95e057b4;
k01[726] = 32'h95ca579b;
k01[727] = 32'h95b55781;
k01[728] = 32'h959f5768;
k01[729] = 32'h9589574e;
k01[730] = 32'h95735735;
k01[731] = 32'h955d571b;
k01[732] = 32'h95475702;
k01[733] = 32'h953256e8;
k01[734] = 32'h951c56cf;
k01[735] = 32'h950656b6;
k01[736] = 32'h94f1569d;
k01[737] = 32'h94db5683;
k01[738] = 32'h94c5566a;
k01[739] = 32'h94b05651;
k01[740] = 32'h949a5638;
k01[741] = 32'h9485561f;
k01[742] = 32'h946f5606;
k01[743] = 32'h945955ed;
k01[744] = 32'h944455d5;
k01[745] = 32'h942f55bc;
k01[746] = 32'h941955a3;
k01[747] = 32'h9404558a;
k01[748] = 32'h93ee5571;
k01[749] = 32'h93d95559;
k01[750] = 32'h93c45540;
k01[751] = 32'h93ae5528;
k01[752] = 32'h9399550f;
k01[753] = 32'h938454f7;
k01[754] = 32'h936f54de;
k01[755] = 32'h935954c6;
k01[756] = 32'h934454ad;
k01[757] = 32'h932f5495;
k01[758] = 32'h931a547d;
k01[759] = 32'h93055464;
k01[760] = 32'h92f0544c;
k01[761] = 32'h92da5434;
k01[762] = 32'h92c5541c;
k01[763] = 32'h92b05404;
k01[764] = 32'h929b53ec;
k01[765] = 32'h928653d4;
k01[766] = 32'h927153bc;
k01[767] = 32'h925d53a4;
k01[768] = 32'h9248538c;
k01[769] = 32'h92335374;
k01[770] = 32'h921e535c;
k01[771] = 32'h92095345;
k01[772] = 32'h91f4532d;
k01[773] = 32'h91df5315;
k01[774] = 32'h91cb52fe;
k01[775] = 32'h91b652e6;
k01[776] = 32'h91a152ce;
k01[777] = 32'h918c52b7;
k01[778] = 32'h9178529f;
k01[779] = 32'h91635288;
k01[780] = 32'h914f5271;
k01[781] = 32'h913a5259;
k01[782] = 32'h91255242;
k01[783] = 32'h9111522b;
k01[784] = 32'h90fc5213;
k01[785] = 32'h90e851fc;
k01[786] = 32'h90d351e5;
k01[787] = 32'h90bf51ce;
k01[788] = 32'h90aa51b7;
k01[789] = 32'h909651a0;
k01[790] = 32'h90815189;
k01[791] = 32'h906d5172;
k01[792] = 32'h9059515b;
k01[793] = 32'h90445144;
k01[794] = 32'h9030512d;
k01[795] = 32'h901c5116;
k01[796] = 32'h900750ff;
k01[797] = 32'h8ff350e8;
k01[798] = 32'h8fdf50d2;
k01[799] = 32'h8fcb50bb;
k01[800] = 32'h8fb750a4;
k01[801] = 32'h8fa2508e;
k01[802] = 32'h8f8e5077;
k01[803] = 32'h8f7a5061;
k01[804] = 32'h8f66504a;
k01[805] = 32'h8f525034;
k01[806] = 32'h8f3e501d;
k01[807] = 32'h8f2a5007;
k01[808] = 32'h8f164ff1;
k01[809] = 32'h8f024fda;
k01[810] = 32'h8eee4fc4;
k01[811] = 32'h8eda4fae;
k01[812] = 32'h8ec64f98;
k01[813] = 32'h8eb24f81;
k01[814] = 32'h8e9e4f6b;
k01[815] = 32'h8e8b4f55;
k01[816] = 32'h8e774f3f;
k01[817] = 32'h8e634f29;
k01[818] = 32'h8e4f4f13;
k01[819] = 32'h8e3b4efd;
k01[820] = 32'h8e284ee7;
k01[821] = 32'h8e144ed1;
k01[822] = 32'h8e004ebb;
k01[823] = 32'h8dec4ea6;
k01[824] = 32'h8dd94e90;
k01[825] = 32'h8dc54e7a;
k01[826] = 32'h8db24e64;
k01[827] = 32'h8d9e4e4f;
k01[828] = 32'h8d8a4e39;
k01[829] = 32'h8d774e23;
k01[830] = 32'h8d634e0e;
k01[831] = 32'h8d504df8;
k01[832] = 32'h8d3c4de3;
k01[833] = 32'h8d294dcd;
k01[834] = 32'h8d154db8;
k01[835] = 32'h8d024da3;
k01[836] = 32'h8cef4d8d;
k01[837] = 32'h8cdb4d78;
k01[838] = 32'h8cc84d63;
k01[839] = 32'h8cb44d4d;
k01[840] = 32'h8ca14d38;
k01[841] = 32'h8c8e4d23;
k01[842] = 32'h8c7b4d0e;
k01[843] = 32'h8c674cf9;
k01[844] = 32'h8c544ce4;
k01[845] = 32'h8c414ccf;
k01[846] = 32'h8c2e4cba;
k01[847] = 32'h8c1a4ca5;
k01[848] = 32'h8c074c90;
k01[849] = 32'h8bf44c7b;
k01[850] = 32'h8be14c66;
k01[851] = 32'h8bce4c51;
k01[852] = 32'h8bbb4c3c;
k01[853] = 32'h8ba84c27;
k01[854] = 32'h8b954c13;
k01[855] = 32'h8b824bfe;
k01[856] = 32'h8b6f4be9;
k01[857] = 32'h8b5c4bd5;
k01[858] = 32'h8b494bc0;
k01[859] = 32'h8b364bab;
k01[860] = 32'h8b234b97;
k01[861] = 32'h8b104b82;
k01[862] = 32'h8afd4b6e;
k01[863] = 32'h8aea4b59;
k01[864] = 32'h8ad74b45;
k01[865] = 32'h8ac54b31;
k01[866] = 32'h8ab24b1c;
k01[867] = 32'h8a9f4b08;
k01[868] = 32'h8a8c4af4;
k01[869] = 32'h8a7a4adf;
k01[870] = 32'h8a674acb;
k01[871] = 32'h8a544ab7;
k01[872] = 32'h8a414aa3;
k01[873] = 32'h8a2f4a8f;
k01[874] = 32'h8a1c4a7a;
k01[875] = 32'h8a0a4a66;
k01[876] = 32'h89f74a52;
k01[877] = 32'h89e44a3e;
k01[878] = 32'h89d24a2a;
k01[879] = 32'h89bf4a16;
k01[880] = 32'h89ad4a03;
k01[881] = 32'h899a49ef;
k01[882] = 32'h898849db;
k01[883] = 32'h897549c7;
k01[884] = 32'h896349b3;
k01[885] = 32'h8950499f;
k01[886] = 32'h893e498c;
k01[887] = 32'h892c4978;
k01[888] = 32'h89194964;
k01[889] = 32'h89074951;
k01[890] = 32'h88f5493d;
k01[891] = 32'h88e2492a;
k01[892] = 32'h88d04916;
k01[893] = 32'h88be4902;
k01[894] = 32'h88ab48ef;
k01[895] = 32'h889948dc;
k01[896] = 32'h888748c8;
k01[897] = 32'h887548b5;
k01[898] = 32'h886348a1;
k01[899] = 32'h8851488e;
k01[900] = 32'h883e487b;
k01[901] = 32'h882c4868;
k01[902] = 32'h881a4854;
k01[903] = 32'h88084841;
k01[904] = 32'h87f6482e;
k01[905] = 32'h87e4481b;
k01[906] = 32'h87d24808;
k01[907] = 32'h87c047f5;
k01[908] = 32'h87ae47e1;
k01[909] = 32'h879c47ce;
k01[910] = 32'h878a47bb;
k01[911] = 32'h877847a8;
k01[912] = 32'h87664796;
k01[913] = 32'h87544783;
k01[914] = 32'h87424770;
k01[915] = 32'h8731475d;
k01[916] = 32'h871f474a;
k01[917] = 32'h870d4737;
k01[918] = 32'h86fb4725;
k01[919] = 32'h86e94712;
k01[920] = 32'h86d846ff;
k01[921] = 32'h86c646ec;
k01[922] = 32'h86b446da;
k01[923] = 32'h86a246c7;
k01[924] = 32'h869146b5;
k01[925] = 32'h867f46a2;
k01[926] = 32'h866d468f;
k01[927] = 32'h865c467d;
k01[928] = 32'h864a466a;
k01[929] = 32'h86384658;
k01[930] = 32'h86274646;
k01[931] = 32'h86154633;
k01[932] = 32'h86044621;
k01[933] = 32'h85f2460e;
k01[934] = 32'h85e145fc;
k01[935] = 32'h85cf45ea;
k01[936] = 32'h85be45d8;
k01[937] = 32'h85ac45c5;
k01[938] = 32'h859b45b3;
k01[939] = 32'h858945a1;
k01[940] = 32'h8578458f;
k01[941] = 32'h8567457d;
k01[942] = 32'h8555456b;
k01[943] = 32'h85444559;
k01[944] = 32'h85334547;
k01[945] = 32'h85214535;
k01[946] = 32'h85104523;
k01[947] = 32'h84ff4511;
k01[948] = 32'h84ed44ff;
k01[949] = 32'h84dc44ed;
k01[950] = 32'h84cb44db;
k01[951] = 32'h84ba44c9;
k01[952] = 32'h84a844b7;
k01[953] = 32'h849744a6;
k01[954] = 32'h84864494;
k01[955] = 32'h84754482;
k01[956] = 32'h84644470;
k01[957] = 32'h8453445f;
k01[958] = 32'h8442444d;
k01[959] = 32'h8431443b;
k01[960] = 32'h8420442a;
k01[961] = 32'h840e4418;
k01[962] = 32'h83fd4407;
k01[963] = 32'h83ec43f5;
k01[964] = 32'h83db43e4;
k01[965] = 32'h83ca43d2;
k01[966] = 32'h83ba43c1;
k01[967] = 32'h83a943af;
k01[968] = 32'h8398439e;
k01[969] = 32'h8387438d;
k01[970] = 32'h8376437b;
k01[971] = 32'h8365436a;
k01[972] = 32'h83544359;
k01[973] = 32'h83434347;
k01[974] = 32'h83334336;
k01[975] = 32'h83224325;
k01[976] = 32'h83114314;
k01[977] = 32'h83004303;
k01[978] = 32'h82ef42f2;
k01[979] = 32'h82df42e0;
k01[980] = 32'h82ce42cf;
k01[981] = 32'h82bd42be;
k01[982] = 32'h82ad42ad;
k01[983] = 32'h829c429c;
k01[984] = 32'h828b428b;
k01[985] = 32'h827b427a;
k01[986] = 32'h826a4269;
k01[987] = 32'h82594258;
k01[988] = 32'h82494248;
k01[989] = 32'h82384237;
k01[990] = 32'h82284226;
k01[991] = 32'h82174215;
k01[992] = 32'h82074204;
k01[993] = 32'h81f641f4;
k01[994] = 32'h81e641e3;
k01[995] = 32'h81d541d2;
k01[996] = 32'h81c541c2;
k01[997] = 32'h81b441b1;
k01[998] = 32'h81a441a0;
k01[999] = 32'h81934190;
k01[1000] = 32'h8183417f;
k01[1001] = 32'h8173416f;
k01[1002] = 32'h8162415e;
k01[1003] = 32'h8152414d;
k01[1004] = 32'h8142413d;
k01[1005] = 32'h8131412d;
k01[1006] = 32'h8121411c;
k01[1007] = 32'h8111410c;
k01[1008] = 32'h810140fb;
k01[1009] = 32'h80f040eb;
k01[1010] = 32'h80e040db;
k01[1011] = 32'h80d040ca;
k01[1012] = 32'h80c040ba;
k01[1013] = 32'h80af40aa;
k01[1014] = 32'h809f409a;
k01[1015] = 32'h808f4089;
k01[1016] = 32'h807f4079;
k01[1017] = 32'h806f4069;
k01[1018] = 32'h805f4059;
k01[1019] = 32'h804f4049;
k01[1020] = 32'h803f4039;
k01[1021] = 32'h802f4029;
k01[1022] = 32'h801f4019;
k01[1023] = 32'h800f4009;
end

wire sa;
wire [EMSB:0] xa;
wire [FMSB:0] ma;
fpDecomp #(WID) u1 (.i(a), .sgn(sa), .exp(xa), .man(ma), .fract(), .xz(), .vz(), .xinf(), .inf(), .nan() );

wire [EMSB+1:0] bias = {1'b0,{EMSB{1'b1}}};
wire [EMSB+1:0] x1 = xa - bias;
wire [EMSB:0] exp = bias - x1 - 2'd1;	// make exponent negative
wire sa3;
wire [EMSB:0] exp3;
wire [9:0] index = ma[FMSB:FMSB-9];
reg [9:0] indexr;
reg [15:0] k0, k1;
always @(posedge clk)
	indexr <= index;
always @(posedge clk)
	k0 <= k01[indexr][31:16];
always @(posedge clk)
	k1 <= k01[indexr][15: 0];
delay3 #(1) u2 (.clk(clk), .ce(1'b1), .i(sa), .o(sa3));
delay3 #(EMSB+1) u3 (.clk(clk), .ce(1'b1), .i(exp), .o(exp3));
wire [15:0] eps = ma[FMSB-10:FMSB-10-15];
wire [31:0] p = k1 * eps;
reg [15:0] r0;
always @(posedge clk)
	r0 <= k0 - (p >> 26);
assign o = {sa3,exp3,r0[14:0],{FMSB+2-16{1'b0}}};

always @*
	if (WID < 48) begin
		$display("Reciprocal estimate needs at least 48 bit floats.");
		$stop;
	end

endmodule

