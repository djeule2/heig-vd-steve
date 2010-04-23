/** \mainpage Exclusion Mutuelle
 * Cette documentation décrit le programme Exclusion Mutuelle qui consiste 
 * à tester et comparer différents algorithmes d'exclusion mutuelle, en 
 * comparant le temps nécessaire à chacun d'eux pour s'exécuter. 
 * Cela a été mis en plage dans le laboratoire n°2 du cours PCO.
 *
 * \version 1.0
 *
  * \section Introduction
 *	Le but de ce programme consiste en la réalisation d'un programme permettant
 *	de comparer les performances de différents algorithmes permettant
 *	l'exclusion mutuelle.
 *	Les 3 algorithmes en question, sont:
 *		 - l'algorithme 2.2 du cours
 *		 - l'algorithme de Dekker
 *		 - l'algorithme de Peterson
 *
 * \section Comparaison
 *	Afin de comparer les différents algorithmes d'exclusion mutuelle, nous avons
 *	fait en sorte d'exécuter chacun d'entre eux l'un après l'autre et de manière
 *	indépendante, afin de pouvoir récupérer les temps nécessaires à chacun
 *	d'eux pour effectuer une opération critique (identique aux 3 algorithmes).
 *	Pour avoir des valeurs corrects et représentant uniquement le temps utile
 *	aux algorithmes et non pas avec les différentes tâches associées, tel que la
 *	création des threads, nous avons procédé de la manière suivante: 
 *	Au début de chaque tâche, nous avons ajouté une partie permettant la
 *	synchronisation des deux tâches d'un algorithme entre elles. Seulement 
 *	une fois les deux tâches prêtes, nous commençons l'exécution de l'algorithme
 *	et récupérons le temps de début. Une fois l'exécution finie, nous récupérons
 *	le temps de fin, et part la suite nous pouvons calculer le temps effectif
 *	de l'algorithme en soustrayons le temps de la première tâche  ayant débuté
 *	l'algorithme au temps de fin de la dernière tâche.
 *
 * \section Matériel
 *	Les propriétés de la machine sur laquelle ont été réalisées les mesures
 *	suivante:
 *		- Processeur: Intel Core 2 Duo T8100 2.1 GHz
 *		- RAM : 4 Go
 *		- Système d'exploitation: Windows 7 Professionnal sur 32 bits
 *
 * \section Résultats
 *	Les résultats que nous avons obtenus, et qui vont être présenté ci-dessous,
 *	portent sur 15 mesures par algorithmes. Nous avons décidé de prendre un
 *	suffisant de mesure afin d'éviter qu'une valeur atypique n'aille une 
 *	influence trop importante sur les résultats finaux.
 *	Les résultats obtenus et représenté par les graphiques disponibles en annexe
 *	nous ont permit de faire ressortir les observations suivantes:
 *	Premièrement nous pouvons constater que malgré ça simplicité, l'algorithme 
 *	de Peterson est le plus gourmand en temps. En moyenne, celui-ci
 *	nécessite environ 60% de temps en plus que l'algorithme de Dekker.
 *	Cela est sans doute du au fait que la boucle while exécutée par le thread
 *	attendant son tour contient deux conditions, contrairement aux deux autres
 *	algorithmes, qui eux n'en contiennent qu'une.
 *	Les graphiques nous permettent clairement de constater que l'algorithme 
 *	de Dekker ainsi que l'algorithme 2.2 du cours nécessitent à peu près le même
 *	temps, se qui permet de mettre l'algorithme de Dekker en avant, du fait
 *	que celui-ci vérifie la règle 3 des propriétés des algorithmes, 
 *	contrairement au second algorithme, qui oblige les deux tâches à
 *	fonctionner en même temps.
 */


