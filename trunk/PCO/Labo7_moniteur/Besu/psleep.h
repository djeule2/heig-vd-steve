/**
 * \file moniteur.h
 * \date 11.06.2010
 *
 * Fichier permettant de définir la bonne méthode à appeler pour endormir un 
 * thread en fonction du système d'exploitation.
 */
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

