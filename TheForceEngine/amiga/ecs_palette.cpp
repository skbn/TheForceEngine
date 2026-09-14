#include "ecs_palette.h"
#include "ecs_quant.h"
#include <TFE_System/system.h>
#include <string.h>
#include <stdio.h>

#define FX_ONE_16 0x10000
#define FX_HALF_16 0x8000

#define HUD_COLORS_START 24
#define HUD_COLORS_COUNT 8
#define HUD_BYTE_START  (HUD_COLORS_START * 3)
#define HUD_BYTE_END    ((HUD_COLORS_START + HUD_COLORS_COUNT) * 3)

static uint8_t ecsPaletteInput[768];
static uint8_t ecsLastPalette[768];
static int16_t colorWeight[256];
static const uint8_t* ecsActiveColorMap = NULL;
static int ecsHasPalette = 0;
static int ecsColorMapDirty = 0;
static UWORD ecsPaletteBase[64];
static UWORD ecsPaletteClean[64];

static UWORD packHudColor(const uint8_t* rgb)
{
	int r = rgb[0] >> 3;
	int g = rgb[1] >> 3;
	int b = rgb[2] >> 3;

	return (UWORD)(((r >> 1) << 8) | ((g >> 1) << 4) | (b >> 1));
}

static void unpackColor(UWORD c, int* r, int* g, int* b)
{
	*r = (c >> 8) & 15;
	*g = (c >> 4) & 15;
	*b = c & 15;
}

static int colorDist(int r1, int g1, int b1, int r2, int g2, int b2)
{
	int dr = r1 - r2;
	int dg = g1 - g2;
	int db = b1 - b2;

	return dr * dr * 30 + dg * dg * 59 + db * db * 11;
}

static void ecsAssignHudSlots(const uint8_t* palette768)
{
	int used[64] = {0};

	for (int i = 0; i < HUD_COLORS_COUNT; i++)
	{
		const uint8_t* src = palette768 + (HUD_COLORS_START + i) * 3;
		int sr = src[0] >> 4;
		int sg = src[1] >> 4;
		int sb = src[2] >> 4;
		int bestSlot = -1;
		int bestDist = 0x7FFFFFFF;

		for (int j = 0; j < numColors; j++)
		{
			int pr;
			int pg;
			int pb;

			if (used[j])
				continue;

			unpackColor(ecsPaletteBase[j], &pr, &pg, &pb);

			int dist = colorDist(sr, sg, sb, pr, pg, pb);

			if (dist < bestDist)
			{
				bestDist = dist;
				bestSlot = j;
			}
		}

		if (bestSlot >= 0)
		{
			ecsPaletteBase[bestSlot] = packHudColor(src);
			used[bestSlot] = 1;
		}
	}
}

void ecsUpdateColormap(const uint8_t* colorMap)
{
	if (colorMap == ecsActiveColorMap)
		return;

	ecsActiveColorMap = colorMap;
	ecsColorMapDirty = 1;
}

void ecsUpdatePalette(const uint32_t* rgba)
{
	const uint8_t* palrgba = (const uint8_t*)rgba;

	for (int i = 0; i < 256; i++)
	{
		ecsPaletteInput[i*3+0] = palrgba[3];
		ecsPaletteInput[i*3+1] = palrgba[2];
		ecsPaletteInput[i*3+2] = palrgba[1];

		palrgba += 4;
	}

	ecsUpdatePaletteRaw(ecsPaletteInput);
}