/**\file main.c
 * \author Steve Lienhard et Arnaud Burkhalter
 * \date 16.03.2010
 * \version 1.0
 * \section Description
 *	Ce fichier définit les 
 *
 * \section Tests
 * Afin de tester que les algorithmes soient exécuté de manières correcte et
 *	contrôler que l'exclusion mutuelle aille bien lieu, nous avons affiché,
 *	à la fin de l'exécution de chaque thread, la variable globale sur laquelle
 *	les différentes tâches de chaque algorithme ont travaillées. Cela afin de 
 *	vérifier que la variable aille été accédée un nombre correcte de fois, soit
 *	deux fois le nombre d'itérations d'une section critique. 
 *	Dans notre cas, deux fois la constante NB_ITERATIONS, donc 200000000.
 * 
 */
 
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <stdbool.h>
#include <time.h>

/* tableaux d'états utile pour chaque algorithme*/
bool etat_algo1[2] = {false, false};
bool etat_algoDekker[2] = {false, false};
bool etat_algoPeterson[2] = {false, false};

/* gestion de jeton utile pour chaque algorithme */
int tour_algo1 = 0;
int tour_algoDekker = 0;
int tour_algoPeterson = 0;

/* variables récupérant le temps de début et de fin de l'algorithme 2.2 */
clock_t start_tache0_algo1, start_tache1_algo1, end_algo1;
/* variables récupérant le temps de début et de fin de l'algorithme de Dekker */
clock_t start_tache0_algoDekker, start_tache1_algoDekker, end_algoDekker;
/* variables récupérant les temps de début et fin de l'algorithme de Peterson */
clock_t start_tache0_algoPeterson, start_tache1_algoPeterson, end_algoPeterson;

/* Nombre d'itérations à exécuter dans la section critique */
const int NB_ITERATION = 100000000;

/* Compteur d'itération pour chaque algorithme*/
int cpt_algo1, cpt_algoDekker, cpt_algoPeterson;

/* variables permettant la synchronisation des tâches de chaque algorithme */
bool readyTask0_algo1 = false;
bool readyTask1_algo1 = false;

bool readyTask0_algoDekker = false;
bool readyTask1_algoDekker = false;

bool readyTask0_algoPeterson = false;
bool readyTask1_algoPeterson = false;

/* variable contenant le temps total d'exécution d'un algorithme */
double tempsExecution_algo1,
			 tempsExecution_algoDekker,
			 tempsExecution_algoPeterson;

/**
* But         : Fonction qui sera exécutée par un thread traitant la tâche 0
*								de l'algorithme	de l'exemple 2.2 du support de cours.
*								Dans une première phase, la fonction observera la seconde tâche
*								de l'algorithme et attendra que celle-ci soit prête. Si celle-ci
*								n'est pas encore prête, nous entrerons dans une boucle en
*								attendant le feu vert de l'autre tâche, se qui sera fait à
*								l'aide de la variable readyTask1_algo1.
*								Une fois les deux tâche prêtes, nous commençons l'algorithme et
*								récupérons le temps de début de celui-ci pour la tâche en cours.
*								Lorsque l'algorithme est terminé, nous récupérons le temps de 
*								fin de celui-ci, que nous stockons dans end_algo1.
*								Cette variable est identique pour les deux tâches car nous 
*								avons uniquement besoin du temps de la tâche finissant 
*								l'algorithme en dernier.
*
* Paramètre(s): arg : pointeur passé à la fonction.
*										  Il est inutilisé, mais permet à la fonction de 
*											correspondre au prototype nécessaire pour que celle-ci
*											puisse être utilisée par un thread.
*
*/
void *algo1_T0(void *arg)
{
 		 /* partie permettant la synchronisation des deux tâches de l'algorithme*/
 		 readyTask0_algo1 = true;
 		 while (!readyTask1_algo1){
		 			 ;
		 }
		 /* fin sychronisation*/
		 
		 /* récupère le temps de début de l'algorithme pour cette tâche */
	 	 start_tache0_algo1 = clock();
		 
		 /* début de l'algorithme */
		 while (tour_algo1 != 0)
		 {
		 			 ;
     }
     
		/* section critique */
		int i;
		for (i = 0; i < NB_ITERATION;i++)
		{
		 		cpt_algo1++;
		}
    tour_algo1 = 1;
    
    /* fin section critique */
 		readyTask0_algo1 = false;
    end_algo1 = clock(); 
     
} /* fin de algo1_T0 */


