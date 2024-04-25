#include <stdio.h>
#include <signals.h>

int main(int argc, char **argv){
  int n;
  alarm(5);
  for(;;){
    printf("%x ", signal());
}