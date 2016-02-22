<html>
	<head>
		<meta http-equiv="Cache-Control" content="no-cache">
		<meta http-equiv="Pragma" content="no-cache">
		<title>Print Schedule</title>
	</head>

	<body background="../../Images/Background.gif" bgcolor=#FFFFFF link=#0000FF vlink=#0000FF alink=#000080 topmargin=2>
		<span style="font-family: sans-serif">
			<pre>
				<%@ Page LANGUAGE="CSHARP" %>
				<%
					/********************************************
					Cablecast Print Schedule Plugin

					Generates a printable schedule form the
					Cablecast Database.

					This page prints the schedule selected from the
					default.asp, the channelID is passed via the
					query string 'ChannelID'

					Date:       18/02/2004
					Programmer: Scott Jann
					********************************************/

					string ChannelName									= "";
					int ChannelID										= Convert.ToInt32(Request.QueryString["ChannelID"]);
					DateTime startDate							= DateTime.Parse(Request.QueryString["Start"]);
					int numDays											= Convert.ToInt32(Request.QueryString["Length"]);
					DateTime endDate								= startDate.AddDays(numDays);
				 	string dateFormat									= "dddd, MMMM d, yyyy";
					System.Data.SqlClient.SqlConnection SqlConn			= new System.Data.SqlClient.SqlConnection();
					System.Data.SqlClient.SqlDataReader SqlDr			= null;

					try
					{
						//open database connection
						SqlConn.ConnectionString						= "Data Source=(local);Initial Catalog=Cablecast40;Integrated Security=SSPI;Persist Security Info=False;Packet Size=4096";
						SqlConn.Open();

						System.Data.SqlClient.SqlCommand SqlCmd			= new System.Data.SqlClient.SqlCommand("SELECT stChannels.* FROM stChannels WHERE ChannelID=" + ChannelID + ";", SqlConn);

						//set data reader
						SqlDr											= SqlCmd.ExecuteReader();
						if(SqlDr.Read())
						{
							ChannelName = SqlDr["ChannelName"].ToString();
						}
						SqlDr.Close();

						Response.Write("Schedule for " + ChannelName + " starting " + startDate.ToString("d") + " for " + numDays.ToString() + " days\n\n");

						string sql = @"DECLARE @PrintSchedule TABLE (RunStart datetime, RunEnd dateTime, Length int, CGTitle varchar(255), Producer varchar(255))

				INSERT @PrintSchedule SELECT ScheduleView.RunStart, ScheduleView.RunEnd, ScheduleView.Length, Shows.CGTitle, stLocationProducers.ProducerName
				FROM ScheduleView
				INNER JOIN Shows ON ScheduleView.ShowID = Shows.ShowID
				LEFT OUTER JOIN stLocationProducers ON Shows.Producer = stLocationProducers.ID
				WHERE ScheduleView.RunStart >= '" + startDate.ToString("g") + @"'
				AND ScheduleView.RunStart <= '" + endDate.ToString("g") + @"'
				AND (ScheduleView.ChannelID = " + ChannelID + @")
				AND (ScheduleView.CGExempt <> 1)
				AND (ScheduleView.Deleted = 0)
				ORDER BY ScheduleView.RunStart


				SELECT * FROM @PrintSchedule ORDER BY RunStart";

						SqlCmd											= new System.Data.SqlClient.SqlCommand(sql, SqlConn);
						SqlDr											= SqlCmd.ExecuteReader();
						int Count										= 0;
						string LastRunDate								= "";

						while(SqlDr.Read())
						{
							// convert length to nice format
							int     inputSecs							= Convert.ToInt32(SqlDr["Length"]);
							int		seconds								= 0;
							int		minutes								= 0;
							int		hours								= 0;
							string	secondsStr							= "";

							if (inputSecs > 0)
							{
								seconds = inputSecs % 60;
								inputSecs = inputSecs - seconds;
								if (inputSecs > 0)
								{
									inputSecs = inputSecs / 60;
									minutes = inputSecs % 60;
									inputSecs = inputSecs - minutes;
									if (inputSecs > 0)
									{
										inputSecs = inputSecs / 60;
										hours = inputSecs;
									}
								}
								if (hours < 10)
									secondsStr = "0" + hours.ToString() + ":";
								else
									secondsStr = hours.ToString() + ":";

								if (minutes < 10)
									secondsStr += "0" + minutes.ToString() + ":";
								else
									secondsStr += minutes.ToString() + ":";

								if (seconds < 10)
									secondsStr += "0" + seconds.ToString();
								else
									secondsStr += seconds.ToString();
							}
							else
								secondsStr = "00:00:00";
							string Length = secondsStr;

							DateTime RunDate = Convert.ToDateTime(SqlDr["RunStart"]);
							DateTime RunEnd = Convert.ToDateTime(SqlDr["RunEnd"]);
							string Title = SqlDr["CGTitle"].ToString();
							if(RunDate.ToString(dateFormat) != LastRunDate)
								Response.Write("\n" + RunDate.ToString(dateFormat) + "\n");
							string TimeString = RunDate.ToString("t");
							if((TimeString.Split(':'))[0].Length == 1)
								TimeString = " " + TimeString;
							Response.Write(TimeString + " - " + RunEnd.ToString("t") + "\t" + Length + "\t" + Title + "\t" + SqlDr["Producer"] + "\n");
							LastRunDate									= RunDate.ToString(dateFormat);
							Count++;
						}
						SqlDr.Close();

						if(Count == 0)
							Response.Write("There is no schedule information.");

					}
				  	catch(System.Threading.ThreadAbortException){}
					catch(Exception ex)
					{
						Response.Write("Error: " + ex.ToString() + "<br>");
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
				%>
			</pre>
		</span>
	</body>
</html>