/**
* But         : Fonction qui sera exécutée par un thread traitant la tâche 1
*								de l'algorithme	de l'exemple 2.2 du support de cours.
*								Dans une première phase, la fonction observera la seconde tâche
*								de l'algorithme et attendra que celle-ci soit prête. Si celle-ci
*								n'est pas encore prête, nous entrerons dans une boucle en
*								attendant le feu vert de l'autre tâche, se qui sera fait à
*								l'aide de la variable readyTask0_algo1.
*								Une fois les deux tâche prêtes, nous commençons l'algorithme et
*								récupérons le temps de début de celui-ci pour la tâche en cours.
*								Lorsque l'algorithme est terminé, nous récupérons le temps de 
*								fin de celui-ci, que nous stockons dans end_algo1.
*								Cette variable est identique pour les deux tâches car nous 
*								avons uniquement besoin du temps de la tâche finissant 
*								l'algorithme en dernier.
*
* Paramètre(s): arg : pointeur passé à la fonction.
*										  Il est inutilisé, mais permet à la fonction de 
*											correspondre au prototype nécessaire pour que celle-ci
*											puisse être utilisée par un thread.
*
*/
void *algo1_T1(void *arg)
{
 		 /* partie permettant la synchronisation des deux tâches de l'algorithme*/
 		 readyTask1_algo1 = true;
 		 while (!readyTask0_algo1){
		 			;
		 }
 		 /* fin synchronisation */
 		 
 		 /* récupère le temps de début de l'algorithme pour cette tâche */
 		 start_tache1_algo1 = clock();
 		 
 		 /* début de l'algorithme */
		 while (tour_algo1 != 1)
		 {
			 			 ;
     }
		// section critique
		int i;
		for (i = 0; i < NB_ITERATION;i++)
		{
		 		cpt_algo1++;
		}

    tour_algo1 = 0;
    // section non critique
    readyTask1_algo1 = false;
    end_algo1 = clock();
    
} /* fin de algo1_T1 */


/**
* But         : Fonction qui sera exécutée par un thread traitant la tâche 0
*								de l'algorithme	de Dekker.
*								Dans une première phase, la fonction observera la seconde tâche
*								de l'algorithme et attendra que celle-ci soit prête. Si celle-ci
*								n'est pas encore prête, nous entrerons dans une boucle en
*								attendant le feu vert de l'autre tâche, se qui sera fait à
*								l'aide de la variable readyTask1_algoDekker.
*								Une fois les deux tâche prêtes, nous commençons l'algorithme et
*								récupérons le temps de début de celui-ci pour la tâche en cours.
*								Lorsque l'algorithme est terminé, nous récupérons le temps de 
*								fin de celui-ci, que nous stockons dans end_algoDekker.
*								Cette variable est identique pour les deux tâches car nous 
*								avons uniquement besoin du temps de la tâche finissant 
*								l'algorithme en dernier.
*
* Paramètre(s): arg : pointeur passé à la fonction.
*										  Il est inutilisé, mais permet à la fonction de 
*											correspondre au prototype nécessaire pour que celle-ci
*											puisse être utilisée par un thread.
*
*/
void *algoDekker_T0(void *arg)
{
 		 /* partie permettant la synchronisation des deux tâches de l'algorithme*/
 		 readyTask0_algoDekker = true;
 		 while (!readyTask1_algoDekker){
		 			;
		 }
		 /* fin synchronisation*/
		 
		 /* récupère le temps de début de l'algorithme pour cette tâche */
		 start_tache0_algoDekker = clock();
		 
		 /* début de l'algorithme de Dekker */
		 etat_algoDekker[0]= true;
		 while (etat_algoDekker[1])
 			  if (tour_algoDekker == 1)
 			  {
				 	 etat_algoDekker[0] = false;
				 	 while (tour_algoDekker == 1)
				 	 {
					 			;
					 }
		 			 etat_algoDekker[0] = true; 
				}
				//section critique
				int j;
				for (j = 0; j < NB_ITERATION;j++)
				{
				 		cpt_algoDekker++;
				}
				
				tour_algoDekker = 1;
				etat_algoDekker[0]= false;
				// section non critique
    
     readyTask0_algoDekker = false;
     end_algoDekker = clock(); 
   
} /* fin de algo1_T1 */

