//
//  bridge.h
//  Chiptune Pi
//
//  Created by Ben Anderman on 4/5/16.
//
//

#ifndef bridge_h
#define bridge_h

#import "mikmod.h"

// Provide non-variadic wrappers to these functions, because Swift doesn't support variadic functions
void Player_MuteNV(SLONG channel);
void Player_UnmuteNV(SLONG channel);

#endif /* bridge_h */
