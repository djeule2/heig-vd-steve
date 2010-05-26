/**\file main.c
 * \author Steve Lienhard et Arnaud Burkhalter
 * \date 25.04.2010
 * \version 1.0
 * \section Description
 *	Ce fichier met en place un programme de tri multithread� bas� sur
 *	l'algorithme de tri Bulles.
 */

/** \mainpage Tri Multithread�
 * 	Cette documentation d�crit le programme Tri Multithread� qui doit
 *	permettre le tri d'un tableau r�parti en plusieurs t�ches.
 * 	Cela a �t� mis en place dans le laboratoire n�6 du cours PCO.
 *
 * \section Introduction
 *	Le but de ce programme est la r�alisation d'un programme permettant
 *	le tri d'un tableau � l'aide de plusieurs threads.
 *	Pour ce faire, le tableau doit �tre divis� en diff�rentes zones, et chacune
 *	de ces zones va �tre tri�e par un thread. Entre chaque zones existe une
 *	cellule commune aux deux zones adjacentes.
 *	La principale difficult� consiste en la gestion de ces cellules communes.
 *
 *	Afin de r�aliser le tri, l'algorithme de tri � bulles sera utilis�.
 *	De plus, les informations concernant la taille du tableau ainsi que du
 *	nombre de threads doivent �tre ins�r�es par l'utilisateur.
 *
 * \section R�alisation
 *	Les diff�rentes �tapes n�cessaires � la r�alisation de notre programme,
 *	ainsi que la mani�re dont celles-ci ont �t� impl�ment�es vont �tre
 *	expliqu�es dans la section � venir.
 *
 *	Afin d'aboutir aux r�sultats souhait�s dans ce projet, nous avons tout
 *	d'abord d� cr�er un tableau contenant des valeurs al�atoires. Pour ce faire
 *	nous avons d�clar� un pointeur sur int, se qui nous permet de d�clarer un
 *	tableau de taille variable et ainsi laisser l'utilisateur entrer la taille
 *	du tableau souhait�. La m�me d�marche a �t� r�alis�e pour d�finir le nombre
 *	de threads.
 *	Une fois la taille du tableau d�finie, nous avons rempli les cellules de
 *	celui-ci de mani�re al�atoire � l'aide de la fonction rand().
 *
 *	D�s le tableau peupl�, la premi�re difficult� que nous avons rencontr�e �
 *	consist� � d�limiter et d�finir la taille de zone attribu�e � chaque thread.
 *	Pour ce faire, nous avons effectu� les calculs suivants:
 *
 *	tailleZone = (TailleTableau + (nbThreads - 1)) / nbTreads
 *
 *	Ce premier calcul nous permet d'obtenir la taille de base de chaque zone.
 *
 *	nbZoneSup = (tailleTableau + (nbThreads - 1)) % nbThreads
 *
 *	Ce second calcul nous permet d'obtenir le nombre de zone qui vont avoir
 *	une cellule en plus que la taille de base.
 *
 *	Une fois le tableau rempli et les zones attribu�es aux threads, nous avons
 *	attaqu� la r�alisation du tri � proprement parl�. Pour ce faire nous avons
 *	cr�e une fonction, nomm� tache_tri(), et qui sera effectu�e par chacun des
 *	threads afin de trier sa partie du tableau.
 *	Cette fonction permet � chaque thread de g�rer sa partie du tableau. Chaque
 *	partie est tri�e � l'aide de l'algorithme de tri bulle. Lorsqu'un thread
 *	arrive � l'une ou l'autre de ses cellules communes � un autre thread
 *	(cellules critiques), celui-ci prend le mutex sur cette cellule avant de la
 *	traiter, afin d'assurer l'exclusion mutuelle.
 *	Lorsqu'un thread a termin� le tri de sa partie, il se met en attente et
 *	sera r�veill� par un autre thread, si celui-ci a modifi� la valeur se
 *	trouvant dans la cellule commune.
 *	Chaque thread travaille de la mani�re jusqu'� ce que le tri soit termin�, se
 *	qui sera le cas lorsque la derni�re partie sera tri�e et donc que tous les
 *	threads seront en attentes.
 *
 *	Finalement pour nous assurer que le tri a correctement eu lieu, nous
 *	affichons le tableau final � l'aide de la fonction afficherTableau().
 *
 *
 * \section Tests
 * Afin de tester que le cahier des charges est respect� nous avant r�alis� les
 * tests suivants:
 *
 *	\subsection test_1
 *	Le premier test � consist� � tester que l'utilisateur ne peux pas introduire
 *	un nombre de thread sup�rieur au nombre de cellules dans le tableau.
 *
 *	R�sultat: Il est redemand� � l'utilisateur d'effectuer sa saisie tant que
 *	les valeurs ne sont pas coh�rentes, se qui correspond � nos d�sires.
 *
 *	\subsection test_2
 *	Le deuxi�me test � consist� � contr�ler que la s�paration du tableau en
 *	diff�rentes zones se fasse de mani�re correcte.
 *	Pour tester cela, nous avons affich� notre tableau d'indices et avons
 *	v�rifi� que la taille des zones soit correcte.
 *
 *	R�sultat: La taille des zones est correcte, � savoir une variance du nombre
 *	de cellule de un au maximum.
 *
 *
 *	\subsection test_3
 *	Ce test � consist� � tester que le tri du tableau se fasse de mani�re
 *	correcte et cela avec des tailles de tableau diff�rents ainsi qu'avec des
 *	nombres de thread petit ou grand.
 *	Pour tester cela, nous avons test� le tri de tableaux de plus en plus grand
 *	et avons utilis� des nombres de threads variables.
 *
 *	R�sultat: Le tri du tableau se fait de mani�re correcte lors du tri de
 *	tableaux de petites tailles � taille moyenne, cependant lors du tri de
 *	tableaux de grandes tailles ou ayant un nombre important de threads, le
 *	tri ne s'effectue pas et le programme reste bloqu�. (voir section Bugs)
 *
 *
 *  \section Bugs
 * Notre programme contient toujours un objectif qui ne fonctionne pas
 * parfaitement, dans le fait qu'il arrive lors de tri de tableaux de grande
 * taille ou ayant un nombre important de threads, que notre programme ne
 * termine pas le tri des cellules et se bloque en cours d'ex�cution.
 *
 *
 *\section Mesures
 * Comme demand� pour le laboratoire, nous avons mis en place un chronom�tre
 * permettant de mesurer le temps n�cessaire pour trier un tableau � l'aide
 * de l'algorithme multithreads que nous avons mis en place ainsi qu'� l'aide
 * d'un simple tri bulle.
 *
 * \subsection Comparaison
 * La comparaison des diff�rents temps n�cessaires pour le tri de tableaux nous
 * montre clairement que le tri multithread� que nous avons mis en place
 * n�cessite plus de temps que la variante du simple tri bulle.
 * Cela doit venir du fait que notre prise de temps pour le tri multithread�
 * englobe et comprend la cr�ation des threads, se qui n�cessite passablement de
 * temps. De plus l'attente des diff�rents threads sur les mutex co�te aussi du
 * temps.
 *
 */