/**
* But         : Fonction qui sera exécutée par un thread traitant la tâche 1
*								de l'algorithme	de Dekker.
*								Dans une première phase, la fonction observera la seconde tâche
*								de l'algorithme et attendra que celle-ci soit prête. Si celle-ci
*								n'est pas encore prête, nous entrerons dans une boucle en
*								attendant le feu vert de l'autre tâche, se qui sera fait à
*								l'aide de la variable readyTask0_algoDekker.
*								Une fois les deux tâche prêtes, nous commençons l'algorithme et
*								récupérons le temps de début de celui-ci pour la tâche en cours.
*								Lorsque l'algorithme est terminé, nous récupérons le temps de 
*								fin de celui-ci, que nous stockons dans end_algoDekker.
*								Cette variable est identique pour les deux tâches car nous 
*								avons uniquement besoin du temps de la tâche finissant 
*								l'algorithme en dernier.
*
* Paramètre(s): arg : pointeur passé à la fonction.
*										  Il est inutilisé, mais permet à la fonction de 
*											correspondre au prototype nécessaire pour que celle-ci
*											puisse être utilisée par un thread.
*
*/
void *algoDekker_T1(void *arg)
{
 		 /* partie permettant la synchronisation des deux tâches de l'algorithme*/
 		 readyTask1_algoDekker = true;
 		 while (!readyTask0_algoDekker){
		 			;
		 }
		 /* fin synchronisation */
 		 
 		 /* récupère le temps de début de l'algorithme pour cette tâche */
 		 start_tache1_algoDekker = clock();
		 
		 /* début de l'algorithme de Dekker */
		 etat_algoDekker[1]= true;
		 while (etat_algoDekker[0])
	   if (tour_algoDekker == 0)
	   {
				 	 etat_algoDekker[1] = false;
				 	 while (tour_algoDekker == 0)
				 	 {
					 			 ;
					 }
		 			 etat_algoDekker[1] = true; 
		 }
		 
		 //section critique
		 int i;
		 for (i = 0; i < NB_ITERATION;i++)
		 {
		  		cpt_algoDekker++;
		 }
		
		 tour_algoDekker = 0;
		 etat_algoDekker[1]= false;
		 // section non critique

     readyTask1_algoDekker = false;
     end_algoDekker = clock(); 

} /* fin de algo1_T1 */

