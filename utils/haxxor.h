#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// This displays an error message before exiting
void fatal(char *message)
{
	char error[100];
	strcpy(error, "[ERROR] Fatal Error ");
	strncat(error, message, 80);
	perror(error);
	exit(1);
}

// checking errors for malloc, usefull wrapper function
void *Malloc(unsigned int size)
{
	void *ptr;
	ptr = malloc(size);
	if(ptr == NULL)
		fatal("in Malloc() while allocating memory");
	return ptr;
}

// Used for dumping memory in hex (similar to a sniffer output)
void mem_dump(const unsigned char *dump_buffer, const unsigned int length)
{
	unsigned char byte;
	unsigned int x, y;
	for(x=0;x<length;x++){
		byte = dump_buffer[x];
		printf("%02x ", dump_buffer[x]);
		if(((x%16)==15) || (x==length-1)) {
		  for(y=0;y<15-(x%16); y++)
		    printf("  ");
		  printf("| ");
		  for(y=(x-(x%16));y<=x; y++) {
		    byte = dump_buffer[y];
		    if((byte>31) && (byte<127))
		      printf("%c", byte);
		    else
		      printf(".");
		  }
		  printf("\n");
		}
	}
}