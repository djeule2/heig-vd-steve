
/**\file main.c
 * \author Steve Lienhard et Arnaud Burkhalter
 * \date 26.04.2010
 * \version 1.1
 * \section Description
 *	Ce fichier met en place des threads permettant la gestion de mani�re
 *	concurrente d'un barbier ainsi que de clients souhaitant se faire couper les
 *	cheveux ou se faire tatouer.
 */

/** \mainpage S�maphore
 * 	Cette documentation d�crit le programme Semaphore qui consiste � mettre sur
 *	pied un logiciel permettant la repr�sentation d'un barbier, de sa salle
 *	d'attente ainsi que des clients ayant recours aux services de celui-ci.
 * 	Cela a �t� mis en place dans le laboratoire n�5 du cours PCO.
 *
 * \section Introduction
 *
 *	Le but de ce programme est la r�alisation d'un programme permettant
 *	la simulation d'un salon de coiffure et tatouage. 
 *	Une salle d'attente pouvant contenir un certain nombre de clients doit �tre 
 *	mise en place. Lorsqu'un client se pr�sente et que la salle d'attente est 
 *	vide, ou contient encore des si�ges	non occup�s, le client prend place dans 
 *	la pi�ce. Dans le cas ou la salle	d'attente est pleine, le client va faire 
 *	un tour et revient tenter sa chance plus tard. 
 *	Diff�rentes sortes de clients sont pr�sents: les clients standard qui 
 *	souhaitent se faire couper les cheveux, et les clients souhaitons se faire
 *	tatouer. La deuxi�me cat�gorie de clients a priorit� sur la premi�re lorsque
 *	les clients se trouvent dans la salle d'attente.
 *	Le barbier quant � lui doit couper les cheveux ou tatouer des
 *	clients, les uns apr�s les autres. Dans le cas ou il n'est pas entrain de
 *	s'occuper de l'un des clients et que la salle d'attente est vide, il
 *	s'endort et sera r�veill� par le prochain client � entrer dans la salle
 *	d'attente.
 *
 * \section R�alisation
 *
 *	La r�alisation de notre programme, a n�cessit� l'impl�mentation de plusieurs
 *	fonctions qui vont �tre d�crites ci-dessous:
 *
 *	Une premi�re fonction 'saisieClavier()' nous permet d'effectuer les saisies
 *	utilisateur, c'est � dire le nombre de client ainsi que le nombre de place
 * 	dans la salle d'attente du barbier.
 *
 *	Une seconde fonction, nomm�e 'Client()' a �t� impl�ment�e afin de
 *	repr�senter les clients. Cette fonction sera ex�cut�e par des threads
 *	repr�sentant chacun un client. Le nombre de clients, de part la m�me
 *	occasion, de threads utilisant cette fonction est nombre variable
 *	d�pendant de la saisie utilisateur. Chaque client aura le comportement
 *	suivant: ses cheveux poussent; une fois cela fait il se rend chez le barbier
 *	et entre dans la salle d'attente. Si la salle d'attente est vide, et donc
 *	que le barbier est entrain de dormir, il r�veil celui-ci et se fait couper
 *	les cheveux. S'il n'est pas le premier dans la salle d'attente et qu'il
 *	reste des places de libre, il prend un si�ge et attend son tour. Finalement
 *	dans le cas ou en arrivant il trouve la salle d'attente pleine, il ressort
 *	et retentera sa chance apr�s un laps de temps �quivalent � la moiti� du
 *	temps qu'il lui a fallu pour voir ses cheveux pousser.
 *
 *	La fonction suivante que nous avons du impl�menter 'Barbier()', permet de
 *	repr�senter le r�le que joue le barbier, et sera donc ex�cut�e uniquement
 *	par un thread. De part la fonction, le barbier effectue les actions
 *	suivantes:
 *	Il regarde si la salle d'attente comporte des clients qui sont pr�t � se
 *	faire couper les cheveux. Si c'est le cas, il prend le premier afin de lui
 *	couper les cheveux et d�cr�mente le nombre de personnes pr�sentes dans la
 *	salle. Au contraire, si la salle d'attente est vide, il s'endort jusqu'� ce
 *	qu'un client entre dans la salle et le r�veil. Cela a �t� r�alis� � l'aide
 *	d'une variable booleen 'barbier_endormi', repr�sentant le fait que le
 *	barbier soit endormi ou non, ainsi que d'un s�maphore 'barbierDort'. 
 *
 *	Une autre fonction concernant les clients a �t� ajout�e 'client_tatoue()', 
 *	afin de traiter le cas des clients souhaitant se faire tatouer. 
 *	Cette fonction sera effectu�e par les threads simulant le r�le des clients
 *	se pr�sentant dans la salle d'attente dans le but de se faire tatouer. Pour 
 *	cela nous avons ajout� une s�maphore 'clientTatoue' qui permet � un client
 *	de cette cat�gorie de se faire tatouer � la fois. De plus une variable de 
 *	type int a �t� ajouter au programme afin de compter le nombre de clients de
 *	se type pr�sents dans la salle d'attente. Valeur qui nous sera utile au
 *	barbier.
 *
 * \section Tests
 *
 * Afin de tester que le cahier des charges est respect� et que notre simulateur
 *	de salon de coiffure/tatouage s'op�re de mani�re correcte, nous avons tout 
 *	d'abord	effectu� des simulations avec de petits nombres de clients puis 
 *	avons au fur et � mesure des tests, augment� le nombre de clients pr�sents 
 *	dans la	simulation. 
 *	Pour chacune de ces phases de tests, nous avons contr�l� la	coh�rence des 
 *	r�sultats obtenu.
 *	Pour chacun des tests effectu�s, les r�sultats obtenus correspondaient aux
 *	valeurs souhait�es. Il est toutefois � noter que lorsqu'un client a fini de
 *	se faire couper les cheveux, le client suivant ne passera entre les mains du
 *	barbier qu'une fois que le client en cours ait laiss� la main � un autre 
 *	thread.
 *	
 */

