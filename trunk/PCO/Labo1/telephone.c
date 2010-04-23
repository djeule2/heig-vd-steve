/* Fichier : telephone.c
** But : Realise l'implementation simulant un telephone.
** Auteur : CEZ, YTA (15 fevrier 2010)
** Compilation : gcc application.c machine.c -lpthread
*/

#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include "telephone.h"
#include "psleep.h"


#define MAXTAMPON 4
typedef struct TAMPON {
  pthread_mutex_t mutex;
  pthread_cond_t depot, retrait;
  int indiceDepot, indiceRetrait, nbElements;
  int contenu[MAXTAMPON];
} TAMPON;

TAMPON TamponIntroductionPieces;
TAMPON TamponIntroductionTouches;

static int InitialiseTampon(TAMPON *tampon)
{
  int err;
  if ((err = pthread_cond_init(&tampon->retrait,NULL)) == 0) {
     if ((err = pthread_cond_init(&tampon->depot,NULL)) == 0) {
        if ((err = pthread_mutex_init(&tampon->mutex,NULL)) == 0) {
           tampon->indiceDepot = tampon->indiceRetrait = tampon->nbElements = 0;
           return 1;
        }
        printf("InitialiseTamponIntroductionPieces: Erreur pthread_mutex_init = %d\n",err);
        pthread_cond_destroy(&tampon->depot);
     }
     else
        printf("InitialiseTamponIntroductionPieces: Erreur pthread_cond_init = %d\n",err);     
     pthread_cond_destroy(&tampon->retrait);
  }
  else
     printf("InitialiseTamponIntroductionPieces: Erreur pthread_cond_init = %d\n",err);
  return 0;
} /* fin de InitialiseTampon */


static void LibereTampon(TAMPON *tampon)
{
  pthread_cond_destroy(&tampon->retrait);
  pthread_cond_destroy(&tampon->depot);
  pthread_mutex_destroy(&tampon->mutex);
} /* fin de LibereTampon */


static int RetireTampon(TAMPON *tampon)
{
  int tmp;
  pthread_mutex_lock(&tampon->mutex);
  if (tampon->nbElements == 0)
     pthread_cond_wait(&tampon->retrait,&tampon->mutex);
  tmp = tampon->contenu[tampon->indiceRetrait];
  tampon->indiceRetrait = (tampon->indiceRetrait + 1) % MAXTAMPON;
  tampon->nbElements -= 1;
  pthread_cond_signal(&tampon->depot);  
  pthread_mutex_unlock(&tampon->mutex);
  return tmp;
} /* fin de RetireTampon */


static int DeposeTampon(TAMPON *tampon, int contenu)
{
  struct timespec chienGarde;
  pthread_mutex_lock(&tampon->mutex);
  if (tampon->nbElements == MAXTAMPON) {
     time(&chienGarde.tv_sec);
     chienGarde.tv_sec += 1;
     pthread_cond_timedwait(&tampon->depot,&tampon->mutex,&chienGarde);
  }
  if (tampon->nbElements < MAXTAMPON) {
     tampon->contenu[tampon->indiceDepot] = contenu;
     tampon->nbElements += 1;
     pthread_cond_signal(&tampon->retrait);
     tampon->indiceDepot = (tampon->indiceDepot + 1) % MAXTAMPON;
  }
  else
     contenu = 0;
  pthread_mutex_unlock(&tampon->mutex);
  return contenu;
} /* fin de DeposeTampon */


PIECE Telephone_GetPiece(void)
{
  return (PIECE)RetireTampon(&TamponIntroductionPieces);
} /* end of Telephone_GetPiece */


int Telephone_GetTouche(void)
{
  return RetireTampon(&TamponIntroductionTouches);
} /* end of Telephone_GetTouche */



static pthread_mutex_t MutexCarteIn = PTHREAD_MUTEX_INITIALIZER;
static pthread_mutex_t MutexCarteOut = PTHREAD_MUTEX_INITIALIZER;
static int carte_montant = 0;
static int montantProchaineUtilisation = 0;

int Telephone_CarteInseree(void)
{
  pthread_mutex_lock(&MutexCarteIn);
  return carte_montant;
} /* fin de Telephone_CarteInseree */


void Telephone_CarteRecuperee(void)
{
  pthread_mutex_lock(&MutexCarteOut);
} /* fin de Telephone_CarteInseree */


static int etatCarte = 0;

