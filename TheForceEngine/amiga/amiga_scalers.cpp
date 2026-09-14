#include <stdint.h>

#define Object AmiObject
#include <exec/types.h>
#undef Object

#define FRAME_WIDTH  320
#define FRAME_HEIGHT 200
#define X_INLINE     inline

#include "amiga_scalers.h"

int filterMode = FILTER_NONE;

void scaleNearest2x_c(const uint8_t *src, uint8_t *dst, int displayWidth)
{
    int stride = displayWidth;

    for (int y = 0; y < FRAME_HEIGHT; y++)
    {
        const uint8_t *srcP = src + y * FRAME_WIDTH;
        uint8_t *d0 = dst + (y * 2) * stride;
        uint8_t *d1 = d0 + stride;

        for (int x = 0; x < FRAME_WIDTH; x += 4)
        {
            uint8_t p0 = *srcP++;
            uint8_t p1 = *srcP++;
            uint8_t p2 = *srcP++;
            uint8_t p3 = *srcP++;

            uint32_t w0 = ((uint32_t)p0 << 24) | ((uint32_t)p0 << 16) | ((uint32_t)p1 << 8) | p1;
            uint32_t w1 = ((uint32_t)p2 << 24) | ((uint32_t)p2 << 16) | ((uint32_t)p3 << 8) | p3;

            *(uint32_t*)d0 = w0; d0 += 4;
            *(uint32_t*)d0 = w1; d0 += 4;
            *(uint32_t*)d1 = w0; d1 += 4;
            *(uint32_t*)d1 = w1; d1 += 4;
        }
    }
}

X_INLINE static void scale2x_pixel(uint8_t b, uint8_t d, uint8_t e, uint8_t f, uint8_t h, uint8_t *&o0, uint8_t *&o1)
{
    uint8_t e0 = e;
    uint8_t e1 = e;
    uint8_t e2 = e;
    uint8_t e3 = e;

    if (b != h && d != f)
    {
        e0 = (d == b) ? d : e;
        e1 = (b == f) ? f : e;
        e2 = (d == h) ? d : e;
        e3 = (h == f) ? f : e;
    }

    *(uint16_t*)o0 = (e0 << 8) | e1; o0 += 2;
    *(uint16_t*)o1 = (e2 << 8) | e3; o1 += 2;
}

void scale2x_c(const uint8_t *src, uint8_t *dst, int displayWidth)
{
    int stride = displayWidth;

    for (int y = 0; y < FRAME_HEIGHT; y++)
    {
        const uint8_t *rowUp = src + (y - (y > 0)) * FRAME_WIDTH;
        const uint8_t *rowMid = src + y * FRAME_WIDTH;
        const uint8_t *rowDn = src + (y + (y < FRAME_HEIGHT - 1)) * FRAME_WIDTH;
        uint8_t *d0 = dst + (y * 2) * stride;
        uint8_t *d1 = d0 + stride;

        uint8_t e = rowMid[0];
        uint8_t b = rowUp[0];
        uint8_t d;
        uint8_t f = rowMid[1];
        uint8_t h = rowDn[0];
        uint8_t *p0 = d0;
        uint8_t *p1 = d1;
        
        scale2x_pixel(b, e, e, f, h, p0, p1);

        const uint8_t *up = rowUp + 1;
        const uint8_t *mid = rowMid + 1;
        const uint8_t *dn = rowDn + 1;
        uint8_t *o0 = d0 + 2;
        uint8_t *o1 = d1 + 2;
        uint8_t prevE = rowMid[0];

        for (int x = 1; x < FRAME_WIDTH - 1; x++)
        {
            b = *up++;
            e = *mid++;
            h = *dn++;
            d = prevE;
            f = *mid;

            scale2x_pixel(b, d, e, f, h, o0, o1);

            prevE = e;
        }

        int li = FRAME_WIDTH - 1;
        e = rowMid[li];
        b = rowUp[li];
        d = rowMid[li - 1];
        h = rowDn[li];
        p0 = d0 + li * 2;
        p1 = d1 + li * 2;

        scale2x_pixel(b, d, e, e, h, p0, p1);
    }
}
