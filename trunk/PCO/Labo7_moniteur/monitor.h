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
*	mutex 			: 	Verrou permettant l'exclusion mutuelle sur les diff�rentes 
*						variables du programme.
*	mutexMonitor	:	Verrou permettant l'exclusion mutuelle sur les variables cond.
*/
pthread_mutex_t mutex, mutexMonitor;

/** Condition permettant de repr�senter la salle d'attente */
static pthread_cond_t * salleAttente;

/** Variable de type int repr�sentant le num�ro du siege suivant disponible
*	dans la salle d'attente */
int prochainSiege;

/** Variable de type int repr�sentant le num�ro du client qui est g�r� 
*	actuellement */
int clientEnCours;

/** Variable de type bool indiquant si le barbier est endormi ou non */
bool barbier_endormi;

/** Variable de type int repr�sentant le nombre de places dans la salle
*	d'attente.*/
int nb_sieges;

/** Variable de type int repr�sentant le nombre de clients pr�sent dans la salle
* d'attente.*/
int nb_clients_attente;


/** Variable de type int repr�sentant le nombre de clients dans le programme */
int nb_clients;

/**
* But : Fonction permettant de cr�er les tableaux dynamiques ainsi que 
*		d'initialiser les diff�rentes variables n�cessaires au bon 
*		fonctionnement du programme.
*		
*
* Param�tre(s): (aucun)
*
*/
void initialiserTampon(int);


/**
* But : Fonction permettant de lib�rer les diff�rentes allocations m�moire
*		qui ont �t� faite par le programme, ainsi que d�truire les variables
*		conditions.
*
* Param�tre(s): (aucun)
*
*/
void detruireTampon(void);

/**
* But : Fonction qui permet de g�rer l'acc�s d'un client au salon de coiffure.
*		Si le client arrive � acc�der au magasin, la fonction retourne vrai
*		et retourne faux dans le cas contraire.
*		
* Param�tre(s): int : Num�ro du client 
*
*/
bool entrerSalleAttente(int);


/**
* But : Fonction permettant de g�rer la coupe des cheveux du client.
*		Cette fonction fait simplement en sorte que le barbier 
*		r�veil le client lorsqu'il a fini de lui couper les cheveux.
*
* Param�tre(s): (aucun)
*
*/
void couperCheveux(void);


/**
* But : Fonction qui permet de faire attendre le client lorsqu'il
*		est entrain de se faire couper les cheveux.
*
* Param�tre(s): (aucun)
*
*/
void attenteCouperCheveux(void);


/**
* But : Fonction qui permet de faire en sorte que le barbier
*		s'endorme lorsqu'il n'y a plus de client dans la salle d'attente
*
* Param�tre(s): (aucun)
*
*/
void barbierSendort(void);


/**
* But : Fonction qui permet de prendre un client dans la salle
*		d'attente
*
* Param�tre(s): (aucun)
*
*/
void reveillerClient(void);


#endif /* MONITOR_H_ */
