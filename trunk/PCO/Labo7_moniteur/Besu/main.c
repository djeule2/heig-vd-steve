/**
 * \mainpage Mod�lisation par moniteur - Boutique de Barbier
 * Le pr�sent document d�crit le d�veloppement du laboratoire du cours de PCO 
 * pour la mod�lisation d�un probl�me concurrent � l�aide de moniteurs. 
 */

/**
 * \file main.c
 * \author St�phane Besuchet & Gr�goire Corpataux
 * \date 11.06.2010
 * \version 1.0.42
 */

 /**
 * \section Introduction
 * Ce laboratoire effectue la simulation d'une boutique de barbier avec
 * plusieurs clients et une salle d'attente. L'utilisation de moniteurs sera
 * n�cessaire pour g�rer le comportement des clients et du barbier.
 */
 
 /**
 * \section Description
 * Chaque client � un cycle de vie assez simple, premi�rement il attend que ses
 * cheveux poussent puis il se rend dans la boutique du barbier, d�s lors, si
 * aucun autre client n'est pr�sent, il r�veille le barbier et se place sur le
 * fauteuil pour se faire raser. Dans le cas ou il y a d�j� quelqu'un entrain
 * se faire raser, il se met dans la salle d'attente, si celle-ci est pleine,
 * il quitte la boutique pour y revenir plus tard.\n
 * Le nombre de si�ges de la salle d'attente ainsi que le nombre de clients
 * est d�finit � l'execution.\n
 * Le mode de fonctionnement de la file d'attente est FIFO (premier arriv�,
 * premier servi). Pour g�rer ce cas, sachant que le moniteur ne le fait pas par
 * d�faut comme les s�maphores, nous avons impl�ment�s un syst�me de liste 
 * circulaire.
 */ 
 
 /**
 * \section Saisie utilisateur
 * Pour la saisie du nombre de clients et de si�ges. Une boucle se charge
 * de demander la saisie d'un entier, une erreur se produit si l'entier
 * n'est pas plus grand ou �gal � z�ro. Dans ce cas le programme demande
 * un nouveau nombre. Si tout autre caract�re est saisi, il sera ignor�.\n
 */
 
 /**
 * \section Remarques
 * La gestion des valeurs al�atoires est tr�s probl�matique dans le cadre de
 * programmation concurente, en effet malgr� une seule initialisation de la
 * racine du g�n�rateur, lors de l'execution de la simulation tous les clients
 * on le m�me temps pour la pousse des cheveux, cela leur donne une certaine
 * synchronisation qui nous emp�che de pouvoir observer tous les cas
 * d'executions. Nous avons essay� de reg�n�rer une nouvelle racine � chaque
 * appel de la fonction retournant un nombre al�atoire en fonction de l'heure,
 * mais comme l'unit� est la seconde, cela n'arrange en rien notre probl�me,
 * l'execution �tant beaucoup plus rapide. Une solution reste a �tre trouv�e.
 */

 /**
 * \section Tests
 * Afin de tester le bon fonctionnement de notre impl�mentation, nous avons
 * utilis� plusieurs syst�mes d'exploitations, notamment Windows XP et une
 * distribution d'Ubuntu sur machine virtuelle.\n
 * 
 * Les tests consistent � suivre le bon d�roulement de la simulation, trois
 * cas principaux sont possibles :\n
 * - Plus de clients que de chaises en salle d'attente\n
 * - Moins de clients que de chaises en salle d'attente\n
 * - Autant de clients que de chaises en salle d'attente
 * 
 * Dans les trois situations, notre programme a fonctionn� plus de 3 minutes
 * sans probl�mes et ce sur les deux platformes.
 */
 
 /**
 * \section section Compilation, Librairies et Environnements
 * Compilateur :     gcc 3.4.2\n
 * Environnements :  Windows XP Pro - Intel T2500 et Linux Ubuntu - VMWare\n
 * Librairies :      lpthreadGC2
 */
 
 /**
 * \section Conlusion
 * Nous avons pu remarquer la complexit� d'une application multit�che dont la
 * synchronisation est g�r�e par des moniteurs. Il doit certainement exister 
 * beaucoup d'autres solutions � ce cahier des charges, nous avons impl�ment� 
 * celle qui nous paraissait la plus logique.
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdio.h>
#include <pthread.h>
#include <stdbool.h>
#include "psleep.h"

/**
 * Constantes d�finies pour le temps de repousse
 */
const unsigned int REPOUSSE_MIN = 10;
const unsigned int REPOUSSE_MAX = 20;

/**
 * Temps d�fini pour effectuer la coupe de cheveux (en secondes)
 */
const unsigned int DUREE_COUPE = 10;

// D�claration du thread du barbier
pthread_t t_barbier;

// D�claration des threads pour les clients
pthread_t * t_clients;



/**
 * Retourne un nombre al�atoire entre deux bornes, min et max sont d�termin�s
 * automatiquement au cas ou l'utilisateur inverse les bornes
 * 
 * \param borne_inf Bonre inferieure comprise
 * \param borne_sup Borne supp�rieure comprise
 * \return Nombre al�atoire entre les bornes
 */
int nombreAleatoire(int borne_inf, int borne_sup)
{
   // Inversion des bornes si l'utilisateur s'est tromp�
   int min = borne_inf < borne_sup ? borne_inf : borne_sup;
   int max = borne_inf < borne_sup ? borne_sup : borne_inf;
   
   return (rand() % (max - min)) + min;
}



/**
 * Effectue la saisie d'un entier strictement positif
 * 
 * \param message Message destin� � l'utilisateur
 * \return Entier positif saisi
 */
