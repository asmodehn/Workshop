#ifndef WKPLATFORM_HH
#define WKPLATFORM_HH

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

#endif // WKPLATFORM_HH
