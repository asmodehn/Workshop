#ifndef WKPLATFORM_HH
#define WKPLATFORM_HH

/* *
 *  Copyright (c) 2009, Asmodehn's Corp.
 *  All rights reserved.
 * 
 *  Redistribution and use in source and binary forms, with or without 
 *  modification, are permitted provided that the following conditions are met:
 *  
 *      - Redistributions of source code must retain the above copyright notice, 
 * 	    this list of conditions and the following disclaimer.
 *      - Redistributions in binary form must reproduce the above copyright
 * 		notice, this list of conditions and the following disclaimer in the 
 * 	    documentation and/or other materials provided with the distribution.
 *      - either the name of the Asmodehn's Corp. nor the names of its 
 * 	    contributors may be used to endorse or promote products derived
 * 	    from this software without specific prior written permission.
 *  
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 *  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 *  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 *  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
 *  BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
 *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 *  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
 *  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 *  THE POSSIBILITY OF SUCH DAMAGE.
 * 
 */

/*Platform type detection */
#if defined (__MINGW32__) || defined (_MSC_VER)
	#define WIN32_PLATFORM
#endif

/*adjusting declspec values*/

/* If building core */
#if defined (WIN32_PLATFORM) && defined (WK_SHAREDLIB_BUILD)
	#define WK_DECLSPEC __declspec(dllexport)
/* or building dependencies */
#elif defined (WIN32_PLATFORM) && defined (WK_SHAREDLIB_IMPORT)
	#define WK_DECLSPEC __declspec(dllimport)
#endif

/* TODO : Handle multiple interlinked libraries in same project... */

#ifndef WK_DECLSPEC
	#define WK_DECLSPEC
#endif


#ifndef NULL
#define NULL 0
#endif

#endif /* WKPLATFORM_HH */
