/** \file main.c
 *
 * Programme exemple d'utilisation de la librairie libtrainsim.
 *
 * - Demande une locomotive au simulateur, celle-ci sera positionnée entre
 *   les contacts 6 et 11.
 * - Démarre la loco et la fait parcourir les contacts 6, 11, 10, 13, 14, 19, 3 avant
 *   de la stopper.
 *
 * Utilisation :
 * - Démarrer le simulateur : dans un terminal, lancer trainsim
 * - Lancer ce programme.
 * - Le simulateur demande la maquette à utiliser, entrer B1.
 * - Entrer les options par défaut au questions suivantes.
 * - Le simulateur demande le numéros et la vitesse de la loco à utiliser, entrer
 *   des valeurs corrects.
 * - La simulation commence.
 * - Pour mettre fin à la simulation entrer CTRL-C dans le termial du simulateur et mettre fin
 *   au programme exemple.
 *
 * \author Kevin Georgy
 * \date 26.03.09
 */

#include <stdlib.h>
#include <stdio.h>

// Fichier en-tête de la librairie libtrainsim
#include <trainsim/ctrain_handler.h>

// Contacts à parcourir
#define NB_CTS 7
int parcours[] = {6, 11, 10, 13, 14, 19, 3};

/**
 * Programme principal
 */
int main(void) {

	// Numéros et vitesse de la loco qui sera utilisée
	int no, vit;
	int ct;

	// Initialisation de la maquette (à effectuer une seule fois en début de programme)
	init_maquette();

	// Demande au simulateur de placer une loco entre les contacts 6 et 11. Attention à l'ordre!
	// Récupère le numéros et la vitesse saisis par l'utilisateur.
	demander_loco(parcours[1], parcours[0], &no, &vit);

	// Dirige les aiguillages sur le parcours
	diriger_aiguillage(7, TOUT_DROIT, 0);
	diriger_aiguillage(8, DEVIE, 0);
	diriger_aiguillage(5, TOUT_DROIT, 0);
	diriger_aiguillage(9, DEVIE, 0);
	diriger_aiguillage(10, TOUT_DROIT, 0);
	diriger_aiguillage(14, TOUT_DROIT, 0);
	diriger_aiguillage(13, DEVIE, 0);
	diriger_aiguillage(1, TOUT_DROIT, 0);

	// Démarre la loco
	mettre_vitesse_loco(no, vit);

	// Attend que la loco passe sur les différents contacts de son parcours.
	for (ct=1; ct<NB_CTS; ct++) {
		attendre_contact(parcours[ct]);
		printf("Loco %d de vitesse %d a atteint le contact %d.\n",
				vit, no, ct);
	}

	// Stoppe la loco.
	arreter_loco(no);

	// Fin de la simulation (à effectuer une seule fois en fin de programme, sans effet
	// sur le simulateur, mais nécessaire sur les maquettes réelles).
	mettre_maquette_hors_service();

	// Fin du programme
	exit(0);
}
