#include <pcap.h>
#include "haxxor.h"
#include "networking.h"
#include <time.h>

#define DEBUG printf("[DEBUG]\n");
#define ADDR "192.168.0.225"

void pcap_fatal(const char *fatal_in, const char *errbuf) {
    printf("Fatal Error in %s: %s\n", fatal_in, errbuf);
    exit(1);
}

int ping(void) {
    clock_t current, saved;
    struct pcap_pkthdr header;
    const u_char *packet;
    char errbuf[PCAP_ERRBUF_SIZE];
    char *device;
    pcap_t *pcap_handle;
    int i;
    
    device = pcap_lookupdev(errbuf);
    if(device == NULL)
	pcap_fatal("pcap_lookupdev", errbuf);
 
    pcap_handle = pcap_open_live(device, 4096, 1, 0, errbuf);
    if(pcap_handle == NULL)
      pcap_fatal("pcap_open_live", errbuf);
    saved = clock() + (5 * CLOCKS_PER_SEC);
    send_udp();
    printf("%x\n", clock());
    do{
      packet = pcap_next(pcap_handle, &header);
      if((*(packet+35) == 0x17) && (*(packet+34) == 0x26) && (*(packet+37) == 0x17) && (*(packet+36) == 0x26)){  // Little-Endian type thingy
	    printf("ACK\n");
	    pcap_close(pcap_handle);
	    return 0;
	}
      printf("%x\n", clock());
    }while(clock() < saved);
    DEBUG
    pcap_close(pcap_handle);
    return 1;
}

int send_udp(void) { // Might want to replace the exit(1) with return 1...
  
  char buffer[256];
  int sockfd, length, n;
  struct sockaddr_in server;
  
  if ((sockfd = socket(AF_INET, SOCK_DGRAM, 0)) < 0){
    printf("Error while opening socket!\n");
    exit(1);}
  
  server.sin_family = AF_INET;
  inet_pton(AF_INET, ADDR, &server.sin_addr);
  server.sin_port = 9751;
  length = sizeof(struct sockaddr_in);
  
  bzero(buffer, 256);
  strcpy(buffer, "Brew me one!");
  
  n = sendto(sockfd, buffer, strlen(buffer), 0,(struct sockaddr*) &server, length);
  
  if(n<0){
    printf("Error while sending message!\n");
    exit(1);}
  
  return 0;
}

    
int main(int argc, char *argv[]) {
  
  int n, x;
  
  printf("How many cups? >> ");
  scanf("%i", &x);
  
  if(x == 2){
    for(n=0;n<5;n++){
      if(ping())
	n--;
	//break;
    } //rof 
  } //fi
  else if(x == 0){
    for(n=0;n<4;n++){
      if(ping())
	n--;
    } //rof
  } //fi
  else{
    printf("This feature is not available yet!\n");
  }
  exit(0);
} 

