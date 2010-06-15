/**
 * \mainpage Modélisation par moniteur - Boutique de Barbier
 * Le présent document décrit le développement du laboratoire du cours de PCO 
 * pour la modélisation d’un problème concurrent à l’aide de moniteurs. 
 */

/**
 * \file main.c
 * \author Stéphane Besuchet & Grégoire Corpataux
 * \date 11.06.2010
 * \version 1.0.42
 */

 /**
 * \section Introduction
 * Ce laboratoire effectue la simulation d'une boutique de barbier avec
 * plusieurs clients et une salle d'attente. L'utilisation de moniteurs sera
 * nécessaire pour gérer le comportement des clients et du barbier.
 */
 
 /**
 * \section Description
 * Chaque client à un cycle de vie assez simple, premièrement il attend que ses
 * cheveux poussent puis il se rend dans la boutique du barbier, dès lors, si
 * aucun autre client n'est présent, il réveille le barbier et se place sur le
 * fauteuil pour se faire raser. Dans le cas ou il y a déjà quelqu'un entrain
 * se faire raser, il se met dans la salle d'attente, si celle-ci est pleine,
 * il quitte la boutique pour y revenir plus tard.\n
 * Le nombre de sièges de la salle d'attente ainsi que le nombre de clients
 * est définit à l'execution.\n
 * Le mode de fonctionnement de la file d'attente est FIFO (premier arrivé,
 * premier servi). Pour gérer ce cas, sachant que le moniteur ne le fait pas par
 * défaut comme les sémaphores, nous avons implémentés un système de liste 
 * circulaire.
 */ 
 
 /**
 * \section Saisie utilisateur
 * Pour la saisie du nombre de clients et de sièges. Une boucle se charge
 * de demander la saisie d'un entier, une erreur se produit si l'entier
 * n'est pas plus grand ou égal à zéro. Dans ce cas le programme demande
 * un nouveau nombre. Si tout autre caractère est saisi, il sera ignoré.\n
 */
 
 /**
 * \section Remarques
 * La gestion des valeurs aléatoires est très problèmatique dans le cadre de
 * programmation concurente, en effet malgré une seule initialisation de la
 * racine du générateur, lors de l'execution de la simulation tous les clients
 * on le même temps pour la pousse des cheveux, cela leur donne une certaine
 * synchronisation qui nous empèche de pouvoir observer tous les cas
 * d'executions. Nous avons essayé de regénérer une nouvelle racine à chaque
 * appel de la fonction retournant un nombre aléatoire en fonction de l'heure,
 * mais comme l'unité est la seconde, cela n'arrange en rien notre problème,
 * l'execution étant beaucoup plus rapide. Une solution reste a être trouvée.
 */

 /**
 * \section Tests
 * Afin de tester le bon fonctionnement de notre implémentation, nous avons
 * utilisé plusieurs systèmes d'exploitations, notamment Windows XP et une
 * distribution d'Ubuntu sur machine virtuelle.\n
 * 
 * Les tests consistent à suivre le bon déroulement de la simulation, trois
 * cas principaux sont possibles :\n
 * - Plus de clients que de chaises en salle d'attente\n
 * - Moins de clients que de chaises en salle d'attente\n
 * - Autant de clients que de chaises en salle d'attente
 * 
 * Dans les trois situations, notre programme a fonctionné plus de 3 minutes
 * sans problèmes et ce sur les deux platformes.
 */
 
 /**
 * \section section Compilation, Librairies et Environnements
 * Compilateur :     gcc 3.4.2\n
 * Environnements :  Windows XP Pro - Intel T2500 et Linux Ubuntu - VMWare\n
 * Librairies :      lpthreadGC2
 */
 
 /**
 * \section Conlusion
 * Nous avons pu remarquer la complexité d'une application multitâche dont la
 * synchronisation est gérée par des moniteurs. Il doit certainement exister 
 * beaucoup d'autres solutions à ce cahier des charges, nous avons implémenté 
 * celle qui nous paraissait la plus logique.
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdio.h>
#include <pthread.h>
#include <stdbool.h>
#include "psleep.h"

/**
 * Constantes définies pour le temps de repousse
 */
const unsigned int REPOUSSE_MIN = 10;
const unsigned int REPOUSSE_MAX = 20;

/**
 * Temps défini pour effectuer la coupe de cheveux (en secondes)
 */
const unsigned int DUREE_COUPE = 10;

// Déclaration du thread du barbier
pthread_t t_barbier;

// Déclaration des threads pour les clients
pthread_t * t_clients;



/**
 * Retourne un nombre aléatoire entre deux bornes, min et max sont déterminés
 * automatiquement au cas ou l'utilisateur inverse les bornes
 * 
 * \param borne_inf Bonre inferieure comprise
 * \param borne_sup Borne suppérieure comprise
 * \return Nombre aléatoire entre les bornes
 */
