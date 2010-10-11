import Waiting;
import SourceSet;
import PulseSrc;
import java.util.*;
import ExcelIo;

class Server {
	int busyCount;
	static double releaseProb;
	Server() { busyCount = 0; }
	boolean stepAndMarkFree()
		{ busyCount--;
		  if (busyCount <= 0) 
			{ busyCount = 0; return true; }
		  else return false;
		}
	void occupy(int procTime) { busyCount = procTime; }
	boolean isFree() { return (busyCount == 0); }
	boolean isBusy() { return (busyCount > 0); }
	void markAsBusy() { busyCount = 1; }
	void markAsFree() { busyCount = 0; }
	}

public class QModels {
	/**
	* Single queue, single server, with constant
	* processing time. The sources do not abandon
	* a sollicitation once made.
	* The simulation time is represented by the process time,
	* as the process time is strictly constant.
	* When the queue overflows, the system loses the
	* sollicitations.
	*/
	public static void SingleServerConstantTime(double processTime,
												double sollRate,
												int maxQueueSize,
												int srcCount,
												long steps)
		{
		PulseSrc pulses = new PulseSrc(srcCount, sollRate*processTime / 10);
		Waiting w = new Waiting(maxQueueSize);
		w.setSimulationTimeUnit(processTime / 10);
		int sim = 0; // server is free
		for (int i = 0; i < steps; i++)
			{
			for (int j = 0; j < srcCount; j++)
				{
				if (pulses.sollicitate())
					{
					w.add(new Integer(j));
					// System.out.println("Add "+j+ " / " + sim);
					}
				pulses.next();
				}
			if (sim <= 0)
				{
				Integer k;
				if ((k = (Integer) w.retrieve()) != null)
					{
					sim = 10;
					// System.out.println("Retrieve "+k.intValue());
					}
				}
			else sim--;
			// Not retrieved items are waiting.
			w.clockTick();
			}
		w.dumpToFile("tmp.dat");
		}

	/**
	* 
	* Multiple Servers, Single queue, constant processing time.
	* Common case in informatics processing.
	* The previous case may also be handled by this routine,
	* but it performs slightly slower than the dedicated one.
	*
	*/

	public static void multipleServerConstantTime(int serverCount,
												double processTime,
												double sollRate,
												int maxQueueSize,
												int srcCount,
												long steps)
		{
		Server[] srv = new Server[serverCount];
		for (int i = 0; i < serverCount; i++)
			srv[i] = new Server();
		double lambda = sollRate * processTime;
		PulseSrc pulses = new PulseSrc(srcCount, sollRate*processTime / 10);
		Waiting w = new Waiting(maxQueueSize);
		w.setSimulationTimeUnit(processTime/10);
		for (int i = 0; i < steps; i++)
			{
			for (int j = 0; j < srcCount; j++)
				{
				if (pulses.sollicitate())
					{
					w.add(new Integer(j));
					}
				pulses.next();
				}
			for (int j = 0; j < serverCount; j++)
				{
				if (srv[j].stepAndMarkFree())
					{
					if (w.retrieve() != null) srv[j].occupy(10);
					}
				}
			// Not retrieved items are waiting.
			w.clockTick();
			}
		w.dumpToFile("tmp.dat");
		}
	/**
	*
	* One queue, multiple servers, random processing time.
	* This is a common case in telephony
	*
	*/
	public static void multipleServerRandomTime(int serverCount,
												double meanProcessTime,
												double sollRate,
												int maxQueueSize,
												int srcCount,
												long steps)
		{
		Server[] srv = new Server[serverCount];
		int i, j;
		for (i = 0; i < serverCount; i++)
			srv[i] = new Server();
		//
		// DeltaT = meanProcessTime / 10
		//
		Server.releaseProb = 0.1;
		double lambda = sollRate * meanProcessTime / 10;
		PulseSrc pulses = new PulseSrc(srcCount, lambda);
		Waiting w = new Waiting(maxQueueSize);
		w.setSimulationTimeUnit(meanProcessTime / 10);
		for (i = 0; i < steps; i++)
			{
			for (j = 0; j < srcCount; j++)
				{
				if (pulses.sollicitate())
					{
					w.add(new Integer(j));
					}
				pulses.next();
				}
			for (j = 0; j < serverCount; j++)
				{
				if (srv[j].isBusy())
					{
					if (SourceSet.getRandomDouble() < Server.releaseProb)
						srv[j].markAsFree();
					}
				if (srv[j].isFree()) 
					{
					w.retrieve();
					srv[j].markAsBusy();
					}
				}
			// Not retrieved items are waiting.
			w.clockTick();
			}
		w.dumpToFile("tmp.dat");
		}

	/**
	*
	* Multiple servers, multiple queue (one queue for each server)
	* Random processing time.
	* This case tries to demonstrate the benefits of having only
	* one single queue for n servers, instead of one queue per server
	*
	*/
	public static void mulSrvRndTimeMulQueue(int serverCount,
											double meanProcessTime,
											double sollRate,
											int maxQueueSize,
											int srcCount,
											long steps)
		{
		Server[] srv = new Server[serverCount];
		int i, j, k;
		Random gen = new Random((new Date()).getTime());
		for (i = 0; i < serverCount; i++)
			srv[i] = new Server();
		Waiting[] w = new Waiting[serverCount];
		for (i = 0; i < serverCount; i++)
			{
			w[i] = new Waiting(maxQueueSize);
			w[i].setSimulationTimeUnit(meanProcessTime / 10);
			}
					System.out.println("Queues built");
		Server.releaseProb = 0.1;
		double lambda = sollRate * meanProcessTime / 10;
		PulseSrc pulses = new PulseSrc(srcCount, lambda);
		for (i = 0; i < steps; i++)
			{
			for (j = 0; j < srcCount; j++)
				{
				if (pulses.sollicitate())
					{
					// CHOOSE A SERVER (AND A QUEUE) AT RANDOM
					k =  Math.abs(gen.nextInt()%serverCount);

					w[k].add(new Integer(j));
					}
				pulses.next();
				}
			for (j = 0; j < serverCount; j++)
				{
				if (srv[j].isBusy())
					{
					if (SourceSet.getRandomDouble() < Server.releaseProb)
						srv[j].markAsFree();
					}
				if (srv[j].isFree()) 
					{
					w[j].retrieve();
					srv[j].markAsBusy();
					}
				}
			// Not retrieved items are waiting.
			for (j = 0; j < serverCount; j++)
				w[j].clockTick();
			}
		// Put the full statistic into the waiting queue 0 :
		ExcelIo os = new ExcelIo();
		if (os.open("tmp.dat"))
			{
			for (i = 0; i < serverCount; i++) {
				os.put("File d'attente no "+ i);
				os.eor();
				w[i].prStat(os);
				}
			os.put("Statistique cumulée : "); os.eor();
			for (k = 1; k < serverCount; k++) {
				for (j = 0; j < w[0].statistic.length; j++)
					w[0].statistic[j] += w[k].statistic[j];
				for (j = 0; j < w[0].waitingStatistic.length; j++)
					w[0].waitingStatistic[j] += w[k].waitingStatistic[j];
				w[0].lossCount += w[k].lossCount;
				w[0].maxWaitingExceeded += w[k].maxWaitingExceeded;
				}
			w[0].prStat(os);
			os.close();
			}
		}

	}
