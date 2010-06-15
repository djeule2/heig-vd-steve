#include "moniteur.h"

void InitialiserSalleAttente (int sieges)
{
	pthread_mutex_init(&mutex, NULL);
	pthread_cond_init(&salleAttente, NULL);
	pthread_cond_init(&condBarbier, NULL);

	ptClient = ptSiegeSuivant = nbSalleAttente = 0;

	tabSiegesCond = malloc(sieges * sizeof(pthread_cond_t));

	nombreSieges = sieges;

	endormi = false;

	int i;

	for(i = 0; i < nombreSieges; i++)
		pthread_cond_init(&tabSiegesCond[i], NULL);
}

void DetruitSalleAttente (void)
{
	pthread_mutex_destroy(&mutex);
	pthread_cond_destroy(&salleAttente);
	pthread_cond_destroy(&condBarbier);

	int i;

	for(i = 0; i < nombreSieges; i++)
		pthread_cond_destroy(&tabSiegesCond[i]);

	free(tabSiegesCond);

}

bool EntreeClient (int client)
{
	pthread_mutex_lock(&mutex);

	if(nbSalleAttente == nombreSieges)
	{
		pthread_mutex_unlock(&mutex);
		return false;
	}

	if(! endormi)
	{
		nbSalleAttente++;

		ptSiegeSuivant++;
		ptSiegeSuivant %= nombreSieges;
		printf("\nLe client no %d se place dans la file d'attente", client);
		pthread_cond_wait(&tabSiegesCond[ptSiegeSuivant], &mutex);
		pthread_mutex_unlock(&mutex);
	}
	else
	{
		endormi = false;
		printf("\nLe client no %d entre puis reveille le barbier.", client);
		pthread_cond_signal(&condBarbier);
		pthread_mutex_unlock(&mutex);
	}

	return true;

}

void DebutRasage (void)
{
	pthread_mutex_lock(&mutex);
	pthread_cond_wait(&salleAttente, &mutex);
	pthread_mutex_unlock(&mutex);
}

void FinRasage (void)
{
	pthread_mutex_lock(&mutex);
	pthread_cond_signal(&salleAttente);
	pthread_mutex_unlock(&mutex);
}

bool SalleVide (void)
{
	pthread_mutex_lock(&mutex);
	if(nbSalleAttente == 0)
	{
		pthread_mutex_unlock(&mutex);
		return true;
	}
	pthread_mutex_unlock(&mutex);
	return false;
}

void BarbierDort (void)
{
	pthread_mutex_lock(&mutex);
	endormi = true;
	pthread_cond_wait(&condBarbier, &mutex);
	pthread_mutex_unlock(&mutex);
}

void AppelleClient (void)
{
	pthread_mutex_lock(&mutex);
	endormi = false;
	nbSalleAttente--;
	ptClient++;
	ptClient %= nombreSieges;
	pthread_mutex_unlock(&mutex);
	pthread_cond_signal(&tabSiegesCond[ptClient]);
}
