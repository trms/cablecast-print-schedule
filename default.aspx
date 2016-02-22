<html>
	<head>
		<meta http-equiv="Cache-Control" content="no-cache">
		<meta http-equiv="Pragma" content="no-cache">
		<title>Cablecast Print Schedule</title>
	</head>

	<body background="../../Images/Background.gif" bgcolor=#FFFFFF link=#0000FF vlink=#0000FF alink=#000080 topmargin=2>
		<span style="font-family: sans-serif">
			<%@ Page LANGUAGE="CSHARP" %>
			<%
				/********************************************
				Cablecast Print Schedule Plugin

				Generates a web schedule form the
				Cablecast Database.

				Date:       12/7/2015
				Programmer: Brandon McKenzie
				********************************************/

				//--Returned Data Processing--
				//Help Toggle
				if(Request.QueryString["Help"] != null)
				{
					if(Session["Help"] == null)
						Session["Help"] = true;
					else
						Session["Help"] = !Convert.ToBoolean(Session["Help"]);
				}

				//--Header--
				int PostbackLen	= Request.FilePath.LastIndexOf('/') + 1;
				// Postback is the requested path minus the filename (remainder of path after last /)
				string Postback		= Request.FilePath.Substring(PostbackLen, Request.FilePath.Length - PostbackLen);
				string HelpString	= "There is no help avaliable for this screen.";

				//Cache control
				Response.Expires = -1;
				Response.Buffer = true;

				//Blanket form
				Response.Write("<form name=FormData method=post action=" + Postback + ">");

				//Full page table
				Response.Write("<table border=0 width=\"100%\" height=\"100%\" cellpadding=0 cellspacing=0>");
				Response.Write("<tr valign=top><td>");

				//Top bar table
				Response.Write("<table border=0 width=\"100%\" cellpadding=0 cellspacing=0>");

				//Help & messages
				if(Session["Message"] != "")
				{
					Response.Write("<tr><td colspan=2><b><i>" + Session["Message"] + "</i></b></td></tr>");
					Session["Message"] = "";
				}
				if(Convert.ToBoolean(Session["Help"]) == true)
				{
					Response.Write("<tr><td colspan=2>" + HelpString + "</td></tr>");
				}

				//Top bar table ending
				Response.Write("</table><p>");

				Response.Write("</form><form name=FormData method=get action=print.aspx>");
				Response.Write("<h1>Vernon Schedule</h1><b>Select a channel:</b><p><blockquote><ul>");

				System.Data.SqlClient.SqlConnection SqlConn			= new System.Data.SqlClient.SqlConnection();
				System.Data.SqlClient.SqlDataReader SqlDr			= null;
				try
				{
					//open database connection
					SqlConn.ConnectionString						= "Data Source=(local);Initial Catalog=Cablecast40;Integrated Security=SSPI;Persist Security Info=False;Packet Size=4096";
					SqlConn.Open();

					System.Data.SqlClient.SqlCommand SqlCmd			= new System.Data.SqlClient.SqlCommand("SELECT stChannels.* FROM stChannels ORDER BY ChannelID;", SqlConn);

					//set data reader
					SqlDr											= SqlCmd.ExecuteReader();

					bool first = true;

					while(SqlDr.Read())
					{
						Response.Write("<input type=radio " + (first ? "checked" : "") + " name=ChannelID value=\""+ SqlDr["ChannelID"] + "\">" + SqlDr["ChannelName"] + "<br>");
						first = false;
					}
					SqlDr.Close();

					Response.Write("<br>Start Date <input type=text size=10 name=Start value=\"" + DateTime.Now.ToString("d") + "\">" );
					Response.Write("<br>Display for <input type=text size=3 name=Length value=14> days.</blockquote>");

					Response.Write("<input type=Submit name=Buttons value=Generate></form>");
				}
			  catch(System.Threading.ThreadAbortException){}
				catch(Exception ex)
				{
					Response.Write("Error: " + ex.Message + "<br>");
				}
				finally
				{
					// make sure the things get closed
					//close data reader
					if(SqlDr != null)
					{
						if(SqlDr.IsClosed == false)
							SqlDr.Close();
					}

					// close database connection
					if(SqlConn != null)
					{
						if(SqlConn.State != System.Data.ConnectionState.Closed)
							SqlConn.Close();
					}
				}

				Response.Write("</ul></blockquote>");

				//Content flush
				Response.Flush();

			%>
		</span>
	</body>
</html>