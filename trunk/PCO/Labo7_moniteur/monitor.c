/*
 * monitor.c
 *
 *  Created on: 8 juin 2010
 *      Author: steve
 */

#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <semaphore.h>
#include <stdbool.h>
#include <psleep.h>
#include "monitor.h"

void entreeSalle(int dureePousse, int numeroClient)
{
	printf("le client nÂ° %d a les cheveux qui poussent \n",numeroClient);
	sleep(dureePousse);
	//pthread_mutex_lock(&mutex);

	while(nb_clients_attente >= NB_SIEGES)
	{
		printf("la salle d'attente est pleine, le client nÂ° %d ressort\n", numeroClient);
		pthread_mutex_unlock(&mutex);

		sleep(dureePousse/2);
		printf("Duree pousse : %d\n", dureePousse);
		// prise du mutex
		pthread_mutex_lock(&mutex);
	}
	//printf("le client n° %d est dans la salle d'attente\n", numeroClient);
	//nb_clients_attente++;
	//pthread_cond_wait(&salleAttente,&mutex);

}


void couperCheveux(int numeroClient)
{
	if(!barbier_endormi){
		printf("le client n° %d est entre dans la salle d'attente\n",numeroClient);
	}
	else {
		// On réveil le barbier
		printf("le client n° %d reveil le barbier\n",numeroClient);
		barbier_endormi = false;
		pthread_cond_signal(&barbierDort);
	}
	nb_clients_attente++;
	pthread_cond_wait(&salleAttente, &mutex);
	printf("le client nÂ° %d est entrain de se faire couper les cheveux\n",numeroClient);
	pthread_cond_wait(&clientDort, &mutex);
	printf("le client nÂ° %d a fini de se faire couper les cheveux\n",numeroClient);
}

void barbierCoupeCheveux()
{
  pthread_mutex_lock(&mutex);
	if(nb_clients_attente){
		// le barbier prend le client en attente sur la salle barbier
		pthread_cond_signal(&salleAttente);
		pthread_mutex_unlock(&mutex);
		// Il coupe les cheveux du client
		sleep(dureeCoupe);
		// le client sort de la salle d'attente pour aller chez le barbier
		pthread_cond_signal(&clientDort);
		nb_clients_attente--;
		pthread_mutex_unlock(&mutex);
	}
	else{
    printf("le barbier dort\n");
    pthread_cond_wait(&barbierDort, &mutex);
	}

}

void initialiserTampon(){
		 pthread_mutex_init(&mutex,NULL);
		 pthread_cond_init(&clientDort,NULL);
		 pthread_cond_init(&salleVide,NULL);
		 pthread_cond_init(&sallePleine,NULL);
		 pthread_cond_init(&barbierDort,NULL);
		 pthread_cond_init(&salleAttente,NULL);

}

void detruireTampon(){
		 pthread_mutex_destroy(&mutex);
		 pthread_cond_destroy(&clientDort);
		 pthread_cond_destroy(&salleVide);
		 pthread_cond_destroy(&sallePleine);
		 pthread_cond_destroy(&barbierDort);
		 pthread_cond_destroy(&salleAttente);
		 if (tampon != NULL){
		 		free(tampon);
				tampon = NULL;
			}
}
