#include <stdio.h>

int main(int argc, char *argv[]){
  int x;
  __asm__ (	mov dx,%%70
		in al,dx
