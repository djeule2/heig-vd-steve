#include <stdlib.h>
#include <stdio.h>
// Fichier en-tÃªte de la librairie libtrainsim
#include <trainsim/ctrain_handler.h>
#include <pthread.h>
#include <errno.h>
#include <time.h>

// Les différents parcours des locomotives
int parcours1[] = {16,21,22,3,4,9,12,17};
int parcoursEvitement[] = {24,5};
int parcours2[] = {13,14,19,1,2,7};

// Type structure représentant une locomotive
typedef struct{
	int numero;
	int vitesse;
	int nbContact;
}loco_t;

loco_t locomotive1;
loco_t locomotive2;

pthread_t thread1;
pthread_t thread2;
pthread_t thread3;


// Mutex permettant de gérer le tronçon critique
static pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;

// Thread gÃ©rant la locomotive nÂ°1
void *locomotive1_tache(void* arg){
	int i;
	const unsigned periodeMinutes = 1;
	long attenteClocks;
	struct timeval periode, prochaineEcheance, maintenant;
	struct timespec delai;

	periode.tv_sec = periodeMinutes * 60;
	periode.tv_usec = 0;
	gettimeofday(&prochaineEcheance,NULL);
	for(i=0; i<5; i+=1){
		prochaineEcheance.tv_sec += periode.tv_sec;

		// Démarre la loco
		mettre_vitesse_progressive(locomotive1.numero, locomotive1.vitesse);

		int ct;
		// Attend que la loco passe sur les différents contacts de son parcours.
		for (ct=1; ct<locomotive1.nbContact; ct++){
			attendre_contact(parcours1[ct]);
			// On test si la locomotive 1 arrive en section critique
			if(parcours1[ct] == 21){
				switch(pthread_mutex_trylock(&mutex)){
					case 0:		printf("loco1 dans section critique\n");
								// On règle les aiguillages
								diriger_aiguillage(13, TOUT_DROIT, 0);
								diriger_aiguillage(1, TOUT_DROIT, 0);
								ct+=2;
								// On attend que la loco ait passé (contact 3 dans notre cas)
								attendre_contact(parcours1[ct]);
								// On dévérouille la section critique
								pthread_mutex_unlock(&mutex);
								break;

					case EBUSY:	// On prend la voie d'évitement
								diriger_aiguillage(15, DEVIE,0);
								diriger_aiguillage(16, TOUT_DROIT,0);
								diriger_aiguillage(18, DEVIE,0);
								diriger_aiguillage(3, TOUT_DROIT,0);
								ct+=3;
								attendre_contact(parcours1[ct]);
								printf("mouh");
								diriger_aiguillage(16,DEVIE,0);
								diriger_aiguillage(3,DEVIE,0);
								break;

					case EINVAL: printf("Le verrou1 est invalide \n");
								 break;
				}
			}
				printf("Loco %d de vitesse %d a atteint le contact %d.\n",
					locomotive1.numero, locomotive1.vitesse, ct);

		}
		attendre_contact(parcours1[0]);
		arreter_loco(locomotive1.numero);
		gettimeofday(&maintenant,NULL);
		delai.tv_sec = prochaineEcheance.tv_sec - maintenant.tv_sec;
		delai.tv_nsec = (prochaineEcheance.tv_usec - maintenant.tv_usec)*1000;
		while(delai.tv_nsec < 0){
			delai.tv_sec -= 1;
			delai.tv_nsec += 1000000000;
		}
		if (delai.tv_sec >= 0){
			printf("Attente de %d sec et %d nanos\n",(int)delai.tv_sec,(int)delai.tv_nsec);
			nanosleep(&delai,NULL);
		}
	}

	return NULL;
}

