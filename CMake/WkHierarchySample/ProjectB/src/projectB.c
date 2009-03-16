#include "projectB.h"

#include <stdio.h>

int B_display(const char* txt)
{
	printf(" %s ",txt);
	C_display("C");
	return 0;
}
