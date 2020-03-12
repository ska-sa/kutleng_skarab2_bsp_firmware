#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>
 

#define MAXLINE 2048
#define MAXSEND 1500-64

uint32_t prbitstreamloader(char* ipAddress, uint32_t port, char* buffer)
{
	int sockfd;
    char ibuffer[MAXLINE];
    struct sockaddr_in     servaddr;
    
	printf("udp_echo_client() from C library\n");
	printf("ipAddress == %s\n", ipAddress);
	printf("port      == %d\n", port);
	printf("buffer    == %s\n", buffer);
	
    // Creating socket file descriptor
    if ( (sockfd = socket(AF_INET, SOCK_DGRAM, 0)) < 0 ) 
    {
        printf("socket creation failed");
        return -1;
        //exit(EXIT_FAILURE);
    }
 
    memset(&servaddr, 0, sizeof(servaddr));
     
    // Filling server information
    servaddr.sin_family = AF_INET;
    servaddr.sin_port = htons(port);
    servaddr.sin_addr.s_addr = inet_addr(ipAddress);
    
    int n, len;
    int sendnum=MAXSEND;
    int iterations;
    int fixedlen = MAXSEND; 
    for(n = 0;n<22;n++)
    {
	if((n>5) &&( n <10))  ibuffer[n]=buffer[n];
	else ibuffer[n]=0x00;
    }
    ibuffer[0]=0x01;
    ibuffer[1]=0xDA;
    ibuffer[5]=0x01;
    //for (n = 0;n< MAXLINE; n++) buffer[n]=' '+(n%2);
	//for(iterations = 0; iterations <20;iterations++)
	//{
		//for(sendnum =1;sendnum<MAXSEND;sendnum++)
		sendnum = 22;
		{
			printf("sendnum == %d\n", sendnum);
		    sendto(sockfd, (const char *)ibuffer, sendnum,
			MSG_CONFIRM, (const struct sockaddr *) &servaddr, 
			    sizeof(servaddr));
			
			printf("receiving == %d\n", sendnum);
		    n = recvfrom(sockfd, (char *)ibuffer, 22,//MAXLINE, 
				MSG_WAITALL, (struct sockaddr *) &servaddr,
				&len);
			printf("done == %d\n", len);
		}
	//}
    //printf("Server : %s\n", ibuffer);
 
    close(sockfd);
    return 0;
}
