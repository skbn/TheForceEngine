#ifndef RENDERER_ASM_H
#define RENDERER_ASM_H

#include <TFE_System/types.h>
#include "TFE_Jedi/Math/fixedPoint.h"
#include "TFE_Jedi/Math/core_math.h"

namespace TFE_Jedi
{

#ifdef USE_ASM
    extern "C"
    {
        void drawColumn_Fullbright_asm();
        void drawColumn_Lit_asm();
        void drawColumn_Fullbright_Trans_asm();
        void drawColumn_Lit_Trans_asm();

        void drawColumnS_Fullbright_asm();
        void drawColumnS_Lit_asm();
        void drawColumnS_Fullbright_Trans_asm();
        void drawColumnS_Lit_Trans_asm();

        void drawScanline_Lit_asm();
        void drawScanline_Fullbright_asm();
        void drawScanline_Trans_asm();
        void drawScanline_Fullbright_Trans_asm();

        void robj3d_drawColumnFlatColor_asm();
        void robj3d_drawColumnShadedColor_asm();
        void robj3d_drawColumnFlatTexture_asm();
        void robj3d_drawColumnShadedTexture_asm();

        fixed16_16 solveForZ_asm(RWallSegmentFixed* wallSegment __asm("a0"), s32 x __asm("d0"), fixed16_16 numerator __asm("d1"), fixed16_16* outViewDx __asm("a1") = nullptr);
        void wall_drawSolid_asm(RWallSegmentFixed* wallSegment __asm("a0"));
        void wall_drawTransparent_asm(RWallSegmentFixed* wallSegment __asm("a0"), EdgePairFixed* edge __asm("a1"));
        void wall_drawBottom_asm(RWallSegmentFixed* wallSegment __asm("a0"));
        void wall_drawTop_asm(RWallSegmentFixed* wallSegment __asm("a0"));
        void wall_drawTopAndBottom_asm(RWallSegmentFixed* wallSegment __asm("a0"));

        void robj3d_transformVertices_asm(s32 vertexCount __asm("d0"), vec3_fixed* vtxIn __asm("a0"), s32* xform __asm("a1"), vec3_fixed* offset __asm("a2"), vec3_fixed* vtxOut __asm("a3"));
        void robj3d_shadeVertices_asm(s32 vertexCount __asm("d0"), fixed16_16* outShading __asm("a0"), const vec3_fixed* vertices __asm("a1"), const vec3_fixed* normals __asm("a2"));
        fixed16_16 robj3d_dotProduct_asm(const vec3_fixed* pos __asm("a0"), const vec3_fixed* normal __asm("a1"), const vec3_fixed* dir __asm("a2"));
        void robj3d_projectVertices_asm(vec3_fixed* pos __asm("a0"), s32 count __asm("d0"), vec3_fixed* out __asm("a1"));

        extern void* g_rcfState_ptr;

        extern fixed16_16* g_asm_scanlineU0;
        extern fixed16_16* g_asm_scanlineV0;
        extern fixed16_16* g_asm_scanline_dUdX;
        extern fixed16_16* g_asm_scanline_dVdX;
        extern s32* g_asm_scanlineWidth;
        extern const u8** g_asm_scanlineLight;
        extern u8** g_asm_scanlineOut;
        extern u8** g_asm_ftexImage;

        extern s32* g_asm_s_sectorAmbient;
        extern s32* g_asm_s_scaledAmbient;
        extern s32* g_asm_s_cameraLightSource;
        extern s32* g_asm_s_worldAmbient;
        extern s32* g_asm_s_sectorAmbientFraction;
        extern s32* g_asm_s_lightCount;
        extern const u8** g_asm_s_lightSourceRamp;
        extern void* g_asm_s_cameraLight;

        extern s32* g_asm_s_columnHeight;
        extern u8** g_asm_s_pcolumnOut;
        extern u8* g_asm_s_polyColorIndex;
        extern const u8** g_asm_s_polyColorMap;
        extern TextureData** g_asm_s_polyTexture;
        extern fixed16_16* g_asm_s_col_I0;
        extern fixed16_16* g_asm_s_col_dIdY;
        extern vec2_fixed* g_asm_s_col_Uv0;
        extern vec2_fixed* g_asm_s_col_dUVdY;
        extern s32* g_asm_s_dither;
        extern fixed16_16* g_asm_s_ditherOffset;
    }

    #define drawColumn_Fullbright drawColumn_Fullbright_asm
    #define drawColumn_Lit drawColumn_Lit_asm
    #define drawColumn_Fullbright_Trans drawColumn_Fullbright_Trans_asm
    #define drawColumn_Lit_Trans drawColumn_Lit_Trans_asm

    #define drawColumnS_Fullbright drawColumnS_Fullbright_asm
    #define drawColumnS_Lit drawColumnS_Lit_asm
    #define drawColumnS_Fullbright_Trans drawColumnS_Fullbright_Trans_asm
    #define drawColumnS_Lit_Trans drawColumnS_Lit_Trans_asm

