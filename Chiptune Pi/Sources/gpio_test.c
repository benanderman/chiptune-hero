//
//  gpio_test.c
//  Chiptune Pi
//
//  Created by Ben Anderman on 4/6/16.
//
//

#include "RPI.h"

int main()
{
  bool value;
  int pin = 6;
  setup_gpio();
  
  set_gpio_to_output(4);
  set_gpio_to_output(20);
  set_gpio_to_input(17);
  
//  int pins[] = {4, 5, 6, 12, 13, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27};
//  for (int i = 0; i < 17; i++) {
//    set_gpio_to_output(pins[i]);
//  }
  
  while(1)
  {
    value = get_gpio_value(17);
    set_gpio_value(4, value);
    set_gpio_value(20, true);
    set_gpio_value(20, false);
    usleep(100000);
  }
  
  return 0;
}