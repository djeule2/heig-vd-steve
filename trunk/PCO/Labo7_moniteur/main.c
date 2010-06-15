
/** \file main.c
 *  \author Burkhalter Arnaud et Lienhard Steve
 *  \date 15.06.2010
 *  \version 1.0
 * \section Description
 *	Ce fichier met en place des threads permettant la gestion de mani�re
 *	concurrente d'un barbier ainsi que des diff�rents clients n�cessaires � la
 *	simulation d'un salon de coiffure, et cela � l'aide de MONITEURS.
 */
 
/** \mainpage Moniteurs
 * 	Cette documentation d�crit le programme Moniteurs qui doit
 *	permettre la simulation d'un salon de coiffure � l'aide de moniteurs.
 * 	Cela a �t� mis en place dans le laboratoire n�7 du cours PCO.
 *
 * \section Introduction
 * Le but de ce programme est la r�alisation d'un programme permettant
 * la simulation d'un salon de coiffure et tatouage.
 * Une salle d'attente pouvant contenir un certain nombre de clients doit �tre
 * mise en place. Lorsqu'un client se pr�sente et que la salle d'attente est
 * vide, ou contient encore des si�ges	non occup�s, le client prend place dans
 * la pi�ce. Dans le cas ou la salle d'attente est pleine, le client va faire
 * un tour et revient tenter sa chance plus tard.
 * Le barbier quant � lui doit couper les cheveux des
 * clients, les uns apr�s les autres. Dans le cas ou il n'est pas entrain de
 * s'occuper de l'un des clients et que la salle d'attente est vide, il
 * s'endort et sera r�veill� par le prochain client � entrer dans la salle
 * d'attente.
 *
 * \section Realisation
 * Afin de r�aliser ce programme � l'aide de moniteur, nous avons le plus 
 * possible exploiter le programme r�alis� un mois auparavant afin de ne pas 
 * r�inventer la roue.
 * Nous avons tout d'abord cr�er le moniteur qui va permettre de g�rer les acc�s
 * concurents aux diff�rentes variables. Ce moniteur est compos� d'une fonction 
 * initialiserTampon qui permet d'initialiser correctement les diff�rents mutex,
 * d'une fonction d�truiteTampon qui permet de lib�rer la m�moire, d'une 
 * fonction entreeSalle permettant de g�rer l'acc�s des clients � la salle 
 * d'attente, d'une fonction couperCheveux qui permet de g�rer la coupe
 * de cheveux des clients. Les variables conditions utilis�es sont les 
 * variables : clientDort, barbierDort.
 * Nous avons ensuite deux fonctions, Barbier et Client qui permettent la gestion
 * du barbier et des diff�rents clients. La fonction barbier est ex�cut�e par le
 * thread du barbier et la fonction client par les diff�rents clients du programme
 * Les explications relatives � ces deux fonctions sont d�crites dans les en-t�tes
 * respectives des deux fonctions.
 
 * monitor.c 
 * Ce fichier contient l'impl�mentation des fonctions d�finies dans monitor.h
 * Les diff�rentes fonctionnalit�s r�alis�es par les fonctions sont d�crites dans
 * les en-t�tes respectives des fonctions, situ�es dans le fichier monitor.h
 *
 * monitor.h
 * Ce fichier contient les en-t�tes et les prototypes des diff�rents fonctions
 * du moniteur. 
 * 
 * monitor.c 
 * Ce fichier contient l'impl�mentation des fonctions d�finies dans monitor.h
 * Nous avons donc la fonction entreeSalle qui prend en param�tre la dur�e 
 * de pousse des cheveux ainsi que le num�ro du client ex�cutant la fonction. 
 * Cette fonction g�re l'acc�s � la salle d'attente de la mani�re suivante : 
 * Tant que la salle d'attente a un ou plusieurs si�ges de libres, le client se 
 * met en attente sur &salleAttente (variable condition du moniteur). 
 * Si par contre la salle est pleine, le client ressort et attend une dur�e 
 * d�termin�e avant de ressayer.
 * 
 * \section Conlusion
 * Bien qu'ayant eu quelques difficult� avec la notion de moniteur vue en 
 * th�orie, nous sommes parvenus � nous documents suffisamment sur le sujet afin
 * de pouvoir r�pondre au cahier des charges de ce laboratoire. Apr�s les 
 * diff�rents tests effectu�s, nous pouvons affirmer que notre laboratoire est
 * fonctionnel. La conception � l'aide de moniteur assure donc une meilleure 
 * stabilit� et une meilleure structure du programme que la simple utilisation 
 * de s�maphores, m�me si la plupart des choses restent faisables sans ce 
 * concept.
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


/** Tableau dynamique permettant de contenir un nombre variable de clients.
*	Un nombre de threads variable sera contenu dans tableau. Ce nombre sera �gal
*	au nombre saisi par l'utilisateur en d�but d'ex�cution du programme.*/
pthread_t *tabClients;