#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <time.h>
#include <semaphore.h>
#include <stdbool.h>
#include <psleep.h>

/** Thread repr�sentant le barbier */
pthread_t barbier;
/** Variable de type int repr�sentant le nombre de clients dans le programme */
int nb_clients;
int nb_tatoues;

/** Variable de type int repr�sentant le nombre de place dans la salle d'attente */
int NB_SIEGES;
/** Variable de type int repr�sentant le nombre de client dans la salle d'attente */
int nb_clients_attente = 0;
/** Variable de type int indiquant le temps n�cessaire au barbier pour effectuer
		une coupe de cheveux */
int dureeCoupe = 10;

int nb_tatoues_attente = 0;

/** Variable de type bool permettant d'indiquer si le barbier est endormi */
bool barbier_endormi = false;

/** S�maphore permettant de faire endormir le barbier lorsque la salle d'attente
*	est vide */
sem_t barbierDort;

/** S�maphore permettant de repr�senter une liste des clients pr�sents dans la
* salle d'attente */
sem_t salleAttente;

/** sémaphore garantissant l'exclusion mutuelle entre les clients */
sem_t mutex;

/** sémaphore permettant de faire attendre le client pendant qu'il se fait
* couper les cheveux */
sem_t clientDort;


sem_t clientTatoue;


/** Tableau dynamique permettant de contenir un nombre variable de clients */
pthread_t *tabClients;


/** Tableau dynamique permettant de contenir un nombre variable de clients tatoues */
pthread_t *tabClients_tatoues;


