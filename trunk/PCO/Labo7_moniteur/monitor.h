/*
 * monitor.h
 *
 *  Created on: 1 juin 2010
 *      Author: Burkhalter - Lienhard
 */

#ifndef MONITOR_H_
#define MONITOR_H_

/** Variables condition
*	clientDort 		:	Permet de bloquer un client lorsqu'il est dans 
*								la salle d'attente ou qu'il est entrain de se faire
*								couper les cheveux
*	barbierDort		:	Permet de mettre en attente le barbier lorsqu'il n'a pas de 
*								travail
*/
pthread_cond_t clientDort,  barbierDort;

/**	Mutex
*	mutex 			: 	Verrou permettant l'exclusion mutuelle sur les différentes 
*						variables du programme.
*	mutexMonitor	:	Verrou permettant l'exclusion mutuelle sur les variables cond.
*/
pthread_mutex_t mutex, mutexMonitor;

/** Condition permettant de représenter la salle d'attente */
static pthread_cond_t * salleAttente;

/** Variable de type int représentant le numéro du siege suivant disponible
*	dans la salle d'attente */
int prochainSiege;

/** Variable de type int représentant le numéro du client qui est géré 
*	actuellement */
int clientEnCours;

/** Variable de type bool indiquant si le barbier est endormi ou non */
bool barbier_endormi;

/** Variable de type int représentant le nombre de places dans la salle
*	d'attente.*/
int nb_sieges;

/** Variable de type int représentant le nombre de clients présent dans la salle
* d'attente.*/
int nb_clients_attente;


/** Variable de type int représentant le nombre de clients dans le programme */
int nb_clients;

/**
* But : Fonction permettant de créer les tableaux dynamiques ainsi que 
*		d'initialiser les différentes variables nécessaires au bon 
*		fonctionnement du programme.
*		
*
* Paramètre(s): (aucun)
*
*/
void initialiserTampon(int);


/**
* But : Fonction permettant de libérer les différentes allocations mémoire
*		qui ont été faite par le programme, ainsi que détruire les variables
*		conditions.
*
* Paramètre(s): (aucun)
*
*/
void detruireTampon(void);

/**
* But : Fonction qui permet de gérer l'accès d'un client au salon de coiffure.
*		Si le client arrive à accéder au magasin, la fonction retourne vrai
*		et retourne faux dans le cas contraire.
*		
* Paramètre(s): int : Numéro du client 
*
*/
bool entrerSalleAttente(int);


/**
* But : Fonction permettant de gérer la coupe des cheveux du client.
*		Cette fonction fait simplement en sorte que le barbier 
*		réveil le client lorsqu'il a fini de lui couper les cheveux.
*
* Paramètre(s): (aucun)
*
*/
void couperCheveux(void);


/**
* But : Fonction qui permet de faire attendre le client lorsqu'il
*		est entrain de se faire couper les cheveux.
*
* Paramètre(s): (aucun)
*
*/
void attenteCouperCheveux(void);


/**
* But : Fonction qui permet de faire en sorte que le barbier
*		s'endorme lorsqu'il n'y a plus de client dans la salle d'attente
*
* Paramètre(s): (aucun)
*
*/
void barbierSendort(void);


/**
* But : Fonction qui permet de prendre un client dans la salle
*		d'attente
*
* Paramètre(s): (aucun)
*
*/
void reveillerClient(void);


#endif /* MONITOR_H_ */
