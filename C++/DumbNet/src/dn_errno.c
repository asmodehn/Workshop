#include "DumbNet/dn_errno.h"

///storing last errno that was detected
int dn_errno;


const char * dn_errlist[] =
{
    "my dn_error"
}


///storing the size of errlist
int dn_nerr = sys_nerr + sizeof(dn_errlist);

const char* dn_get_errlist(int index)
{
    if ( index < sys_nerr )
    {
        return sys_errlist[index];
    }
    else if ( index < dn_nerr )
    {
        return dn_errlist[index - sys_nerr];
    }
    else
    {
        return "unknown error code";
    }
}

const char* dn_perror()
{
    dn_get_errlist(dn_errno);
    //TODO : add \n
}
