
/**\file main.c
 * \author Steve Lienhard et Arnaud Burkhalter
 * \date 26.04.2010
 * \version 1.1
 * \section Description
 *	Ce fichier met en place des threads permettant la gestion de manière
 *	concurrente d'un barbier ainsi que de clients souhaitant se faire couper les
 *	cheveux ou se faire tatouer.
 */

/** \mainpage Sémaphore
 * 	Cette documentation décrit le programme Semaphore qui consiste à mettre sur
 *	pied un logiciel permettant la représentation d'un barbier, de sa salle
 *	d'attente ainsi que des clients ayant recours aux services de celui-ci.
 * 	Cela a été mis en place dans le laboratoire n°5 du cours PCO.
 *
 * \section Introduction
 *
 *	Le but de ce programme est la réalisation d'un programme permettant
 *	la simulation d'un salon de coiffure et tatouage. 
 *	Une salle d'attente pouvant contenir un certain nombre de clients doit être 
 *	mise en place. Lorsqu'un client se présente et que la salle d'attente est 
 *	vide, ou contient encore des sièges	non occupés, le client prend place dans 
 *	la pièce. Dans le cas ou la salle	d'attente est pleine, le client va faire 
 *	un tour et revient tenter sa chance plus tard. 
 *	Différentes sortes de clients sont présents: les clients standard qui 
 *	souhaitent se faire couper les cheveux, et les clients souhaitons se faire
 *	tatouer. La deuxième catégorie de clients a priorité sur la première lorsque
 *	les clients se trouvent dans la salle d'attente.
 *	Le barbier quant à lui doit couper les cheveux ou tatouer des
 *	clients, les uns après les autres. Dans le cas ou il n'est pas entrain de
 *	s'occuper de l'un des clients et que la salle d'attente est vide, il
 *	s'endort et sera réveillé par le prochain client à entrer dans la salle
 *	d'attente.
 *
 * \section Réalisation
 *
 *	La réalisation de notre programme, a nécessité l'implémentation de plusieurs
 *	fonctions qui vont être décrites ci-dessous:
 *
 *	Une première fonction 'saisieClavier()' nous permet d'effectuer les saisies
 *	utilisateur, c'est à dire le nombre de client ainsi que le nombre de place
 * 	dans la salle d'attente du barbier.
 *
 *	Une seconde fonction, nommée 'Client()' a été implémentée afin de
 *	représenter les clients. Cette fonction sera exécutée par des threads
 *	représentant chacun un client. Le nombre de clients, de part la même
 *	occasion, de threads utilisant cette fonction est nombre variable
 *	dépendant de la saisie utilisateur. Chaque client aura le comportement
 *	suivant: ses cheveux poussent; une fois cela fait il se rend chez le barbier
 *	et entre dans la salle d'attente. Si la salle d'attente est vide, et donc
 *	que le barbier est entrain de dormir, il réveil celui-ci et se fait couper
 *	les cheveux. S'il n'est pas le premier dans la salle d'attente et qu'il
 *	reste des places de libre, il prend un siège et attend son tour. Finalement
 *	dans le cas ou en arrivant il trouve la salle d'attente pleine, il ressort
 *	et retentera sa chance après un laps de temps équivalent à la moitié du
 *	temps qu'il lui a fallu pour voir ses cheveux pousser.
 *
 *	La fonction suivante que nous avons du implémenter 'Barbier()', permet de
 *	représenter le rôle que joue le barbier, et sera donc exécutée uniquement
 *	par un thread. De part la fonction, le barbier effectue les actions
 *	suivantes:
 *	Il regarde si la salle d'attente comporte des clients qui sont prêt à se
 *	faire couper les cheveux. Si c'est le cas, il prend le premier afin de lui
 *	couper les cheveux et décrémente le nombre de personnes présentes dans la
 *	salle. Au contraire, si la salle d'attente est vide, il s'endort jusqu'à ce
 *	qu'un client entre dans la salle et le réveil. Cela a été réalisé à l'aide
 *	d'une variable booleen 'barbier_endormi', représentant le fait que le
 *	barbier soit endormi ou non, ainsi que d'un sémaphore 'barbierDort'. 
 *
 *	Une autre fonction concernant les clients a été ajoutée 'client_tatoue()', 
 *	afin de traiter le cas des clients souhaitant se faire tatouer. 
 *	Cette fonction sera effectuée par les threads simulant le rôle des clients
 *	se présentant dans la salle d'attente dans le but de se faire tatouer. Pour 
 *	cela nous avons ajouté une sémaphore 'clientTatoue' qui permet à un client
 *	de cette catégorie de se faire tatouer à la fois. De plus une variable de 
 *	type int a été ajouter au programme afin de compter le nombre de clients de
 *	se type présents dans la salle d'attente. Valeur qui nous sera utile au
 *	barbier.
 *
 * \section Tests
 *
 * Afin de tester que le cahier des charges est respecté et que notre simulateur
 *	de salon de coiffure/tatouage s'opère de manière correcte, nous avons tout 
 *	d'abord	effectué des simulations avec de petits nombres de clients puis 
 *	avons au fur et à mesure des tests, augmenté le nombre de clients présents 
 *	dans la	simulation. 
 *	Pour chacune de ces phases de tests, nous avons contrôlé la	cohérence des 
 *	résultats obtenu.
 *	Pour chacun des tests effectués, les résultats obtenus correspondaient aux
 *	valeurs souhaitées. Il est toutefois à noter que lorsqu'un client a fini de
 *	se faire couper les cheveux, le client suivant ne passera entre les mains du
 *	barbier qu'une fois que le client en cours ait laissé la main à un autre 
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

/** Thread reprï¿½sentant le barbier */
pthread_t barbier;
/** Variable de type int reprï¿½sentant le nombre de clients dans le programme */
int nb_clients;
int nb_tatoues;

