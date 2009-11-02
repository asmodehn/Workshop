
#include "prototest.h"

#define DEFAULTPORT "3490"  /* the port users will be connecting to */

#define BACKLOG 10     /* how many pending connections queue will hold */


int socket_on_connect_cb( int new_fd, struct sockaddr * client_addr, socklen_t sockaddr_size )
{
    char s[INET6_ADDRSTRLEN];

    inet_ntop(client_addr->sa_family,
              get_in_addr(client_addr),
              s, sizeof s);
    printf("server: child process for connection from %s\n", s);

    if (send(new_fd, "Hello, world!", 13, 0) == -1)
        perror("send");

    close(new_fd);

    return 0;
}


typedef enum tprotocol { tcp, udp} protocol;

int server(protocol proto, char * port, char * listenip)
{
    int sockfd;
    struct addrinfo *servinfo, *p;

switch ( proto )
{
    case udp : setup_addrinfo(  &servinfo, listenip, port, listenip?0:AI_PASSIVE, AF_UNSPEC, SOCK_DGRAM); break;
    case tcp :
    default : setup_addrinfo(  &servinfo, listenip, port, listenip?0:AI_PASSIVE, AF_UNSPEC, SOCK_STREAM); break;
}

    // loop through all the results and bind to the first we can
    for (p = servinfo; p != NULL; p = p->ai_next)
    {

        sockfd = create_socket( p->ai_family, p->ai_socktype, p->ai_protocol, 1 );

        if ( socket_listen(sockfd, p->ai_addr, p->ai_addrlen, p->ai_socktype, BACKLOG) != 0)
        {
            fprintf( stderr, "server: impossible to listen on this address" );
        }
        else //only listening on one address
        {
            break;
        }
    }

    if (p == NULL)
    {
        fprintf(stderr, "server: failed to bind to any address\n");
        return 2;
    }

    freeaddrinfo(servinfo); // all done with this structure

    if ( proto != udp )
    {
        //now accepting connections
        socket_accept(sockfd, &socket_on_connect_cb);
    }
    return 0;
}


void dispusage(void)
{
        fprintf(stderr,"usage: server [ -proto <tcp/udp> ] [ -p port ] [ -ip listenip ] \n");
        exit(1);
}

int main(int argc, char * argv [])
{

  int i;
  protocol p=tcp; // TCP default
  char* port = DEFAULTPORT;
  char * listenip = NULL ;

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
            ( strcmp(popt, "proto") == 0 )
            )
            {
                //-proto <proto>
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
        else if ( ( strcmp (popt, "ip" ) == 0 ) )
        {
            listenip = argv[++i];
        }
        else

        {
            dispusage();
        }
    }
    else
    {
      /* no arguments */
      dispusage();
    }
  }


  server(p, port, listenip);

  return 0;



}