#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <time.h>
#include <stdbool.h>

/** Tableau contenant les nombres � trier */
int * tableau1;

/** Copie du tableau contenant les nombres � trier */
int * tableau2;

/** Tableau qui contient les indices des diff�rentes zones du tableau principal */
int * tableau_indices;

/** Tableau qui contient les threads qui trient le tableau principal */
pthread_t * tableau_threads;

/** Constante qui repr�sente le nombre de threads qui vont trier le tableau */
int NB_THREADS;

/** Constante qui repr�sente la taille du tableau */
int TAILLE_TABLEAU;

/** Bool indiquant si la saisie de l'utilisateur est correcte ou non */
bool saisieOK = false;

/** Tableau indiquant si le thread i est tri� */
bool * threadTrie;

/** Tableau indiquand si le thread i est en attente */
bool * estEnAttente;

/** Mutex garantissant l'exlusion mutuelle quand deux threads veulent acc�der �
 * une seule case */
pthread_mutex_t * mutex;

/** Mutex qui permet d'attendre la fin du tri */
pthread_mutex_t * threadAttente;

/** Mutex qui permet de modifier nbAttente */
pthread_mutex_t mutex_attente;

/** nb de threads en attente */
int nbAttente = 0;

/** Temps processeur auquel le tri avec threads d�marre */
clock_t debut_tri_threads;