/**
* But : Fonction qui sera ex�cut�e par un thread traitant un client.
*				Une boucle infini englobe les actions du client afin que celles-ci
*				soient ex�cut�es tant que le programme tourne.
*				A chaque itt�ration de la boucle, le client attend une dur�e de temps
*				al�atoire que ses cheveux poussent puis se rend chez le barbier.
*				Une deuxi�me boucle while permet au client de tenter �a chance chez le
*				barbier tant qu'il n'a pas r�ussi � obtenir une place dans la salle
*				attente.
*
* Param�tre(s): arg : pointeur pass� � la fonction.
*										  Il est inutilis�, mais permet � la fonction de
*											correspondre au prototype n�cessaire pour que celle-ci
*											puisse �tre utilis�e par un thread.
*
*/
void *Client(void *arg){
	// Temps de pousse des cheveux
	int dureePousse = rand() % 10 + 1;
	int numeroClient = (int)arg;

	while(true){
		printf("le client n° %d a les cheveux qui poussent\n",numeroClient);
		// Temps aléatoire pour la poussee des cheveux
		// Attente que les cheveux aient poussé
		sleep(dureePousse);
		sem_wait(&mutex);

		while(nb_clients_attente >= NB_SIEGES){
			printf("la salle d'attente est pleine, le client n° %d ressort\n",numeroClient);
			sem_post(&mutex);
			// Le client ressort et ressayera ensuite
			sleep(dureePousse/2);
			printf("Duree pousse : %d\n",dureePousse);
			sem_wait(&mutex);
		}

		// On vérrouille le mutex
		//sem_wait(&mutex);
		if(!barbier_endormi){
			printf("le client n° %d est entre dans la salle d'attente\n",numeroClient);
		}
		else {
			// On réveil le barbier
			printf("le client n° %d reveil le barbier\n",numeroClient);
			barbier_endormi = false;
			sem_post(&barbierDort);
		}
		nb_clients_attente++;
		sem_post(&mutex);
		sem_wait(&salleAttente);
		printf("le client n° %d est entrain de se faire couper les cheveux\n",numeroClient);
		sem_wait(&clientDort);
		printf("le client n° %d a fini de se faire couper les cheveux\n",numeroClient);
	}
}


/**
* But : Fonction qui sera ex�cut�e par un thread traitant un client souhaitant
*				se faire tatouer.
*				Une boucle infini englobe les actions du client afin que celles-ci
*				soient ex�cut�es tant que le programme tourne.
*				A chaque itt�ration de la boucle, le client attend une dur�e de temps
*				al�atoire que une nouvelle id�e de tatouage lui vienne � l'esprit, puis
*				se rend chez le barbier.
*				Une deuxi�me boucle while permet au client de tenter �a chance chez le
*				barbier tant qu'il n'a pas r�ussi � obtenir une place dans la salle
*				attente.
*
* Param�tre(s): arg : pointeur pass� � la fonction.
*										  Il est utilis� dans notre fonction pour passer le num�ro
*											du client. Celui-ci nous est utile pour l'affichage.
*
*/
void *Client_tatoue(void *arg){
	// Temps de pousse des cheveux
	int dureeAttente = rand() % 30 + 1;
	int numeroClient = 10+(int)arg;

	while(true){
			printf("le tatoue n° %d réfléchi à un nouveau tatouage\n",numeroClient);
			// Temps aléatoire pour la poussee des cheveux
			// Attente que les cheveux aient poussé
			sleep(dureeAttente);

		while(nb_clients_attente >= NB_SIEGES){
			printf("la salle d'attente est pleine, le tatoue n° %d ressort\n",numeroClient);
			sem_post(&mutex);
			// Le client ressort et ressayera ensuite
			sleep(dureeAttente/2);
		}

		// On vérrouille le mutex
		sem_wait(&mutex);
		if(!barbier_endormi){
			printf("le client n° %d est entre dans la salle d'attente\n",numeroClient);
		}
		else {
			// On réveil le barbier
			printf("le tatoue n° %d reveil le barbier\n",numeroClient);
			barbier_endormi = false;
			sem_post(&barbierDort);
		}
		nb_clients_attente++;
		nb_tatoues_attente++;
		sem_post(&mutex);
		sem_wait(&clientTatoue);
		printf("le tatoue n° %d est entrain de se faire tatoue\n",numeroClient);
		sem_wait(&clientDort);
		printf("le tatoue n° %d a fini de se faire tatouer\n",numeroClient);
	}
}



