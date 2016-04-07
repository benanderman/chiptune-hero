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
  setup_gpio();
  
  // Define pin 7 as output
//  INP_GPIO(4);
//  OUT_GPIO(4);
  
  set_gpio_to_output(4);
  set_gpio_to_input(17);
  
  while(1)
  {
    // Toggle pin 7 (blink a led!)
//    GPIO_SET = 1 << 4;
//    sleep(1);
    
    value = get_gpio_value(17);
    printf("Value: %d\n", value);
    set_gpio_value(4, value);
    
//    GPIO_CLR = 1 << 4;
    sleep(1);
  }
  
  return 0;
}