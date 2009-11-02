#include "prototest.h"

#define DEFAULTPORT "3490" /* the port client will be connecting to */

#define MAXDATASIZE 100 // max number of bytes we can get at once


int clientonconnect_cb( int new_fd, struct sockaddr *server_addr, socklen_t sockaddr_size )
{
    int numbytes;
    char s[INET6_ADDRSTRLEN];
    char buf[MAXDATASIZE];

    inet_ntop(server_addr->sa_family, get_in_addr((struct sockaddr *)server_addr),
              s, sizeof s);
    printf("client: connecting to %s\n", s);


    if ((numbytes = recv(new_fd, buf, MAXDATASIZE-1, 0)) == -1)
    {
        perror("recv");
        exit(1);
    }

    buf[numbytes] = '\0';

    printf("client: received '%s'\n",buf);

    return 0;

}


typedef enum tprotocol { tcp, udp} protocol;

int client ( protocol proto, char* port, const char * servip)
{
    int sockfd;


    struct addrinfo *servinfo, *p;

switch ( proto )
{
    case udp : setup_addrinfo(  &servinfo, servip, port, 0, AF_UNSPEC, SOCK_DGRAM); break;
    case tcp :
    default : setup_addrinfo(  &servinfo, servip, port, 0, AF_UNSPEC, SOCK_STREAM); break;
}


    /* loop through all the results and connect to the first we can */
    for (p = servinfo; p != NULL; p = p->ai_next)
    {

        sockfd = create_socket(p->ai_family, p->ai_socktype, p->ai_protocol, 0);


        socket_connect(sockfd, p->ai_addr, p->ai_addrlen, clientonconnect_cb);

        if ( sockfd ) break;
    }

    if (p == NULL)
    {
        fprintf(stderr, "client: failed to connect\n");
        return 2;
    }

    freeaddrinfo(servinfo); // all done with this structure

    close(sockfd);

    return 0;
}

void dispusage(void)
{
        fprintf(stderr,"usage: client [ -p <tcp/udp> ] hostname\n");
        exit(1);
}


int main(int argc, char *argv[])
{
  int i;
  protocol p=tcp; // TCP default
  char * port = DEFAULTPORT;
  char * servip = "" ;

  for (i = 1; i != argc; ++i)
  {
    /* if first character is '-' */
    if (argv[i][0] == '-')
    {
      /* it s an option */
      char* popt = &argv[i][1];

      if ( ( strcmp(popt, "help") == 0 ) || (strcmp(popt, "h") ==0 ) )
      {
        dispusage();
      }

      else if ( ( strcmp(popt, "protocol") == 0 )
            ||
            ( strcmp(popt, "p") == 0 )
            )
            {
                //-p <proto>
                ++i;
                if ( (strcmp(argv[i], "tcp" ) ==0 || ( strcmp(argv[i], "TCP") == 0) ) )
                {
                    p=tcp;
                }
                else if ( (strcmp(argv[i], "udp" ) ==0 || ( strcmp(argv[i], "UDP") == 0) ) )
                {
                    p=udp;
                }
                else
                {
                    dispusage();
                }

        }
        else if ( ( strcmp(popt, "port") == 0 ) || ( strcmp(popt, "p" )==0 ) )

        {
            port = argv[++i];
        }
        else
        {
            dispusage();
        }
    }
    else
    {
      /* IP to connect to */
      servip = argv[i];
    }
  }

  /* if servip has not been set */
  if (  strcmp(servip,"") == 0 )
  {
       dispusage();
  }

  client(p, port, servip);

  return 0;


}


