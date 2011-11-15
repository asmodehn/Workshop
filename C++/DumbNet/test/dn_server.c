#include "DumbNet/dumbnet.h"


void usage(char * arg0)
{
    printf("Usage: %s server",arg0);
    printf("Usage: %s client  [hostname]",arg0);
}

void server_main()
{

    dn_socket sock = serv_init();

    while(1) {  // main accept() loop
     serv_connec_accept(sock,serv_connec_proc);
    }

}


int main(int argc, char * argv [])
{
        server_main();

    return 0;
}

