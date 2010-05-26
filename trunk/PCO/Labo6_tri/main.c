/**\file main.c
 * \author Steve Lienhard et Arnaud Burkhalter
 * \date 25.04.2010
 * \version 1.0
 * \section Description
 *	Ce fichier met en place un programme de tri multithreadé basé sur
 *	l'algorithme de tri Bulles.
 */

/** \mainpage Tri Multithreadé
 * 	Cette documentation décrit le programme Tri Multithreadé qui doit
 *	permettre le tri d'un tableau réparti en plusieurs tâches.
 * 	Cela a été mis en place dans le laboratoire n°6 du cours PCO.
 *
 * \section Introduction
 *	Le but de ce programme est la réalisation d'un programme permettant
 *	le tri d'un tableau à l'aide de plusieurs threads.
 *	Pour ce faire, le tableau doit être divisé en différentes zones, et chacune
 *	de ces zones va être triée par un thread. Entre chaque zones existe une
 *	cellule commune aux deux zones adjacentes.
 *	La principale difficulté consiste en la gestion de ces cellules communes.
 *
 *	Afin de réaliser le tri, l'algorithme de tri à bulles sera utilisé.
 *	De plus, les informations concernant la taille du tableau ainsi que du
 *	nombre de threads doivent être insérées par l'utilisateur.
 *
 * \section Réalisation
 *	Les différentes étapes nécessaires à la réalisation de notre programme,
 *	ainsi que la manière dont celles-ci ont été implémentées vont être
 *	expliquées dans la section à venir.
 *
 *	Afin d'aboutir aux résultats souhaités dans ce projet, nous avons tout
 *	d'abord dû créer un tableau contenant des valeurs aléatoires. Pour ce faire
 *	nous avons déclaré un pointeur sur int, se qui nous permet de déclarer un
 *	tableau de taille variable et ainsi laisser l'utilisateur entrer la taille
 *	du tableau souhaité. La même démarche a été réalisée pour définir le nombre
 *	de threads.
 *	Une fois la taille du tableau définie, nous avons rempli les cellules de
 *	celui-ci de manière aléatoire à l'aide de la fonction rand().
 *
 *	Dès le tableau peuplé, la première difficulté que nous avons rencontrée à
 *	consisté à délimiter et définir la taille de zone attribuée à chaque thread.
 *	Pour ce faire, nous avons effectué les calculs suivants:
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
 *	Une fois le tableau rempli et les zones attribuées aux threads, nous avons
 *	attaqué la réalisation du tri à proprement parlé. Pour ce faire nous avons
 *	crée une fonction, nommé tache_tri(), et qui sera effectuée par chacun des
 *	threads afin de trier sa partie du tableau.
 *	Cette fonction permet à chaque thread de gérer sa partie du tableau. Chaque
 *	partie est triée à l'aide de l'algorithme de tri bulle. Lorsqu'un thread
 *	arrive à l'une ou l'autre de ses cellules communes à un autre thread
 *	(cellules critiques), celui-ci prend le mutex sur cette cellule avant de la
 *	traiter, afin d'assurer l'exclusion mutuelle.
 *	Lorsqu'un thread a terminé le tri de sa partie, il se met en attente et
 *	sera réveillé par un autre thread, si celui-ci a modifié la valeur se
 *	trouvant dans la cellule commune.
 *	Chaque thread travaille de la manière jusqu'à ce que le tri soit terminé, se
 *	qui sera le cas lorsque la dernière partie sera triée et donc que tous les
 *	threads seront en attentes.
 *
 *	Finalement pour nous assurer que le tri a correctement eu lieu, nous
 *	affichons le tableau final à l'aide de la fonction afficherTableau().
 *
 *
 * \section Tests
 * Afin de tester que le cahier des charges est respecté nous avant réalisé les
 * tests suivants:
 *
 *	\subsection test_1
 *	Le premier test à consisté à tester que l'utilisateur ne peux pas introduire
 *	un nombre de thread supérieur au nombre de cellules dans le tableau.
 *
 *	Résultat: Il est redemandé à l'utilisateur d'effectuer sa saisie tant que
 *	les valeurs ne sont pas cohérentes, se qui correspond à nos désires.
 *
 *	\subsection test_2
 *	Le deuxième test à consisté à contrôler que la séparation du tableau en
 *	différentes zones se fasse de manière correcte.
 *	Pour tester cela, nous avons affiché notre tableau d'indices et avons
 *	vérifié que la taille des zones soit correcte.
 *
 *	Résultat: La taille des zones est correcte, à savoir une variance du nombre
 *	de cellule de un au maximum.
 *
 *
 *	\subsection test_3
 *	Ce test à consisté à tester que le tri du tableau se fasse de manière
 *	correcte et cela avec des tailles de tableau différents ainsi qu'avec des
 *	nombres de thread petit ou grand.
 *	Pour tester cela, nous avons testé le tri de tableaux de plus en plus grand
 *	et avons utilisé des nombres de threads variables.
 *
 *	Résultat: Le tri du tableau se fait de manière correcte lors du tri de
 *	tableaux de petites tailles à taille moyenne, cependant lors du tri de
 *	tableaux de grandes tailles ou ayant un nombre important de threads, le
 *	tri ne s'effectue pas et le programme reste bloqué. (voir section Bugs)
 *
 *
 *  \section Bugs
 * Notre programme contient toujours un objectif qui ne fonctionne pas
 * parfaitement, dans le fait qu'il arrive lors de tri de tableaux de grande
 * taille ou ayant un nombre important de threads, que notre programme ne
 * termine pas le tri des cellules et se bloque en cours d'exécution.
 *
 *
 *\section Mesures
 * Comme demandé pour le laboratoire, nous avons mis en place un chronomètre
 * permettant de mesurer le temps nécessaire pour trier un tableau à l'aide
 * de l'algorithme multithreads que nous avons mis en place ainsi qu'à l'aide
 * d'un simple tri bulle.
 *
 * \subsection Comparaison
 * La comparaison des différents temps nécessaires pour le tri de tableaux nous
 * montre clairement que le tri multithreadé que nous avons mis en place
 * nécessite plus de temps que la variante du simple tri bulle.
 * Cela doit venir du fait que notre prise de temps pour le tri multithreadé
 * englobe et comprend la création des threads, se qui nécessite passablement de
 * temps. De plus l'attente des différents threads sur les mutex coûte aussi du
 * temps.
 *
 */


