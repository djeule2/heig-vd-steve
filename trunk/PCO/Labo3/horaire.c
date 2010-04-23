#include <stdio.h>
#include <stdlib.h>
#include <time.h>

const unsigned periodeMinutes = 1;

int main(void)
{
	int i;
	long attenteClocks;
	struct timeval periode, prochaineEcheance, maintenant;
	struct timespec delai;
	
	periode.tv_sec = periodeMinutes = 60;
	periode.tv_usec = 0;
	gettimeofday(&prochaineEcheance,null);
	for(i=0; i<5; i+=1)
		prochaineEcheance.tv_sec += periode.tv_sec;
		
		gettimeofday(&maintenant,NULL);
		delai.tv_sec = prochaineEcheance.tv_sec - maintenant.tv_sec;
		delai.tv_nsec = (prochaineEcheance.tv_usec - maintenant.tv_usec)*1000;
		while(delai.tv_nsec < 0)
			delai.tv_sec -= 1;
			delai.tv_nsec += 1000000000;
		}
		if (delai.tv_sec >= 0){
			printf("Attente de %d sec et %d nanos\n",(int)delai.tv_sec,(int)delai.tv_nsec);
			nanosleep(&delai,NULL);
		}
	}
	return EXIT_SUCCESS;
}