/**
* But : Fonction qui sera ex�cut�e par un thread traitant le barbier.
*				Une boucle infini englobe les actions du barbier afin que celles-ci
*				soient ex�cut�es tant que le programme tourne.
*				A chaque itt�ration de la boucle, le barbier va observer si au moins un
*				client est pr�sent dans la salle d'attente. Si c'est le cas, il lui
*				coupe les cheveux, si ce n'est pas le cas, le barbier s'endors et attend
*				que le prochain client le r�veil � l'aide de la s�maphore 'barbierDors'.
*
* Param�tre(s): arg : pointeur pass� � la fonction.
*										  Il est inutilis�, mais permet � la fonction de
*											correspondre au prototype n�cessaire pour que celle-ci
*											puisse �tre utilis�e par un thread.
*
*/
void *Barbier(void *arg){
	while(true){
		sem_wait(&mutex);
		sem_post(&clientDort);
		if(nb_tatoues_attente){
			sem_post(&clientTatoue);
			nb_tatoues_attente--;
			nb_clients_attente--;
			sem_post(&mutex);
			// Il tatoue le client
			sleep(dureeCoupe);
			//sem_post(&clientDort);
		}
		else if(nb_clients_attente){
			// le barbier prend le client en attente sur la salle barbier
			sem_post(&salleAttente);
			// le client sort de la salle d'attente pour aller chez le barbier
			nb_clients_attente--;
			sem_post(&mutex);
			// Il coupe les cheveux du client
			sleep(dureeCoupe);
			//sem_post(&clientDort);
		}
		else{
			barbier_endormi = true;
			printf("le barbier dort\n");
			sem_post(&mutex);
			// le barbier s'endort
			sem_wait(&barbierDort);
		}
	}
}

/**
* But : Fonction permettant la saisie de valeurs au clavier par l'utilisateur.
*				Le nombre de si�ges dans la salle d'attente ainsi que le nombre de 
*				clients standards et clients � tatouer sont demand� � l'utilisateur.
*				Les traitements sur les variables sont directement effectu�s � 
*				l'int�rieur de la fonction.
*
* Param�tre(s): aucun
*
*/
void saisieClavier(){
	printf("Saisir le nb de clients : ");
	scanf("%d",&nb_clients);
	tabClients = malloc(nb_clients*sizeof(pthread_t));

	printf("Saisir le nb de tatoues : ");
	scanf("%d",&nb_tatoues);
	tabClients_tatoues = malloc(nb_tatoues*sizeof(pthread_t));


	printf("\n \n Saisir la taille de la salle d'attente : ");
	scanf("%d",&NB_SIEGES);
}

/**
* But : Fonction principale permettant l'initialisation des s�maphores et la
*				cr�ation des threads.
*				Une valeur enti�re sera retourn�e, repr�sentant si la fonction s'est
*				termin�e de mani�re correct ou non.
*
*/
int main(void){

	// Saisie du nb de clients et de la taille de la salle d'attente
	saisieClavier();

	// Initialisation des différents sémaphores à leurs valeurs respectives
	sem_init(&mutex,0,1);
	sem_init(&barbierDort,0,0);
	sem_init(&salleAttente,0,0);
	sem_init(&clientDort,0,0);

	// Création du thread barbier
	if (pthread_create(&barbier,NULL,Barbier,NULL)!=0){
		printf("Erreur: pthread_create barbier");
		exit(1);
	}

	// remplissage du tableau de thread avec le nb de clients
	// entré par l'utilisateur
	int i;
	// Création des threads client
	for(i=0;i<nb_clients;i++){
		if(pthread_create(&(tabClients[i]),NULL,Client,i)!=0){
			printf("Erreur: pthread_create client");
			exit(1);
		}
	}

	// Création des threads tatoues
	for(i=0;i<nb_tatoues;i++){
		if(pthread_create(&(tabClients_tatoues[i]),NULL,Client_tatoue,i)!=0){
			printf("Erreur: pthread_create client_tatoue");
			exit(1);
		}
	}


	for(i=0; i<nb_clients;i++){
		pthread_join(tabClients[i],NULL);
		pthread_join(tabClients_tatoues[i],NULL);
	}

	pthread_join(barbier,NULL);

	return 0;
}

