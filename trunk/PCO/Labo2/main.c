/** \mainpage Exclusion Mutuelle
 * Cette documentation d�crit le programme Exclusion Mutuelle qui consiste 
 * � tester et comparer diff�rents algorithmes d'exclusion mutuelle, en 
 * comparant le temps n�cessaire � chacun d'eux pour s'ex�cuter. 
 * Cela a �t� mis en plage dans le laboratoire n�2 du cours PCO.
 *
 * \version 1.0
 *
  * \section Introduction
 *	Le but de ce programme consiste en la r�alisation d'un programme permettant
 *	de comparer les performances de diff�rents algorithmes permettant
 *	l'exclusion mutuelle.
 *	Les 3 algorithmes en question, sont:
 *		 - l'algorithme 2.2 du cours
 *		 - l'algorithme de Dekker
 *		 - l'algorithme de Peterson
 *
 * \section Comparaison
 *	Afin de comparer les diff�rents algorithmes d'exclusion mutuelle, nous avons
 *	fait en sorte d'ex�cuter chacun d'entre eux l'un apr�s l'autre et de mani�re
 *	ind�pendante, afin de pouvoir r�cup�rer les temps n�cessaires � chacun
 *	d'eux pour effectuer une op�ration critique (identique aux 3 algorithmes).
 *	Pour avoir des valeurs corrects et repr�sentant uniquement le temps utile
 *	aux algorithmes et non pas avec les diff�rentes t�ches associ�es, tel que la
 *	cr�ation des threads, nous avons proc�d� de la mani�re suivante: 
 *	Au d�but de chaque t�che, nous avons ajout� une partie permettant la
 *	synchronisation des deux t�ches d'un algorithme entre elles. Seulement 
 *	une fois les deux t�ches pr�tes, nous commen�ons l'ex�cution de l'algorithme
 *	et r�cup�rons le temps de d�but. Une fois l'ex�cution finie, nous r�cup�rons
 *	le temps de fin, et part la suite nous pouvons calculer le temps effectif
 *	de l'algorithme en soustrayons le temps de la premi�re t�che  ayant d�but�
 *	l'algorithme au temps de fin de la derni�re t�che.
 *
 * \section Mat�riel
 *	Les propri�t�s de la machine sur laquelle ont �t� r�alis�es les mesures
 *	suivante:
 *		- Processeur: Intel Core 2 Duo T8100 2.1 GHz
 *		- RAM : 4 Go
 *		- Syst�me d'exploitation: Windows 7 Professionnal sur 32 bits
 *
 * \section R�sultats
 *	Les r�sultats que nous avons obtenus, et qui vont �tre pr�sent� ci-dessous,
 *	portent sur 15 mesures par algorithmes. Nous avons d�cid� de prendre un
 *	suffisant de mesure afin d'�viter qu'une valeur atypique n'aille une 
 *	influence trop importante sur les r�sultats finaux.
 *	Les r�sultats obtenus et repr�sent� par les graphiques disponibles en annexe
 *	nous ont permit de faire ressortir les observations suivantes:
 *	Premi�rement nous pouvons constater que malgr� �a simplicit�, l'algorithme 
 *	de Peterson est le plus gourmand en temps. En moyenne, celui-ci
 *	n�cessite environ 60% de temps en plus que l'algorithme de Dekker.
 *	Cela est sans doute du au fait que la boucle while ex�cut�e par le thread
 *	attendant son tour contient deux conditions, contrairement aux deux autres
 *	algorithmes, qui eux n'en contiennent qu'une.
 *	Les graphiques nous permettent clairement de constater que l'algorithme 
 *	de Dekker ainsi que l'algorithme 2.2 du cours n�cessitent � peu pr�s le m�me
 *	temps, se qui permet de mettre l'algorithme de Dekker en avant, du fait
 *	que celui-ci v�rifie la r�gle 3 des propri�t�s des algorithmes, 
 *	contrairement au second algorithme, qui oblige les deux t�ches �
 *	fonctionner en m�me temps.
 */


/**\file main.c
 * \author Steve Lienhard et Arnaud Burkhalter
 * \date 16.03.2010
 * \version 1.0
 * \section Description
 *	Ce fichier d�finit les 
 *
 * \section Tests
 * Afin de tester que les algorithmes soient ex�cut� de mani�res correcte et
 *	contr�ler que l'exclusion mutuelle aille bien lieu, nous avons affich�,
 *	� la fin de l'ex�cution de chaque thread, la variable globale sur laquelle
 *	les diff�rentes t�ches de chaque algorithme ont travaill�es. Cela afin de 
 *	v�rifier que la variable aille �t� acc�d�e un nombre correcte de fois, soit
 *	deux fois le nombre d'it�rations d'une section critique. 
 *	Dans notre cas, deux fois la constante NB_ITERATIONS, donc 200000000.
 * 
 */
 
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <stdbool.h>
#include <time.h>

