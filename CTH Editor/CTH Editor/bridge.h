//
//  bridge.h
//  CTH Editor
//
//  Created by Ben Anderman on 3/14/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

#ifndef bridge_h
#define bridge_h

#include "mikmod.h"

extern void (*MikMod_KickCallback)(int sngpos, int patpos, int *channels, int *lengths, int len);

#endif /* bridge_h */