    #define drawScanline drawScanline_Lit_asm
    #define drawScanline_Lit drawScanline_Lit_asm
    #define drawScanline_Fullbright drawScanline_Fullbright_asm
    #define drawScanline_Trans drawScanline_Trans_asm
    #define drawScanline_Fullbright_Trans drawScanline_Fullbright_Trans_asm

    #define robj3d_drawColumnFlatColor robj3d_drawColumnFlatColor_asm
    #define robj3d_drawColumnShadedColor robj3d_drawColumnShadedColor_asm
    #define robj3d_drawColumnFlatTexture robj3d_drawColumnFlatTexture_asm
    #define robj3d_drawColumnShadedTexture robj3d_drawColumnShadedTexture_asm

    #define solveForZ solveForZ_asm
    #define wall_drawSolid wall_drawSolid_asm

    #define wall_drawTransparent wall_drawTransparent_asm
    #define wall_drawBottom wall_drawBottom_asm
    #define wall_drawTop wall_drawTop_asm
    #define wall_drawTopAndBottom wall_drawTopAndBottom_asm

    #define robj3d_transformVertices robj3d_transformVertices_asm
    #define robj3d_shadeVertices robj3d_shadeVertices_asm
    #define robj3d_dotProduct robj3d_dotProduct_asm
    #define robj3d_projectVertices robj3d_projectVertices_asm
#else
    #define drawColumn_Fullbright drawColumn_Fullbright_c
    #define drawColumn_Lit drawColumn_Lit_c
    #define drawColumn_Fullbright_Trans drawColumn_Fullbright_Trans_c
    #define drawColumn_Lit_Trans drawColumn_Lit_Trans_c

    #define drawColumnS_Fullbright drawColumnS_Fullbright_c
    #define drawColumnS_Lit drawColumnS_Lit_c
    #define drawColumnS_Fullbright_Trans drawColumnS_Fullbright_Trans_c
    #define drawColumnS_Lit_Trans drawColumnS_Lit_Trans_c

    #define drawScanline drawScanline_Lit_c
    #define drawScanline_Lit drawScanline_Lit_c
    #define drawScanline_Fullbright drawScanline_Fullbright_c
    #define drawScanline_Trans drawScanline_Trans_c
    #define drawScanline_Fullbright_Trans drawScanline_Fullbright_Trans_c

    #define robj3d_drawColumnFlatColor robj3d_drawColumnFlatColor_c
    #define robj3d_drawColumnShadedColor robj3d_drawColumnShadedColor_c
    #define robj3d_drawColumnFlatTexture robj3d_drawColumnFlatTexture_c
    #define robj3d_drawColumnShadedTexture robj3d_drawColumnShadedTexture_c

    #define solveForZ solveForZ_c
    #define wall_drawSolid wall_drawSolid_c

    #define wall_drawTransparent wall_drawTransparent_c
    #define wall_drawBottom wall_drawBottom_c
    #define wall_drawTop wall_drawTop_c
    #define wall_drawTopAndBottom wall_drawTopAndBottom_c

    #define robj3d_transformVertices robj3d_transformVertices_c
    #define robj3d_shadeVertices robj3d_shadeVertices_c
    #define robj3d_dotProduct robj3d_dotProduct_c
    #define robj3d_projectVertices robj3d_projectVertices_c
#endif

    namespace RClassic_Fixed
    {
        void drawColumn_Fullbright_c();
        void drawColumn_Lit_c();
        void drawColumn_Fullbright_Trans_c();
        void drawColumn_Lit_Trans_c();

        void drawColumnS_Fullbright_c();
        void drawColumnS_Lit_c();
        void drawColumnS_Fullbright_Trans_c();
        void drawColumnS_Lit_Trans_c();

        void drawScanline_Lit_c();
        void drawScanline_Fullbright_c();
        void drawScanline_Trans_c();
        void drawScanline_Fullbright_Trans_c();

        void robj3d_drawColumnFlatColor_c();
        void robj3d_drawColumnShadedColor_c();
        void robj3d_drawColumnFlatTexture_c();
        void robj3d_drawColumnShadedTexture_c();

        fixed16_16 solveForZ_c(RWallSegmentFixed* wallSegment, s32 x, fixed16_16 numerator, fixed16_16* outViewDx = nullptr);   
        void wall_drawSolid_c(RWallSegmentFixed* wallSegment);
        void wall_drawTransparent_c(RWallSegmentFixed* wallSegment, EdgePairFixed* edge);
        void wall_drawBottom_c(RWallSegmentFixed* wallSegment);
        void wall_drawTop_c(RWallSegmentFixed* wallSegment);
        void wall_drawTopAndBottom_c(RWallSegmentFixed* wallSegment);

        void robj3d_transformVertices_c(s32 vertexCount, vec3_fixed* vtxIn, s32* xform, vec3_fixed* offset, vec3_fixed* vtxOut);
        void robj3d_shadeVertices_c(s32 vertexCount, fixed16_16* outShading, const vec3_fixed* vertices, const vec3_fixed* normals);
        fixed16_16 robj3d_dotProduct_c(const vec3_fixed* pos, const vec3_fixed* normal, const vec3_fixed* dir);
        void robj3d_projectVertices_c(vec3_fixed* pos, s32 count, vec3_fixed* out);
    }
}

#endif
