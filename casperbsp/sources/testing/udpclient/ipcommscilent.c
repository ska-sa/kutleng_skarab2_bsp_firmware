// Client side implementation of UDP client-server model
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>
 
#define PORT     10000
#define MAXLINE 4
#define MAXSEND 1500-64
 
// Driver code
int main() {
    int sockfd;
    char buffer[MAXLINE];
    char *hello = "Hello";
    struct sockaddr_in     servaddr;
 
    // Creating socket file descriptor
    if ( (sockfd = socket(AF_INET, SOCK_DGRAM, 0)) < 0 ) {
        perror("socket creation failed");
        exit(EXIT_FAILURE);
    }
 
    memset(&servaddr, 0, sizeof(servaddr));
     
    // Filling server information
    servaddr.sin_family = AF_INET;
    servaddr.sin_port = htons(PORT);
    servaddr.sin_addr.s_addr = inet_addr("192.168.100.10");
     
    int n, len;
    int sendnum=MAXSEND;
    int iterations;
    int fixedlen = MAXSEND; 
    for (n = 0;n< MAXLINE; n++) buffer[n]=' '+(n%2);
	for(iterations = 0; iterations <20;iterations++)
	{
		for(sendnum =1;sendnum<MAXSEND;sendnum++)
		//sendnum = 70;
		{
		    sendto(sockfd, (const char *)buffer, sendnum,
			MSG_CONFIRM, (const struct sockaddr *) &servaddr, 
			    sizeof(servaddr));
			 
		    n = recvfrom(sockfd, (char *)buffer, MAXLINE, 
				MSG_WAITALL, (struct sockaddr *) &servaddr,
				&len);
		}
	}
//    printf("Server : %s\n", buffer);
 
    close(sockfd);
    return 0;
}
