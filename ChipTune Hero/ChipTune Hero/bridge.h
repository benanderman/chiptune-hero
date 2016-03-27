//
//  bridge.h
//  ChipTune Hero
//
//  Created by Ben Anderman on 3/22/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

#ifndef bridge_h
#define bridge_h

#include "SDL.h"
#include "mikmod.h"

// Provide non-variadic wrappers to these functions, because Swift doesn't support variadic functions
void Player_MuteNV(SLONG channel);
void Player_UnmuteNV(SLONG channel);

#endif /* bridge_h */
