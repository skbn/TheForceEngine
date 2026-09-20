#include <TFE_RenderBackend/renderBackend.h>
#include <TFE_RenderBackend/dynamicTexture.h>
#include <TFE_RenderBackend/textureGpu.h>

#include <TFE_System/system.h>
#include <TFE_Input/input.h>
/*
#include <TFE_Settings/settings.h>
#include <TFE_Asset/imageAsset.h>	// For image saving, this should be refactored...
#include <TFE_System/profiler.h>
#include <TFE_PostProcess/blit.h>
#include <TFE_PostProcess/postprocess.h>
*/
#include <TFE_FileSystem/filestream.h>

#define MonitorInfo MonitorInfo_Amiga
#define DisplayInfo DisplayInfo_Amiga

// #include <devices/input.h>
#include <libraries/lowlevel.h>
#include <intuition/intuition.h>
// #include <intuition/intuitionbase.h>
#include <graphics/videocontrol.h>
// #include <workbench/startup.h>
#include <clib/alib_protos.h>
#include <clib/debug_protos.h>
#include <proto/intuition.h>
#include <exec/execbase.h>
#include <proto/exec.h>
// #include <proto/keymap.h>
// #include <proto/lowlevel.h>
#include <proto/dos.h>
// #include <proto/timer.h>
#include <proto/graphics.h>
// #include <proto/icon.h>
// #include <proto/input.h>

#include <cybergraphx/cybergraphics.h>
#include <proto/cybergraphics.h>

// #include <newmouse.h>

#undef MonitorInfo
#undef DisplayInfo

#include <SDI_compiler.h>
// #include <SDI_interrupt.h>

#include <stdio.h>
#include <math.h>
#include <string.h>

#include "ecs_quant.h"
#include "ecs_palette.h"
#include "amiga_scalers.h"

#define buildprintf(...) TFE_System::logWrite(LOG_MSG, "RenderBackend", __VA_ARGS__)
#define buildputs(x) TFE_System::logWrite(LOG_MSG, "RenderBackend", (x))

/* AFF_68080 is not in NDK 3.2: bit 10 is AFF_FPGA, reused by Apollo for 68080 */
#ifndef AFB_68080
#define AFB_68080 10
#endif

#ifndef AFF_68080
#define AFF_68080 (1L << AFB_68080)
#endif

// #define BENCHMARK

extern "C"
{
    void ASM c2p1x1_8_c5_bm(REG(d0, WORD chunkyx), REG(d1, WORD chunkyy), REG(d2, WORD offsx), REG(d3, WORD offsy), REG(a0, APTR chunkyscreen), REG(a1, struct BitMap *bitmap));
    void ASM c2p1x1_8_c5_bm_040(REG(d0, WORD chunkyx), REG(d1, WORD chunkyy), REG(d2, WORD offsx), REG(d3, WORD offsy), REG(a0, APTR chunkyscreen), REG(a1, struct BitMap *bitmap));
    void ASM c2p1x1_4_c5_bm(REG(d0, WORD chunkyx), REG(d1, WORD chunkyy), REG(d2, WORD offsx), REG(d3, WORD offsy), REG(a0, APTR chunkyscreen), REG(a1, struct BitMap *bitmap));
    void ASM c2p1x1_5_c5_bm(REG(d0, WORD chunkyx), REG(d1, WORD chunkyy), REG(d2, WORD offsx), REG(d3, WORD offsy), REG(a0, APTR chunkyscreen), REG(a1, struct BitMap *bitmap));
    void ASM c2p1x1_6_c5_bm(REG(d0, WORD chunkyx), REG(d1, WORD chunkyy), REG(d2, WORD offsx), REG(d3, WORD offsy), REG(a0, APTR chunkyscreen), REG(a1, struct BitMap *bitmap));
    int ASM c2p1x1_4_c5_bm_remap(REG(d0, WORD chunkyx), REG(d1, WORD chunkyy), REG(d2, WORD offsx), REG(d3, WORD offsy), REG(a0, APTR chunkyscreen), REG(a1, struct BitMap *bitmap), REG(a2, UBYTE *remap));
    int ASM c2p1x1_5_c5_bm_remap(REG(d0, WORD chunkyx), REG(d1, WORD chunkyy), REG(d2, WORD offsx), REG(d3, WORD offsy), REG(a0, APTR chunkyscreen), REG(a1, struct BitMap *bitmap), REG(a2, UBYTE *remap));
    int ASM c2p1x1_6_c5_bm_remap(REG(d0, WORD chunkyx), REG(d1, WORD chunkyy), REG(d2, WORD offsx), REG(d3, WORD offsy), REG(a0, APTR chunkyscreen), REG(a1, struct BitMap *bitmap), REG(a2, UBYTE *remap));

    // struct Library *CyberGfxBase = NULL;
    struct Device *InputBase;
}

