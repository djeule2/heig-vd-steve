/** \mainpage Barbier-Modélisation à l'aide de moniteurs
 * Cette documentation explique notre laboratoire mettant en pratique le principe
 * de modélisation d'un problème concurrent à l'aide de moniteurs. Le
 * but du trvail est de gérer une boutique de barbier et ses différents clients.
 */

/** \file main.c
 *  \author Loïc Augsburger et Florian Veillard
 *  \date 14.06.2010
 *  \version 1.0.0
 *
 *  \section Introduction
 * Ce laboratoire met en oeuvre un programme gérant l'arrivée des clients
 * chez un barbier. Il faudra gérer une salle d'attente et la coupe de cheveux,
 * tout ceci avec un moniteur.
 *
 * \section Description
 * Les clients se présentant doivent dans un premier temps attendre la pousse
 * des cheveux puis se présenter chez le barbier. Si ce dernier est libre, il
 * faut le réveiller de sa sieste. S’il est occupé à couper quelqu’un d’autre,
 * il faut attendre dans sa salle d’attente que la place se libère. Le premier
 * client arrivé devra être le premier client servi (PAPS). Mais il se peut que
 * la salle d’attente soit pleine, le client devra alors revenir un moment plus
 * tard lorsqu’une place y sera disponible (il attend la moitié du temps que 
 * ses cheveux ont mis pour pousser.
 * Le nombre de siège de la salle d’attente ainsi que le nombre de client du barbier
 * sont saisit par l’utilisateur au début du programme. La pousse des cheveux ainsi
 * que le temps de coupe sont gérés par une attente passive (sleep).
 *
 * \section Conlusion
 * Nous avons correctement su appliquer la notion de moniteurs vue en classe.
 * Ce laboratoire fut très utile pour nous car nous avions au début pas une grande
 * maitrise de cette notion et pour finir nous nous sommes aperçu qu'une fois 
 * la structure du programme définie, il était plus facile d'implémenter ce labo
 * à l'aide des moniteurs qu'avec les sémaphores.
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "psleep.h"
#include <pthread.h>*/
#include "moniteur.h"


/** Contient le nombre de sièges disponibles dans la salle d'attente du
 * barbier. Ce nombre est demandé à l'utilisateur au début du programme.
 * Si tous les sièges sont occupés, le client repart et revient
 * plus tard.
 */
static int nbSieges;

/** Contient le nombre de client du barbier. Ce nombre de client est demandé
 * au démarrage du proramme à l'utilisateur. Tous ces clients vont ensuite
 * attendre la pousse de leurs cheveux avant de se représenter chez le barbier.
 */
static int nbClients;

/** Pointeur sur le début du tableau contenant les différents thread pour
* chaque client créé.
*/
pthread_t * tClients;

/** Thread s'occupant de gérer les tâches du barbier. 
*/
pthread_t tBarbier;


/** Méthode permettant de calculer un nombre alétoire entre 2
 * nombres donnés.
 *  \param min Nombre minimal du nombre aléatoire
 *  \param max Nombre maximum du nombre aléatoire
 *  \return Le nombre aléatoire calculé
 */
int aleat (int min, int max)
{
	return (min + (rand() % (max - min + 1)));
}


/** Tâche créée pour chaque client du barbier.
 * Elle gère les différentes actions du client, soit:
 * -La pousse des cheveux (temps aléatoire)
 * -L'accès à la salle d'attente
 * -Le début du rasage du client
 * \param arg Argument pouvant être passé en paramètre au thread, dans notre
 * cas, on lui passe le numéro du client
*/
void *client(void *arg)
{
	const int noClient = (int) arg;
	int tempsCheveux;
	tempsCheveux = aleat(2, 10);

	while (true)
	{
		printf("\nLe client no %d attend que ses cheveux poussent.", noClient);
		sleep(tempsCheveux);

		// Le client obtient un siège en salle d'attente et attend que le barbier se libère
		while (! EntreeClient(noClient))
		{
			printf("\nLe client no %d entre, puis ressort, car la salle d'attente"
					" est pleine.", noClient);

			sleep(tempsCheveux / 2);
		}

		printf("\nLe client no %d commence à se faire raser.", noClient);
		DebutRasage();
	}
}


/** Tâche gérant les actions du barbier.
 *  - Si il n'y a aucun client en attente, le barbier s'endort et fait une
 *  sieste
 * - Si il y un (ou plus) client en attente, il le fait entrer dans son salon,
 * le rase pendant un certains temps aléatoire compris entre 5 et 10 secondes
 * puis signal la fin du rasage.
 * \param arg Argument pouvant être passé en paramètre au thread
 */
void *barbier(void *arg)
{
	while (true)
	{
		/* S'il n'y a personne dans son commerce, le barbier s'endort */
		if (SalleVide())
		{
			printf("\nLe barbier s'endort.");
			BarbierDort();
		}
		else
		{
			AppelleClient();
		}
		printf("\nLe barbier commence a raser le client.");
		/* Il coupe les cheveux, puis libère le client */
		sleep(aleat(5, 10));
		printf("\nLe barbier a fini de raser le client.");
		FinRasage();
		/* Ici, nous faisons un sleep, afin que l'ordre des message affiché
		 * soient tout le temps dans le même ordre (l'ordre que nous avons
		 * souhaité) */
		sleep(1);
	}
}


/** Méthode permettant de libérer la mémoire alouée à l'aide des 
* mallocs.
*/
void libererMemoire()
{
	free(tClients);
	DetruitSalleAttente();
}


/** Méthode permettant la saisie et la vérifiaction d'un nombre saisit au
* clavier par l'utilisateur. Elle est utilisée pour la demande du nombre
* de siège et du nombre de client.
* \return La valeur saisie par l'utilisateur
*/
int saisieNombre ()
{
	int nombre = 0;

	while (true)
	{
		scanf("%d", &nombre);
		if (nombre <= 0)
			printf("Le nombre doit etre superieur a 0, veuillez "
					"entrer une nouvelle valeur : ");
		else
			return nombre;
	}
	return nombre;
}


/** Programme principal ayant pour mission de :
 * - Demander à l'utilisateur les différents paramètres du salon du Barbier
 * - Créer les 2 tâches gérant le salon du Barbier
 * - Attendre que les tâches se terminent (join)
 *  \return Etat du programme lors de sa terminaison
 */
int main(void)
{
	int err;
	int i;

	srand((unsigned) time(NULL));

	printf("BOUTIQUE DE BARBIER\n\nVeuillez entrer le nombre de chaises : ");
	nbSieges = saisieNombre();
	printf("Veuillez entrer le nombre de clients : ");
	nbClients = saisieNombre();

	tClients = malloc(nbClients * sizeof(pthread_t));

	InitialiserSalleAttente(nbSieges);

	atexit(libererMemoire);

	if ((err = pthread_create(&tBarbier, NULL, barbier, NULL)) == 0)
	{
		for (i = 0; i < nbClients; i++)
			if ((err = pthread_create(&tClients[i], NULL, client, i)) != 0)
				printf("Main: Erreur de creation du thread client no %d : %d\n", i, err);
	}
	else
		printf("Main: Erreur de creation du thread barbier : %d\n", err);

	pthread_join(tBarbier, NULL);
	for (i = 0; i < nbClients; i++)
		pthread_join(tClients[i], NULL);
	return EXIT_SUCCESS;
}
