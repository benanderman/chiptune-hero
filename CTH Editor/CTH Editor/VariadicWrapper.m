//
//  VariadicWrapper.m
//  CTH Editor
//
//  Created by Ben Anderman on 3/18/16.
//  Copyright © 2016 Ben Anderman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "bridge.h"

void Player_MuteNV(SLONG channel)
{
	Player_Mute(channel);
}

void Player_UnmuteNV(SLONG channel)
{
	Player_Unmute(channel);
}
