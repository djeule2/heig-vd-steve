#ifndef H_CTRAIN_HANDLER

#define H_CTRAIN_HANDLER

/*
 * Fichier          : ctrain_handler.h
 * Auteur           : Kevin Georgy
 *
 * Date de creation : 4.2.2009
 * But              : Fournit les fonctions de controle du simulateur/maquette de trains.
 *                    Mappage en C des fonctions fournies par "train_handler.ads".
 * Revision         : 27.3.2009 (CEZ)
 *                    27.4.2009 (KGY) Ajout du extern "CE pour les applications c++
 */

#ifdef __cplusplus
extern "C" {
#endif

// Vitesse a l'arret
#define	VITESSE_NULLE 0

// Vitesse minimum
#define	VITESSE_MINIMUM 3

// Vitesse maximum
#define	VITESSE_MAXIMUM 14

// Numero max. d'aiguillage
#define	MAX_AIGUILLAGES 80

// Numero max. de contact
#define MAX_CONTACTS 64

// Numero max. de loco
#define	MAX_LOCOS 80

// Direction des aiguillages
#define DEVIE 0
#define TOUT_DROIT 1

// Etat des phares
#define ETEINT 0
#define ALLUME 1

/*
 * Initialise la communication avec la maquette/simulateur.
 * A appeler au debut du programme client.
 */
void init_maquette(void);

/*
 * Met fin a la simulation. A appeler a la fin du programme client.
 */
void mettre_maquette_hors_service(void);

/*
 * Realimente la maquette. Inutile apres init_maquette().
 */
void mettre_maquette_en_service(void);

/*
 * Change la direction d'un aiguillage.
 *   no_aiguillage : No de l'aiguillage a diriger.
 *   direction     : Nouvelle direction. (DEVIE ou TOUT_DROIT)
 *   temps_alim    : Temps l'alimentation minimal du bobinage de l'aiguillage.
 */
void diriger_aiguillage(int no_aiguillage, int direction, int temps_alim);

/*
 * Attend l'activation du contact donne.
 *   no_contact : No du contact dont on attend l'activation.
 */
void attendre_contact(int no_contact);

/*
 * Arrete une locomotive (met sa vitesse a VITESSE_NULLE).
 *   no_loco : No de la loco a arreter.
 */
void arreter_loco(int no_loco);

/*
 * Change la vitesse d'une loco par palier.
 *   no_loco        : No de la loco a stopper.
 *   vitesse_future : Vitesse apres changement.
 * Remarque : Dans le simulateur cette procedure agit comme la fonction
 *            "mettre_vitesse_loco". C'est-a-dire que l'acceleration est immediate (de la
 *            vitesse actuelle a la vitesse specifiee).
 */
void mettre_vitesse_progressive(int no_loco, int vitesse_future);

/*
 * Permettre d'allumer ou d'eteindre les phares de la locomotive.
 *   no_loco : No de la loco a controler.
 *   etat    : Nouvel etat des phares. (ETEINT ou ALLUME)
 * Remarque : Dans le simulateur cette fonction n'a aucun effet.
 *            Les locomotive sont representee par des rectangles et possedent une partie
 *            jaune indiquant le sens de deplacement. L'utilisation des phares n'est donc
 *            plus utile.
 */
void mettre_fonction_loco(int no_loco, char etat);

/*
 * Inverse le sens d'une locomotive, en conservant sa vitesse.
 *   no_loco : No de la loco a inverser.
 */
void inverser_sens_loco(int no_loco);

/*
 * Change la vitesse d'une loco.
 *   no_loco : No de la loco a controler.
 *   vitesse : Nouvelle vitesse.
 */
void mettre_vitesse_loco(int no_loco, int vitesse);

/*
 * Indique au simulateur de demander une loco a l'utilisateur. L'utilisateur entre le
 * numero et la vitesse de la loco. Celle-ci est ensuite placee entre les contacts
 * "contact_a" et "contact_b".
 *   contact_a   : Contact vers lequel la loco va se diriger.
 *   contact_b   : Contact a l'arriere de la loco.
 *   numero_loco : Numero de loco choisi par l'utilisateur.
 *   vitesse     : Vitesse choisie par l'utilisateur.
 */
void demander_loco(int contact_a, int contact_b, int *no_loco, int *vitesse);

#ifdef __cplusplus
}
#endif

#endif