/* tableaux d'�tats utile pour chaque algorithme*/
bool etat_algo1[2] = {false, false};
bool etat_algoDekker[2] = {false, false};
bool etat_algoPeterson[2] = {false, false};

/* gestion de jeton utile pour chaque algorithme */
int tour_algo1 = 0;
int tour_algoDekker = 0;
int tour_algoPeterson = 0;

/* variables r�cup�rant le temps de d�but et de fin de l'algorithme 2.2 */
clock_t start_tache0_algo1, start_tache1_algo1, end_algo1;
/* variables r�cup�rant le temps de d�but et de fin de l'algorithme de Dekker */
clock_t start_tache0_algoDekker, start_tache1_algoDekker, end_algoDekker;
/* variables r�cup�rant les temps de d�but et fin de l'algorithme de Peterson */
clock_t start_tache0_algoPeterson, start_tache1_algoPeterson, end_algoPeterson;

/* Nombre d'it�rations � ex�cuter dans la section critique */
const int NB_ITERATION = 100000000;

/* Compteur d'it�ration pour chaque algorithme*/
int cpt_algo1, cpt_algoDekker, cpt_algoPeterson;

/* variables permettant la synchronisation des t�ches de chaque algorithme */
bool readyTask0_algo1 = false;
bool readyTask1_algo1 = false;

bool readyTask0_algoDekker = false;
bool readyTask1_algoDekker = false;

bool readyTask0_algoPeterson = false;
bool readyTask1_algoPeterson = false;

/* variable contenant le temps total d'ex�cution d'un algorithme */
double tempsExecution_algo1,
			 tempsExecution_algoDekker,
			 tempsExecution_algoPeterson;