static void InsereCarte(void)
{
  if (etatCarte == 0) {
     carte_montant = montantProchaineUtilisation;
     pthread_mutex_unlock(&MutexCarteIn);
     etatCarte = 1;
  }
} /* fin de InsereCarte */


static void EnleveCarte(void)
{
  if (etatCarte == 1) {
     montantProchaineUtilisation = carte_montant;
     carte_montant = 0;
     pthread_mutex_unlock(&MutexCarteOut);
     etatCarte = 0;
  }
} /* fin de EnleveCarte */


void Telephone_SetMontant(unsigned montant)
{
  sleep(1);
  carte_montant = montant;
} /* fin de Telephone_SetMontant */


static pthread_mutex_t MutexDecroche = PTHREAD_MUTEX_INITIALIZER;
static pthread_mutex_t MutexRaccroche = PTHREAD_MUTEX_INITIALIZER;

void Telephone_DecrocheCombine(void)
{
  pthread_mutex_lock(&MutexDecroche);
}

void Telephone_RaccrocheCombine(void)
{
  pthread_mutex_lock(&MutexRaccroche);
}

static int etatCombine = 0;

static void Decroche(void)
{
  if (etatCombine == 0) {
     pthread_mutex_unlock(&MutexDecroche);
     etatCombine = 1;
  }
} /* end of Decroche */

static void Raccroche(void)
{
  if (etatCombine == 1) {
     pthread_mutex_unlock(&MutexRaccroche);
     etatCombine = 0;
  }
} /* end of Raccroche */


void *TacheBoutton(void *arg)
{
  char car;
  while (1) 
      switch (car = getchar()) {
          case 'D':
             Decroche();
             break;
          case 'R':
             Raccroche();
             break;
          case 'O':
             EnleveCarte();
             break;
          case 'I':
             InsereCarte();
             break;
          case '1':  case '2':  case '3':  case '4':  case '5':  case '6':  case '7':
          case '8':  case '9':  case '0':
             DeposeTampon(&TamponIntroductionTouches,car - '0');
             break;
          case 'q':
             DeposeTampon(&TamponIntroductionPieces,1);
             break;
          case 'w':
             DeposeTampon(&TamponIntroductionPieces,2);
             break;
          case 'e':
             DeposeTampon(&TamponIntroductionPieces,3);
             break;
          case 'r':
             DeposeTampon(&TamponIntroductionPieces,4);
             break;
          case 't':
             DeposeTampon(&TamponIntroductionPieces,5);
             break;
          case 'z':
             DeposeTampon(&TamponIntroductionPieces,6);
             break;
          case 'u':
             DeposeTampon(&TamponIntroductionPieces,7);
             break;
          case 'i':
             DeposeTampon(&TamponIntroductionPieces,8);
             break;
          case 'o':
             DeposeTampon(&TamponIntroductionPieces,9);
          default:
             break;
     }
} /* fin de TacheBoutton */
  

/* Semaphore a usage externe */
static pthread_mutex_t MutexExterne = PTHREAD_MUTEX_INITIALIZER;


void Telephone_DebutSectionCritique(void)
{
  pthread_mutex_lock(&MutexExterne);
} /* fin de Telephone_DebutSectionCritique */


void Telephone_FinSectionCritique(void)
{
  pthread_mutex_unlock(&MutexExterne);
} /* fin de Telephone_FinSectionCritique */


int Telephone_Initialise(void)
{
  pthread_mutex_lock(&MutexCarteIn);
  pthread_mutex_lock(&MutexCarteOut);
  pthread_mutex_lock(&MutexDecroche);
  pthread_mutex_lock(&MutexRaccroche);
  if (InitialiseTampon(&TamponIntroductionTouches)) {
     if (InitialiseTampon(&TamponIntroductionPieces)) {
        pthread_attr_t attr;
        pthread_t thread;
        pthread_attr_init(&attr);
        pthread_attr_setschedpolicy(&attr,SCHED_RR);
        pthread_attr_setdetachstate(&attr,PTHREAD_CREATE_DETACHED);
        if (pthread_create(&thread,&attr,TacheBoutton,NULL) == 0)
           return 1;
        printf("Machine_Initialise: Erreur pthread_create\n");
        LibereTampon(&TamponIntroductionPieces);
     }
     LibereTampon(&TamponIntroductionTouches);
  }
  return 0;
} /* fin de Telephone_Initialise */
