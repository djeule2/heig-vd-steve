public class Erlang {

    static public double       Erlang(double y, int n)
    
        {
        double  denominator;
    	int i = 0;
		denominator = 1.0;
		while (i++ < n)
			denominator = 1 + (i/y)*denominator;
		return (1/denominator);
        }

	public static void main(String[] arg)
		{
		if (arg.length != 2) {
			System.out.println("Usage : java Erlang <Trafic> <Nb serveurs>");
			return;
			}
		Double d = new Double(arg[0]);
		double traffic = d.doubleValue();
		Integer i = new Integer(arg[1]);
		int servers = i.intValue();
		System.out.println("Erlang("+traffic+", "+servers+") = "+Erlang.Erlang(traffic, servers));
		}
	}