/**
 * \file moniteur.c
 * \author Stéphane Besuchet & Grégoire Corpataux
 * \date 11.06.2010
 * \version 1.0.42
 */
#include "moniteur.h"

/** Verrou pour l'exclusion mutuelle des appels aux methodes du moniteur */
static pthread_mutex_t mutexMoniteur;

/** Mutex pour l'accès aux variables globales */
static pthread_mutex_t mutex;


/** Condition pour le reveil du barbier */
static pthread_cond_t condBarbier;

/** Condition pour le reveil du client après rasage */
static pthread_cond_t condRasage;

/** Condition pour le reveil d'un client sur un siège */
static pthread_cond_t * condSiege;


/** Nombre de sièges de la salle d'attente */
unsigned int            nbSieges;

/** Occupation de la salle d'attente */
volatile unsigned int   occupation;

/** Siège suivant disponible dans le cadre d'un tableau de sièges parcouru 
 * cycliquement  */
volatile unsigned int   siegeDisponibleSuivant;

/** Client suivant dans le tableau des sièges parcouru cycliquement */
volatile unsigned int   clientSuivant;

/** Définit si le barbier est en train de dormir sur son siège */
volatile bool           barbierLibre;



/**
 * Permet l'initialisation du moniteur, initialise les variables conditions,
 * les verrous et les variables globalse
 * 
 * \param nombreSieges Nombre de sièges de la salle d'attente
 */
void moniteur_init(unsigned int nombreSieges)
{
   pthread_mutex_init(&mutexMoniteur, NULL);
   pthread_mutex_init(&mutex, NULL);
   
   pthread_cond_init(&condBarbier, NULL);
   pthread_cond_init(&condRasage, NULL);
   condSiege = malloc(nombreSieges * sizeof(pthread_cond_t));
   
   unsigned int i;
   
   for(i = 0; i < nombreSieges; i++)
      pthread_cond_init(&condSiege[i], NULL);
   
   nbSieges = nombreSieges;
   occupation = 0;
   siegeDisponibleSuivant = 0;
   clientSuivant = 0;
   barbierLibre = true;
}



/**
 * Permet la libèration de la mémoire allouée à l'initalisation du moniteur
 */
void moniteur_libererMemoire(void)
{
   free(condSiege);
}



/**
 * Met le barbier en attente, implique qu'il est endormi sur son fauteuil et
 * le défini comme libre (pas entrain de travailler)
 */
void barbier_wait(void)
{
   pthread_mutex_lock(&mutexMoniteur);
      barbierLibre = true;
      pthread_cond_wait(&condBarbier, &mutexMoniteur);
   pthread_mutex_unlock(&mutexMoniteur);
}



/**
 * Permet de reveiller le barbier
 */
void barbier_notify(void)
{
   pthread_mutex_lock(&mutexMoniteur);
      pthread_cond_signal(&condBarbier);
   pthread_mutex_unlock(&mutexMoniteur);
}



/**
 * Permet de mettre un client en attente de fin de rasage, utilisé pour
 * synchroniser le client avec le barbier lors de la coupe
 */
void rasage_wait(void)
{
   pthread_mutex_lock(&mutexMoniteur);
      pthread_cond_wait(&condRasage, &mutexMoniteur);
   pthread_mutex_unlock(&mutexMoniteur);
}



/**
 * Reveille le client en attente de la fin du rasage
 */
void rasage_notify(void)
{
   pthread_mutex_lock(&mutexMoniteur);
      pthread_cond_signal(&condRasage);
   pthread_mutex_unlock(&mutexMoniteur);
}



/**
 * Met le client en attente sur un siège de la salle d'attente précis
 * 
 * \param siege Numéro du siège concerné
 */
void siege_wait(int siege)
{
   pthread_mutex_lock(&mutexMoniteur);
      pthread_cond_wait(&condSiege[siege], &mutexMoniteur);
   pthread_mutex_unlock(&mutexMoniteur);
}



/**
 * Reveille le client en attente sur un siège de la salle d'attente précis
 * 
 * \param siege Numéro du siège concerné
 */
void siege_notify(int siege)
{
   pthread_mutex_lock(&mutexMoniteur);
      pthread_cond_signal(&condSiege[siege]);
   pthread_mutex_unlock(&mutexMoniteur);
}



/**
 * Permet de reveiller le prochain client à être servi par le barbier.
 */
void reveillerProchainClient(void)
{
   pthread_mutex_lock(&mutex);
      occupation--;
      // Déplace le pointeur sur le client suivant
      clientSuivant++;
      clientSuivant %= nbSieges;
      barbierLibre = false;
   pthread_mutex_unlock(&mutex);
   siege_notify(clientSuivant);
}



/**
 * Permet de gérer un client qui rentre dans la boutique, 
 * retourne faux si la salle d'attente est pleine et si le client doit revenir
 * plus tard, sinon si le barbier est endormi, il le reveille et se place dans
 * le fauteuil pour se faire raser, sinon il se met dans la salle d'attente.
 * 
 * \param id Identifiant du thread pour les affichage internes
 * \return Faux si la salle d'attente est pleine, vrai sinon
 */
bool essayerEntrerBoutique(unsigned int id)
{
   pthread_mutex_lock(&mutex);
   
   if(occupation == nbSieges)
   {
      pthread_mutex_unlock(&mutex);
      return false;
   }
   
   if(! barbierLibre)
   {
      // Se place dans la salle d'attente
      occupation++;
      // Déplace le pointeur sur le prochain siège libre
      siegeDisponibleSuivant++;
      siegeDisponibleSuivant %= nbSieges;
      printf("Client %d - Se place en salle d'attente\n", id);
      pthread_mutex_unlock(&mutex);
      // Attend d'être appelé pour se faire raser
      siege_wait(siegeDisponibleSuivant);
   }
   else
   {
      // Reveille le barbier
      barbierLibre = false;
      printf("Client %d - Reveille le barbier\n", id);
      pthread_mutex_unlock(&mutex);
      barbier_notify();
   }
   
   return true;
}



/**
 * Retourne vrai si la salle d'attente est vide
 * 
 * \return Vrai si la salle est vide
 */
bool estSalleVide(void)
{
   bool val = false;
      pthread_mutex_lock(&mutex);
         if(occupation == 0)
            val = true;
      pthread_mutex_unlock(&mutex);
   return val;
}