/** Temps processeur auquel le tri avec threads s'arr�te */
clock_t fin_tri_threads;

/** Temps processeur auquel le tri sans thread d�marre */
clock_t debut_tri_normal;

/** Temps processeur auquel le tri sans thread s'arr�te */
clock_t fin_tri_normal;

/** Temp d'ex�cution pour le tri avec thread */
double temps_threads;

/** Temps d'ex�cution du simple tri bulle */
double temps_sans_thread;


/**
* But : Le but de cette fonction est d'effectuer la saisie de valeurs au clavier
* 		par l'utilisateur.
* 		Il est demand� � l'utilisateur d'introduire le nombre de cellules que va
* 		devoir contenir le tableau, ainsi que du nombre de threads n�cessaire
* 		pour traiter celui-ci.
*/
void saisieClavier(){
	printf("Saisir la taille du tableau : ");
	scanf("%d",&TAILLE_TABLEAU);

	while(saisieOK == false){
		printf("Saisir le nombre de threads : ");
		scanf("%d",&NB_THREADS);
		if(NB_THREADS > TAILLE_TABLEAU){
			printf("Erreur, le nombre de threads que vous avez defini est"
					"plus grand que la taille du tableau");
		}
		else{
			saisieOK = true;
		}
	}
}


/**
* But : Cette fonction a pour but de peupler un tableau de valeur al�atoire.
* 		Les valeurs sont g�n�r�es al�atoirement dans un intervalle de 0 � 100.
*
* Param�tre(s): tab : 	pointeur sur int pass� � la fonction.
*						Ce pointeur fait r�f�rence au tableau de valeurs
*						enti�res qu'il faut remplir al�atoirement.
*				length:	Valeur de type enti�re indiquant la dimension du tableau.
*/
void remplirTableau(int *tab,int length){
	int i;
	for(i=length-1;i>0;i--){
		tab[i]= rand() % 100;
	}
}


/**
* But : Le but de cette fonction est d'afficher le contenu d'un tableau pass�
* 		en param�tre.
*
* Param�tre(s): tab : 	pointeur sur int pass� � la fonction.
*						Ce pointeur fait r�f�rence au tableau de valeurs
*						enti�res qu'il faut afficher.
*				length:	Valeur de type enti�re indiquant la dimension du tableau.
*/
void afficherTableau(int *tab, int length){
	int i;
	for(i=0;i<length;i++){
		printf("%d",tab[i]);
		if(i != length - 1)
		{
			printf(" --- ");
		}
	}
	printf("\n");
}


/**
* But : cette fonction effectue le tri du tableau selon l'algorithme de tri
* 		bulle.
*
* Param�tre(s): tab : 	pointeur sur int pass� � la fonction.
*						Ce pointeur fait r�f�rence au tableau de valeurs
*						enti�res qu'il trier.
*				length :Valeur de type enti�re indiquant la dimension du tableau.
*/
void BubbleSort(int *tab, int length){
	int i;
	int j;
	int temp;
	for(i=0;i<length;i++){
		for(j=0;j<i;j++){
			if(tab[j]>tab[i]){
				temp=tab[j];
				tab[j]=tab[i];
				tab[i]=temp;
			}
		}
	}
}


/**
* But : Le but de cette fonction est de contr�ler que le tri d'un tableau a
* 		correctement �t� effectu�.
*
* Param�tre(s): tab : 	pointeur sur int pass� � la fonction.
*						Ce pointeur fait r�f�rence au tableau que l'on souhaite
*						tester.
*				length :Valeur de type enti�re indiquant la dimension du tableau.
*/
bool test_BubbleSort(int *tab, int length){
	int i;
	for(i=0;i<length-1;i++){
		if(tab[i] > tab[i+1]){
			return 0;
		}
	}
	return 1;
}


