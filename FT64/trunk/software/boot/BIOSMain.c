#define BTNC	16
#define BTNU	8
#define BTND	4
#define BTNL	2
#define BTNR	1
#define AVIC	((unsigned __int32 *)0xFFDCC000)

// By declaring the function with the __no_temps attribute it tells the
// compiler that the function doesn't use any temporaries. That means
// the compiler can omit the code to save / restore temporary registers
// across function calls. This makes the code smaller and faster.
// This is not usually safe to do unless the function was coded
// entirely in assembler where it is known no temporaries are in use.
extern int GetRand(register int stream) __attribute__(__no_temps);
extern __int32 DBGAttr;
extern void DBGClearScreen();
extern void DBGHomeCursor();
extern void putch(register char);
extern int printf(char *, ...);
extern pascal int prtflt(register float, register int, register int, register char);
extern void ramtest();
extern void FloatTest();
extern void DBGDisplayString(char *p);
extern void puthex(register int num);
void SpriteDemo();

extern int randStream;

void interrupt DBERout()
{
	int nn;

	DBGDisplayString("\r\nDatabus error: ");
	puthex(GetEPC());
	putch(' ');
	puthex(GetBadAddr());
	putch(' ');
	for (nn = 63; nn >= 0; nn--) {
		SetPCHNDX(nn);
		puthex(ReadPCHIST());
		putch(' ');
	}
	forever {}
}

static naked inline void LEDS(register int n)
{
	asm {
		sh		$a0,$FFDC0600
	}
}

static naked inline int GetButton()
{
	asm {
		lb		$v0,BUTTONS
	}
}

void BIOSMain()
{
	float pi = 3.1415926535897932384626;
	// 400921FB54442D18 
	float a,b;
	int btn;
	int seln=0;
	int *pStack;
	int info;

	pStack = new int[1024];
	// priority | hApp | affinity
	info = (077 << 48) | (0 << 32) | 0;
	FMTK_StartThread(IdleThread,1024,pStack,0,info);
	info = (030 << 48) | (0 << 32) | 0;
	FMTK_StartThread(FocusSwitcher, 1024, new int[1024], 0, info);
    asm {
        ldi   r1,#46
        sb    r1,$FFDC0600
    }
	info = (033 << 48) | (0 << 32) | 0;
	FMTK_StartThread(shell, 1024, new int[1024], 0, info);
    asm {
        ldi   r1,#129
        sb    r1,$FFDC0600
    }

	LEDS(1);
//	SpriteDemo();
	DBGAttr = 0x087FC00;//0b0000_1000_0111_1111_1100_0000_0000;
	DBGClearScreen();
	DBGHomeCursor();
	DBGDisplayString("  FT64 Bios Started\r\n");
	DBGDisplayString("  Menu\r\n  up = ramtest\r\n  down = graphics demo\r\n  left = float test\r\n  right=TinyBasic\r\n");
	forever {
		//0b0000_1000_0111_1111_1100_0000_0000;
		//0b1111_1111_1000_0100_0000_0000_0000;
		btn = GetButton();
		switch(btn) {
		case BTND:
			while(GetButton());
			SpriteDemo();
			break;
		case BTNU:
			while(GetButton());
			ramtest();
			break;
		case BTNL:
			while(GetButton());
			FloatTest();
			break;
		case BTNR:
			while(GetButton());
			asm {
				jmp	TinyBasicDSD9
			};
			break;
		}
	}
}

static naked inline int GetEPC()
{
	asm {
		csrrd	$v0,#$40,$r0
	}
}

static naked inline int GetBadAddr()
{
	asm {
		csrrd	$v0,#7,$r0
		sh		$v0,$FFDC0080
	}
}

static naked inline void SetPCHNDX(register int nn)
{
	asm {
		csrrw	$r0,#$101,$a0
	}
}

static naked inline int ReadPCHIST()
{
	asm {
		csrrd	$v0,#$100,$r0
	}
}

void interrupt BTNCIRQHandler()
{
	int nn;

	asm {
		ldi		r1,#30
		sh		r1,PIC_ESR
	}
	DBGDisplayString("\r\nPC History:\r\n");
	for (nn = 63; nn >= 0; nn--) {
		SetPCHNDX(nn);
		puthex(ReadPCHIST());
		putch(' ');
	}
}

