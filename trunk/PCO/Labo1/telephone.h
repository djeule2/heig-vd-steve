/** \mainpage Telephone
 * Cette documentation décrit l'interface fournie par le fichier telephone.h.
 * Pour les attentes, utilisez sleep(s), où s est en secondes. Cette fonction
 * est déclarée dans psleep.h, et permet d'avoir un code compatible
 * Linux/MacOS/Windows
 */

/** \file telephone.h
 *  \author CEZ et YTA
 *  \date 16.02.2009
 * \version 1.0.0
 * \section Description
 * Ce fichier définit l'interface permettant de gérer un téléphone.
 * Plusieurs des fonctions sont bloquantes. Il est dès lors nécessaire de
 * gérer le téléphone via plusieurs tâches, étant donné que l'utilisateur
 * peut effectuer les opérations dans un ordre quelconque.
 */


/** Réalise toutes les initialisations nécessaire. Cette fonction
 * doit être appelée avant d'utiliser l'une des fonctions de cet interface.
 * \return 1 si tout est en ordre et 0 en cas d'erreur.
 */
int Telephone_Initialise(void);

/** Fonction bloquante attendant qu'une carte soit insérée.
 *  Cette fonction est bloquante, attention à la traiter correctement. Elle
 *  attend que la touche 'I', en majuscule, soit pressée. Elle retourne ensuite
 *  le montant disponible sur la carte. La première fois que la carte est
 *  insérée, le montant est nul. Ensuite il est mémorisé de manière interne.
 *  \return Le montant disponible sur la carte.
 */
int Telephone_CarteInseree(void);

/** Fonction bloquante attendant que la carte soit récupérée.
 *  Cette fonction est bloquante, attention à la traiter correctement. Elle
 *  attend que la touche 'O', en majuscule, soit pressée.
 */
void Telephone_CarteRecuperee(void);

/** Fonction permettant de modifier le montant de la carte.
 *  Le montant est mémorisé sur la carte, notamment si elle est ensuite
 *  retirée de la machine. 
 *  \param montant Le nouveau montant de la carte.
 */
void Telephone_SetMontant(unsigned montant);


/** Fonction bloquante attendant que le combiné soit décroché.
 *  Cette fonction est bloquante, attention à la traiter correctement. Elle
 *  attend que la touche 'D', en majuscule, soit pressée.
 */
void Telephone_DecrocheCombine(void);

/** Fonction bloquante attendant que le combiné soit raccroché.
 *  Cette fonction est bloquante, attention à la traiter correctement. Elle
 *  attend que la touche 'R', en majuscule, soit pressée.
 */
void Telephone_RaccrocheCombine(void);


/** Fonction bloquante attendant qu'une touche de numérotation soit pressée.
 *  Cette fonction est bloquante, attention à la traiter correctement. Elle
 *  attend qu'une des touches du clavier entre '0' et '9' soit pressée,
 *  et retourne alors le nombre correspondant.
 *	\return un nombre de 0 à 9.
*/
int Telephone_GetTouche(void);


/** Type des différentes pieces de monnaie, une valeur dans 1..9. */
typedef int PIECE;

/** Fonction bloquante attendant qu'une pièce de monnaie soit introduite.
 *  Cette fonction est bloquante, attention à la traiter correctement. Elle
 *  attend qu'une des touches du clavier 'q', 'w', 'e', 'r', 't', 'z', 'u',
 *  'i', ou 'o'.
 *  La valeur de la pièce est alors retournée. La valeur est la suivante:
 *		- q: 1
 *		- w: 2
 *		- e: 3
 *		- r: 4
 *		- t: 5
 *		- z: 6
 *		- u: 7
 *		- i: 8
 *		- o: 9
 * \return une piece de type PIECE, valeur entière entre 1 et 9.
 */
PIECE Telephone_GetPiece(void);



/** Procédure définissant l'entrée dans la section critique.
 *  Une section critique est fournie par l'interface, et peut être utilisée
 *  pour protéger les variables qui doivent l'être.
 *  Cette procédure est bloquante, le thread restant bloqué jusqu'à ce que la
 *  section critique soit relâchée par un autre.
 */
void Telephone_DebutSectionCritique(void);

/** Procédure définissant la sortie de la section critique.
 *  Une section critique est fournie par l'interface, et peut être utilisée
 *  pour protéger les variables qui doivent l'être.
 *  Si un autre thread est en attente d'accès à la section critique, il est
 *  relâché par cette procédure.
 *  Cette procédure ne doit être appelée qu'après avoir appelé
 *  Telephone_DebutSectionCritique().
 */
void Telephone_FinSectionCritique(void);