/**
* But : Le but de cette fonction est de d�finir la zone d'action de chaque
* 		thread, en d'autre termes d'attribuer un certain nombre de cellules �
* 		chaque thread prenant part au tri du tableau.
* 		Ces valeurs d'indices sont stock�es dans la variable tableau_indices.
*
* Param�tre(s): tab : 	pointeur sur int pass� � la fonction.
*						Ce pointeur fait r�f�rence au tableau de valeur enti�res
*						qu'il va falloir trier.
*				length:	Valeur de type enti�re indiquant la dimension du tableau.
*/
void remplir_tableau_indices(int *tab, int length){


	int tailleZone = (TAILLE_TABLEAU + (NB_THREADS - 1)) / NB_THREADS;
	int nbZoneSup = (TAILLE_TABLEAU + (NB_THREADS - 1)) % NB_THREADS;

	// On remplit le tableau d'indices en tenant compte de la taille des zones
	int i;
	for(i = 0; i < NB_THREADS; i++)
	{
		if(i < NB_THREADS - nbZoneSup)
		{
			tableau_indices[2*i] = i * (tailleZone - 1);
			tableau_indices[2*i + 1] = tableau_indices[2*i] + (tailleZone - 1);
		}
		else if (i == NB_THREADS - nbZoneSup)
		{
			tableau_indices[2*i] = i * (tailleZone - 1);
			tableau_indices[2*i + 1] = tableau_indices[2*i] + (tailleZone);
		}
		else
		{
			tableau_indices[2*i] =  tableau_indices[2*(i-1)+1];
			tableau_indices[2*i + 1] = tableau_indices[2*i] + (tailleZone);
		}
	}
}


/**
* But : Cette fonction permet de permuter les valeurs de deux cellules pass�es
* 		en param�tre.
*
* Param�tre(s): element_1 : �l�ment de type int dont on souhaite affecter la
* 							valeur � element_2.
* 				element_2 : �l�ment de type int dont on souhaite affecter la
* 							valeur � element_1.
*/
void permuter(int * element_1, int * element_2)
{
	int temp = *element_1;
	*element_1 = *element_2;
	*element_2 = temp;
}