void interrupt IBERout()
{
	int nn;

	DBGDisplayString("\r\nInstruction Bus Error:\r\n");
	DBGDisplayString("PC History:\r\n");
	for (nn = 63; nn >= 0; nn--) {
		SetPCHNDX(nn);
		puthex(ReadPCHIST());
		putch(' ');
	}
	forever {}
}


// Wait for num queue entry slots to be available.
// Returns:
// 	r1 = number of entries in queue

int GrWaitQue(register int num)
{
	asm {
		sub		$sp,$sp,#16
		sw		$v1,[$sp]
		sw		$r6,8[$sp]
		ldi		$r6,#$FFDCC000
		neg		$v1,$a0
		add		$v1,$v1,#1020
.0001:
		lhu		$v0,$6E8[r6]
		bgt		$v0,$v1,.0001
		lw		$v1,[$sp]
		lw		$r6,8[$sp]
		add		$sp,$sp,#16
	}
}

// GrQueCmd
//    Place a command in the graphics command queue.
// Parameters:
// 	val		data for command
//	cmd		command number
// Returns:
//	nothing

void GrQueCmd(register int val, register int cmd)
{
	asm {
		sub		$sp,$sp,#8
		sw		$r6,[$sp]
		ldi		$r6,#$FFDCC000
		sh		$a0,$6E0[$r6]		; set value
		sh		$a1,$6E4[$r6]		; set command
		sh		$r0,$6E8[$r6]		; queue
		lw		$r6,[$sp]
		add		$sp,$sp,#8
	}
}

void GrResetCmdQue()
{
	GrQueCmd(0,254);
}

// Send four NOP commands to the command queue.
void GrFlushCmdQue()
{
	int nn;

	GrWaitQue(4);	
	for (nn = 0; nn < 4; nn++)
		GrQueCmd(0,255);
}

// GrPlotPoint
//    Plot a point.
//
// Parameters:
// 	x 		x position as a fixed point 16.16 number
//	y		y position as a fixed point number
//	color	15 bit RGB555 color
//  alpha	16 bit alpha value as fraction of one 0xFFFF = 1, 0x0000 = 0
// Returns:
// 	nothing

void GrPlotPoint(int x, int y, int color, int alpha)
{
	GrWaitQue(5);
	GrQueCmd(color & 0x7fff, 12);	// set pen color
	GrQueCmd(alpha & 0xffff, 14);	// set alpha value
	GrQueCmd(x,16);			// set x0 pos
	GrQueCmd(y,17);			// set y0 pos
	GrQueCmd(0x10,1);				// plot point
}

void GrDrawLine(int x0, int y0, int x1, int y1, int color, int alpha)
{
	GrWaitQue(7);
	GrQueCmd(color & 0x7fff, 12);	// set pen color
	GrQueCmd(alpha & 0xffff, 14);	// set alpha value
	GrQueCmd(x0,16);			// set x0 pos
	GrQueCmd(y0,17);			// set y0 pos
	GrQueCmd(x1,19);			// set x1 pos
	GrQueCmd(y1,20);			// set y1 pos
	GrQueCmd(0x10,2);				// draw line
}

// Plot some points on the screen in random colors.

void RandomPoints()
{
	int nn;
	int x, y, color;

	randStream = 0;
	for (nn = 0; nn < 10000; nn++) {
		color = GetRand(randStream) & 0x7fff;
		x = (GetRand(randStream) % 400) + 128;
		y = (GetRand(randStream) % 300) + 14;
		GrPlotPoint(x<<16,y<<16,color,-1);
	}
}

void RandomLines()
{
	int nn;
	int x0,y0,x1,y1;
	int color;
		
	randStream = 0;
	for (nn = 0; nn < 20000; nn++) {
		color = GetRand(randStream) & 0x7fff;
		x0 = (GetRand(randStream) % 400) + 128;
		y0 = (GetRand(randStream) % 300) + 14;
		x1 = (GetRand(randStream) % 400) + 128;
		y1 = (GetRand(randStream) % 300) + 14;
		GrDrawLine(x0<<16,y0<<16,x1<<16,y1<<16,color,-1);
	}
}

void GrFillRect(int x0, int y0, int x1, int y1, int color)
{
	GrWaitQue(6);
	GrQueCmd(color & 0x7fff, 13);	// set fill color
	GrQueCmd(x0,16);			// set x0 pos
	GrQueCmd(y0,17);			// set y0 pos
	GrQueCmd(x1,19);			// set x1 pos
	GrQueCmd(y1,20);			// set y1 pos
	GrQueCmd(0x10,3);			// fill rect
}

