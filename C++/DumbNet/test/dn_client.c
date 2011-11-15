#include "DumbNet/dumbnet.h"

void usage(char * arg0)
{
    printf("Usage: %s server",arg0);
    printf("Usage: %s client  [hostname]",arg0);
}

void client_main(const char * host)
{
    dn_socket sock = client_connec_init(host);

    client_connec_proc(sock);

}


int main(int argc, char * argv [])
{
    if ( argc < 1 )
        {
            client_main("localhost");
        }
        else
        {
            client_main(argv[1]);
        }
    return 0;
}