unsigned int saisieEntierPositif(char * message)
{
   unsigned int saisie = 0;
   int caractere;

   // Tant que la saisie n'est pas positive
   while (saisie <= 0)
   {
      printf("Veuillez saisir %s [1, inf] : ", message);
      
      // R�cup�re un entier
      if (scanf("%d", &saisie) == 0)
         saisie = 0;
      
      // Vide le buffer de tout caract�re innutile
      while ((caractere = getchar()) != '\n' && caractere != EOF)
         ;
   }

   printf("\n");
   return saisie;
}



/**
 * Fonction d�terminant l'activit� du thread Barbier, son travail consiste �,
 * si des clients sont en attentes, de les raser dans leur ordre d'arriv�e, et
 * sinon de s'endormir sur son fauteuil.\n
 * Le temps du rasage a �t� d�fini dans une constante globale.
 * 
 * \param args Arguments d'entr�e de la fonction (Non utilis�)
 * \return Argument de sortie de la methode (Non utilis�)
 */
void * barbier_run (void * args)
{
   // Le barbier sera vivant pendant toute la dur�e du programme
   while (true)
   {
      // On attend qu'un client se pr�sente
      printf("Barbier  - Pret a travailler !\n");
      
      // On v�rifie si la salle d'attente est vide
      if (estSalleVide())
      {   
         // On attend qu'un client arrive
         printf("Barbier  - Pas de client, le barbier s'endort.\n");
         barbier_wait();
         printf("Barbier  - Le barbier est reveille.\n");
      }
      // Si la salle n'est pas vide
      else
      {
         printf("Barbier  - Appelle un nouveau client depuis la salle d'attente.\n");
         reveillerProchainClient();
         printf("Barbier  - Commence le rasage.\n");
      }
      
      // On attend le temps d�fini pour effectuer la coupe de cheveux
      sleep(DUREE_COUPE);
      
      // On avertit le client que sa coupe est termin�e
      printf("Barbier  - Fin du rasage.\n");
      rasage_notify();
   }
}



/**
 * Fonction d�terminant l'activit� d'un thread client. Son cycle de vie :
 * - Les cheveux du client doivent pousser\n
 * - Fait entrer le client dans la boutique\n
 * - R�veille le barbier s'il dort et se place dans le fauteuil\n
 * - Se place dans la salle d'attente si le barbier travaille deja\n
 * - Quitte la boutique si la salle d'attente est pleine\n
 * - Attend que le barbier finisse la coupe pour relancer un cycle
 * 
 * \param args Passe l'ID du client au thread
 * \return Argument de sortie de la methode (Non utilis�)
 */
void * client_run (void * args)
{
   // ID du client, pass� en param�tre
   const unsigned int ID = (int) args;
   // Temps de repousse d�fini al�atoirement
   //const unsigned int TEMPS_REPOUSSE = nombreAleatoire(REPOUSSE_MIN, REPOUSSE_MAX);
   const unsigned int TEMPS_REPOUSSE = ID * 2 + 5;
      

   // Client d�finis � l'infini
   while (true)
   {
      // On attend que les cheveux du client repoussent
      printf("Client %d - Attend %d secondes que sa barbe pousse.\n", 
            ID, TEMPS_REPOUSSE);

      // On attend que les cheveux du client repousse
      sleep(TEMPS_REPOUSSE);

      // Le client obtient un si�ge en salle d'attente et attend que le barbier se lib�re
      while (! essayerEntrerBoutique(ID))
      {
         printf("Client %d - Repart pendant %d secondes, la salle d'attente "
               "est pleine\n",  ID, TEMPS_REPOUSSE / 2);

         // On attend la moiti� du temps de repousse car la salle d'attente est pleine (selon �nonc�)
         sleep(TEMPS_REPOUSSE / 2);
      }
      
      // Le client va s'installer sur le fauteuil du barbier pour se faire raser
      printf("Client %d - Le rasage commence\n", ID);
      rasage_wait();
      //printf("Client %d - Le rasage est termine\n", ID);
   }
}



/**
 * Fonction permettant d'initialiser la simulation, initialise les threads
 */
void init(unsigned int nbClients, unsigned int nbSieges)
{
   moniteur_init(nbSieges);
   t_clients = malloc(nbClients * sizeof(pthread_t));
}



/**
 * Fonction permettant de lib�rer la m�moire allou�e dans la m�thode init()
 */
void libererMemoire()
{
   free(t_clients);
}



/**
 * Fonction de d�marrage du programme, lance l'initialisation et d�marre
 * les threads
 */
int main(int argc, char *argv[])
{
   // Nombre de place dans la salle d'attente
   const int NB_SIEGES = saisieEntierPositif("le nombre de sieges");
   
   // Nombre de clients
   const int NB_CLIENTS = saisieEntierPositif("le nombre de clients");
   
   int i, err;

   // Initialisation de la racine du g�n�rateur al�atoire
   srand(time(NULL));
   
   // Initalise les threads
   init(NB_CLIENTS, NB_SIEGES);
   
   // Avant la fermeture du programme, lib�re proprement la m�moire allou�e
   atexit(libererMemoire);
   
   // Cr�ation du thread pour le barbier
   if ((err = pthread_create(&t_barbier, NULL, barbier_run, NULL)) != 0)
   {
      printf("Erreur lors de la cr�ation du thread : barbier\n");
      return EXIT_FAILURE;
   }
   
   // Cr�ation des threads pour les clients
   for (i = 0; i < NB_CLIENTS; i++)
   {
      if ((err = pthread_create(&t_clients[i], NULL, client_run, i)) != 0)
      {
         printf("Erreur lors de la cr�ation du thread : client\n");
         return EXIT_FAILURE;
      }
   }
   
   //system("PAUSE");
   pthread_exit(EXIT_SUCCESS);
}
