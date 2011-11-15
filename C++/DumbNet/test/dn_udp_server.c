#include "DumbNet/dumbnet.h"

#define DN_TEST_BUFSIZE 42

void usage(char * arg0)
{
    printf("Usage: %s ",arg0);
}

int conn_server_main(nb_success)
{
    char buf[DN_TEST_BUFSIZE];
    int n=0;
    int success=0;
    int len;

    dn_socket sock = dn_udp_init(DUMB_PORT);

    //TODO : timer to abort in case of error somewhere else
    while( n<nb_success)
    {
        len = dn_udp_recv(sock, buf, len);
        if ( len <= 0 )
        {
            printf("ERROR : dn_udp_recv");
        }
        else (len > 0 )
        {
            printf("MSG : %s",buf);
            ++success;
        }
        ++n;
    }
    return success;
}

void noconn_server_main()
{
        char buf[DN_TEST_BUFSIZE];
    int n=0;
    int success=0;
    int len;

    dn_socket sock = dn_udp_init(DUMB_PORT);

    //TODO : timer to abort in case of error somewhere else
    while( n<nb_success)
    {
        len = dn_udp_recv(sock, buf, len);
        if ( len <= 0 )
        {
            printf("ERROR : dn_udp_recv");
        }
        else (len > 0 )
        {
            printf("MSG : %s",buf);
            ++success;
        }
        ++n;
    }
    return success;
}


int main(int argc, char * argv [])
{

    if (argc < 1  || ( argc >1 && strcmp(argv[1],"noconn") == 0 ) )
    {
        //unconnected mode ( default udp )
        server_main();
    }
    else if (argc >1 && strcmp(argv[1],"conn") == 0 )
    {
        //connected mode
        server_main();
    }
    else
    {
        usage();
    }

    return 0;
}