/**
* But : Fonction qui sera ex�cut�e par un thread traitant le tri d'une certaine
* 		zone du tableau.
*
*
* Param�tre(s): arg : pointeur pass� � la fonction.
*					Il est utilis� dans notre fonction pour passer le num�ro
*					du thread. Il nous est donc utile pour associer un thread �
*					l'une des zones du tableau.
*/
void *Tache_tri(void *arg){
	int numero_thread = (int)arg;
	int index_debut = tableau_indices[numero_thread*2];
	int index_fin = tableau_indices[numero_thread*2+1];
	int temp;
	int i, j;

	// Tant que le tableau n'est pas compl�tement tri�
	while(!threadTrie[numero_thread])
	{
		threadTrie[numero_thread] = true;

		for(i = index_fin; i > index_debut; i--)
		{
			// Si on est sur la case de droite et qu'elle
			// a une case partag�e on prend le verrou sur cette case
			if(i == index_fin && numero_thread < NB_THREADS - 1)
			{
				pthread_mutex_lock(&mutex[numero_thread]);
			}

			for(j = index_debut; j < i; j++)
			{
				// Si on se trouve sur la case de gauche et qu'elle a
				// une case partag�e on prend le verrou sur cette case
				if(j == index_debut && numero_thread > 0)
				{
					pthread_mutex_lock(&mutex[numero_thread - 1]);
				}

				if(tableau1[j] > tableau1[i])
				{
					permuter(&tableau1[i],&tableau1[j]);

					// Si on a chang� une valeur dans une case critique,
					// on r�veille le thread pour qu'il retrie sa partie
					if(i == index_fin && numero_thread < NB_THREADS - 1)
					{
						threadTrie[numero_thread+1] = false;
						if(estEnAttente[numero_thread + 1])
						{
							pthread_mutex_lock(&mutex_attente);
							estEnAttente[numero_thread + 1] = false;
							nbAttente--;
							pthread_mutex_unlock(&threadAttente[numero_thread + 1]);
							pthread_mutex_unlock(&mutex_attente);
						}
					}

					if(j == index_debut && numero_thread > 0)
					{
						threadTrie[numero_thread - 1] = false;
						if(estEnAttente[numero_thread - 1])
						{
							pthread_mutex_lock(&mutex_attente);
							estEnAttente[numero_thread - 1]=false;
							nbAttente--;
							pthread_mutex_unlock(&threadAttente[numero_thread - 1]);
							pthread_mutex_unlock(&mutex_attente);
						}
					}

				}
				// Si on est sur la case de gauche de la zone du thread
				// et qu'elle est partag�e, on lib�re le mutex
				if(j == index_debut && numero_thread > 0)
				{
					pthread_mutex_unlock(&mutex[numero_thread - 1]);
				}

			}

			// Si on se trouve sur la case de droite de la zone du thread
			// et qu'elle est partag�e, on lib�re le mutex
			if(i == index_fin && numero_thread < NB_THREADS - 1)
			{
				pthread_mutex_unlock(&mutex[numero_thread]);
			}

		}


		// Si c'est le thread qui a sa section critique � gauche,
		// on prend le verrou
		if(numero_thread > 0)
		{
			pthread_mutex_lock(&mutex[numero_thread - 1]);
		}

		// Si c'est le thread qui a sa section critique � droite
		// on prend le verrou
		if(numero_thread < NB_THREADS - 1)
		{
			pthread_mutex_lock(&mutex[numero_thread]);
		}

		// Si la zone est tri�, le thread se met en attente
		//(sauf si c'est le dernier thread !)
		if(threadTrie[numero_thread])
		{
			pthread_mutex_lock(&mutex_attente);

			if(nbAttente == NB_THREADS - 1)
			{
				pthread_mutex_unlock(&mutex_attente);
				for(i = 0; i < NB_THREADS; i++)
				{
					pthread_mutex_unlock(&threadAttente[i]);
				}
			}
			else
			{
				nbAttente++;
				estEnAttente[numero_thread]=true;

				if(numero_thread > 0)
				{
					pthread_mutex_unlock(&mutex[numero_thread - 1]);
				}
				if(numero_thread < NB_THREADS - 1)
				{
					pthread_mutex_unlock(&mutex[numero_thread]);
				}

				pthread_mutex_unlock(&mutex_attente);
				pthread_mutex_lock(&threadAttente[numero_thread]);
			}
		}
		else
		{
			if(numero_thread > 0)
			{
				pthread_mutex_unlock(&mutex[numero_thread-1]);
			}

			if(numero_thread < NB_THREADS-1)
			{
				pthread_mutex_unlock(&mutex[numero_thread]);
			}
		}
	}
}


/**
* But : Le but de cette fonction consiste � allouer l'espace m�moire n�cessaire
* 		aux variables dynamiques utilis�es dans notre programme.
*/
void allocationMemoire()
{
	tableau1 = 			malloc(TAILLE_TABLEAU*sizeof(int));
	tableau_threads = 	malloc(NB_THREADS*sizeof(pthread_t));
	threadAttente = 	malloc(NB_THREADS*sizeof(pthread_mutex_t));
	mutex = 			malloc((NB_THREADS-1)*sizeof(pthread_mutex_t));
	tableau_indices = 	malloc(NB_THREADS*2*sizeof(int));
	threadTrie = 		malloc(NB_THREADS*sizeof(bool));
	estEnAttente = 		malloc(NB_THREADS*sizeof(bool));
}


/**
* But : Comme son nom l'indique, cette fonction � pour objectif d'initialiser
* 		les mutex utilis�s par les diff�rents threads afin d'assurer l'exclusion
* 		mutuel entre eux.
*/
void initialisationMutex()
{
	pthread_mutex_init(&mutex_attente,NULL);

	int i;

	for(i = 0; i < NB_THREADS; i++)
	{
		pthread_mutex_init(&threadAttente[i],NULL);
		pthread_mutex_lock(&threadAttente[i]);
		threadTrie[i]=false;
		estEnAttente[i]=false;
	}

	for(i = 0; i < NB_THREADS - 1; i++)
	{
		pthread_mutex_init(&mutex[i],NULL);
	}
}


/**
* But : Cette fonction a pour but de restituer l'espace m�moire qui a
* 		pr�c�demment �t� allou� � l'aide de malloc.
*/
void liberationMemoire()
{
	free(tableau1);
	free(tableau2);
	free(threadTrie);
	free(estEnAttente);
	free(threadAttente);
	free(mutex);
	free(tableau_threads);
}


