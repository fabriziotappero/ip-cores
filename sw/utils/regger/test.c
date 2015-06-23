//declarations of register addresses:
#define GFX_CONTROL        (GFX_BASEADDR + 0x00) /* Control Register */
#define GFX_STATUS         (GFX_BASEADDR + 0x04) /* Status Register */
#define GFX_ALPHA          (GFX_BASEADDR + 0x08) /* Alpha channel Register */
#define GFX_COLORKEY       (GFX_BASEADDR + 0x0c) /* Colorkey Register */

#define GFX_TARGET_BASE    (GFX_BASEADDR + 0x10) /* Offset to "Target" framebuffer */
#define GFX_TARGET_SIZE_X  (GFX_BASEADDR + 0x14) /* Target Width */
#define GFX_TARGET_SIZE_Y  (GFX_BASEADDR + 0x18) /* Target Height */

#define GFX_TEX0_BASE      (GFX_BASEADDR + 0x1c) /* Offset to texturebuffer */
#define GFX_TEX0_SIZE_X    (GFX_BASEADDR + 0x20) /* Texturebuffer Width */
#define GFX_TEX0_SIZE_Y    (GFX_BASEADDR + 0x24) /* Texturebuffer Height*/

#define GFX_SRC_PIXEL0_X   (GFX_BASEADDR + 0x28) /* source rect spanned by pixel0 and pixel1, ex a position in a image */
#define GFX_SRC_PIXEL0_Y   (GFX_BASEADDR + 0x2c) /*   0******   */
#define GFX_SRC_PIXEL1_X   (GFX_BASEADDR + 0x30) /*   *******   */
#define GFX_SRC_PIXEL1_Y   (GFX_BASEADDR + 0x34) /*   ******1   */

#define GFX_DEST_PIXEL_X   (GFX_BASEADDR + 0x38) /* Destination pixels, used to draw Rects,Lines,Curves or Triangles */
#define GFX_DEST_PIXEL_Y   (GFX_BASEADDR + 0x3c)
#define GFX_DEST_PIXEL_Z   (GFX_BASEADDR + 0x40)

#define GFX_AA             (GFX_BASEADDR + 0x44)
#define GFX_AB             (GFX_BASEADDR + 0x48)
#define GFX_AC             (GFX_BASEADDR + 0x4c)
#define GFX_TX             (GFX_BASEADDR + 0x50)
#define GFX_BA             (GFX_BASEADDR + 0x54)
#define GFX_BB             (GFX_BASEADDR + 0x58)
#define GFX_BC             (GFX_BASEADDR + 0x5c)
#define GFX_TY             (GFX_BASEADDR + 0x60)
#define GFX_CA             (GFX_BASEADDR + 0x64)
#define GFX_CB             (GFX_BASEADDR + 0x68)
#define GFX_CC             (GFX_BASEADDR + 0x6c)
#define GFX_TZ             (GFX_BASEADDR + 0x70)

#define GFX_CLIP_PIXEL0_X  (GFX_BASEADDR + 0x74) /* Clip Rect registers, only pixels inside the clip rect */
#define GFX_CLIP_PIXEL0_Y  (GFX_BASEADDR + 0x78) /* will be drawn on the screen when clipping is enabled. */
#define GFX_CLIP_PIXEL1_X  (GFX_BASEADDR + 0x7c)
#define GFX_CLIP_PIXEL1_Y  (GFX_BASEADDR + 0x80)

#define GFX_COLOR0         (GFX_BASEADDR + 0x84) /* Color registers, Color0 is mostly used.    */
#define GFX_COLOR1         (GFX_BASEADDR + 0x88) /* Color 1 & 2 is only used in interpolation  */
#define GFX_COLOR2         (GFX_BASEADDR + 0x8c) /* ex. triangle, one color from each corner   */
