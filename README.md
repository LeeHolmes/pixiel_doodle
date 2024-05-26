# Pixel Doodle
Pixel Doodle is a cute pixel editor for Gameboy, written using Gameboy Studio. For more details, [the Pixel Doodle Homepage](https://www.leeholmes.com/pixel-doodle/).

## Implementation Details

Pixel Doodle was developed using the amazing [Gameboy Studio](https://chrismaltby.itch.io/gb-studio). If you're looking to experiment with Gameboy development, I would strongly recommend checking it out. I've [published the source for Pixel Doodle on GitHub](https://github.com/LeeHolmes/pixiel_doodle).

Some points of interest:

### Tile Optimization

To fit within Gameboy memory constraints, Gameboy Studio aggressively optimizes large images into 8x8 px reusable tiles. When you change or alter any tile, you change or alter all of them. That's not a very useful feature on a big white canvas where you want the user to be able to draw anything they want.

To prevent the main canvas from reusing any tiles, the backing image starts as random noise. This prevents any tile reuse optimization.

![](https://www.leeholmes.com/images/2024/05/main_screen_random_noise.png)

Pixel Doodle replaces all of these tiles with basic white tiles once it launches.

Gameboy Studio has a a hard limit of 192 tiles. The canvas consumes 168 of them, and reused tiles for the palette take up another 4, leaving room for only 20 more. This is why the canvas isn't any bigger than it is.

### PutPixel in Gameboy Studio

Gameboy Studio doesn't have the equivalent of "draw a pixel in this color at this place on the screen."

Gameboy itself does let you literally draw a single pixel in a specified color on the screen if you interact with the LCD memory correctly, but the goal of Pixel Doodle is to draw big chonky stuff!

The approach that Pixel Doodle takes is that you can replace any 8x8 tile on the screen with another tile altogether. Gameboy Studio doesn't have a feature to change the color (attributes) of a tile, so Pixel Doodle addresses this by a [simple engine plugin](https://github.com/LeeHolmes/pixiel_doodle/tree/main/plugins/attr/engine) to do so.

```c
#pragma bank 255

#include <gbdk/platform.h>
#include "vm.h"

int16_t b_set_bg_attr = 255;
void set_bg_attr(SCRIPT_CTX * THIS) OLDCALL BANKED {

    set_bkg_attribute_xy(
        *(int16_t*) VM_REF_TO_PTR(FN_ARG2),
        *(int16_t*) VM_REF_TO_PTR(FN_ARG1),
        *(int16_t*) VM_REF_TO_PTR(FN_ARG0));
}
```

### Arrays in Gameboy Studio

When you push 'B' in Pixel Doodle, it goes into "Inspo Mode" and gives you a simple random word to inspire your pixel art.

While Gameboy Studio does support random numbers, there is no data type for a big array of strings to let it pick one of them randomly.

To fake this out, Pixel Doodle uses code generation. I wrote a [simple PowerShell script](https://github.com/LeeHolmes/pixiel_doodle/blob/main/Get-Inspoword.ps1) with the big array of strings. When you run the PowerShell script, it generates a GBVM script with a huge hard-coded switch statement. If the random number matches one of the hard-coded constants, it jumps to a hard-coded label, which pushes a hard-coded string onto the stack. Then, that generated GBVM script displays the string that's on the stack.

```c
; Background Text
VM_PUSH_CONST 0
VM_GET_UINT8 .ARG0, _overlay_priority
VM_SET_CONST_UINT8 _overlay_priority, 0
VM_SWITCH_TEXT_LAYER .TEXT_LAYER_BKG

VM_LOAD_TEXT 0
.asciz "\003\003\002              "
VM_DISPLAY_TEXT
VM_OVERLAY_WAIT .UI_NONMODAL, .UI_WAIT_TEXT

VM_RANDOMIZE

; Begin cut / paste

VM_RAND VAR_RANDOMWORD, 0, 101
VM_IF_CONST .EQ, VAR_RANDOMWORD, 0, _WORD_0, 0
VM_IF_CONST .EQ, VAR_RANDOMWORD, 1, _WORD_1, 0
// ...
VM_IF_CONST .EQ, VAR_RANDOMWORD, 99, _WORD_99, 0
VM_IF_CONST .EQ, VAR_RANDOMWORD, 100, _WORD_100, 0


_WORD_0::
VM_LOAD_TEXT 0
.asciz "\003\003\002    Coffee"
VM_JUMP _END

// ...

_WORD_100::
VM_LOAD_TEXT 0
.asciz "\003\003\002    Robot"
VM_JUMP _END
                
; End cut / paste

_END::
VM_DISPLAY_TEXT
VM_OVERLAY_WAIT .UI_NONMODAL, .UI_WAIT_TEXT

VM_SWITCH_TEXT_LAYER .TEXT_LAYER_WIN

VM_SET_UINT8 _overlay_priority, .ARG0
VM_POP 1
```

Finally, I brought this resulting GBVM script into Gameboy Studio for Pixel Doodle to use in an event.

Have fun with the game or the project!


