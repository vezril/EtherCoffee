#include "haxxor.h"
#include "networking.h"

#include <sys/socket.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <netinet/in.h>
#include <net/if.h>
#include <linux/if_ether.h>
#include <arpa/inet.h>

#define DEBUG printf("[DEBUG]\n");
#define ADDR "192.168.0.225"
#define LOCAL_ADDR "192.168.0.176"
#define MAX 11
#define SA struct sockaddr
#define PORT "9751"

#define DSTATUS 0xA0
#define DIDLE 	0xA1
#define DBREW	0xA2
#define DWATER	0xB0
#define DATA_BYTE_1 42
#define DATA_BYTE_2 43

int ping(void) {
    
    int i, recv_length = 0, sockfd, n=0, m=0;
    u_char buffer[9000];
    struct timeval tv;    
    struct ifreq ifr;
    struct sockaddr_in myaddr;
    
    bzero(&myaddr, sizeof(myaddr));
    
    myaddr.sin_family = PF_PACKET;
    myaddr.sin_addr.s_addr = htonl(LOCAL_ADDR);
    myaddr.sin_port = htons(PORT);
    tv.tv_sec = 2;
    tv.tv_usec = 0;

    if((sockfd = socket(PF_PACKET, SOCK_RAW, htons(ETH_P_IP))) == -1)
	fatal("in socket");
/*    if(setsockopt(sockfd, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv))){
	printf("setsockopt error\n");
	exit(1);}
*/	/*
    if((bind(sockfd, (SA*) &myaddr, sizeof(myaddr))) != 0){
      fatal("in bind");
      exit(1);
    }*/
    memset(&ifr, 0, sizeof(ifr));
    snprintf(ifr.ifr_name, sizeof(ifr.ifr_name), "eth0");
    send_udp();
	
    for(;;){
    if(setsockopt(sockfd, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv)) != 0){
	printf("setsockopt error\n");
	exit(1);}
    if(setsockopt(sockfd, SOL_SOCKET, SO_BINDTODEVICE, (void*)&ifr, sizeof(ifr)) != 0){
	printf("setsockopt error\n");	// NEED TO BIND ETH0 TO THIS SOCKET!
	exit(1);}			// IF WIFI IS ON, I SNIFF THE PACKETS FROM IT
    if((recv_length = recv(sockfd, buffer, 8000, 0)) <= 0){
	  fprintf(stdout, "socket timeout\n");
	return 1;}
      //printf("%i\n", recv_length);
      if(buffer[0] == 00 && buffer[1] == 0x26 && buffer[2] == 0x2D){
	fprintf(stdout, "Water\n");
	fprintf(stdout, "%x\n",buffer[DATA_BYTE_1]);
	fprintf(stdout, "Status\n");
	fprintf(stdout, "%x\n",buffer[DATA_BYTE_2]);
	close(sockfd);
	return 0;
      }
    }
    return 1;
}

int send_udp(void) { // Might want to replace the exit(1) with return 1...
  
  char buffer[256];
  int sockfd, length, n;
  struct sockaddr_in server;
  struct timeval tv;
  
  tv.tv_sec = 2;
  tv.tv_usec = 0;
    
  if ((sockfd = socket(AF_INET, SOCK_DGRAM, 0)) < 0){
    fprintf(stderr, "Error while opening socket!\n");
    exit(1);}
  if(setsockopt(sockfd, SOL_SOCKET, SO_SNDTIMEO, &tv, sizeof(tv))){
    printf("setsockopt error\n");
    exit(1);} // hci control right here
  
  server.sin_family = AF_INET;
  inet_pton(AF_INET, ADDR, &server.sin_addr);
  server.sin_port = 9751;
  length = sizeof(struct sockaddr_in);
  
  bzero(buffer, 256);
  strcpy(buffer, "Brew me one!");
  
  n = sendto(sockfd, buffer, strlen(buffer), 0,(struct sockaddr*) &server, length);
  
  if(n<0){
    fprintf(stderr, "Error while sending message!\n");
    exit(1);}
    
  close(sockfd);
  return 0;
}
