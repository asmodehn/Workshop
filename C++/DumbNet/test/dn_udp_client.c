#include "DumbNet/dumbnet.h"

void usage(char * arg0)
{
    printf("Usage: %s [ hostname ]",arg0);
}


int client_main(const char * host)
{
    dn_socket sock = dn_udp_client_init();
//PROBLEM : grab error here ?? -> use dn_perror


}


int main(int argc, char * argv [])
{
    int res = 0;
    if ( argc < 1 )
        {
            res = client_main("localhost");
        }
        else
        {
            res = client_main(argv[1]);
        }
    return 0;
}
