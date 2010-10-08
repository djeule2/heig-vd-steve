import java.util.HashMap;


public class HttpResponse
{
	protected String statusCode;
	protected String reasonPhrase;
	protected HashMap<String,String> headers = new HashMap<String,String>();
	protected String content;
	
	
}
