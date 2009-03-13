#ifndef WKPLATFORM_HH
#define WKPLATFORM_HH

#if defined (__MINGW32__)
#define WK_DECLSPEC_EXPORT __declspec(dllexport)
#define WK_DECLSPEC_IMPORT __declspec(dllimport)

#elif defined(_MSC_VER)
#define WK_DECLSPEC_EXPORT _declspec(dllexport)
#define WK_DECLSPEC_IMPORT _declspec(dllimport)

#endif

#ifndef GCN_CORE_DECLSPEC
#define GCN_CORE_DECLSPEC
#endif

#ifndef GCN_EXTENSION_DECLSPEC
#define GCN_EXTENSION_DECLSPEC
#endif

#ifndef NULL
#define NULL 0
#endif

#endif // WKPLATFORM_HH