int nombreAleatoire(int borne_inf, int borne_sup)
{
   // Inversion des bornes si l'utilisateur s'est trompé
   int min = borne_inf < borne_sup ? borne_inf : borne_sup;
   int max = borne_inf < borne_sup ? borne_sup : borne_inf;
   
   return (rand() % (max - min)) + min;
}



/**
 * Effectue la saisie d'un entier strictement positif
 * 
 * \param message Message destiné à l'utilisateur
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
      
      // Récupère un entier
      if (scanf("%d", &saisie) == 0)
         saisie = 0;
      
      // Vide le buffer de tout caractère innutile
      while ((caractere = getchar()) != '\n' && caractere != EOF)
         ;
   }

   printf("\n");
   return saisie;
}



/**
 * Fonction déterminant l'activité du thread Barbier, son travail consiste à,
 * si des clients sont en attentes, de les raser dans leur ordre d'arrivée, et
 * sinon de s'endormir sur son fauteuil.\n
 * Le temps du rasage a été défini dans une constante globale.
 * 
 * \param args Arguments d'entrée de la fonction (Non utilisé)
 * \return Argument de sortie de la methode (Non utilisé)
 */
void * barbier_run (void * args)
{
   // Le barbier sera vivant pendant toute la durée du programme
   while (true)
   {
      // On attend qu'un client se présente
      printf("Barbier  - Pret a travailler !\n");
      
      // On vérifie si la salle d'attente est vide
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
      
      // On attend le temps défini pour effectuer la coupe de cheveux
      sleep(DUREE_COUPE);
      
      // On avertit le client que sa coupe est terminée
      printf("Barbier  - Fin du rasage.\n");
      rasage_notify();
   }
}



/**
 * Fonction déterminant l'activité d'un thread client. Son cycle de vie :
 * - Les cheveux du client doivent pousser\n
 * - Fait entrer le client dans la boutique\n
 * - Réveille le barbier s'il dort et se place dans le fauteuil\n
 * - Se place dans la salle d'attente si le barbier travaille deja\n
 * - Quitte la boutique si la salle d'attente est pleine\n
 * - Attend que le barbier finisse la coupe pour relancer un cycle
 * 
 * \param args Passe l'ID du client au thread
 * \return Argument de sortie de la methode (Non utilisé)
 */
void * client_run (void * args)
{
   // ID du client, passé en paramètre
   const unsigned int ID = (int) args;
   // Temps de repousse défini aléatoirement
   //const unsigned int TEMPS_REPOUSSE = nombreAleatoire(REPOUSSE_MIN, REPOUSSE_MAX);
   const unsigned int TEMPS_REPOUSSE = ID * 2 + 5;
      

   // Client définis à l'infini
   while (true)
   {
      // On attend que les cheveux du client repoussent
      printf("Client %d - Attend %d secondes que sa barbe pousse.\n", 
            ID, TEMPS_REPOUSSE);

      // On attend que les cheveux du client repousse
      sleep(TEMPS_REPOUSSE);

      // Le client obtient un siège en salle d'attente et attend que le barbier se libère
      while (! essayerEntrerBoutique(ID))
      {
         printf("Client %d - Repart pendant %d secondes, la salle d'attente "
               "est pleine\n",  ID, TEMPS_REPOUSSE / 2);

         // On attend la moitié du temps de repousse car la salle d'attente est pleine (selon énoncé)
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
 * Fonction permettant de libérer la mémoire allouée dans la méthode init()
 */
void libererMemoire()
{
   free(t_clients);
}



/**
 * Fonction de démarrage du programme, lance l'initialisation et démarre
 * les threads
 */
int main(int argc, char *argv[])
{
   // Nombre de place dans la salle d'attente
   const int NB_SIEGES = saisieEntierPositif("le nombre de sieges");
   
   // Nombre de clients
   const int NB_CLIENTS = saisieEntierPositif("le nombre de clients");
   
   int i, err;

   // Initialisation de la racine du générateur aléatoire
   srand(time(NULL));
   
   // Initalise les threads
   init(NB_CLIENTS, NB_SIEGES);
   
   // Avant la fermeture du programme, libère proprement la mémoire allouée
   atexit(libererMemoire);
   
   // Création du thread pour le barbier
   if ((err = pthread_create(&t_barbier, NULL, barbier_run, NULL)) != 0)
   {
      printf("Erreur lors de la création du thread : barbier\n");
      return EXIT_FAILURE;
   }
   
   // Création des threads pour les clients
   for (i = 0; i < NB_CLIENTS; i++)
   {
      if ((err = pthread_create(&t_clients[i], NULL, client_run, i)) != 0)
      {
         printf("Erreur lors de la création du thread : client\n");
         return EXIT_FAILURE;
      }
   }
   
   //system("PAUSE");
   pthread_exit(EXIT_SUCCESS);
}
