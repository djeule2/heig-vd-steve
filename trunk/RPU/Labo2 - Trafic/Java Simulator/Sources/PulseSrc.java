import SourceSet;

class PulseSrc extends SourceSet {
	public PulseSrc(int count, double lambda)
		{
		super(count, lambda, 0);
		}
	public boolean sollicitate()
		{
		if (super.sollicitate())
			{
			theSources[iterate].setActive(false);
			return true;
			}
		else return false;
		}
	}