//
//  grid_controller.c
//  Chiptune Pi
//
//  Created by Ben Anderman on 12/25/16.
//
//
#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <netdb.h>
#include <sys/socket.h>
#include <netinet/in.h>

#include <sys/uio.h>

#include <stdio.h>
#include "RPI.h"

#define die printf
#define warn printf

void set_display(char data[8]) {
  for (int i = 0; i < 64; i++) {
    bool value = data[7 - i / 8] >> (i % 8) & 1;
    
    set_gpio_value(5, value);
    set_gpio_value(21, true);
    set_gpio_value(21, false);
  }
  set_gpio_value(20, true);
  set_gpio_value(20, false);
}

int main()
{
  bool value = false;
  setup_gpio();
  
  set_gpio_to_output(5);
  set_gpio_to_output(20);
  set_gpio_to_output(21);
  
  const char *hostname = 0; /* wildcard */
  const char *portname = "1337";
  struct addrinfo hints;
  memset(&hints, 0, sizeof(hints));
  hints.ai_family = AF_UNSPEC;
  hints.ai_socktype = SOCK_DGRAM;
  hints.ai_protocol = 0;
  hints.ai_flags = AI_PASSIVE | AI_ADDRCONFIG;
  struct addrinfo *res = 0;
  int err = getaddrinfo(hostname, portname, &hints, &res);
  if (err != 0) {
    die("failed to resolve local socket address (err=%d)", err);
  }
  
  int fd = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
  if (fd == -1) {
    die("%s", strerror(errno));
  }
  
  if (bind(fd, res->ai_addr, res->ai_addrlen) == -1) {
    die("%s",strerror(errno));
  }
  
  freeaddrinfo(res);
  
  while (1) {
    char buffer[9];
    struct sockaddr_storage src_addr;
    socklen_t src_addr_len = sizeof(src_addr);
    ssize_t count = recvfrom(fd, buffer, sizeof(buffer), 0, (struct sockaddr*)&src_addr, &src_addr_len);
    if (count == -1) {
      die("%s", strerror(errno));
    } else if (count == sizeof(buffer)) {
      warn("datagram too large for buffer: truncated");
    } else {
      set_display(buffer);
    }
  }
  
  return 0;
}
