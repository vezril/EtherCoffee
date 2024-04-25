#include <stdio.h>
#include <stdlib.h>
#define MAX 3

int main(int argc, char **argv){
  
  int saved, tt;
  tt = system_clock();
  saved = system_clock() + 5;
  while(saved > tt){
    fprintf(stdout, "%i", system_clock());
    tt = system_clock() ;
  }
  printf("Done!\n");
}

int system_clock(void){
  char buffer[MAX];
  int x, seconds;
  FILE *fp;
  
  system("date +%S> time");
  if((fp = fopen("time", "r")) == NULL){
    fprintf(stderr, "Error while opening file\n");
    exit(1);
  }

  fgets(buffer, MAX, fp);
  seconds = atoi(buffer);
  //printf("%i\n", seconds);
  fclose(fp);
  return seconds;
}