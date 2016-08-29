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
  bool value = false;
  setup_gpio();
  
  set_gpio_to_output(5);
  set_gpio_to_output(20);
  set_gpio_to_output(21);
  set_gpio_to_input(18);
  set_gpio_to_input(23);
  set_gpio_to_input(24);
  set_gpio_to_input(25);
  
//  int pins[] = {4, 5, 6, 12, 13, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27};
//  for (int i = 0; i < 17; i++) {
//    set_gpio_to_output(pins[i]);
//  }
  
  while(1)
  {
    value = get_gpio_value(18);
    value = get_gpio_value(23) || value;
    value = get_gpio_value(24) || value;
    value = get_gpio_value(25) || value;
    set_gpio_value(5, value);
    set_gpio_value(20, true);
    set_gpio_value(20, false);
    set_gpio_value(21, true);
    set_gpio_value(21, false);
    usleep(100000);
  }
  
  return 0;
}