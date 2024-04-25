#include "brew.h"

int main(int argc, char *argv[]) {
  
  if(argc != 1){
    fprintf(stderr, "Too many arguments, aborting\n");
    exit(1);
  }
  int n, x;
  char select[MAX];

  system("sudo ifconfig eth0 192.168.0.176");
  system("arp -s 192.168.0.225 00:6F:66:66:65:65");

  fprintf(stdout, "EtherCoffee Version 1.0 Copyright (C) 2010 Calvin O. Ference\n\n");
  fprintf(stdout, "This program is free software: you can redistribute it and/or modify\n");
  fprintf(stdout, "it under the terms of the GNU General Public License as published by\n");
  fprintf(stdout, "the Free Software Foundation, either version 3 of the License, or\n");
  fprintf(stdout, "any later version.\n\n");
  fprintf(stdout, "This program is distributed in the hope that it will be useful, but\n");
  fprintf(stdout, "WITHOUT ANY WARRANTY; without even the implied warranty of\n");
  fprintf(stdout, "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU\n");
  fprintf(stdout, "General Public License for more details.\n");
  fprintf(stdout, "\nType help for a list of commands\n>> ");
  for(;;){
    fgets(select, MAX, stdin);  
    for(n=0;n<sizeof(select);n++){
      select[n] = tolower(select[n]);
    }
    if(strcmp(select, "brew\n") == 0){
      for(n=0;n<5;n++){
	if(ping())
	  n--;
      }
      fprintf(stdout, "\n>> ");
    }
    else if(strcmp(select, "check\n") == 0){
      for(n=0;n<1;n++){
	if(ping())
	  n--;
      }
    }
    else if(strcmp(select, "stop\n") == 0){
      for(n=0;n<4;n++){
	if(ping())
	  n--;
      }
      fprintf(stdout, "\n>> ");
    }
    
    else if(strcmp(select, "water\n") == 0){
      for(n=0;n<6;n++){
	if(ping())
	  n--;
      }
      fprintf(stdout, "\n>> ");
    }
    else if((strcmp(select, "quit\n") == 0) || ((strcmp(select, "exit\n") == 0))){
      fprintf(stdout, "Enjoy the coffee!\n");
      exit(0);
    }
    else if(strcmp(select, "clear\n") == 0){
      system("clear");
      fprintf(stdout, "Type help for a list of commands\n>> ");
    }
    else if(strcmp(select, "status\n") == 0){
      fprintf(stdout, "This feature is not yet available! Sorry! Mille Pardon! Gomen Nasai! Verzeihen Sie! Sentímolo!\n>> ");
    }
    else if(strcmp(select, "help\n") == 0){
      fprintf(stdout, "\nEtherCoffee Version 0.3, Written by Calvin O. Ference (w3b_wizzard)\n\n");
      fprintf(stdout, "(brew) - Tells EtherCoffee to make a tasty cup o' Jo\n");
      fprintf(stdout, "(check) - Checks if EtherCoffee is online\n");
      fprintf(stdout, "(clear) - Clears the screen\n");
      fprintf(stdout, "(help) - Prints this menu\n");
      fprintf(stdout, "(quit) - Exits this application\n");
      fprintf(stdout, "(status) - Gets EtheCoffees Status\n");
      fprintf(stdout, "(stop) - (Legacy) Overides the brew command\n");
      fprintf(stdout, "(water) - Checks the current water level of EtherCoffee\n>> ");
      }
    else if(strcmp(select, "xyzzy\n") == 0){
      fprintf(stdout, "nothing happens\n>> ");
    }
    else
      fprintf(stdout, "Invalid Command\n>> ");
  }
  exit(1); // If it got here... then there's a problem
} 

