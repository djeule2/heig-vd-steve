#ifndef H_ED_PSLEEP
#define H_ED_PSLEEP

#if defined (WIN32) || defined (_WIN32)
#include <windows.h>

#define sleep(s) Sleep((s)*1000)

#elif defined (__linux) || defined (linux)

#include <unistd.h>

#define sleep(s) sleep(s)

#endif

#endif /* H_ED_PSLEEP */

