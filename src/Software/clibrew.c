#include "brew.h"

int main(int argc, char *argv[]) {
  
  if(argc != 1){
    fprintf(stderr, "Too many arguments, aborting\n");
    exit(1);
  }
  int x;;

  system("sudo ifconfig eth0 192.168.0.176");
  system("arp -s 192.168.0.225 00:6F:66:66:65:65");

  for(x=0;x<5;x++){
    if(ping())
      x--;
  }
    
} 

