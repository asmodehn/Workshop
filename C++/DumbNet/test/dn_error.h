#include "DumbNet/dumbnet.h"

///setting error ( artificial -> test only )
dn_test_trigger ( int dn_errcode )
{
    dn_errno = dn_errcode;
}
