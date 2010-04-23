import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.util.*;

public class formulaire extends HttpServlet{

	public void doGet(HttpServletRequest request, HttpServletResponse response)
		throws IOException, ServletException{

		response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        out.println("<html>");
        out.println("<body bgcolor=\"white\">");
        out.println("<head>");

        out.println("<title>" +"Formulaire"+ "</title>");
        out.println("</head>");
        out.println("<body>");
		
        out.println("<h1>" + "Stock" + "</h1>");
		
		out.println("<FORM action='panier' method='POST'>"+
			"<TABLE>"+
				"<TR>"+
					"<TH ALIGN='center' VALIGN='top'>Article</TH>"+
					"<TH ALIGN='center' VALIGN='top'>Unit Price (?)</TH>"+
					"<TH ALIGN='center' VALIGN='top'>Quantity</TH>"+
				"</TR>" +
				"<tr>" +
				"<td><b>Tasse Snoopy</b> " +
				"</td>" +
				"<td> Prix : 12.- </td>" +
				"<td> <SELECT NAME='tasse'>"+
							"<OPTION>0</OPTION>"+
							"<OPTION>1</OPTION>"+
							"<OPTION>2</OPTION>"+
							"<OPTION>3</OPTION>"+
						"</SELECT>" +
				"</td>" +
				"</tr>" +
				"<tr>" +
					"<td>" +
						"<b>Assiette Charlot</b> " +
					"</td>" +
					"<td> Prix : 12.- </td>" +
					"<td> <SELECT NAME='assiette'>"+
							"<OPTION>0</OPTION>"+
							"<OPTION>1</OPTION>"+
							"<OPTION>2</OPTION>"+
							"<OPTION>3</OPTION>"+
						"</SELECT>" +
					"</td>" +
				"</tr>" +
				"<tr>" +
					"<TD><input type=submit value='Ajouter au panier'> </TD>" +
				"</tr>" +
			"</TABLE>" +
		"</FORM>");
		
        out.println("</body>");
        out.println("</html>");
		
		
	}
}
