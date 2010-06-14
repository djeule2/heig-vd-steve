/*
 * monitor.h
 *
 *  Created on: 1 juin 2010
 *      Author: steve
 */

#ifndef MONITOR_H_
#define MONITOR_H_

#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <time.h>
#include <semaphore.h>
#include <stdbool.h>
#include <psleep.h>
#include "monitor.h"

pthread_cond_t clientDort, salleVide, sallePleine, barbierDort, salleAttente;
pthread_mutex_t mutex;

/** Variable de type int représentant le nombre de place dans la salle
*	d'attente.*/
int NB_SIEGES;

/** Variable de type int représentant le nombre de clients dans la salle
* d'attente.*/
int nb_clients_attente = 0;

/** Variable de type int indiquant le temps nécessaire au barbier pour effectuer
		une coupe de cheveux. */
int dureeCoupe = 10;

bool barbier_endormi;

static pthread_t * tampon;

void initialiserTampon(void);

void detruireTampon(void);

void entreeSalle(int, int);

void couperCheveux(int);


#endif /* MONITOR_H_ */