/**
* But : Cette fonction permet de cr�er un nombre de threads �quivalent au
* 		nombre de threads souhait� par l'utilisateur.
*/
void creationThreads()
{
	int i;
	// Cr�ation des threads de tri
	for(i = 0; i < NB_THREADS; i++){
		if(pthread_create(&tableau_threads[i],NULL,Tache_tri,(void*)i)!=0){
			printf("Erreur: pthread_create client");
			exit(1);
		}
	}
}


/**
* But : Cette fonction effectue un join sur chaque thread afin que le programme
* 		ne se termine pas avant que tous les threads aient fini leur t�che.
*/
void attenteFinThreads()
{
	int i;
	// On attend que tous les threads ait termin�
	for(i = 0; i < NB_THREADS; i++)
	{
		pthread_join(tableau_threads[i],NULL);
	}
}


/**
* But : Le but de cette fonction est de retourner une copie du tableau pass� en
* 		param�tre.
*
* Param�tre(s): tableau : pointeur sur int repr�sentant le tableau que l'on
* 						souhaite copier.
* 				taille_tab : dimension du tableau pass� en param�tre.
*/
int * copierTableau(int * tableau, int TAILLE_TABLEAU)
{
	int i;
	int * nouveau_tableau = malloc(TAILLE_TABLEAU * sizeof(int));

	for(i = 0; i < TAILLE_TABLEAU; i++)
	{
		nouveau_tableau[i] = tableau[i];
	}

	return nouveau_tableau;
}



/**
* But : Fonction principale permettant l'ex�cution du programme. Celle-ci fait
* 		appel aux autres fonctions pr�c�demment impl�ment�es.
*		Une valeur enti�re sera retourn�e, repr�sentant si la fonction s'est
*		termin�e de mani�re correct ou non.
*/
int main(void){

	// saisie des valeurs par l'utilisateur
	saisieClavier();

	allocationMemoire();
	initialisationMutex();

	remplirTableau(tableau1,TAILLE_TABLEAU);
	// copie du tableau qui sera utilis�e pour le tri normal (non multithread�)
	tableau2 = copierTableau(tableau1,TAILLE_TABLEAU);

	remplir_tableau_indices(tableau_indices,NB_THREADS*2);

	afficherTableau(tableau1,TAILLE_TABLEAU);

	// Tri du tableau (m�thode threads) et calcul du temps
	debut_tri_threads = clock();
	creationThreads();
	attenteFinThreads();
	// Fin du calcul du temps
	fin_tri_threads = clock();
	temps_threads =((double)(fin_tri_threads - debut_tri_threads))/CLOCKS_PER_SEC;


	afficherTableau(tableau1,TAILLE_TABLEAU);

	// tester que le tableau est correctement tri�
	if(test_BubbleSort(tableau1,TAILLE_TABLEAU))
	{
		printf("Le tableau est trie ! \n");
	}
	else
	{
		printf("Le tableau n'est pas trie ! \n");
	}
	printf("Temps d'execution : %f \n",temps_threads);

	printf("Tri du tableau sans les threads : \n");
	afficherTableau(tableau2,TAILLE_TABLEAU);

	// Tri du tableau (m�thode normale) et calcul du temps
	debut_tri_normal = clock();
	BubbleSort(tableau2,TAILLE_TABLEAU);
	fin_tri_normal = clock();
	// calcul du temps n�cessaire pour effectuer le tri normal
	temps_sans_thread = 
	              ((double)(fin_tri_normal - debut_tri_normal))/CLOCKS_PER_SEC;
	// Fin du calcul

	afficherTableau(tableau2,TAILLE_TABLEAU);

	// tester que le tableau est correctement tri�
	if(test_BubbleSort(tableau2,TAILLE_TABLEAU))
	{
		printf("Le tableau est trie ! \n");
	}
	else
	{
		printf("Le tableau n'est pas trie ! \n");
	}
	printf("Temps d'execution : %f \n",temps_sans_thread);

	// lib�ration de l'espace m�moire pr�c�dement allou�e
	liberationMemoire();

	return 0;
}
