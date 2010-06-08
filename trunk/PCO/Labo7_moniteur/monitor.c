/*
 * monitor.c
 *
 *  Created on: 8 juin 2010
 *      Author: steve
 */

void entreeSalle()
{
	int dureePousse = rand() % 10 + 1;
	int numeroClient = (int)arg;

	while(true)
	{
		printf("le client n° %d a les cheveux qui poussent \n",numeroClient);
		sleep(dureePousse);
		sem_wait(&mutex);
	}

	while(nb_clients_attente >= NB_SIEGES)
	{
		printf("la salle d'attente est pleine, le client n° %d ressort\n", numeroClient);
		sem_post(&mutex);

		sleep(dureePousse/2);
		printf("Duree pousse : %d\n", dureePousse);
		sem_wait(&mutex);
	}
}


void couperCheveux()
{
	if(!barbier_endormi){
		printf("le client n° %d est entre dans la salle d'attente\n",numeroClient);
	}
	else {
		// On réveil le barbier
		printf("le client n° %d reveil le barbier\n",numeroClient);
		barbier_endormi = false;
		pthread_cond_signal(&barbierDort);
		sem_post(&mutex);
	}
	nb_clients_attente++;
	pthread_cond_wait(&salleAttente, &mutex);
	printf("le client n° %d est entrain de se faire couper les cheveux\n",numeroClient);
	pthread_cond_wait(&clientDort, &mutex);
	printf("le client n° %d a fini de se faire couper les cheveux\n",numeroClient);
}

void barbierCoupeCheveux()
{
	if(nb_clients_attente){
		// le barbier prend le client en attente sur la salle barbier
		pthread_cond_signal(&salleAttente);
		// le client sort de la salle d'attente pour aller chez le barbier
		pthread_cond_signal(&client_dort);
		nb_clients_attente--;
		sem_post(&mutex);
		// Il coupe les cheveux du client
		sleep(dureeCoupe);
		sem_post(&clientDort);
	}
	else{
		barbier_endormi = true;
		printf("le barbier dort\n");
		sem_post(&mutex);
		// le barbier s'endort
		sem_wait(&barbierDort);
	}

}
}
