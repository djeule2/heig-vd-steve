import java.util.*;
import QModels;

public class TestQ {
	static final int SOLL_RATE = 0;
	static final int PROC_TIME = 1;
	static final int QUEUE_SIZE = 2;
	static final int SERVER_COUNT = 3;
	static final int SOURCE_COUNT = 4;
	static final int SIM_DURATION = 5;
	static final int QUEUE_MODEL = 6;

	static final String[] commands = {
		"c", // Sollicitation Rate
		"h", // Process Time in steps
		"q", // Queue Size
		"n", // Server count
		"N", // Source count
		"t", // Duration of simulation in steps
		"m"  // Queue Model
		};

	static final int MUL_SRC_CST = 0;
	static final int SNGL_SRC_CST = 1;
	static final int MUL_SRC_RND = 2;
	static final int MUL_SRC_RND_MULQ = 3;

	public static void main(String[] arg)
		{
		int qSize, srcCount, serverCount, queueModel;
		int cmdNo, inx;
		long steps;
		double sollRate, processTime;
		Double argVal;

		cmdNo = 0;
		queueModel = MUL_SRC_CST;	// Multiple server, constant proc time
		sollRate = 2.2;				// sollicitations per second
		processTime = 0.12;			// 120 ms processing time
		qSize = 100;				// length of waiting queue
		srcCount = 4;				// Number of source ( => srcCount * sollrate ! )
		steps = 100000;				// Simulation duration = 100000 processings.
		serverCount = 2;
		for (int i = 0; i < arg.length; i++)
			{
			for (int j = 0; j < commands.length; j++)
				if (arg[i].indexOf(commands[j]) >= 0) { cmdNo = j; break; }
			if (cmdNo < 0)
				{
				System.out.println("Commande non interprétable : "+arg[i]);
				break;
				}
			inx = arg[i].indexOf("=");
			if (inx < 0)
				{
				System.out.println("Erreur de syntaxe (= manquant) : "+arg[i]);
				cmdNo = -1;
				break;
				}
			String s = arg[i].substring(inx + 1);
			argVal = new Double("0");
			try 
				{
				argVal = new Double(s);
				}
			catch(Exception e)
				{
				System.out.println("Argument non numérique : "+s);
				cmdNo = -1;
				}
			if (cmdNo < 0) break;
			switch (cmdNo)
				{
				case SOLL_RATE : sollRate = argVal.doubleValue(); break;
				case PROC_TIME : processTime = argVal.doubleValue(); break;
				case QUEUE_SIZE : qSize = argVal.intValue(); break;
				case SERVER_COUNT : serverCount = argVal.intValue(); break;
				case SOURCE_COUNT : srcCount = argVal.intValue(); break;
				case SIM_DURATION : steps = argVal.longValue(); break;
				case QUEUE_MODEL : queueModel = argVal.intValue(); break;
				default :
					System.out.println("Erreur d'interprétation "+arg[i]);
					cmdNo = -1;
				}
			}
		if (cmdNo >= 0)
			{
			System.out.println("Taux de sollicitation "+ sollRate);
			System.out.println("Temps de traitement "+ processTime);
			System.out.println("Grandeur de la file "+ qSize);
			System.out.println("Nombre de serveurs "+ serverCount);
			System.out.println("Nombre de sources "+ srcCount);
			System.out.println("Durée de la simulation (pas) "+ steps);
			Date aDate = new Date();
			switch(queueModel)
				{
				// Multiple sources, constant processing time
				// Dynamic sources
				case MUL_SRC_CST :
					System.out.println("Serveurs multiples, temps de traitement constant");
					QModels.multipleServerConstantTime(serverCount,
										processTime,
										sollRate,
										qSize,
										srcCount,
										steps);
					break;

				case SNGL_SRC_CST :
					System.out.println("Serveur unique, temps de traitement constant");
					QModels.SingleServerConstantTime(processTime,
										sollRate,
										qSize,
										srcCount,
										steps);
					break;

				case MUL_SRC_RND :	
					System.out.println("Serveurs multiples, temps de traitement aléatoire");
					QModels.multipleServerRandomTime(serverCount,
										processTime,
										sollRate,
										qSize,
										srcCount,
										steps);
					break;
				case MUL_SRC_RND_MULQ :
					System.out.println("Serveurs et files multiples, temps de traitement aléatoire");
					QModels.mulSrvRndTimeMulQueue(serverCount,
										processTime,
										sollRate,
										qSize,
										srcCount,
										steps);
					break;
				default :
					System.out.println("Modèle de queue non implémenté");
					cmdNo = -1;
				}
			System.out.println("Simulation terminée, durée = "+
				(((new Date()).getTime() - aDate.getTime()) / 1000.0) + " secondes");
			}
		if (cmdNo < 0)
			{
			System.out.println("Erreur fatale, simulation non effectuée");
			}
		}
	}