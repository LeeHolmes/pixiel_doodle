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