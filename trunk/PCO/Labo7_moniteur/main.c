
/**\file main.c
 * \author Steve Lienhard et Arnaud Burkhalter
 * \date 26.04.2010
 * \version 1.0
 * \section Description
 *	Ce fichier met en place des threads permettant la gestion de manière
 *	concurrente d'un barbier ainsi que des différents clients nécessaires à la
 *	à la simulation d'un salon de coiffure, et cela à l'aide de MONITEURS.
 */

#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <time.h>
#include <semaphore.h>
#include <stdbool.h>
#include <psleep.h>
#include "monitor.h"

/** Thread représentant le barbier */
pthread_t barbier;
/** Variable de type int représentant le nombre de clients dans le programme */
int nb_clients;

/** Tableau dynamique permettant de contenir un nombre variable de clients.
*	Un nombre de threads variable sera contenu dans tableau. Ce nombre sera égal
*	au nombre saisi par l'utilisateur en début d'exécution du programme.*/
pthread_t *tabClients;


/**
* But : Fonction qui sera exécutée par un thread traitant un client.
*				Une boucle infinie englobe les actions du client afin que celles-ci
*				soient exécutées tant que le programme tourne.
*				A chaque itération de la boucle, le client attend une durée de temps
*				aléatoire que ses cheveux poussent puis se rend chez le barbier.
*				Une deuxième boucle while permet au client de tenter ça chance chez le
*				barbier tant qu'il n'a pas réussi à obtenir une place dans la salle
*				attente.
*
* Paramètre(s): arg : pointeur passé à la fonction.
*										  Il est utilisé dans notre fonction pour passer le numéro
*											du client. Celui-ci nous est utile pour l'affichage.
*
*/
void *Client(void *arg){
	// Temps de pousse des cheveux
	int dureePousse = rand() % 10 + 1;
	int numeroClient = (int)arg;

	while(true){

			// le client entre dans la salle d'attente
			entreeSalle(dureePousse, numeroClient);

			// le client se fait couper les cheveux
			couperCheveux(numeroClient);
	}
}

/**
* But : Fonction qui sera exécutée par un thread traitant le barbier.
*				Une boucle infinie englobe les actions du barbier afin que celles-ci
*				soient exécutées tant que le programme tourne.
*				A chaque itération de la boucle, le barbier va observer si au moins un
*				client est présent dans la salle d'attente. Si c'est le cas, il lui
*				coupe les cheveux, si ce n'est pas le cas, le barbier s'endors et attend
*				que le prochain client le réveil à l'aide du sémaphore 'barbierDors'.
*
* Paramètre(s): arg : pointeur passé à la fonction.
*										  Il est inutilisé, mais permet à la fonction de
*											correspondre au prototype nécessaire pour que celle-ci
*											puisse être utilisée par un thread.
*
*/
void *Barbier(void *arg){
	while(true){
		barbierCoupeCheveux();
	}
}

/**
* But : Fonction permettant la saisie de valeur au clavier par l'utilisateur.
*				Le nombre de siège dans la salle d'attente ainsi que le nombre de client
*				sont demandé à l'utilisateur.
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

	printf("\n \n Saisir la taille de la salle d'attente : ");
	scanf("%d",&NB_SIEGES);
}

/**
* But : Fonction principale permettant l'initialisation des sémaphores et la
*				création des threads.
*				Une valeur entière sera retournée, représentant si la fonction s'est
*				terminée de manière correct ou non.
*
*/
int main(void){

	// Saisie du nombre de clients et de la taille de la salle d'attente
	saisieClavier();

	// Initialisation des conditions moniteur
	initialiserTampon();


	// Création du thread barbier
	if (pthread_create(&barbier,NULL,Barbier,NULL)!=0){
		printf("Erreur: pthread_create barbier");
		exit(1);
	}

	// remplissage du tableau de thread avec le nombre de clients
	// entré par l'utilisateur
	int i;
	// Création des threads client
	for(i=0;i<nb_clients;i++){
		if(pthread_create(&(tabClients[i]),NULL,Client,i)!=0){
			printf("Erreur: pthread_create client");
			exit(1);
		}
	}

	// Application d'une jointure à chaque thread précédemment créé
	for(i=0; i<nb_clients;i++){
		pthread_join(tabClients[i],NULL);
	}

	pthread_join(barbier,NULL);

	// déstruction du tampon et des conditions moniteur
	detruireTampon();

	return 0;
}

