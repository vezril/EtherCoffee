#include <pcap.h>
#include "haxxor.h"

void pcap_fatal(const char *fatal_in, const char *errbuf) {
    printf("Fatal Error in %s: %s\n", fatal_in, errbuf);
    exit(1);
}

int main()
{
    struct pcap_pkthdr header;
    const u_char *packet;
    char errbuf[PCAP_ERRBUF_SIZE];
    char *device;
    pcap_t *pcap_handle;
    int i;
    
    device = pcap_lookupdev(errbuf);
    if(device == NULL)
	pcap_fatal("pcap_lookupdev", errbuf);
    
    printf("Sniffing on device %s\n", device);
    pcap_handle = pcap_open_live(device, 4096, 1, 0, errbuf);
    if(pcap_handle == NULL)
      pcap_fatal("pcap_open_live", errbuf);
    
    //for(i=0;i<3;i++){
    for(;;){
      packet = pcap_next(pcap_handle, &header);
      printf("Got a %d byte packet\n", header.len);
      //mem_dump(packet, header.len);
      if((*(packet+35) == 0x17) && (*(packet+34) == 0x26)){ 		// Little-Endian type thingy
	printf("Source Port: %x%x\n", *(packet+34), *(packet+35));
	if((*(packet+37) == 0x17) && (*(packet+36) == 0x26)){ 
	  printf("Destination Port: %x%x\n", *(packet+36), *(packet+37));
	  printf("Data: %x%x\n", *(packet+42), *(packet+43));
	}
      }
    }
    pcap_close(pcap_handle);
}