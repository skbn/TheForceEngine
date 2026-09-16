#ifndef ECS_PALETTE_H
#define ECS_PALETTE_H

#include <stdint.h>

extern unsigned char ecsDepth;

void ecsUpdatePalette(const uint32_t *rgba);
void ecsUpdatePaletteRaw(const uint8_t *palette768);
void ecsUpdateColormap(const uint8_t *colorMap);
void ecsApplyFrameFx(int healthFx, int shieldFx, int flashFx, int lumR, int lumG, int lumB, int brightness, int fxEnabled, int brightnessEnabled);

#endif
