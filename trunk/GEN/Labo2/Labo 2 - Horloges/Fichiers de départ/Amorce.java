/****************************************************************
 * Auteur:	    Eric Lefrançois                                 *
 * Groupe:	    HES_SO  Informatique & Télécommunications       *
 * Fichier:     1er Octobre 2009  -  DEPART		                *
 * Projet:	    Horloges synchronisées                          *
 ****************************************************************
*/




public class Amorce {
    public static void main (String argv[]){

        new Emetteur(100);  	// Emetteur avec une seconde de 100msec
        
        // Création d'une pendule, avec une seconde valant 120msec (plus lente que l'emetteur
   
        new Pendule ("H", 120, 100, 0);
  

    }
}