void ecsUpdatePaletteRaw(const uint8_t* palette768)
{
	memcpy(ecsPaletteInput, palette768, 768);

	if (ecsHasPalette && !ecsColorMapDirty)
	{
		if (memcmp(ecsPaletteInput, ecsLastPalette, 768) == 0)
			return;

		int nonHudMatch = (memcmp(ecsPaletteInput, ecsLastPalette, HUD_BYTE_START) == 0 && memcmp(ecsPaletteInput + HUD_BYTE_END, ecsLastPalette + HUD_BYTE_END, 768 - HUD_BYTE_END) == 0);

		if (nonHudMatch)
		{
			memcpy(ecsPaletteBase, ecsPaletteClean, numColors * sizeof(UWORD));
			ecsAssignHudSlots(ecsPaletteInput);
			memcpy(ecsPalette, ecsPaletteBase, numColors * sizeof(UWORD));
			ecsBuildRemap(ecsPaletteInput, ecsRemap);
			memcpy(ecsLastPalette, ecsPaletteInput, 768);
			return;
		}
	}

	if (ecsActiveColorMap)
		ecsComputeColorWeights(ecsActiveColorMap, colorWeight);
	else
	{
		for (int i = 0; i < 256; i++)
			colorWeight[i] = 1;
	}

	for (int i = HUD_COLORS_START; i < HUD_COLORS_START + HUD_COLORS_COUNT; i++)
		colorWeight[i] = 0;

	if (quantMethod == QUANT_WU)
		ecsWuQuant(ecsPaletteInput, colorWeight, ecsPalette);
	else if (quantMethod == QUANT_LLOYD3D)
		ecsLloyd3DQuant(ecsPaletteInput, colorWeight, ecsPalette);
	else
		ecsLloydQuant(ecsPaletteInput, colorWeight, ecsPalette);

	memcpy(ecsPaletteBase, ecsPalette, numColors * sizeof(UWORD));
	memcpy(ecsPaletteClean, ecsPalette, numColors * sizeof(UWORD));

	ecsAssignHudSlots(ecsPaletteInput);
	
	memcpy(ecsPalette, ecsPaletteBase, numColors * sizeof(UWORD));

	ecsBuildRemap(ecsPaletteInput, ecsRemap);

	memcpy(ecsLastPalette, ecsPaletteInput, 768);

	ecsHasPalette = 1;
	ecsColorMapDirty = 0;
}

void ecsApplyFrameFx(int healthFx, int shieldFx, int flashFx, int lumR, int lumG, int lumB, int brightness, int fxEnabled, int brightnessEnabled)
{
	memcpy(ecsPalette, ecsPaletteBase, numColors * sizeof(UWORD));

	if (lumR || lumG || lumB)
	{
		for (int i = 0; i < numColors; i++)
		{
			int r = (ecsPalette[i] >> 8) & 15;
			int g = (ecsPalette[i] >> 4) & 15;
			int b = ecsPalette[i] & 15;
			int L = (r >> 2) + (g >> 1) + (b >> 2);

			r = lumR ? L : 0;
			g = lumG ? L : 0;
			b = lumB ? L : 0;

			ecsPalette[i] = (UWORD)((r << 8) | (g << 4) | b);
		}
	}

	if (fxEnabled && (healthFx || shieldFx || flashFx))
	{
		int intensity;
		int filterIdx;
		int c0Idx;
		int c1Idx;

		if (healthFx)
		{
			intensity = 63 - (healthFx & 63);
			filterIdx = 0;
			c0Idx = 1;
			c1Idx = 2;
		}
		else if (shieldFx)
		{
			intensity = 63 - (shieldFx & 63);
			filterIdx = 1;
			c0Idx = 0;
			c1Idx = 2;
		}
		else
		{
			intensity = 63 - (flashFx & 63);
			filterIdx = 2;
			c0Idx = 0;
			c1Idx = 1;
		}

		for (int i = 0; i < numColors; i++)
		{
			int rgb[3];
			rgb[0] = (ecsPalette[i] >> 8) & 15;
			rgb[1] = (ecsPalette[i] >> 4) & 15;
			rgb[2] = ecsPalette[i] & 15;

			rgb[filterIdx] = 15 - (((15 - rgb[filterIdx]) * intensity) >> 6);
			rgb[c0Idx] = (rgb[c0Idx] * intensity) >> 6;
			rgb[c1Idx] = (rgb[c1Idx] * intensity) >> 6;

			ecsPalette[i] = (UWORD)((rgb[0] << 8) | (rgb[1] << 4) | rgb[2]);
		}
	}

	if (brightnessEnabled && brightness < FX_ONE_16)
	{
		for (int i = 0; i < numColors; i++)
		{
			int r = (ecsPalette[i] >> 8) & 15;
			int g = (ecsPalette[i] >> 4) & 15;
			int b = ecsPalette[i] & 15;

			r = (r * brightness + FX_HALF_16) >> 16;
			g = (g * brightness + FX_HALF_16) >> 16;
			b = (b * brightness + FX_HALF_16) >> 16;

			ecsPalette[i] = (UWORD)((r << 8) | (g << 4) | b);
		}
	}
}