#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <time.h>
#include <stdbool.h>

/** Tableau contenant les nombres à trier */
int * tableau1;

/** Copie du tableau contenant les nombres à trier */
int * tableau2;

/** Tableau qui contient les indices des différentes zones du tableau principal */
int * tableau_indices;

/** Tableau qui contient les threads qui trient le tableau principal */
pthread_t * tableau_threads;

/** Constante qui représente le nombre de threads qui vont trier le tableau */
int NB_THREADS;

/** Constante qui représente la taille du tableau */
int TAILLE_TABLEAU;

/** Bool indiquant si la saisie de l'utilisateur est correcte ou non */
bool saisieOK = false;

/** Tableau indiquant si le thread i est trié */
bool * threadTrie;

/** Tableau indiquand si le thread i est en attente */
bool * estEnAttente;

/** Mutex garantissant l'exlusion mutuelle quand deux threads veulent accéder à
 * une seule case */
pthread_mutex_t * mutex;

/** Mutex qui permet d'attendre la fin du tri */
pthread_mutex_t * threadAttente;

/** Mutex qui permet de modifier nbAttente */
pthread_mutex_t mutex_attente;

/** nb de threads en attente */
int nbAttente = 0;

/** Temps processeur auquel le tri avec threads démarre */
clock_t debut_tri_threads;

/** Temps processeur auquel le tri avec threads s'arrête */
clock_t fin_tri_threads;

/** Temps processeur auquel le tri sans thread démarre */
clock_t debut_tri_normal;

/** Temps processeur auquel le tri sans thread s'arrête */
clock_t fin_tri_normal;

/** Temp d'exécution pour le tri avec thread */
double temps_threads;

/** Temps d'exécution du simple tri bulle */
double temps_sans_thread;


