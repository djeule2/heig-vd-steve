import ExcelIo;

class QueueElement {
	Object data;
	int    waitingTime;
	private int    priority;
	static  int    maxPriority = 100;
	
	QueueElement(Object obj) {
		data = obj; waitingTime = 0;
		priority = 0;
		maxPriority = 0;
		}
	QueueElement(Object ob, int pri) {
		data = ob; waitingTime = 0;
		priority = pri;
		}
	static void	setPrLimit(int limit) { maxPriority = limit; }
	void	incPriority(int increment)
		{ if (priority + increment < maxPriority)
			priority +=increment;
		  else priority = maxPriority - 1; }
	void	incPriority() { if (priority < maxPriority) priority++; }
	void	decPriority() { if (priority > 0) priority--; }
	int		getPriority() { return priority; }
	void	letItBe() { waitingTime++; }
	}
	
public class Waiting {
		// The physical waiting queue
	QueueElement[] queue;
		// Losses due to queue overflow
	long lossCount;
		// Statistic of occupations (cumulative)
		// This will measure the cumulated occupations
		// of each cell in the waiting queue
	long[] statistic;
		// Total number of simulation steps
	long   numberOfSteps;
		// Statistic measuring the waiting times in the queue
	long[] waitingStatistic;
		// Waiting time statistic overflow
	long	maxWaitingExceeded;
		// Simulation time interval
	private double simulationTimeUnit = 1;
	private void initW(int maxQsze, int maxWsze)
		{
		queue = new QueueElement[maxQsze];
		for (int i = 0; i < maxQsze; i++) queue[i] = null;
		statistic = new long[maxQsze];
		for (int i = 0; i < maxQsze; i++) statistic[i] = 0;
		waitingStatistic = new long[maxWsze];
		for (int i = 0; i < waitingStatistic.length; i++)
			waitingStatistic[i] = 0;
		numberOfSteps = lossCount = 0;
		maxWaitingExceeded = 0;
		}
	public Waiting(int maxQsze, int maxWsze) { initW(maxQsze, maxWsze); }
	public Waiting(int maxSize) { initW(maxSize, 2*maxSize); }
	
	public void setSimulationTimeUnit(double s) { simulationTimeUnit = s; }

	public void clockTick()
		{
		int i;
		numberOfSteps++;
		for (i = 0; (i < queue.length) && (queue[i] != null); i++)
			queue[i].letItBe();
		if (i < queue.length)
			statistic[i]++;
		}
	
	public Object retrieve()
		{
		QueueElement q = queue[0];
		if (q != null)
			{
			for (int i = 1; i < queue.length; i++)
				if ((queue[i - 1] = queue[i]) == null) break;
			queue[queue.length - 1] = null;
			if (q.waitingTime < waitingStatistic.length)
				waitingStatistic[q.waitingTime]++;
			else maxWaitingExceeded++;
			return q.data;
			}
		else return null;
		}
		
	public void add(Object data)
		{
		if (queue[queue.length - 1] != null)
			{
			lossCount++;
			return;
			}
		QueueElement q = new QueueElement(data);
		for (int i = 0; i < queue.length; i++)
			if (queue[i] == null)
				{
				queue[i] = q;
				return;
				}
		}

	public void prStat(ExcelIo os)
		{
		int i, j;
		long temp, curSum = 0, tot = 0;
		os.put("Statistique des occupations");
		for (i = 0; i < statistic.length; i++) os.put(statistic[i]);
		os.eor();
		os.put("Statistique des attentes");
		for (i = 0; i < waitingStatistic.length; i++)
			os.put(waitingStatistic[i]);
		os.eor();
		os.put("Pertes de la file"); os.put(lossCount); os.eor();
		os.put("Nombre de depassements de l'attente maximale");
		os.put(maxWaitingExceeded); os.eor();
		os.put("Attente maximale [pas de simulation]");
		os.put(waitingStatistic.length); os.eor();
		os.put("Duree de la simulation en pas");
		os.put(numberOfSteps); os.eor();
		os.put("Unité de temps de simulation");
		os.put(simulationTimeUnit); os.eor();
		}

	public boolean dumpToFile(String name)
		{
		ExcelIo os = new ExcelIo();
		if (os.open(name)) {
			prStat(os);
			os.close();
			return true;
			}
		else return false;
		}
	}
