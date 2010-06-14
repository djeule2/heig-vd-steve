
/**\file main.c
 * \author Steve Lienhard et Arnaud Burkhalter
 * \date 26.04.2010
 * \version 1.0
 * \section Description
 *	Ce fichier met en place des threads permettant la gestion de mani�re
 *	concurrente d'un barbier ainsi que des diff�rents clients n�cessaires � la
 *	� la simulation d'un salon de coiffure, et cela � l'aide de MONITEURS.
 */

#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <time.h>
#include <semaphore.h>
#include <stdbool.h>
#include <psleep.h>
#include "monitor.h"

/** Thread repr�sentant le barbier */
pthread_t barbier;
/** Variable de type int repr�sentant le nombre de clients dans le programme */
int nb_clients;

/** Tableau dynamique permettant de contenir un nombre variable de clients.
*	Un nombre de threads variable sera contenu dans tableau. Ce nombre sera �gal
*	au nombre saisi par l'utilisateur en d�but d'ex�cution du programme.*/
pthread_t *tabClients;


/**
* But : Fonction qui sera ex�cut�e par un thread traitant un client.
*				Une boucle infinie englobe les actions du client afin que celles-ci
*				soient ex�cut�es tant que le programme tourne.
*				A chaque it�ration de la boucle, le client attend une dur�e de temps
*				al�atoire que ses cheveux poussent puis se rend chez le barbier.
*				Une deuxi�me boucle while permet au client de tenter �a chance chez le
*				barbier tant qu'il n'a pas r�ussi � obtenir une place dans la salle
*				attente.
*
* Param�tre(s): arg : pointeur pass� � la fonction.
*										  Il est utilis� dans notre fonction pour passer le num�ro
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
* But : Fonction qui sera ex�cut�e par un thread traitant le barbier.
*				Une boucle infinie englobe les actions du barbier afin que celles-ci
*				soient ex�cut�es tant que le programme tourne.
*				A chaque it�ration de la boucle, le barbier va observer si au moins un
*				client est pr�sent dans la salle d'attente. Si c'est le cas, il lui
*				coupe les cheveux, si ce n'est pas le cas, le barbier s'endors et attend
*				que le prochain client le r�veil � l'aide du s�maphore 'barbierDors'.
*
* Param�tre(s): arg : pointeur pass� � la fonction.
*										  Il est inutilis�, mais permet � la fonction de
*											correspondre au prototype n�cessaire pour que celle-ci
*											puisse �tre utilis�e par un thread.
*
*/
void *Barbier(void *arg){
	while(true){
		barbierCoupeCheveux();
	}
}

/**
* But : Fonction permettant la saisie de valeur au clavier par l'utilisateur.
*				Le nombre de si�ge dans la salle d'attente ainsi que le nombre de client
*				sont demand� � l'utilisateur.
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

	// Saisie du nombre de clients et de la taille de la salle d'attente
	saisieClavier();

	// Initialisation des conditions moniteur
	initialiserTampon();


	// Cr�ation du thread barbier
	if (pthread_create(&barbier,NULL,Barbier,NULL)!=0){
		printf("Erreur: pthread_create barbier");
		exit(1);
	}

	// remplissage du tableau de thread avec le nombre de clients
	// entr� par l'utilisateur
	int i;
	// Cr�ation des threads client
	for(i=0;i<nb_clients;i++){
		if(pthread_create(&(tabClients[i]),NULL,Client,i)!=0){
			printf("Erreur: pthread_create client");
			exit(1);
		}
	}

	// Application d'une jointure � chaque thread pr�c�demment cr��
	for(i=0; i<nb_clients;i++){
		pthread_join(tabClients[i],NULL);
	}

	pthread_join(barbier,NULL);

	// d�struction du tampon et des conditions moniteur
	detruireTampon();

	return 0;
}

