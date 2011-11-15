#include "DumbNet/dumbnet.h"

///headers to artificially trigger errors
#include "dn_error.h"





int main( int argc, char * argv[] )
{
    int errcode = 0;
    int diff_total = 0;

    //checking that systems error are correctly forwarded
    for ( errcode = 0; errcode < dn_nerr; ++errcode )
    {
        if ( errcode < sys_nerr )
        {
            dn_test_trigger(errcode);

            //accumulating differences
            diff_total += strcmp (dn_perror(),perror());
        }
        else
        {
            dn_test_trigger(errcode);

            //TODO : add terminal \n
            diff_total += strcmp (dn_perror(), dn_get_errlist(errcode) );
        }

    }

    //returning number of differences in error code ( ther shouldnt be any )
    return diff_total;

}
