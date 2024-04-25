#include "haxxor.h"
#include "networking.h"

#include <sys/socket.h>
#include <netinet/in.h>

#include <arpa/inet.h>

#define DEBUG printf("[DEBUG]\n");
#define ADDR "192.168.0.225"

int ping(void) {
    
    int i, recv_length = 0, sockfd, n=0, m=0;
    u_char buffer[9000];
    struct timeval tv;    

    tv.tv_sec = 2;
    tv.tv_usec = 0;

    if((sockfd = socket(PF_INET, SOCK_RAW, IPPROTO_UDP)) == -1)
		fatal("in socket");
    send_udp();

    for(;;){
      if(setsockopt(sockfd, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv))){
	printf("setsockopt error\n");
	exit(1);}
      if((recv_length = recv(sockfd, buffer, 8000, 0)) <= 0){
	printf("NADA ");
	break;}
      printf("Got a %i byte packet\n", recv_length);
      mem_dump(buffer, recv_length);
      return 0;
    }
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
  system("clear");
  printf("Press:\n(0) to stop the machine\n(1) to start the machine\nAnything else to quit\n\n>> ");
  scanf("%i", &x);
  
  if(x == 1){ // REPLACE WITH SWITCH?
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
  else if(x == 3){
    for(n=0;n<6;n++){
      if(ping())
	n--;
    }
  }
  else{
    printf("This feature is not available yet!\n");
  }
  exit(0);
} 

