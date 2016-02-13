#pragma once
#include "stdafx.h"
#include "clsKeyboard.h"

extern char refscreen;
extern unsigned int dataBreakpoints[30];
extern int numDataBreakpoints;
extern int runstop;
extern clsKeyboard keybd;
extern volatile unsigned __int8 keybd_status;
extern volatile unsigned __int8 keybd_scancode;

class clsSystem
{
public:
	unsigned __int64 memory[16777216];	// 128 MB
	unsigned __int64 rom[32768];
	unsigned long VideoMem[4096];
	bool VideoMemDirty[4096];
	unsigned long DBGVideoMem[4096];
	bool DBGVideoMemDirty[4096];
	unsigned int leds;
	int m_z;
	int m_w;
	char write_error;
	unsigned int radr1;
	unsigned int radr2;
	bool WriteROM;

	clsSystem();
	void Reset();
	unsigned __int64 Read(unsigned int ad, int sr=0);
	unsigned __int64 ReadByte(unsigned int ad);
	int Write(unsigned int ad, unsigned __int64 dat, unsigned int mask, int cr=0);
 	int random();
};