/**
* But : Le but de cette fonction est d'effectuer la saisie de valeurs au clavier
* 		par l'utilisateur.
* 		Il est demandé à l'utilisateur d'introduire le nombre de cellules que va
* 		devoir contenir le tableau, ainsi que du nombre de threads nécessaire
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
* But : Cette fonction a pour but de peupler un tableau de valeur aléatoire.
* 		Les valeurs sont générées aléatoirement dans un intervalle de 0 à 100.
*
* Paramètre(s): tab : 	pointeur sur int passé à  la fonction.
*						Ce pointeur fait référence au tableau de valeurs
*						entières qu'il faut remplir aléatoirement.
*				length:	Valeur de type entière indiquant la dimension du tableau.
*/
void remplirTableau(int *tab,int length){
	int i;
	for(i=length-1;i>0;i--){
		tab[i]= rand() % 100;
	}
}


/**
* But : Le but de cette fonction est d'afficher le contenu d'un tableau passé
* 		en paramètre.
*
* Paramètre(s): tab : 	pointeur sur int passé à  la fonction.
*						Ce pointeur fait référence au tableau de valeurs
*						entières qu'il faut afficher.
*				length:	Valeur de type entière indiquant la dimension du tableau.
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
* Paramètre(s): tab : 	pointeur sur int passé à  la fonction.
*						Ce pointeur fait référence au tableau de valeurs
*						entières qu'il trier.
*				length :Valeur de type entière indiquant la dimension du tableau.
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
* But : Le but de cette fonction est de contrôler que le tri d'un tableau a
* 		correctement été effectué.
*
* Paramètre(s): tab : 	pointeur sur int passé à  la fonction.
*						Ce pointeur fait référence au tableau que l'on souhaite
*						tester.
*				length :Valeur de type entière indiquant la dimension du tableau.
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
* But : Le but de cette fonction est de définir la zone d'action de chaque
* 		thread, en d'autre termes d'attribuer un certain nombre de cellules à
* 		chaque thread prenant part au tri du tableau.
* 		Ces valeurs d'indices sont stockées dans la variable tableau_indices.
*
* Paramètre(s): tab : 	pointeur sur int passé à  la fonction.
*						Ce pointeur fait référence au tableau de valeur entières
*						qu'il va falloir trier.
*				length:	Valeur de type entière indiquant la dimension du tableau.
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
* But : Cette fonction permet de permuter les valeurs de deux cellules passées
* 		en paramètre.
*
* Paramètre(s): element_1 : élément de type int dont on souhaite affecter la
* 							valeur à element_2.
* 				element_2 : élément de type int dont on souhaite affecter la
* 							valeur à element_1.
*/
void permuter(int * element_1, int * element_2)
{
	int temp = *element_1;
	*element_1 = *element_2;
	*element_2 = temp;
}