/** Variable de type int indiquant le temps n�cessaire au barbier pour effectuer
		une coupe de cheveux. */
int DUREE_COUPE = 3;

int NB_SIEGES;

int NB_CLIENTS;

/**
* But : Fonction permettant la saisie de valeur au clavier par l'utilisateur.
*		Le nombre de si�ge dans la salle d'attente ainsi que le nombre de client
*		sont demand� � l'utilisateur.
*		Les traitements sur les variables sont directement effectu�s
*		l'int�rieur de la fonction.
*
* Param�tre(s): aucun
*
*/
void saisieClavier(){
	printf("Saisir le nb de clients : ");
	scanf("%d",&NB_CLIENTS);
	tabClients = malloc(NB_CLIENTS*sizeof(pthread_t));

	printf("\n Saisir la taille de la salle d'attente : ");
	scanf("%d",&NB_SIEGES);
}

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

		printf("Client n� %d a les cheveux qui poussent \n",numeroClient);
		sleep(dureePousse);

		// le client tente d'entrer dans la salle d'attente
		while (!entrerSalleAttente(numeroClient))
		{
			printf("Client n� %d n'a pas trouv� de place et resort \n",numeroClient);
			 // On attend la moiti� du temps de pousse
			 sleep(dureePousse / 2);
		}

		// le client se fait couper les cheveux
		printf("Client n� %d se fait couper les cheveux \n", numeroClient);
		attenteCouperCheveux();
	}
}


/**
* But : Fonction qui sera ex�cut�e par un thread traitant le barbier.
*				Une boucle infinie englobe les actions du barbier afin que celles-ci
*				soient ex�cut�es tant que le programme tourne.
*				A chaque it�ration de la boucle, le barbier va observer si au moins un
*				client est pr�sent dans la salle d'attente. Si c'est le cas, il lui
*				coupe les cheveux, si ce n'est pas le cas, le barbier s'endors et attend
*				que le prochain client le r�veil � l'aide de la condition 'barbierDors'.
*
* Param�tre(s): arg : pointeur pass� � la fonction.
*										  Il est inutilis�, mais permet � la fonction de
*											correspondre au prototype n�cessaire pour que celle-ci
*											puisse �tre utilis�e par un thread.
*
*/
void *Barbier(void *arg){
	while(true){

		if(salleOccupee()){
			printf("Le BARBIER reveil un client \n");
			// on r�veil un client pr�sent
			reveillerClient();
		}
		else
		{
			printf("Le BARBIER s'endort \n");
			barbierSendort();
		}

		sleep(DUREE_COUPE);
		CouperCheveux();
	}
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
	initialiserTampon(NB_SIEGES);

	// Cr�ation du thread barbier
	if (pthread_create(&barbier,NULL,Barbier,NULL)!=0){
		printf("Erreur: pthread_create barbier");
		exit(1);
	}

	// remplissage du tableau de thread avec le nombre de clients
	// entr� par l'utilisateur
	int i;
	// Cr�ation des threads client
	for(i=0;i<NB_CLIENTS;i++){
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

