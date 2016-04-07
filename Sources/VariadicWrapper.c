//
//  VariadicWrapper.c
//  CTH Editor
//
//  Created by Ben Anderman on 3/18/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

// Inside mikmod.h, BOOL is defined as bool, but bool doesn't exist in this context
#define bool char

#include "mikmod.h"

void Player_MuteNV(SLONG channel)
{
	Player_Mute(channel);
}

void Player_UnmuteNV(SLONG channel)
{
	Player_Unmute(channel);
}
