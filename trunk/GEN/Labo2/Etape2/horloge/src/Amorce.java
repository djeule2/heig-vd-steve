/****************************************************************
 * Auteur:	    Eric Lefrançois                                 *
 * Groupe:	    HES_SO  Informatique & Télécommunications       *
 * Fichier:     1er Octobre 2009  -  DEPART		                *
 * Projet:	    Horloges synchronisées                          *
 ****************************************************************
*/

public class Amorce {
    public static void main (String argv[]){
    	// Emetteur avec une seconde de 100msec
        new Emetteur(100);  	        
        // Création d'une pendule, avec une seconde valant 120msec (plus lente que l'emetteur
        new Pendule ("H", 100, 100, 0);
    }
}
