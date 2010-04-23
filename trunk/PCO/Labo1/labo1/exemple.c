/** \file exemple.c
 *  \author CEZ et YTA
 *  \date 15.02.2009
 * Exemple d'utilisation du simulateur de telephone.
 * Squelette du programme a completer et a documenter selon l'enonce pour le labo 1
 * PCO1 2010.
 * Compilation : gcc exemple.c telephone.c -lpthread
 */

#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <stdbool.h>
#include "psleep.h"
#include "telephone.h"

/** Commentaire */
int somme = 0;

/** Commentaire */
bool combineDecroche = false;

/** Commentaire */
void *Combine(void *arg)
{
  while (1) {
     Telephone_DecrocheCombine();
     combineDecroche = true;
     Telephone_RaccrocheCombine();
     combineDecroche = false;
  }
} /* fin de Combine */


/** Commentaire */
void *Touches(void *arg)
{
  int touche;
  while (1) {
     touche = Telephone_GetTouche();
     printf("Touche appuyée: %c\n",'0'+touche);
     /* On parle au téléphone */
     printf("blabla...\n");
     /* Pendant une seconde */
     sleep(1);
  }
} /* fin de Touches */


/** Tache gerant l'arrivee des differentes pieces de monnaie. */
void *Monnaie(void *arg)
{
  PIECE piece;  // piece a traiter
  while (1) {
     piece = Telephone_GetPiece(); // lecteur d'une piece
     printf("Monnaie entree: %d\n",piece);
  }
} /* fin de Monnaie */


/** Tache gerant l'insertion et ejection de la carte de debit. */
void *Carte(void *arg)
{
  while (1) {
     somme = Telephone_CarteInseree();
     printf("Montant disponible: %d\n",somme);
     Telephone_CarteRecuperee();
  }
} /* fin de Carte */


/** Commentaire */
int main(void)
{
  int err;
  if (Telephone_Initialise()) {
     pthread_attr_t attr;
     pthread_t thread;
     pthread_attr_init(&attr);
     pthread_attr_setschedpolicy(&attr,SCHED_RR);
     pthread_attr_setdetachstate(&attr,PTHREAD_CREATE_DETACHED);
     if ((err = pthread_create(&thread,&attr,Monnaie,NULL)) == 0) {
        if ((err = pthread_create(&thread,&attr,Carte,NULL)) == 0) {
           if ((err = pthread_create(&thread,&attr,Combine,NULL)) == 0) {
              if ((err = pthread_create(&thread,&attr,Touches,NULL)) == 0) {
                 pthread_exit(NULL);
              }
              else
                 printf("Main: Erreur de creation de Touches %d\n",err);
           }
           else
              printf("Main: Erreur de creation de Combine %d\n",err);
        }
        else
           printf("Main: Erreur de creation de Carte %d\n",err);
     }
     else
        printf("Main: Erreur de creation de Monnaie %d\n",err);
  }
  return EXIT_FAILURE;
} /* fin de main */
