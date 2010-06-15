/*
 * monitor.c
 *
 *  Created on: 1 juin 2010
 *      Author: Burkhalter - Lienhard
 */

#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <semaphore.h>
#include <stdbool.h>
#include <psleep.h>
#include "monitor.h"


bool entrerSalleAttente(int numeroClient)
{

	pthread_mutex_lock(&mutex);

	// si la salle d'attente est pleine
	if(nb_clients_attente == nb_sieges)
	{
		pthread_mutex_unlock(&mutex);

		return false;
	}
	// si le barbier travail déjà
	if (!barbier_endormi)
	{
		// Se place dans la salle d'attente
		nb_clients_attente++;
		  // Déplace le pointeur sur le prochain siège libre
		prochainSiege++;
		prochainSiege = prochainSiege % nb_sieges;
		printf("le client n° %d entre dans la salle d'attente\n", numeroClient);
		pthread_mutex_unlock(&mutex);

		// Attend d'être appelé pour se faire raser
		pthread_mutex_lock(&mutexMonitor);
		pthread_cond_wait(&salleAttente[prochainSiege], &mutexMonitor);
		pthread_mutex_unlock(&mutexMonitor);
	 }
	 else
	 {
		// Reveille le barbier
		barbier_endormi = false;
		printf("Client n° %d réveil le barbier \n", numeroClient);

		// on signal au barbier qu'il y a un client
		pthread_mutex_lock(&mutexMonitor);
		// le client réveil le barbier avec la condition barbierDort
		pthread_cond_signal(&barbierDort);
		pthread_mutex_unlock(&mutexMonitor);

		pthread_mutex_unlock(&mutex);
	 }
	return true;
}

void attenteCouperCheveux(void)
{
	pthread_mutex_lock(&mutexMonitor);
	// le client se met en attente sur clientDort
	pthread_cond_wait(&clientDort, &mutexMonitor);
	pthread_mutex_unlock(&mutexMonitor);
}

void CouperCheveux(void)
{
	pthread_mutex_lock(&mutexMonitor);
	// le barbier réveil un client
	pthread_cond_signal(&clientDort);
	pthread_mutex_unlock(&mutexMonitor);
}

void barbierSendort()
{
	pthread_mutex_lock(&mutexMonitor);
	barbier_endormi = true;
	// le barbier se met en attente sur barbierDort
	pthread_cond_wait(&barbierDort, &mutexMonitor);
	pthread_mutex_unlock(&mutexMonitor);
}

bool salleOccupee(void)
{
	bool occupe = false;
	pthread_mutex_lock(&mutex);
	// si des clients sont dans la salle celle ci est occupée
	if(nb_clients_attente != 0)
		occupe = true;
	pthread_mutex_unlock(&mutex);

	return occupe;
}

void reveillerClient(void)
{
   pthread_mutex_lock(&mutex);
   nb_clients_attente--;
   // Déplace le pointeur sur le client suivant
   clientEnCours++;
   clientEnCours = clientEnCours % nb_sieges;
   barbier_endormi = false;
   pthread_mutex_unlock(&mutex);

   // libère un siège
   pthread_mutex_lock(&mutexMonitor);
   pthread_cond_signal(&salleAttente[clientEnCours]);
   pthread_mutex_unlock(&mutexMonitor);
}


void initialiserTampon(int NB_SIEGES){
	pthread_mutex_init(&mutex,NULL);
	pthread_cond_init(&clientDort,NULL);
	pthread_cond_init(&barbierDort,NULL);
	pthread_cond_init(&salleAttente,NULL);
	salleAttente = malloc(nb_clients * sizeof(pthread_cond_t));

	prochainSiege = 0;
	clientEnCours = 0;
	nb_clients_attente = 0;
	nb_sieges = NB_SIEGES;
	barbier_endormi = true;

	salleAttente = malloc(nb_sieges * sizeof(pthread_cond_t));

   unsigned int i;

   for(i = 0; i < nb_sieges; i++)
	  pthread_cond_init(&salleAttente[i], NULL);

}

void detruireTampon(){
	pthread_mutex_destroy(&mutex);
	pthread_cond_destroy(&clientDort);
	pthread_cond_destroy(&barbierDort);

	// on libère la mémoire allouée
	if (salleAttente != NULL){
		free(salleAttente);
		salleAttente = NULL;
	}

}
