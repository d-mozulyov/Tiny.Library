
#ifndef tiny_intrjumps_h
#define tiny_intrjumps_h

#include "../tiny.defines.h"
#include "../tiny.types.h"
#include "tiny.rtti.h"

/*
    Get appropriate interception jump
*/
REGISTER_DECL void* get_intercept_jump(int32_t index, int32_t mode);

#endif
