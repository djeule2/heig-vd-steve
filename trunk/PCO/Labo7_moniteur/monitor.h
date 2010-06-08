/*
 * monitor.h
 *
 *  Created on: 1 juin 2010
 *      Author: steve
 */

#ifndef MONITOR_H_
#define MONITOR_H_

pthread_cond_t clientDort, salleVide, sallePleine, barbierDort, salleAttente;
pthread_mutex_t mutex;
bool barbier_endormi;
static pthread_t * tampon;

void initialiserTampon(void);

void detruireTampon(void);

void entreeSalle();


void couperCheveux();




#endif /* MONITOR_H_ */