/**
* But         : Fonction qui sera exécutée par un thread traitant la tâche 0
*								de l'algorithme	de Peterson.
*								Dans une première phase, la fonction observera la seconde tâche
*								de l'algorithme et attendra que celle-ci soit prête. Si celle-ci
*								n'est pas encore prête, nous entrerons dans une boucle en
*								attendant le feu vert de l'autre tâche, se qui sera fait à
*								l'aide de la variable readyTask1_algoPeterson.
*								Une fois les deux tâche prêtes, nous commençons l'algorithme et
*								récupérons le temps de début de celui-ci pour la tâche en cours.
*								Lorsque l'algorithme est terminé, nous récupérons le temps de 
*								fin de celui-ci, que nous stockons dans end_algoPeterson.
*								Cette variable est identique pour les deux tâches car nous 
*								avons uniquement besoin du temps de la tâche finissant 
*								l'algorithme en dernier.
*
* Paramètre(s): arg : pointeur passé à la fonction.
*										  Il est inutilisé, mais permet à la fonction de 
*											correspondre au prototype nécessaire pour que celle-ci
*											puisse être utilisée par un thread.
*
*/
void *algoPeterson_T0(void *arg)
{
 		 /* partie permettant la synchronisation des deux tâches de l'algorithme*/
 		 readyTask0_algoPeterson = true;
 		 while (!readyTask1_algoPeterson){
		 			 ;
		 }
		 /* fin synchronisation */
		 
		 /* récupère le temps de début de l'algorithme pour cette tâche */
		 start_tache0_algoPeterson = clock();
		 
		 /* début de l'algorithme de Peterson */
		 etat_algoPeterson[0]= true;
		 tour_algoPeterson = 1;
 		 while (etat_algoPeterson[1] && tour_algoPeterson == 1)
		 {
 			 
     }
		 //section critique
		 int i;
		for (i = 0; i < NB_ITERATION;i++)
		{
		 		cpt_algoPeterson++;
		}
		 
	   etat_algoPeterson[0]= false;
			// section non critique
			readyTask0_algoPeterson = false;
			end_algoPeterson = clock(); 
     
} /* fin de algoPeterson_T0 */


/**
* But         : Fonction qui sera exécutée par un thread traitant la tâche 1
*								de l'algorithme	de Peterson.
*								Dans une première phase, la fonction observera la seconde tâche
*								de l'algorithme et attendra que celle-ci soit prête. Si celle-ci
*								n'est pas encore prête, nous entrerons dans une boucle en
*								attendant le feu vert de l'autre tâche, se qui sera fait à
*								l'aide de la variable readyTask0_algoPeterson.
*								Une fois les deux tâche prêtes, nous commençons l'algorithme et
*								récupérons le temps de début de celui-ci pour la tâche en cours.
*								Lorsque l'algorithme est terminé, nous récupérons le temps de 
*								fin de celui-ci, que nous stockons dans end_algoPeterson.
*								Cette variable est identique pour les deux tâches car nous 
*								avons uniquement besoin du temps de la tâche finissant 
*								l'algorithme en dernier.
*
* Paramètre(s): arg : pointeur passé à la fonction.
*										  Il est inutilisé, mais permet à la fonction de 
*											correspondre au prototype nécessaire pour que celle-ci
*											puisse être utilisée par un thread.
*
*/
void *algoPeterson_T1(void *arg)
{
 		 /* partie permettant la synchronisation des deux tâches de l'algorithme*/
 		 readyTask1_algoPeterson = true;
 		 while (!readyTask0_algoPeterson){
		 			 ;
		 }
		 /* fin synchronisation*/
	
		 /* récupère le temps de début de l'algorithme pour cette tâche */
		 start_tache1_algoPeterson = clock();
	
		 /* début de l'algorithme de Peterson */
		 etat_algoPeterson[1]= true;
		 tour_algoPeterson = 0;
		 while (etat_algoPeterson[0] && tour_algoPeterson == 0)
		 {
			 		 ;
	   }
		 //section critique
		 int i;
		for (i = 0; i < NB_ITERATION;i++)
		{
		 		cpt_algoPeterson++;
		}
		 
	   etat_algoPeterson[1]= false;
			// section non critique
			readyTask1_algoPeterson = false;
			end_algoPeterson = clock(); 

} /* fin de algoPeterson_T0 */


