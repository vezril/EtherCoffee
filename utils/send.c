#include "haxxor.h"
#include "networking.h"
#include <stdio.h>
#include <stdlib.h>
#define DEBUG printf("[DEBUG]\n");
int main(int argc, char *argv[]) {
  
  char buffer[256];
  int sockfd, length, n;
  struct sockaddr_in server;
  
  if(argc != 2){
    printf("Usage: ./send <IP Address>\n");
    exit(1);}
  
  if ( (sockfd = socket(AF_INET, SOCK_DGRAM, 0)) < 0){
    printf("Error in opening socket!\n");
    exit(1);}
  
  server.sin_family = AF_INET;
  inet_pton(AF_INET, argv[1], &server.sin_addr);
  server.sin_port = 9751;
  length = sizeof(struct sockaddr_in);
  
  bzero(buffer, 256);
  fgets(buffer, 255, stdin);
  
  n = sendto(sockfd, buffer, strlen(buffer), 0,(struct sockaddr*) &server, length);
  
  if(n<0){
    printf("Error while sending message!\n");
    exit(1);}
  
  
  printf("Done!\n");
  return 0;
}