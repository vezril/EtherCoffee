#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>

// This is used to send all bytes pointed by ptr, returns 1 on success, 0 on failure
int Send(int sockfd, unsigned char *buffer)
{
	int sent, left;
	left = strlen(buffer);
	while(left > 0){
		sent = send(sockfd, buffer, left, 0);
		if(sent == -1)
			return 0;
		left -= sent;
		buffer += sent;
	}
	return 1;
}

int recv_l(int sockfd, unsigned char *dest_buffer)
{
#define EOL "\r\n"
#define EOL_SIZE 2
	unsigned char *ptr;
	int eol_matched = 0;
	ptr = dest_buffer;
	while(recv(sockfd, ptr, 1, 0) == 1) {
		if(*ptr == EOL[eol_matched]) {
			eol_matched++;
			if(eol_matched == EOL_SIZE) {
				*(ptr+1-EOL_SIZE) = '\0';
				return strlen(dest_buffer);
			}
		} else {
			eol_matched = 0;
		}
		ptr++;
	}
	return 0;
}