// Thread gÃ©rant la locomotive nÂ°2
void *locomotive2_tache(void* arg){
	int i;
	const unsigned periodeMinutes = 1;
	long attenteClocks;
	struct timeval periode, prochaineEcheance, maintenant;
	struct timespec delai;

	periode.tv_sec = periodeMinutes * 60;
	periode.tv_usec = 0;
	gettimeofday(&prochaineEcheance,NULL);
	for(i=0; i<5; i+=1){
		prochaineEcheance.tv_sec += periode.tv_sec;
		// On démarre la locomotive
		mettre_vitesse_progressive(locomotive2.numero, locomotive2.vitesse);
		int ct;
		printf("yihaa");
		// Attend que la loco passe sur les diffÃ©rents contacts de son parcours.
		for (ct=1; ct<locomotive2.nbContact; ct++) {
			printf("%d",ct);
			attendre_contact(parcours2[ct]);
			// Si on arrive sur le tronçon critique
			if(parcours2[ct] == 19){
				switch(pthread_mutex_trylock(&mutex)){
					case 0:			printf("loco2 dans section critique\n");
									// On règle les aiguillages
									diriger_aiguillage(13, DEVIE, 0);
									diriger_aiguillage(1, DEVIE, 0);
									// On attend que la locomotive 2 ait atteint le prochain contact
									attendre_contact(parcours2[++ct]);
									// On dévérouille le mutex
									pthread_mutex_unlock(&mutex);
									break;

					case EBUSY:		printf("loco2 attente");
									// On s'arrête
									arreter_loco(locomotive2.numero);
									// On attend que la loco 1 ait quitter la section critique
									pthread_mutex_lock(&mutex);
									diriger_aiguillage(13, DEVIE, 0);
									diriger_aiguillage(1, DEVIE, 0);
									// On redémarre la locomotive
									mettre_vitesse_loco(locomotive2.numero, locomotive2.vitesse);
									// On attend que la locomotive 2 ait atteint le prochain contact
									attendre_contact(parcours2[++ct]);
									pthread_mutex_unlock(&mutex);
									break;

					case EINVAL:	printf("Le verrou2 est invalide \n");
									break;
				}
			}
			printf("Loco %d de vitesse %d a atteint le contact %d.\n",
					locomotive2.numero, locomotive2.vitesse, ct);
		}
		attendre_contact(parcours2[0]);
		arreter_loco(locomotive2.numero);
		gettimeofday(&maintenant,NULL);
		delai.tv_sec = prochaineEcheance.tv_sec - maintenant.tv_sec;
		delai.tv_nsec = (prochaineEcheance.tv_usec - maintenant.tv_usec)*1000;
		while(delai.tv_nsec < 0){
			delai.tv_sec -= 1;
			delai.tv_nsec += 1000000000;
		}
		if (delai.tv_sec >= 0){
			printf("Attente de %d sec et %d nanos\n",(int)delai.tv_sec,(int)delai.tv_nsec);
			nanosleep(&delai,NULL);
		}
	}

	return NULL;
}

void *arret_urgence(void* arg){

	char character;
	while(1){
		if((character = getchar()) == 's'){
				arreter_loco(locomotive1.numero);
				arreter_loco(locomotive2.numero);
				pthread_cancel(thread1);
				pthread_cancel(thread2);
		}
	}
}


int main(void){

	// Initialisation du simulateur
	init_maquette();

	locomotive1.nbContact = 8;
	locomotive2.nbContact = 6 ;

	// Placement de la locomotive entre les deux premiers contacts du parcours
	demander_loco(parcours1[1], parcours1[0], &locomotive1.numero, &locomotive1.vitesse);
	demander_loco(parcours2[1], parcours2[0], &locomotive2.numero, &locomotive2.vitesse);

	// Réglage des aiguillages loco 1
	diriger_aiguillage(15, DEVIE, 0);
	diriger_aiguillage(16, DEVIE, 0);
	diriger_aiguillage(3, DEVIE, 0);
	diriger_aiguillage(4, DEVIE, 0);
	diriger_aiguillage(7, DEVIE, 0);
	diriger_aiguillage(8, TOUT_DROIT, 0);
	diriger_aiguillage(19, DEVIE, 0);
	diriger_aiguillage(11, TOUT_DROIT, 0);
	diriger_aiguillage(12, DEVIE, 0);

	// Réglage des aiguillages loco2
	diriger_aiguillage(10, TOUT_DROIT, 0);
	diriger_aiguillage(14, TOUT_DROIT, 0);
	diriger_aiguillage(2, TOUT_DROIT, 0);
	diriger_aiguillage(6, TOUT_DROIT, 0);
	diriger_aiguillage(5, DEVIE, 0);
	diriger_aiguillage(9, DEVIE, 0);

	pthread_create(&thread1,NULL, locomotive1_tache, &locomotive1);
	pthread_create(&thread2,NULL, locomotive2_tache, &locomotive2);
	pthread_create(&thread3,NULL, arret_urgence, NULL);

	pthread_join(thread1,NULL);
	pthread_join(thread2,NULL);

	// Fin de la simulation
	mettre_maquette_hors_service();
	exit(0);
}