#ifdef BENCHMARK
int t1, t2, t3, t4, t5, t6, t7, t8, t9;
#endif

static uint8 *s_remappedFB = NULL;
static size_t s_remappedFBSize = 0;

namespace TFE_RenderBackend
{
static struct Window *window = NULL;
static struct Screen *screen = NULL;
static unsigned char ppal[256 * 4];
static ULONG spal[1 + (256 * 3) + 1];
static uint8_t s_rtgPal[256 * 3];
static int updatePalette = FALSE;
static int use_c2p = FALSE;
static int use_c2p_040 = FALSE;
// static int use_wcp = FALSE;
static int currentBitMap;
static struct ScreenBuffer *sbuf[2];
static struct RastPort temprp;
// static struct BitMap *tempbm;
static struct MsgPort *dispport;
static struct MsgPort *safeport;
static int safetochange = FALSE;
static int safetowrite = FALSE;
static ULONG fsMonitorID = INVALID_ID;
static ULONG fsModeID = INVALID_ID;
struct Library *CyberGfxBase = NULL;
ULONG directrtg = FALSE;
static char wndPubScreen[32] = {"Workbench"};
static ULONG rtg320x240 = FALSE;

static UWORD *pointermem;

static uint8_t *scaledBuffer = NULL;
static int displayWidth = 0;
static int displayHeight = 0;
static int displayOffsetX = 0;
static int displayOffsetY = 0;

static WindowState m_windowState;
static u32 s_virtualWidth, s_virtualHeight;
static u32 s_virtualWidthUi;
static u32 s_virtualWidth3d;
static u8 *s_curFrameBuffer = nullptr;
static bool s_colorCorrection = false;
static u8 s_gammaTable[256];

static const char *getmonitorname(ULONG modeID)
{
    ULONG monitorid = (modeID & MONITOR_ID_MASK);

    switch (monitorid)
    {
    case PAL_MONITOR_ID:
        return "PAL";
    case NTSC_MONITOR_ID:
        return "NTSC";
    case DBLPAL_MONITOR_ID:
        return "DBLPAL";
    case DBLNTSC_MONITOR_ID:
        return "DBLNTSC";
    case EURO36_MONITOR_ID:
        return "EURO36";
    case EURO72_MONITOR_ID:
        return "EURO72";
    case SUPER72_MONITOR_ID:
        return "SUPER72";
    case VGA_MONITOR_ID:
        return "MULTISCAN";
    }

    if (CyberGfxBase && IsCyberModeID(modeID))
        return "RTG";

    return "UNKNOWN";
}

#include <stdarg.h>

static void BE_ST_DebugText(struct RastPort *rp, int x, int y, const char *fmt, ...)
{
    char buffer[256];
    va_list ap;

    va_start(ap, fmt);
    vsnprintf(buffer, sizeof(buffer), fmt, ap);
    va_end(ap);
    // SetAPen(rp, 247);
    Move(rp, x + window->BorderLeft, y + rp->Font->tf_Baseline + window->BorderTop);
    Text(rp, buffer, strlen(buffer));
}

static void showframe(void)
{
    if (screen)
    {
        const int direct = directrtg && CyberGfxBase && !use_c2p;

        if (direct)
            currentBitMap = 0;
        else
            currentBitMap ^= 1;

        if (use_c2p)
        {
            if (ecsDepth == 4)
            {
                if (c2p1x1_4_c5_bm_remap(s_virtualWidth, s_virtualHeight, 0, 0, s_curFrameBuffer, sbuf[currentBitMap]->sb_BitMap, ecsRemap) != 0)
                {
                    size_t fbsize = s_virtualWidth * s_virtualHeight;

                    if (fbsize > s_remappedFBSize)
                    {
                        if (s_remappedFB)
                            free(s_remappedFB);

                        s_remappedFB = (uint8 *)malloc(fbsize);
                        s_remappedFBSize = fbsize;
                    }

                    memcpy(s_remappedFB, s_curFrameBuffer, fbsize);

                    ecsRemapFramebuffer(s_remappedFB, fbsize, ecsRemap);
                    c2p1x1_4_c5_bm(s_virtualWidth, s_virtualHeight, 0, 0, s_remappedFB, sbuf[currentBitMap]->sb_BitMap);
                }
            }
            else if (ecsDepth == 5)
            {
                if (c2p1x1_5_c5_bm_remap(s_virtualWidth, s_virtualHeight, 0, 0, s_curFrameBuffer, sbuf[currentBitMap]->sb_BitMap, ecsRemap) != 0)
                {
                    size_t fbsize = s_virtualWidth * s_virtualHeight;

                    if (fbsize > s_remappedFBSize)
                    {
                        if (s_remappedFB)
                            free(s_remappedFB);

                        s_remappedFB = (uint8 *)malloc(fbsize);
                        s_remappedFBSize = fbsize;
                    }

                    memcpy(s_remappedFB, s_curFrameBuffer, fbsize);

                    ecsRemapFramebuffer(s_remappedFB, fbsize, ecsRemap);
                    c2p1x1_5_c5_bm(s_virtualWidth, s_virtualHeight, 0, 0, s_remappedFB, sbuf[currentBitMap]->sb_BitMap);
                }
            }
            else if (ecsDepth == 6)
            {
                if (c2p1x1_6_c5_bm_remap(s_virtualWidth, s_virtualHeight, 0, 0, s_curFrameBuffer, sbuf[currentBitMap]->sb_BitMap, ecsRemap) != 0)
                {
                    size_t fbsize = s_virtualWidth * s_virtualHeight;

                    if (fbsize > s_remappedFBSize)
                    {
                        if (s_remappedFB)
                            free(s_remappedFB);

                        s_remappedFB = (uint8 *)malloc(fbsize);
                        s_remappedFBSize = fbsize;
                    }

                    memcpy(s_remappedFB, s_curFrameBuffer, fbsize);

                    ecsRemapFramebuffer(s_remappedFB, fbsize, ecsRemap);
                    c2p1x1_6_c5_bm(s_virtualWidth, s_virtualHeight, 0, 0, s_remappedFB, sbuf[currentBitMap]->sb_BitMap);
                }
            }
            else if (use_c2p_040)
            {
                c2p1x1_8_c5_bm_040(s_virtualWidth, s_virtualHeight, 0, 0, s_curFrameBuffer, sbuf[currentBitMap]->sb_BitMap);
            }
            else
            {
                c2p1x1_8_c5_bm(s_virtualWidth, s_virtualHeight, 0, 0, s_curFrameBuffer, sbuf[currentBitMap]->sb_BitMap);
            }
        }
        else if (CyberGfxBase)
        {
            // WritePixelArray(s_curFrameBuffer, 0, 0, s_virtualWidth, window->RPort, 0, 0, s_virtualWidth, s_virtualHeight, RECTFMT_LUT8);
            temprp.BitMap = sbuf[currentBitMap]->sb_BitMap;

            if (scaledBuffer)
            {
                if (filterMode == FILTER_SCALE2X)
                    scale2x(s_curFrameBuffer, scaledBuffer, displayWidth);
                else
                    scaleNearest2x(s_curFrameBuffer, scaledBuffer, displayWidth);

                WritePixelArray(scaledBuffer, 0, 0, displayWidth, &temprp, displayOffsetX, displayOffsetY, displayWidth, displayHeight, RECTFMT_LUT8);
            }
            else
            {
                WritePixelArray(s_curFrameBuffer, 0, 0, s_virtualWidth, &temprp, 0, 0, s_virtualWidth, s_virtualHeight, RECTFMT_LUT8);
            }
        }
#ifdef BENCHMARK
        {
            struct RastPort *rp = &temprp;

            temprp.BitMap = sbuf[currentBitMap]->sb_BitMap;

            BE_ST_DebugText(rp, 0, 16, "t1 %2d t2 %2d t3 %2d t4 %2d t5 %2d t6 %2d", t1, t2, t3, t4, t5, t6);
        }
#endif

        if (dispport)
        {
            if (!safetochange)
            {
                while (!GetMsg(dispport))
                    WaitPort(dispport);

                safetochange = TRUE;
            }
        }

        if (!direct && ChangeScreenBuffer(screen, sbuf[currentBitMap]))
            safetochange = FALSE;

        if (updatePalette)
        {
            if (ecsDepth && use_c2p)
            {
                ULONG *sp = &spal[1];
                spal[0] = ((ULONG)(1 << ecsDepth) << 16) | 0;

                for (int i = 0; i < (1 << ecsDepth); i++)
                {
                    int r = (ecsPalette[i] >> 8) & 15;
                    int g = (ecsPalette[i] >> 4) & 15;
                    int b = ecsPalette[i] & 15;

                    *sp++ = (ULONG)((r << 4) | r) << 24;
                    *sp++ = (ULONG)((g << 4) | g) << 24;
                    *sp++ = (ULONG)((b << 4) | b) << 24;
                }

                LoadRGB32(&screen->ViewPort, spal);
            }
            else
                LoadRGB32(&screen->ViewPort, spal);

            updatePalette = FALSE;
        }
    }
    else
    {
        WriteLUTPixelArray(s_curFrameBuffer, 0, 0, s_virtualWidth, window->RPort, ppal, window->BorderLeft, window->BorderTop, s_virtualWidth, s_virtualHeight, CTABFMT_XRGB8);
    }
}

static void shutdownvideo(void)
{
    // RemoveInputHandler();

    if (window)
    {
        CloseWindow(window);
        window = NULL;
    }

    if (dispport)
    {
        if (!safetochange)
        {
            while (!GetMsg(dispport))
                WaitPort(dispport);

            safetochange = TRUE;
        }

        while (GetMsg(dispport))
            ;
    }

    if (sbuf[0])
    {
        FreeScreenBuffer(screen, sbuf[0]);
        sbuf[0] = NULL;
    }

    if (sbuf[1])
    {
        FreeScreenBuffer(screen, sbuf[1]);
        sbuf[1] = NULL;
    }

    if (dispport)
    {
        DeleteMsgPort(dispport);
        dispport = NULL;
    }

    if (screen)
    {
        CloseScreen(screen);
        screen = NULL;
    }

    if (scaledBuffer)
    {
        FreeVec(scaledBuffer);
        scaledBuffer = NULL;
    }

    if (s_remappedFB)
    {
        free(s_remappedFB);
        s_remappedFB = nullptr;
        s_remappedFBSize = 0;
    }

    use_c2p = 0;
}

static int setvideomode(int x, int y, int c, int fs)
{
    ULONG flags, idcmp;

    shutdownvideo();

    if (fs)
    {
        ULONG modeID = INVALID_ID;

        int scrW = x, scrH = y;

        if (ecsDepth || fsMonitorID != (ULONG)INVALID_ID)
        {
            if (fsModeID != (ULONG)INVALID_ID)
            {
                modeID = fsModeID;
                buildprintf("Using forced mode id: %08x\n", (int)fsModeID);
            }
            else
            {
                buildprintf("Using forced monitor: %s\n", getmonitorname(fsMonitorID));
            }
        }
        else
        {
            if (filterMode != FILTER_NONE)
            {
                scrW = x * 2;
                scrH = y * 2;
            }

            if (!rtg320x240)
            {
                modeID = BestCModeIDTags(
                    CYBRBIDTG_Depth, 8,
                    CYBRBIDTG_NominalWidth, scrW,
                    CYBRBIDTG_NominalHeight, scrH,
                    TAG_DONE);
            }

            if (modeID == (ULONG)INVALID_ID && x == 320 && y == 200)
            {
                // some cards like the Voodoo 3 lack a 320x200 mode
                modeID = BestCModeIDTags(
                    CYBRBIDTG_Depth, 8,
                    CYBRBIDTG_NominalWidth, 320,
                    CYBRBIDTG_NominalHeight, 240,
                    TAG_DONE);
            }

            if (modeID == (ULONG)INVALID_ID && scrW == 640 && scrH == 400)
            {
                modeID = BestCModeIDTags(
                    CYBRBIDTG_Depth, 8,
                    CYBRBIDTG_NominalWidth, 640,
                    CYBRBIDTG_NominalHeight, 480,
                    TAG_DONE);
            }
        }

        if (modeID == (ULONG)INVALID_ID)
        {
            modeID = BestModeID(
                BIDTAG_NominalWidth, x,
                BIDTAG_NominalHeight, y,
                BIDTAG_Depth, ecsDepth ? ecsDepth : 8,
                // BIDTAG_DIPFMustNotHave, SPECIAL_FLAGS|DIPF_IS_LACE,
                (fsMonitorID == (ULONG)INVALID_ID) ? TAG_IGNORE : BIDTAG_MonitorID, fsMonitorID,
                TAG_DONE);
        }

        struct TagItem vctl[] =
            {
                //{VTAG_SPEVEN_BASE_SET, 10*16},
                //{VTAG_SPEVEN_BASE_SET, 0},
                {VTAG_BORDERBLANK_SET, TRUE},
                {VC_IntermediateCLUpdate, FALSE},
                {VTAG_END_CM, 0}};

        UWORD dummypens[] = {(UWORD)~0};

        screen = OpenScreenTags(0,
                                modeID != (ULONG)INVALID_ID ? SA_DisplayID : TAG_IGNORE, modeID,
                                SA_Width, scrW,
                                SA_Height, scrH,
                                SA_Depth, ecsDepth ? ecsDepth : 8,
                                SA_ShowTitle, FALSE,
                                SA_Quiet, TRUE,
                                SA_Draggable, FALSE,
                                SA_Type, CUSTOMSCREEN,
                                SA_VideoControl, (IPTR)vctl,
                                SA_Pens, (IPTR)dummypens,
                                // SA_Exclusive, TRUE,
                                TAG_DONE);

        memset(spal, 0, sizeof(spal));
        spal[0] = 256 << 16;

        // SetRast(&screen->RastPort, blackcol);
        // SetRast(&screen->RastPort, 0);

        modeID = GetVPModeID(&screen->ViewPort);
        struct NameInfo nameinfo;

        if (GetDisplayInfoData(NULL, (UBYTE *)&nameinfo, sizeof(nameinfo), DTAG_NAME, modeID))
            buildprintf("Opened screen: 0x%08x %s\n", (int)modeID, nameinfo.Name);
        else
            buildprintf("Opened screen: 0x%08x %s\n", (int)modeID, getmonitorname(modeID));

        currentBitMap = 0;
        use_c2p = FALSE;

        InitRastPort(&temprp);

        if ((sbuf[0] = AllocScreenBuffer(screen, 0, SB_SCREEN_BITMAP)) && (sbuf[1] = AllocScreenBuffer(screen, 0, SB_COPY_BITMAP)))
        {
            if ((GetBitMapAttr(screen->RastPort.BitMap, BMA_FLAGS) & BMF_STANDARD) != 0)
                use_c2p = TRUE;

            safetochange = TRUE;

            if ((m_windowState.flags & WINFLAG_VSYNC) != 0)
            {
                dispport = CreateMsgPort();
                sbuf[0]->sb_DBufInfo->dbi_DispMessage.mn_ReplyPort = dispport;
                sbuf[1]->sb_DBufInfo->dbi_DispMessage.mn_ReplyPort = dispport;
            }

            if (CyberGfxBase && !use_c2p && filterMode != FILTER_NONE)
            {
                displayWidth = screen->Width;
                displayHeight = screen->Height;
                displayOffsetX = 0;
                displayOffsetY = 0;

                if (displayWidth >= scrW && displayHeight >= scrH)
                    scaledBuffer = (uint8_t *)AllocVec(displayWidth * displayHeight, MEMF_ANY | MEMF_CLEAR);

                if (!scaledBuffer)
                {
                    filterMode = FILTER_NONE;
                    displayWidth = x;
                    displayHeight = y;
                }
            }
            else
            {
                displayWidth = x;
                displayHeight = y;
            }
        }
        else
        {
            // BIG FAIL
            return -1;
        }
    }

    flags = WFLG_ACTIVATE | WFLG_RMBTRAP;
    idcmp = IDCMP_CLOSEWINDOW /*| IDCMP_ACTIVEWINDOW | IDCMP_INACTIVEWINDOW*/ | IDCMP_RAWKEY | IDCMP_MOUSEBUTTONS;

    if (screen)
        flags |= WFLG_BACKDROP | WFLG_BORDERLESS;
    else
        flags |= WFLG_DRAGBAR | WFLG_DEPTHGADGET | WFLG_CLOSEGADGET;

    if (!screen && strcasecmp(wndPubScreen, "Workbench"))
        buildprintf("Using forced public screen: %s\n", wndPubScreen);

    window = OpenWindowTags(0,
                            WA_InnerWidth, screen ? (s32)screen->Width : x,
                            WA_InnerHeight, screen ? (s32)screen->Height : y,
                            screen ? TAG_IGNORE : WA_Title, (IPTR)m_windowState.name,
                            WA_Flags, flags,
                            screen ? WA_CustomScreen : TAG_IGNORE, (IPTR)screen,
                            !screen ? WA_PubScreenName : TAG_IGNORE, (IPTR)wndPubScreen,
                            WA_IDCMP, idcmp,
                            TAG_DONE);

    if (window == NULL /*|| AddInputHandler()*/)
    {
        shutdownvideo();
        buildputs("Could not open the window");
        return -1;
    }

    char loadText[] = "Loading...";
    // SetAPen(window->RPort, 2);
    Move(window->RPort, 8 + window->BorderLeft, 8 + window->RPort->Font->tf_Baseline + window->BorderTop);
    Text(window->RPort, loadText, sizeof(loadText) - 1);

    if (!screen)
        buildprintf("Opened window on public screen: %s\n", window->WScreen->Title);

    // AddInputHandler();
    if (pointermem && window->Pointer != pointermem)
        SetPointer(window, pointermem, 1, 1, 0, 0);

    return 0;
}

bool init(const WindowState &state)
{
    use_c2p_040 = (SysBase->AttnFlags & (AFF_68040 | AFF_68060 | AFF_68080)) != 0;

    m_windowState = state;
    fsMonitorID = m_windowState.baseWindowWidth;
    fsModeID = m_windowState.baseWindowHeight;
    rtg320x240 = m_windowState.monitorHeight;

    if (!ecsDepth && fsMonitorID == (ULONG)INVALID_ID)
        CyberGfxBase = OpenLibrary((STRPTR) "cybergraphics.library", 41);

    pointermem = (UWORD *)AllocVec(2 * 6, MEMF_CHIP | MEMF_CLEAR);

    int error = setvideomode(state.width, state.height, 8, !!(state.flags & WINFLAG_FULLSCREEN));

    return error == 0;
}

void destroy()
{
    shutdownvideo();
    if (CyberGfxBase)
    {
        CloseLibrary(CyberGfxBase);
        CyberGfxBase = NULL;
    }

    if (pointermem)
    {
        FreeVec(pointermem);
        pointermem = NULL;
    }
}

bool getVsyncEnabled()
{
    return false;
}

void enableVsync(bool enable)
{
}

void setClearColor(const f32 *color)
{
}

void swap(bool blitVirtualDisplay)
{
    // TFE_RenderState::clear();
    if (s_curFrameBuffer)
    {
        showframe();
        s_curFrameBuffer = nullptr;
    }
}

void captureScreenToMemory(u32 *mem)
{
}

void queueScreenshot(const char *screenshotPath)
{
}

void startGifRecording(const char *path)
{
}

void stopGifRecording()
{
}

void updateSettings()
{
    // TODO save window position
}

void resize(s32 width, s32 height)
{
}

void enumerateDisplays()
{
}

s32 getDisplayCount()
{
    return 1;
}

s32 getDisplayIndex(s32 x, s32 y)
{
    return -1;
}

bool getDisplayMonitorInfo(s32 displayIndex, MonitorInfo *monitorInfo)
{
    monitorInfo->x = 0;
    monitorInfo->y = 0;
    monitorInfo->w = 320;
    monitorInfo->h = 200;
    // return false;
    return true;
}

f32 getDisplayRefreshRate()
{
    return 0.0f;
}

void getCurrentMonitorInfo(MonitorInfo *monitorInfo)
{
}

void enableFullscreen(bool enable)
{
}

void clearWindow()
{
}

void getDisplayInfo(DisplayInfo *displayInfo)
{
    displayInfo->width = m_windowState.width;
    displayInfo->height = m_windowState.height;
    displayInfo->refreshRate = (m_windowState.flags & WINFLAG_VSYNC) != 0 ? m_windowState.refreshRate : 0.0f;
}

// New version of the function.
bool createVirtualDisplay(const VirtualDisplayInfo &vdispInfo)
{
    /*
    buildprintf("%s\n width %u\n height %u widthUi %u\n width3d %u\n",
            __FUNCTION__,
            vdispInfo.width,
            vdispInfo.height,
            vdispInfo.widthUi,
            vdispInfo.width3d
    );
    */
    s_virtualWidth = vdispInfo.width;
    s_virtualHeight = vdispInfo.height;
    s_virtualWidthUi = vdispInfo.widthUi;
    s_virtualWidth3d = vdispInfo.width3d;
    return false;
}

u32 getVirtualDisplayWidth2D()
{
    return 0;
}

u32 getVirtualDisplayWidth3D()
{
    return 0;
}

u32 getVirtualDisplayHeight()
{
    return 0;
}

u32 getVirtualDisplayOffset2D()
{
    return 0;
}

u32 getVirtualDisplayOffset3D()
{
    return 0;
}

void *getVirtualDisplayGpuPtr()
{
    // HACK re-purposed for the palette pointer
    return window;
    // return nullptr;
}

bool getWidescreen()
{
    return false;
}

bool getFrameBufferAsync()
{
    return false;
}

bool getGPUColorConvert()
{
    return false;
}

void updateVirtualDisplay(const void *buffer, size_t size)
{
    s_curFrameBuffer = (u8 *)buffer;
}

void bindVirtualDisplay()
{
}

void clearVirtualDisplay(f32 *color, bool clearColor)
{
}

void copyToVirtualDisplay(RenderTargetHandle src)
{
}

void copyBackbufferToRenderTarget(RenderTargetHandle dst)
{
}

void setPalette(const u32 *palette)
{
    u8 *palrgba = (u8 *)palette;

    if (screen)
    {
        if (!(ecsDepth && use_c2p))
        {
            ULONG *sp = &spal[1];
            uint8_t *rp = s_rtgPal;

            spal[0] = (256 << 16) | 0;

            if (s_colorCorrection)
            {
                u8 *gammaTable = s_gammaTable;

                for (int i = 0; i < 256; i++)
                {
                    uint8_t r = gammaTable[palrgba[3]];
                    uint8_t g = gammaTable[palrgba[2]];
                    uint8_t b = gammaTable[palrgba[1]];

                    *sp++ = (ULONG)r << 24;
                    *sp++ = (ULONG)g << 24;
                    *sp++ = (ULONG)b << 24;

                    *rp++ = r;
                    *rp++ = g;
                    *rp++ = b;

                    palrgba += 4;
                }
            }
            else
            {
                for (int i = 0; i < 256; i++)
                {
                    uint8_t r = palrgba[3];
                    uint8_t g = palrgba[2];
                    uint8_t b = palrgba[1];

                    *sp++ = (ULONG)r << 24;
                    *sp++ = (ULONG)g << 24;
                    *sp++ = (ULONG)b << 24;

                    *rp++ = r;
                    *rp++ = g;
                    *rp++ = b;

                    palrgba += 4;
                }
            }

            updatePalette = TRUE;
        }
    }
    else
    {
        unsigned char *pp = ppal;

        for (int i = 0; i < 256; i++)
        {
            *pp++ = 0;
            *pp++ = palrgba[3];
            *pp++ = palrgba[2];
            *pp++ = palrgba[1];

            palrgba += 4;
        }
    }
}

void setBasePalette(const u32 *palette)
{
    if (screen && ecsDepth && use_c2p)
    {
        ecsUpdatePalette(palette);
        updatePalette = TRUE;
    }
}

void setBasePaletteRaw(const u8 *palette768)
{
    if (screen && ecsDepth && use_c2p)
    {
        u8 scaled[768];

        for (int i = 0; i < 768; i++)
            scaled[i] = palette768[i] << 2;

        ecsUpdatePaletteRaw(scaled);

        updatePalette = TRUE;
    }
}

void applyFrameFx(s32 healthFx, s32 shieldFx, s32 flashFx, JBool lumR, JBool lumG, JBool lumB, s32 brightness, JBool fxEnabled, JBool brightnessEnabled)
{
    if (screen && ecsDepth && use_c2p)
    {
        ecsApplyFrameFx((int)healthFx, (int)shieldFx, (int)flashFx, (int)lumR, (int)lumG, (int)lumB, (int)brightness, (int)fxEnabled, (int)brightnessEnabled);
        updatePalette = TRUE;
    }
}

const u32 *getPalette()
{
    // return s_paletteCpu;
    return nullptr; // TODO
}

const TextureGpu *getPaletteTexture()
{
    return nullptr;
}

void setColorCorrection(bool enabled, const ColorCorrection *color /* = nullptr*/, bool bloomChanged /* = false*/)
{
#ifdef TFE_HAVE_FPU
    s_colorCorrection = enabled && color->gamma != 1.0f;

    if (s_colorCorrection)
    {
        for (int i = 0; i < 256; i++)
            s_gammaTable[i] = pow((float)i / 256.0f, 2.0f - color->gamma) * 256.0f;
    }
#else
    s_colorCorrection = false;
#endif
}

void drawVirtualDisplay()
{
}

// GPU commands
// core gpu functionality for UI and editor.
// Render target.
RenderTargetHandle createRenderTarget(u32 width, u32 height, bool hasDepthBuffer)
{
    return RenderTargetHandle(nullptr);
}

void freeRenderTarget(RenderTargetHandle handle)
{
}

void bindRenderTarget(RenderTargetHandle handle)
{
}

void clearRenderTarget(RenderTargetHandle handle, const f32 *clearColor, f32 clearDepth)
{
}

void clearRenderTargetDepth(RenderTargetHandle handle, f32 clearDepth)
{
}

void copyRenderTarget(RenderTargetHandle dst, RenderTargetHandle src)
{
}

void unbindRenderTarget()
{
}

const TextureGpu *getRenderTargetTexture(RenderTargetHandle rtHandle)
{
    return nullptr;
}

void getRenderTargetDim(RenderTargetHandle rtHandle, u32 *width, u32 *height)
{
}

TextureGpu *createTexture(u32 width, u32 height, u32 channels)
{
    return nullptr;
}

TextureGpu *createTextureArray(u32 width, u32 height, u32 layers, u32 channels)
{
    return nullptr;
}

// Create a GPU version of a texture, assumes RGBA8 and returns a GPU handle.
TextureGpu *createTexture(u32 width, u32 height, const u32 *data, MagFilter magFilter)
{
    return nullptr;
}

void freeTexture(TextureGpu *texture)
{
}

void getTextureDim(TextureGpu *texture, u32 *width, u32 *height)
{
    *width = 0;
    *height = 0;
}

void *getGpuPtr(const TextureGpu *texture)
{
    return nullptr;
}

void drawIndexedTriangles(u32 triCount, u32 indexStride, u32 indexStart)
{
}

void drawLines(u32 lineCount)
{
}

// A quick way of toggling the bloom, but just for the final blit.
void bloomPostEnable(bool enable)
{
}

// Setup the Post effect chain based on current settings.
// TODO: Move out of render backend since this should be independent of the backend.
void setupPostEffectChain(bool useDynamicTexture)
{
}
} // namespace TFE_RenderBackend
