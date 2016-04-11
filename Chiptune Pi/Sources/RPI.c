//
//  RPI.c
//  Chiptune Pi
//
//  Created by Ben Anderman on 4/6/16.
//
//  Copy/pasted from http://www.pieter-jan.com/node/15
//

#include "RPI.h"

struct bcm2835_peripheral gpio = {GPIO_BASE};

// Exposes the physical address defined in the passed structure using mmap on /dev/mem
int map_peripheral(struct bcm2835_peripheral *p)
{
  // Open /dev/mem
  if ((p->mem_fd = open("/dev/mem", O_RDWR|O_SYNC) ) < 0) {
    printf("Failed to open /dev/mem, try checking permissions.\n");
    return -1;
  }
  
  p->map = mmap(
                NULL,
                BLOCK_SIZE,
                PROT_READ|PROT_WRITE,
                MAP_SHARED,
                p->mem_fd,      // File descriptor to physical memory virtual file '/dev/mem'
                p->addr_p       // Address in physical map that we want this memory block to expose
                );
  
  if (p->map == MAP_FAILED) {
    perror("mmap");
    return -1;
  }
  
  p->addr = (volatile unsigned int *)p->map;
  
  return 0;
}

void unmap_peripheral(struct bcm2835_peripheral *p) {
  munmap(p->map, BLOCK_SIZE);
  close(p->mem_fd);
}

void setup_gpio() {
  if(map_peripheral(&gpio) == -1)
  {
    printf("Failed to map the physical GPIO registers into the virtual memory space.\n");
  }
}

void set_gpio_to_input(int pin) {
  INP_GPIO(pin);
}

void set_gpio_to_output(int pin) {
  INP_GPIO(pin);
  OUT_GPIO(pin);
}

void set_gpio_to_alternate(int pin, int function) {
  INP_GPIO(pin);
  SET_GPIO_ALT(pin, function);
}

void set_gpio_value(int pin, bool value) {
  if (value) {
    GPIO_SET = 1 << pin;
  } else {
    GPIO_CLR = 1 << pin;
  }
}

bool get_gpio_value(int pin) {
  int value = GPIO_READ(pin);
  return value > 0 ? true : false;
}