/** Variable de type int reprï¿½sentant le nombre de place dans la salle d'attente */
int NB_SIEGES;
/** Variable de type int reprï¿½sentant le nombre de client dans la salle d'attente */
int nb_clients_attente = 0;
/** Variable de type int indiquant le temps nï¿½cessaire au barbier pour effectuer
		une coupe de cheveux */
int dureeCoupe = 10;

int nb_tatoues_attente = 0;

/** Variable de type bool permettant d'indiquer si le barbier est endormi */
bool barbier_endormi = false;

/** Sï¿½maphore permettant de faire endormir le barbier lorsque la salle d'attente
*	est vide */
sem_t barbierDort;

/** Sï¿½maphore permettant de reprï¿½senter une liste des clients prï¿½sents dans la
* salle d'attente */
sem_t salleAttente;

/** sÃ©maphore garantissant l'exclusion mutuelle entre les clients */
sem_t mutex;

/** sÃ©maphore permettant de faire attendre le client pendant qu'il se fait
* couper les cheveux */
sem_t clientDort;


sem_t clientTatoue;


/** Tableau dynamique permettant de contenir un nombre variable de clients */
pthread_t *tabClients;


/** Tableau dynamique permettant de contenir un nombre variable de clients tatoues */
pthread_t *tabClients_tatoues;


/**
* But : Fonction qui sera exï¿½cutï¿½e par un thread traitant un client.
*				Une boucle infini englobe les actions du client afin que celles-ci
*				soient exï¿½cutï¿½es tant que le programme tourne.
*				A chaque ittï¿½ration de la boucle, le client attend une durï¿½e de temps
*				alï¿½atoire que ses cheveux poussent puis se rend chez le barbier.
*				Une deuxiï¿½me boucle while permet au client de tenter ï¿½a chance chez le
*				barbier tant qu'il n'a pas rï¿½ussi ï¿½ obtenir une place dans la salle
*				attente.
*
* Paramï¿½tre(s): arg : pointeur passï¿½ ï¿½ la fonction.
*										  Il est inutilisï¿½, mais permet ï¿½ la fonction de
*											correspondre au prototype nï¿½cessaire pour que celle-ci
*											puisse ï¿½tre utilisï¿½e par un thread.
*
*/
void *Client(void *arg){
	// Temps de pousse des cheveux
	int dureePousse = rand() % 10 + 1;
	int numeroClient = (int)arg;

	while(true){
		printf("le client nÂ° %d a les cheveux qui poussent\n",numeroClient);
		// Temps alÃ©atoire pour la poussee des cheveux
		// Attente que les cheveux aient poussÃ©
		sleep(dureePousse);
		sem_wait(&mutex);

		while(nb_clients_attente >= NB_SIEGES){
			printf("la salle d'attente est pleine, le client nÂ° %d ressort\n",numeroClient);
			sem_post(&mutex);
			// Le client ressort et ressayera ensuite
			sleep(dureePousse/2);
			printf("Duree pousse : %d\n",dureePousse);
			sem_wait(&mutex);
		}

		// On vÃ©rrouille le mutex
		//sem_wait(&mutex);
		if(!barbier_endormi){
			printf("le client nÂ° %d est entre dans la salle d'attente\n",numeroClient);
		}
		else {
			// On rÃ©veil le barbier
			printf("le client nÂ° %d reveil le barbier\n",numeroClient);
			barbier_endormi = false;
			sem_post(&barbierDort);
		}
		nb_clients_attente++;
		sem_post(&mutex);
		sem_wait(&salleAttente);
		printf("le client nÂ° %d est entrain de se faire couper les cheveux\n",numeroClient);
		sem_wait(&clientDort);
		printf("le client nÂ° %d a fini de se faire couper les cheveux\n",numeroClient);
	}
}


