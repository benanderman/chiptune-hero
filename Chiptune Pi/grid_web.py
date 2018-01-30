#!/usr/bin/env python

"""
  Very simple HTTP server in python. Copied from:
  https://gist.github.com/bradmontgomery/2219997
  
  Usage::
  ./grid_web.py [<port>]
  
  Send a POST request::
  curl -d "foo=bar&bin=baz" http://localhost:1300
  
  """

from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
import socket

UDP_IP = "127.0.0.1"
UDP_PORT = 1337

class S(BaseHTTPRequestHandler):
  def _set_headers(self):
    self.send_response(200)
    self.send_header('Content-type', 'text/plain')
    self.end_headers()
  
  def do_GET(self):
    self._set_headers()
    maybe_query = self.path.split("?")
    if len(maybe_query) == 2 and len(maybe_query[1]) == 64:
      query = maybe_query[1]
      bytes = ""
      for byte_idx in range(8):
        byte = 0
        for bit_idx in range(8):
          if query[byte_idx * 8 + bit_idx] == "1":
            byte += 2 ** (7 - bit_idx)
        bytes += chr(byte)
    
      sock = socket.socket(socket.AF_INET, # Internet
                           socket.SOCK_DGRAM) # UDP
      sock.sendto(bytes, (UDP_IP, UDP_PORT))
      self.wfile.write("Maybe it worked!")
    else:
      self.wfile.write("It didn't work")

def run(server_class=HTTPServer, handler_class=S, port=1300):
  server_address = ('', port)
  httpd = server_class(server_address, handler_class)
  print 'Starting httpd...'
  httpd.serve_forever()

if __name__ == "__main__":
  from sys import argv
  if len(argv) == 2:
    run(port=int(argv[1]))
  else:
    run()
