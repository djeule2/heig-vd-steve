/**
 * \file moniteur.h
 * \author St�phane Besuchet & Gr�goire Corpataux
 * \date 11.06.2010
 * \version 1.0.42
 */
#ifndef MONITEUR_H
#define MONITEUR_H

#include <stdlib.h>
#include <stdio.h>
#include <pthread.h>
#include <stdbool.h>
#include <time.h>



/**
 * Permet l'initialisation du moniteur, initialise les variables conditions,
 * les verrous et les variables globalse
 * 
 * \param nombreSieges Nombre de si�ges de la salle d'attente
 */
void moniteur_init(unsigned int);

/**
 * Permet la lib�ration de la m�moire allou�e � l'initalisation du moniteur
 */
void moniteur_libererMemoire(void);

/**
 * Met le barbier en attente, implique qu'il est endormi sur son fauteuil et
 * le d�fini comme libre (pas entrain de travailler)
 */
void barbier_wait(void);

/**
 * Permet de reveiller le barbier
 */
void barbier_notify(void);

/**
 * Permet de mettre un client en attente de fin de rasage, utilis� pour
 * synchroniser le client avec le barbier lors de la coupe
 */
void rasage_wait(void);

/**
 * Reveille le client en attente de la fin du rasage
 */
void rasage_notify(void);

/**
 * Permet de reveiller le prochain client � �tre servi par le barbier.
 */
void reveillerProchainClient(void);

/**
 * Permet de g�rer un client qui rentre dans la boutique, 
 * retourne faux si la salle d'attente est pleine et si le client doit revenir
 * plus tard, sinon si le barbier est endormi, il le reveille et se place dans
 * le fauteuil pour se faire raser, sinon il se met dans la salle d'attente.
 * 
 * \param id Identifiant du thread pour les affichage internes
 * \return Faux si la salle d'attente est pleine, vrai sinon
 */
bool essayerEntrerBoutique(unsigned int);

/**
 * Retourne vrai si la salle d'attente est vide
 * 
 * \return Vrai si la salle est vide
 */
bool estSalleVide(void);

#endif