/**
* But         : Fonction principale qui a pour but de tester les différents
*								algorithmes d'exclusion mutuelle. 
*								Pour chaque algorithme deux threads sont créés et exécutés, 
*								un pour chaque tâche.
*								Après l'exécution de chaque algorithme, nous calculons le temps
*								qu'il a fallu aux tâches pour s'exécuté, et affichons celui-ci.
*
* Résultat: EXIT_SUCCESS : int qui indique si le programme s'est terminé de 
*						manière correct ou non.
*/
int main()
{

	  /* Gestion de l'algorithme 2.2 du cours */
	  /*--------------------------------------*/
	  
	  	printf("Algorithme 2.2 du cours\n");
	  	printf("------------------------\n");
			
			/* déclaration des threads */
			pthread_t tache0_Algo1, tache1_Algo1;
			
			/* création des threads */
			pthread_create(&tache0_Algo1,NULL,algo1_T0,NULL);
			pthread_create(&tache1_Algo1,NULL,algo1_T1,NULL);
			
			/* attend que les deux tâches se terminent */
			pthread_join(tache0_Algo1, NULL);
			pthread_join(tache1_Algo1, NULL);
			
			/* temps utile entre le début de la première tâche et la fin de la dernière */
			tempsExecution_algo1 = ((double)(end_algo1 - (start_tache0_algo1 < 
			start_tache1_algo1?start_tache0_algo1 : start_tache1_algo1)))/CLOCKS_PER_SEC;
			
			/* affichage du temps */
			printf("%e \n", tempsExecution_algo1);
			/* affichage du compteur */
			printf("compteur : %d\n",cpt_algo1);
			
			
			/* Gestion de l'algorithme de Dekker */
	    /*--------------------------------------*/
	    
			printf("\nAlgorithme de Dekker\n");
			printf("------------------------\n");
			
			/* déclaration des threads */
			pthread_t tache0_AlgoDekker, tache1_AlgoDekker;
			
			/* attend que les deux tâches se terminent */
			pthread_create(&tache0_AlgoDekker,NULL,algoDekker_T0,NULL);
			pthread_create(&tache1_AlgoDekker,NULL,algoDekker_T1,NULL);
			
			
			pthread_join(tache0_AlgoDekker, NULL);
			pthread_join(tache1_AlgoDekker, NULL);
			
			/* temps utile entre le début de la première tâche et la fin de la dernière */
			tempsExecution_algoDekker = ((double)(end_algoDekker -
			         (start_tache0_algoDekker < start_tache1_algoDekker ? 
							 start_tache0_algoDekker : start_tache1_algoDekker)))/CLOCKS_PER_SEC;
			
			/* affichage du temps */
			printf("%e \n", tempsExecution_algoDekker);
			/* affichage du compteur */
			printf("compteur : %d \n",cpt_algoDekker);
			
			
			/* Gestion de l'algorithme de Peterson */
	    /*--------------------------------------*/
	  
			printf("\nAlgorithme de Peterson\n");
			printf("------------------------\n");
				
			/* déclaration des threads */
			pthread_t tache0_AlgoPeterson, tache1_AlgoPeterson;
			
			/* création des threads */
			pthread_create(&tache0_AlgoPeterson,NULL,algoPeterson_T0,NULL);
			pthread_create(&tache1_AlgoPeterson,NULL,algoPeterson_T1,NULL);
			
			/* attend que les deux tâches se terminent */
			pthread_join(tache0_AlgoPeterson, NULL);
			pthread_join(tache1_AlgoPeterson, NULL);
			
			/* temps utile entre le début de la première tâche et la fin de la dernière */
			tempsExecution_algoPeterson = ((double)(end_algoPeterson - 
			      (start_tache0_algoPeterson < start_tache1_algoPeterson ? 
			      start_tache0_algoPeterson : start_tache1_algoPeterson)))/CLOCKS_PER_SEC;
			
			/* affichage du temps */
			printf("%e \n", tempsExecution_algoPeterson);
			/* affichage du compteur */
			printf("compteur : %d\n",cpt_algoPeterson);
			
			system("pause");  

return EXIT_SUCCESS;
} /* fin de main */
