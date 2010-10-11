import java.util.*;

class Source {
	private boolean active = false;
	void	setActive(boolean activeState) { active = activeState; }
	boolean isActive() { return active; }
	}

public class SourceSet {
	private static Random generator;
	private double r;
	private double startProb;
	private double stopProb;
	protected Source[] theSources;
	protected int iterate = 0;
	public static double getRandomDouble()
		{
		return generator.nextDouble();
		}
	static {
		generator = new Random((new Date()).getTime());
		}
	public SourceSet(int count, double lambda, double mu)
		{
		startProb = lambda;
		stopProb = mu;
		theSources = new Source[count];
		for (int i = 0; i < count; i++) theSources[i] = new Source();
		}

	public int next()
		{
		r = getRandomDouble();
		if (++iterate >= theSources.length) iterate = 0;
		return iterate;
		}
		
	public boolean sollicitate()
		{
		if ((!theSources[iterate].isActive()) && (r < startProb))
			{
			theSources[iterate].setActive(true);
			return true;
			}
		return false;
		}

	public boolean abandon()
		{
		if (theSources[iterate].isActive() && r < stopProb)
			{
			theSources[iterate].setActive(false);
			return true;
			}
		return false;
		}
	}