/**
* But : Fonction qui sera exécutée par un thread traitant un client souhaitant
*				se faire tatouer.
*				Une boucle infini englobe les actions du client afin que celles-ci
*				soient exécutées tant que le programme tourne.
*				A chaque ittération de la boucle, le client attend une durée de temps
*				aléatoire que une nouvelle idée de tatouage lui vienne à l'esprit, puis
*				se rend chez le barbier.
*				Une deuxième boucle while permet au client de tenter ça chance chez le
*				barbier tant qu'il n'a pas réussi à obtenir une place dans la salle
*				attente.
*
* Paramètre(s): arg : pointeur passé à la fonction.
*										  Il est utilisé dans notre fonction pour passer le numéro
*											du client. Celui-ci nous est utile pour l'affichage.
*
*/
void *Client_tatoue(void *arg){
	// Temps de pousse des cheveux
	int dureeAttente = rand() % 30 + 1;
	int numeroClient = 10+(int)arg;

	while(true){
			printf("le tatoue nÂ° %d rÃ©flÃ©chi Ã  un nouveau tatouage\n",numeroClient);
			// Temps alÃ©atoire pour la poussee des cheveux
			// Attente que les cheveux aient poussÃ©
			sleep(dureeAttente);

		while(nb_clients_attente >= NB_SIEGES){
			printf("la salle d'attente est pleine, le tatoue nÂ° %d ressort\n",numeroClient);
			sem_post(&mutex);
			// Le client ressort et ressayera ensuite
			sleep(dureeAttente/2);
		}

		// On vÃ©rrouille le mutex
		sem_wait(&mutex);
		if(!barbier_endormi){
			printf("le client nÂ° %d est entre dans la salle d'attente\n",numeroClient);
		}
		else {
			// On rÃ©veil le barbier
			printf("le tatoue nÂ° %d reveil le barbier\n",numeroClient);
			barbier_endormi = false;
			sem_post(&barbierDort);
		}
		nb_clients_attente++;
		nb_tatoues_attente++;
		sem_post(&mutex);
		sem_wait(&clientTatoue);
		printf("le tatoue nÂ° %d est entrain de se faire tatoue\n",numeroClient);
		sem_wait(&clientDort);
		printf("le tatoue nÂ° %d a fini de se faire tatouer\n",numeroClient);
	}
}



/**
* But : Fonction qui sera exï¿½cutï¿½e par un thread traitant le barbier.
*				Une boucle infini englobe les actions du barbier afin que celles-ci
*				soient exï¿½cutï¿½es tant que le programme tourne.
*				A chaque ittï¿½ration de la boucle, le barbier va observer si au moins un
*				client est prï¿½sent dans la salle d'attente. Si c'est le cas, il lui
*				coupe les cheveux, si ce n'est pas le cas, le barbier s'endors et attend
*				que le prochain client le rï¿½veil ï¿½ l'aide de la sï¿½maphore 'barbierDors'.
*
* Paramï¿½tre(s): arg : pointeur passï¿½ ï¿½ la fonction.
*										  Il est inutilisï¿½, mais permet ï¿½ la fonction de
*											correspondre au prototype nï¿½cessaire pour que celle-ci
*											puisse ï¿½tre utilisï¿½e par un thread.
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
*				Le nombre de sièges dans la salle d'attente ainsi que le nombre de 
*				clients standards et clients à tatouer sont demandé à l'utilisateur.
*				Les traitements sur les variables sont directement effectués à 
*				l'intérieur de la fonction.
*
* Paramètre(s): aucun
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
* But : Fonction principale permettant l'initialisation des sï¿½maphores et la
*				crï¿½ation des threads.
*				Une valeur entiï¿½re sera retournï¿½e, reprï¿½sentant si la fonction s'est
*				terminï¿½e de maniï¿½re correct ou non.
*
*/
int main(void){

	// Saisie du nb de clients et de la taille de la salle d'attente
	saisieClavier();

	// Initialisation des diffÃ©rents sÃ©maphores Ã  leurs valeurs respectives
	sem_init(&mutex,0,1);
	sem_init(&barbierDort,0,0);
	sem_init(&salleAttente,0,0);
	sem_init(&clientDort,0,0);

	// CrÃ©ation du thread barbier
	if (pthread_create(&barbier,NULL,Barbier,NULL)!=0){
		printf("Erreur: pthread_create barbier");
		exit(1);
	}

	// remplissage du tableau de thread avec le nb de clients
	// entrÃ© par l'utilisateur
	int i;
	// CrÃ©ation des threads client
	for(i=0;i<nb_clients;i++){
		if(pthread_create(&(tabClients[i]),NULL,Client,i)!=0){
			printf("Erreur: pthread_create client");
			exit(1);
		}
	}

	// CrÃ©ation des threads tatoues
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