/**
* But         : Fonction qui sera ex�cut�e par un thread traitant la t�che 0
*								de l'algorithme	de l'exemple 2.2 du support de cours.
*								Dans une premi�re phase, la fonction observera la seconde t�che
*								de l'algorithme et attendra que celle-ci soit pr�te. Si celle-ci
*								n'est pas encore pr�te, nous entrerons dans une boucle en
*								attendant le feu vert de l'autre t�che, se qui sera fait �
*								l'aide de la variable readyTask1_algo1.
*								Une fois les deux t�che pr�tes, nous commen�ons l'algorithme et
*								r�cup�rons le temps de d�but de celui-ci pour la t�che en cours.
*								Lorsque l'algorithme est termin�, nous r�cup�rons le temps de 
*								fin de celui-ci, que nous stockons dans end_algo1.
*								Cette variable est identique pour les deux t�ches car nous 
*								avons uniquement besoin du temps de la t�che finissant 
*								l'algorithme en dernier.
*
* Param�tre(s): arg : pointeur pass� � la fonction.
*										  Il est inutilis�, mais permet � la fonction de 
*											correspondre au prototype n�cessaire pour que celle-ci
*											puisse �tre utilis�e par un thread.
*
*/
void *algo1_T0(void *arg)
{
 		 /* partie permettant la synchronisation des deux t�ches de l'algorithme*/
 		 readyTask0_algo1 = true;
 		 while (!readyTask1_algo1){
		 			 ;
		 }
		 /* fin sychronisation*/
		 
		 /* r�cup�re le temps de d�but de l'algorithme pour cette t�che */
	 	 start_tache0_algo1 = clock();
		 
		 /* d�but de l'algorithme */
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
* But         : Fonction qui sera ex�cut�e par un thread traitant la t�che 1
*								de l'algorithme	de l'exemple 2.2 du support de cours.
*								Dans une premi�re phase, la fonction observera la seconde t�che
*								de l'algorithme et attendra que celle-ci soit pr�te. Si celle-ci
*								n'est pas encore pr�te, nous entrerons dans une boucle en
*								attendant le feu vert de l'autre t�che, se qui sera fait �
*								l'aide de la variable readyTask0_algo1.
*								Une fois les deux t�che pr�tes, nous commen�ons l'algorithme et
*								r�cup�rons le temps de d�but de celui-ci pour la t�che en cours.
*								Lorsque l'algorithme est termin�, nous r�cup�rons le temps de 
*								fin de celui-ci, que nous stockons dans end_algo1.
*								Cette variable est identique pour les deux t�ches car nous 
*								avons uniquement besoin du temps de la t�che finissant 
*								l'algorithme en dernier.
*
* Param�tre(s): arg : pointeur pass� � la fonction.
*										  Il est inutilis�, mais permet � la fonction de 
*											correspondre au prototype n�cessaire pour que celle-ci
*											puisse �tre utilis�e par un thread.
*
*/
void *algo1_T1(void *arg)
{
 		 /* partie permettant la synchronisation des deux t�ches de l'algorithme*/
 		 readyTask1_algo1 = true;
 		 while (!readyTask0_algo1){
		 			;
		 }
 		 /* fin synchronisation */
 		 
 		 /* r�cup�re le temps de d�but de l'algorithme pour cette t�che */
 		 start_tache1_algo1 = clock();
 		 
 		 /* d�but de l'algorithme */
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
* But         : Fonction qui sera ex�cut�e par un thread traitant la t�che 0
*								de l'algorithme	de Dekker.
*								Dans une premi�re phase, la fonction observera la seconde t�che
*								de l'algorithme et attendra que celle-ci soit pr�te. Si celle-ci
*								n'est pas encore pr�te, nous entrerons dans une boucle en
*								attendant le feu vert de l'autre t�che, se qui sera fait �
*								l'aide de la variable readyTask1_algoDekker.
*								Une fois les deux t�che pr�tes, nous commen�ons l'algorithme et
*								r�cup�rons le temps de d�but de celui-ci pour la t�che en cours.
*								Lorsque l'algorithme est termin�, nous r�cup�rons le temps de 
*								fin de celui-ci, que nous stockons dans end_algoDekker.
*								Cette variable est identique pour les deux t�ches car nous 
*								avons uniquement besoin du temps de la t�che finissant 
*								l'algorithme en dernier.
*
* Param�tre(s): arg : pointeur pass� � la fonction.
*										  Il est inutilis�, mais permet � la fonction de 
*											correspondre au prototype n�cessaire pour que celle-ci
*											puisse �tre utilis�e par un thread.
*
*/
void *algoDekker_T0(void *arg)
{
 		 /* partie permettant la synchronisation des deux t�ches de l'algorithme*/
 		 readyTask0_algoDekker = true;
 		 while (!readyTask1_algoDekker){
		 			;
		 }
		 /* fin synchronisation*/
		 
		 /* r�cup�re le temps de d�but de l'algorithme pour cette t�che */
		 start_tache0_algoDekker = clock();
		 
		 /* d�but de l'algorithme de Dekker */
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
* But         : Fonction qui sera ex�cut�e par un thread traitant la t�che 1
*								de l'algorithme	de Dekker.
*								Dans une premi�re phase, la fonction observera la seconde t�che
*								de l'algorithme et attendra que celle-ci soit pr�te. Si celle-ci
*								n'est pas encore pr�te, nous entrerons dans une boucle en
*								attendant le feu vert de l'autre t�che, se qui sera fait �
*								l'aide de la variable readyTask0_algoDekker.
*								Une fois les deux t�che pr�tes, nous commen�ons l'algorithme et
*								r�cup�rons le temps de d�but de celui-ci pour la t�che en cours.
*								Lorsque l'algorithme est termin�, nous r�cup�rons le temps de 
*								fin de celui-ci, que nous stockons dans end_algoDekker.
*								Cette variable est identique pour les deux t�ches car nous 
*								avons uniquement besoin du temps de la t�che finissant 
*								l'algorithme en dernier.
*
* Param�tre(s): arg : pointeur pass� � la fonction.
*										  Il est inutilis�, mais permet � la fonction de 
*											correspondre au prototype n�cessaire pour que celle-ci
*											puisse �tre utilis�e par un thread.
*
*/
void *algoDekker_T1(void *arg)
{
 		 /* partie permettant la synchronisation des deux t�ches de l'algorithme*/
 		 readyTask1_algoDekker = true;
 		 while (!readyTask0_algoDekker){
		 			;
		 }
		 /* fin synchronisation */
 		 
 		 /* r�cup�re le temps de d�but de l'algorithme pour cette t�che */
 		 start_tache1_algoDekker = clock();
		 
		 /* d�but de l'algorithme de Dekker */
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
* But         : Fonction qui sera ex�cut�e par un thread traitant la t�che 0
*								de l'algorithme	de Peterson.
*								Dans une premi�re phase, la fonction observera la seconde t�che
*								de l'algorithme et attendra que celle-ci soit pr�te. Si celle-ci
*								n'est pas encore pr�te, nous entrerons dans une boucle en
*								attendant le feu vert de l'autre t�che, se qui sera fait �
*								l'aide de la variable readyTask1_algoPeterson.
*								Une fois les deux t�che pr�tes, nous commen�ons l'algorithme et
*								r�cup�rons le temps de d�but de celui-ci pour la t�che en cours.
*								Lorsque l'algorithme est termin�, nous r�cup�rons le temps de 
*								fin de celui-ci, que nous stockons dans end_algoPeterson.
*								Cette variable est identique pour les deux t�ches car nous 
*								avons uniquement besoin du temps de la t�che finissant 
*								l'algorithme en dernier.
*
* Param�tre(s): arg : pointeur pass� � la fonction.
*										  Il est inutilis�, mais permet � la fonction de 
*											correspondre au prototype n�cessaire pour que celle-ci
*											puisse �tre utilis�e par un thread.
*
*/
void *algoPeterson_T0(void *arg)
{
 		 /* partie permettant la synchronisation des deux t�ches de l'algorithme*/
 		 readyTask0_algoPeterson = true;
 		 while (!readyTask1_algoPeterson){
		 			 ;
		 }
		 /* fin synchronisation */
		 
		 /* r�cup�re le temps de d�but de l'algorithme pour cette t�che */
		 start_tache0_algoPeterson = clock();
		 
		 /* d�but de l'algorithme de Peterson */
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
* But         : Fonction qui sera ex�cut�e par un thread traitant la t�che 1
*								de l'algorithme	de Peterson.
*								Dans une premi�re phase, la fonction observera la seconde t�che
*								de l'algorithme et attendra que celle-ci soit pr�te. Si celle-ci
*								n'est pas encore pr�te, nous entrerons dans une boucle en
*								attendant le feu vert de l'autre t�che, se qui sera fait �
*								l'aide de la variable readyTask0_algoPeterson.
*								Une fois les deux t�che pr�tes, nous commen�ons l'algorithme et
*								r�cup�rons le temps de d�but de celui-ci pour la t�che en cours.
*								Lorsque l'algorithme est termin�, nous r�cup�rons le temps de 
*								fin de celui-ci, que nous stockons dans end_algoPeterson.
*								Cette variable est identique pour les deux t�ches car nous 
*								avons uniquement besoin du temps de la t�che finissant 
*								l'algorithme en dernier.
*
* Param�tre(s): arg : pointeur pass� � la fonction.
*										  Il est inutilis�, mais permet � la fonction de 
*											correspondre au prototype n�cessaire pour que celle-ci
*											puisse �tre utilis�e par un thread.
*
*/
void *algoPeterson_T1(void *arg)
{
 		 /* partie permettant la synchronisation des deux t�ches de l'algorithme*/
 		 readyTask1_algoPeterson = true;
 		 while (!readyTask0_algoPeterson){
		 			 ;
		 }
		 /* fin synchronisation*/
	
		 /* r�cup�re le temps de d�but de l'algorithme pour cette t�che */
		 start_tache1_algoPeterson = clock();
	
		 /* d�but de l'algorithme de Peterson */
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
* But         : Fonction principale qui a pour but de tester les diff�rents
*								algorithmes d'exclusion mutuelle. 
*								Pour chaque algorithme deux threads sont cr��s et ex�cut�s, 
*								un pour chaque t�che.
*								Apr�s l'ex�cution de chaque algorithme, nous calculons le temps
*								qu'il a fallu aux t�ches pour s'ex�cut�, et affichons celui-ci.
*
* R�sultat: EXIT_SUCCESS : int qui indique si le programme s'est termin� de 
*						mani�re correct ou non.
*/
int main()
{

	  /* Gestion de l'algorithme 2.2 du cours */
	  /*--------------------------------------*/
	  
	  	printf("Algorithme 2.2 du cours\n");
	  	printf("------------------------\n");
			
			/* d�claration des threads */
			pthread_t tache0_Algo1, tache1_Algo1;
			
			/* cr�ation des threads */
			pthread_create(&tache0_Algo1,NULL,algo1_T0,NULL);
			pthread_create(&tache1_Algo1,NULL,algo1_T1,NULL);
			
			/* attend que les deux t�ches se terminent */
			pthread_join(tache0_Algo1, NULL);
			pthread_join(tache1_Algo1, NULL);
			
			/* temps utile entre le d�but de la premi�re t�che et la fin de la derni�re */
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
			
			/* d�claration des threads */
			pthread_t tache0_AlgoDekker, tache1_AlgoDekker;
			
			/* attend que les deux t�ches se terminent */
			pthread_create(&tache0_AlgoDekker,NULL,algoDekker_T0,NULL);
			pthread_create(&tache1_AlgoDekker,NULL,algoDekker_T1,NULL);
			
			
			pthread_join(tache0_AlgoDekker, NULL);
			pthread_join(tache1_AlgoDekker, NULL);
			
			/* temps utile entre le d�but de la premi�re t�che et la fin de la derni�re */
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
				
			/* d�claration des threads */
			pthread_t tache0_AlgoPeterson, tache1_AlgoPeterson;
			
			/* cr�ation des threads */
			pthread_create(&tache0_AlgoPeterson,NULL,algoPeterson_T0,NULL);
			pthread_create(&tache1_AlgoPeterson,NULL,algoPeterson_T1,NULL);
			
			/* attend que les deux t�ches se terminent */
			pthread_join(tache0_AlgoPeterson, NULL);
			pthread_join(tache1_AlgoPeterson, NULL);
			
			/* temps utile entre le d�but de la premi�re t�che et la fin de la derni�re */
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