/**
* But : Fonction qui sera exécutée par un thread traitant le tri d'une certaine
* 		zone du tableau.
*
*
* Paramètre(s): arg : pointeur passé à la fonction.
*					Il est utilisé dans notre fonction pour passer le numéro
*					du thread. Il nous est donc utile pour associer un thread à
*					l'une des zones du tableau.
*/
void *Tache_tri(void *arg){
	int numero_thread = (int)arg;
	int index_debut = tableau_indices[numero_thread*2];
	int index_fin = tableau_indices[numero_thread*2+1];
	int temp;
	int i, j;

	// Tant que le tableau n'est pas complétement trié
	while(!threadTrie[numero_thread])
	{
		threadTrie[numero_thread] = true;

		for(i = index_fin; i > index_debut; i--)
		{
			// Si on est sur la case de droite et qu'elle
			// a une case partagée on prend le verrou sur cette case
			if(i == index_fin && numero_thread < NB_THREADS - 1)
			{
				pthread_mutex_lock(&mutex[numero_thread]);
			}

			for(j = index_debut; j < i; j++)
			{
				// Si on se trouve sur la case de gauche et qu'elle a
				// une case partagée on prend le verrou sur cette case
				if(j == index_debut && numero_thread > 0)
				{
					pthread_mutex_lock(&mutex[numero_thread - 1]);
				}

				if(tableau1[j] > tableau1[i])
				{
					permuter(&tableau1[i],&tableau1[j]);

					// Si on a changé une valeur dans une case critique,
					// on réveille le thread pour qu'il retrie sa partie
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
				// et qu'elle est partagée, on libère le mutex
				if(j == index_debut && numero_thread > 0)
				{
					pthread_mutex_unlock(&mutex[numero_thread - 1]);
				}

			}

			// Si on se trouve sur la case de droite de la zone du thread
			// et qu'elle est partagée, on libère le mutex
			if(i == index_fin && numero_thread < NB_THREADS - 1)
			{
				pthread_mutex_unlock(&mutex[numero_thread]);
			}

		}


		// Si c'est le thread qui a sa section critique à gauche,
		// on prend le verrou
		if(numero_thread > 0)
		{
			pthread_mutex_lock(&mutex[numero_thread - 1]);
		}

		// Si c'est le thread qui a sa section critique à droite
		// on prend le verrou
		if(numero_thread < NB_THREADS - 1)
		{
			pthread_mutex_lock(&mutex[numero_thread]);
		}

		// Si la zone est trié, le thread se met en attente
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
* But : Le but de cette fonction consiste à allouer l'espace mémoire nécessaire
* 		aux variables dynamiques utilisées dans notre programme.
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
* But : Comme son nom l'indique, cette fonction à pour objectif d'initialiser
* 		les mutex utilisés par les différents threads afin d'assurer l'exclusion
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
* But : Cette fonction a pour but de restituer l'espace mémoire qui a
* 		précédemment été alloué à l'aide de malloc.
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
* But : Cette fonction permet de créer un nombre de threads équivalent au
* 		nombre de threads souhaité par l'utilisateur.
*/
void creationThreads()
{
	int i;
	// Création des threads de tri
	for(i = 0; i < NB_THREADS; i++){
		if(pthread_create(&tableau_threads[i],NULL,Tache_tri,(void*)i)!=0){
			printf("Erreur: pthread_create client");
			exit(1);
		}
	}
}


/**
* But : Cette fonction effectue un join sur chaque thread afin que le programme
* 		ne se termine pas avant que tous les threads aient fini leur tâche.
*/
void attenteFinThreads()
{
	int i;
	// On attend que tous les threads ait terminé
	for(i = 0; i < NB_THREADS; i++)
	{
		pthread_join(tableau_threads[i],NULL);
	}
}


/**
* But : Le but de cette fonction est de retourner une copie du tableau passé en
* 		paramètre.
*
* Paramètre(s): tableau : pointeur sur int représentant le tableau que l'on
* 						souhaite copier.
* 				taille_tab : dimension du tableau passé en paramètre.
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
* But : Fonction principale permettant l'exécution du programme. Celle-ci fait
* 		appel aux autres fonctions précédemment implémentées.
*		Une valeur entière sera retournée, représentant si la fonction s'est
*		terminée de manière correct ou non.
*/
int main(void){

	// saisie des valeurs par l'utilisateur
	saisieClavier();

	allocationMemoire();
	initialisationMutex();

	remplirTableau(tableau1,TAILLE_TABLEAU);
	// copie du tableau qui sera utilisée pour le tri normal (non multithreadé)
	tableau2 = copierTableau(tableau1,TAILLE_TABLEAU);

	remplir_tableau_indices(tableau_indices,NB_THREADS*2);

	afficherTableau(tableau1,TAILLE_TABLEAU);

	// Tri du tableau (méthode threads) et calcul du temps
	debut_tri_threads = clock();
	creationThreads();
	attenteFinThreads();
	// Fin du calcul du temps
	fin_tri_threads = clock();
	temps_threads =((double)(fin_tri_threads - debut_tri_threads))/CLOCKS_PER_SEC;


	afficherTableau(tableau1,TAILLE_TABLEAU);

	// tester que le tableau est correctement trié
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

	// Tri du tableau (méthode normale) et calcul du temps
	debut_tri_normal = clock();
	BubbleSort(tableau2,TAILLE_TABLEAU);
	fin_tri_normal = clock();
	// calcul du temps nécessaire pour effectuer le tri normal
	temps_sans_thread = 
	              ((double)(fin_tri_normal - debut_tri_normal))/CLOCKS_PER_SEC;
	// Fin du calcul

	afficherTableau(tableau2,TAILLE_TABLEAU);

	// tester que le tableau est correctement trié
	if(test_BubbleSort(tableau2,TAILLE_TABLEAU))
	{
		printf("Le tableau est trie ! \n");
	}
	else
	{
		printf("Le tableau n'est pas trie ! \n");
	}
	printf("Temps d'execution : %f \n",temps_sans_thread);

	// libération de l'espace mémoire précédement allouée
	liberationMemoire();

	return 0;
}