void RandomRects()
{
	int nn;
	int x0, y0, x1, y1, color;

	randStream = 0;
	for (nn = 0; nn < 1000; nn++) {
		color = GetRand(randStream) & 0x7fff;
		x0 = (GetRand(randStream) % 400) + 128;
		y0 = (GetRand(randStream) % 300) + 14;
		x1 = (GetRand(randStream) % 400) + 128;
		y1 = (GetRand(randStream) % 300) + 14;
		GrFillRect(x0<<16,y0<<16,x1<<16,y1<<16,color);
	}
}

void GrDrawChar(int x, int y, int ch)
{
	GrWaitQue(5);
	GrQueCmd(0x7FFF, 12);	// set pen color
	GrQueCmd(0x000F, 13);	// set fill color
	GrQueCmd(x,16);			// set x0 pos
	GrQueCmd(y,17);			// set y0 pos
	GrQueCmd(ch,0);			// text blit
}

void RandomChars()
{
	int nn, ch;
	int x0, y0;

	randStream = 0;

	y0 = 128;
	ch = 'A';
	GrWaitQue(2);
	GrQueCmd(0x7FFF, 12);	// set pen color
	GrQueCmd(0x000F, 13);	// set fill color
	for (x0 = 128; x0 < 500; x0 += 10) {
		GrWaitQue(3);
		GrQueCmd(x0<<16,16);
		GrQueCmd(y0<<16,17);
		GrQueCmd(ch,0);
		ch++;
	}
	/*
	for (nn = 0; nn < 10000; nn++) {
		x0 = (GetRand(randStream) % 512) + 128;
		y0 = (GetRand(randStream) % 256) + 14;
		ch = (GetRand(randStream) % 128);
		GrWaitQue(5);
		GrQueCmd(0x7FFF, 12);	// set pen color
		GrQueCmd(0x000F, 13);	// set fill color
		GrQueCmd(x0<<16,16);
		GrQueCmd(y0<<16,17);
		GrQueCmd(ch,0);
//		GrDrawChar(x0<<16,y0<<16,ch);
	}
	*/
}


void GrClearScreen()
{
	int nn;
	__int16 *pScreen = (__int16 *)0x100000;

	for (nn = 0; nn < 480000; nn++)	
		pScreen[nn] = 0x000f;
}

void ColorBandMemory()
{
	__int16 *pScreen = (__int16 *)0x100000;
	int nn;
	__int16 color;

	randStream = 0;
	for (nn = 0; nn < 480000; nn++) {
		if (nn % 1024 == 0)
			color = GetRand(randStream);
		pScreen[nn] = color;
	}
}

void EnableSprite(int spriteno)
{
	unsigned __int32 *pAVIC = AVIC;
	pAVIC[492] = pAVIC[492] | (1 << spriteno);
}

void EnableSprites(int sprites)
{
	unsigned __int32 *pAVIC = AVIC;
	pAVIC[492] = pAVIC[492] | sprites;
}

void RandomizeSpriteColors()
{
	int colorno;
	unsigned __int32 *pSprite = &AVIC[0];
	randStream = 0;
	for (colorno = 2; colorno < 256; colorno++) {
		pSprite[colorno] = GetRand(randStream) & 0x7fff;
	}
}

void SetSpritePos(int spriteno, int x, int y)
{
	__int32 *pSprite = &AVIC[0x100];
	pSprite[spriteno*4 + 2] = (__int32)((y << 16) | x);
}

void RandomizeSpritePositions()
{
	int spriteno;
	int x,y;
	__int32 *pSprite = &AVIC[0x100];
	randStream = 0;
	for (spriteno = 0; spriteno < 32; spriteno++) {
		x = (GetRand(randStream) % 400) + 128;
		y = (GetRand(randStream) % 300) + 14;
		pSprite[2] = (y << 16) | x;
		pSprite += 4;
	}
}

