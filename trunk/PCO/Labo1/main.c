/** \file main.c
 *  \author SLD et ABR
 *  \date 16.02.2009
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

/** quantité d'argent dispo. dans la carte */
int somme = 0;
/** indique si le combiné est décroché */
bool combineDecroche = false;
/** indique si une carte est presente */
bool carteInseree = false;
/** indique si les conditions necessaires pour passer un appel sont présente */
bool communicationPossible = false;
/** tableau contenant le numéro composé par l'utilisateur */
int numeroTelephone[10];

bool OrdreOp = false;

/** fonction qui sera exécutée par un thread traitant le combiné */
void *Combine(void *arg)
{
  while (1) {
        
	 // Gestion du décrochement du combiné
     Telephone_DecrocheCombine();
     combineDecroche = true;
     printf("%s \n","le combine est decroche");
     if (carteInseree && somme > 0){
        communicationPossible = true;
        OrdreOp = true;
     }
     else
        printf("%s \n","Veuillez inserer une carte valide");
     
     
     // Gestion du raccorchement du combiné
     Telephone_RaccrocheCombine();
     communicationPossible = false;
     combineDecroche = false;
     possibleAvecArgent = false;
     printf("%s \n","le combine est raccroche");
  }
} /* fin de Combine */


/** fonction qui sera exécutée par un thread traitant les touches */
void *Touches(void *arg)
{
  int touche;
  int nbTouche = 0;
  
  while (1) {
        // Entree des touches  
        touche = Telephone_GetTouche();
        // Dès que la communication est possible   
        if (communicationPossible)
        {   
            numeroTelephone[nbTouche++] = touche;
            printf("Touche appuyee: %d\n",touche);
            
            // Dès que 10 touches ont été entrées on appelle
            // le numéro
            if ( nbTouche >= 10)
            {
               printf("Appel du numero: ");
               int i;
               for (i = 0 ; i < 10 ; i++) 
               {
                   printf("%d",numeroTelephone[i]);
    		   }
       		   
               // La communication peut démarrer   		 
    	       printf("montant disponible: %d\n",somme);
    	       
               // Gestion de la communication	 
    	       while (somme > 0 && carteInseree && combineDecroche){
                  somme -= 1; 
           	      printf("Appel en cours, montant disponible: %d\n",somme);
                  // On parle au téléphone
                  printf("blabla...\n");
                  sleep(2); 
                }
                // Le nombre de touche est remis à 0
                nbTouche=0;
                printf("Fin de la communication");    
                communicationPossible = false;      
             }    
      }
  }
} /* fin de Touches */


/** Tache gerant l'arrivee des differentes pieces de monnaie. */
void *Monnaie(void *arg)
{
  PIECE piece;  // piece a traiter
  while (1) {
		 
     piece = Telephone_GetPiece(); // lecteur d'une piece
     printf("Monnaie entree: %d\n",piece);
     
     if (carteInseree)
     {
        somme += piece;
		printf("Montant disponible: %d\n",somme);
		if(possibleAvecArgent)
		   communicationPossible = true;
     }
	 else
     {
        printf("%s \n","Veuillez inserer une carte");
        printf("Monnaie rendue: %d\n",piece);    
     }     
  }
} /* fin de Monnaie */


/** Tache gerant l'insertion et ejection de la carte de debit. */
void *Carte(void *arg)
{
  while (1) { 
     // Gestion de l'insertion de la carte
     somme = Telephone_CarteInseree();
     printf("Montant disponible: %d\n",somme);
     carteInseree = true;
     
     // Gestion de la récupération de la carte
     Telephone_CarteRecuperee();     
     carteInseree = false;
     communicationPossible = false;   
     OrdreOp = false;  
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
