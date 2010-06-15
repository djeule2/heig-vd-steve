/** \file moniteur.h
 * \author Loïc Augsburger et Florian Veillard
 * \date 14.06.2010
 * \version 1.0.0
 * \section Description
 * Ce fichier définit l'interface permettant de gérer une boutique de barbier.
 * Les fonctions permettent d'initialiser gérer et détruire correctement une
 * salle d'attente ainsi que gérer l'arrivée des clients et leur rasage.
 */

#ifndef MONITEUR
    #define MONITEUR
	#include <stdio.h>
	#include <stdlib.h>
	#include <stdbool.h>
	#include "psleep.h"
	#include <pthread.h>

	/** Variable condition utilisée lorsqu'un client est en train de se faire 
	* raser*/
	static pthread_cond_t salleAttente;
	/** Variable condition permettant de réveiller le barbier */
	static pthread_cond_t condBarbier;
	/** Mutex permettant l'exclusion mutuelle lors de l'accès aux ressources
    * critiques */
	static pthread_mutex_t mutex;
	/** Tableau contenant les conditions de chaque sièges de la salle d'attente */
	static pthread_cond_t * tabSiegesCond = NULL;
	/** Variable permettant de savoir quel est le client qui est traité */
	static int ptClient;
	/** Variable permettant de savoir quel est le numéro du prochain siège
	* devant être traité */
	static int ptSiegeSuivant;
	/** Variable permettant le nombre de client dans la salle d'attente */
	static int nbSalleAttente;
	/** Variable permettant de savoir le nombre de sièges dans la salle 
	* d'attente */
	static int nombreSieges;
	/** Variable indiquant si le barbier dort */
	static bool endormi;

	
	
	/** Méthode permettant d'initiliser une salle d'attente.
	* On y effectue l'allocation mémoire nécessaire suivant le nombre
	* de client (passé en paramètre) ainsi que l'initialisation des
	* conditions. Nous sommes partis sur le choix de créer une variable
	* condition pour chaque siège de la salle d'attente. Il est alors
	* plus facile de réveiller chaque client en attente sur les sièges.
	* \param sieges Nombre de siège de la salle d'attente
	*/
	void InitialiserSalleAttente (int sieges);

	
	/** Méthode permettant de libérer les ressources mémoires attribuées
	* lors de la création de la salle d'attente ainsi que les variables
	* de condition.
	*/
	void DetruitSalleAttente (void);

	
	/** Méthode appellée lors de l'entrée d'un client dans la salle d'attente.
	* Si la salle d'attente est pleine on retourne false. Dans le cas
	* contraire, on regarde si le barbier n'est pas endormi. Si c'est le cas,
	* on le réveil et le client se fait direct couper les cheveux. Dans le cas
	* contraire, on place le client sur le prochain siège libre et on le met
	* en attente avec sa variable condition.
	* \param client Numéroe du client entrant dans le barbier
	* \return False si la salle d'attente est pleine
	*/
	bool EntreeClient (int client);

	/** Méthode permettant de signaler le début du rasage d'un client.
	*/
	void DebutRasage (void);

	/** Méthode permettant de signaler la fin du rasage d'un client.
	*/
	void FinRasage (void);

	/** Méthode permettant de savoir si la salle d'attente est vide.
	* \return True si la salle d'attente est vide
	*/
	bool SalleVide (void);

	/** Méthode permettant d'endormir le barbier et de le mettre en attente
	* qu'un client le réveil.
	*/
	void BarbierDort (void);

	/** Méthode permettant au barbier d'appeller un client à se faire raser.
	* On sélectionne le bon siège pour prendre le premier client arrivé dans
	* la salle et on l'appel grâce à la variable condition du siège.
	*/
	void AppelleClient (void);
#endif