void SpriteDemo()
{
	int spriteno;
	__int32 xpos[32];
	__int32 ypos[32];
	__int32 dx[32];
	__int32 dy[32];
	int n, m;
	int btn;
	int x,y;

	unsigned __int32 *pSprite = &AVIC[0x100];
	unsigned __int32 *pImages = (unsigned __int32 *)0x1E000000;
	int n;
	
	randStream = 0;
	LEDS(2);
	RandomizeSpriteColors();
	EnableSprites(-1);
	// Set some random image data
	for (n = 0; n < 32 * 32 * 4; n = n + 1)
		pImages[n] = GetRand(randStream);
	x = 128; y = 64;
	for (spriteno = 0; spriteno < 32; spriteno++) {
		pSprite[spriteno*4] = (__int32)&pImages[spriteno * 128];
		pSprite[spriteno*4+1] = 32*60;
		xpos[spriteno] = x;
		ypos[spriteno] = y;
		SetSpritePos(spriteno, x, y);
		x += 20;
		if (x >= 500) {
			x = 128;
			y += 64;
		}
	}
	LEDS(0xf7);
	forever {
		btn = GetButton() & 31;
		LEDS(btn);
		switch(btn) {
		case BTNU:	goto j1;
		}
	}
j1:
	while (GetButton() & 31);
	for (spriteno = 0; spriteno < 32; spriteno++) {
//		xpos[spriteno] = (GetRand(randStream) % 400) + 128;
//		ypos[spriteno] = (GetRand(randStream) % 300) + 14;
//		SetSpritePos(spriteno, (int)xpos[spriteno], (int)ypos[spriteno]);
		dx[spriteno] = (GetRand(randStream) % 16) - 8;
		dy[spriteno] = (GetRand(randStream) % 16) - 8;
	}
	// Set some random image data
	for (n = 0; n < 32 * 32 * 2; n = n + 1)
		pImages[n] = GetRand(randStream);
	forever {
		for (m = 0; m < 50000; m++);	// Timing delay
		for (spriteno = 0; spriteno < 32; spriteno++) {
			LEDS(spriteno);
			xpos[spriteno] = xpos[spriteno] + dx[spriteno];
			ypos[spriteno] = ypos[spriteno] + dy[spriteno];
			if (xpos[spriteno] < 128) {
				xpos[spriteno] = 128;
				dx[spriteno] = -dx[spriteno];
			}
			if (xpos[spriteno] >= 528) {
				xpos[spriteno] = 528;
				dx[spriteno] = -dx[spriteno];
			}
			if (ypos[spriteno] < 14) {
				ypos[spriteno] = 14;
				dy[spriteno] = -dy[spriteno];
			}
			if (ypos[spriteno] >= 314) 
				ypos[spriteno] = 314;
				dy[spriteno] = -dy[spriteno];
			}
			SetSpritePos(spriteno, (int)xpos[spriteno], (int)ypos[spriteno]);
		}
	}
}

void AudioTest()
{
	unsigned __int32 *pGPIO = (unsigned __int32 *)(0xFFDC0700);
	unsigned __int32 *pAVIC = AVIC;
	
	LEDS(0xf7);
	pGPIO[0] = 0xFFFFFFFF;		// turn on audio clocks
	pAVIC[404] = 0x0000401F;	// Enable channels and test mode
}

void InitAudio()
{
	unsigned __int32 *pAVIC = AVIC;

	// Channel 0
	pAVIC[384] = 0x200000;
	pAVIC[385] = 65535;		// buffer length
	pAVIC[386] = 0xFFFFF;	// period to max
	pAVIC[387] = 0x0000;	// volume = 0, output data = 0

	// Channel 1
	pAVIC[388] = 0x210000;
	pAVIC[389] = 65535;		// buffer length
	pAVIC[390] = 0xFFFFF;	// period to max
	pAVIC[391] = 0x0000;	// volume = 0, output data = 0

	// Channel 2
	pAVIC[392] = 0x220000;
	pAVIC[393] = 65535;		// buffer length
	pAVIC[394] = 0xFFFFF;	// period to max
	pAVIC[395] = 0x0000;	// volume = 0, output data = 0

	// Channel 3
	pAVIC[396] = 0x230000;
	pAVIC[397] = 65535;		// buffer length
	pAVIC[398] = 0xFFFFF;	// period to max
	pAVIC[399] = 0x0000;	// volume = 0, output data = 0

	// Channel I
	pAVIC[400] = 0x240000;
	pAVIC[401] = 65535;		// buffer length
	pAVIC[402] = 0xFFFFF;	// period to max
	pAVIC[403] = 0x0000;	// volume = 0, output data = 0

	pAVIC[404] = 0x00001F00;	// Reset
	pAVIC[404] = 0x00000000;
}
