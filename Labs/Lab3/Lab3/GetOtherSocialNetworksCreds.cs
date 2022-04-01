using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;

public partial class StoredProcedures
{
    [Microsoft.SqlServer.Server.SqlProcedure]
    public static void GetOtherSocialNetworksCreds(SqlDateTime startDate, SqlDateTime endDate)
    {
        var command = new SqlCommand();
        command.Connection = new SqlConnection("Context connection = true");
        command.Connection.Open();

        string sqlString = "SELECT * FROM OTHER_SOCIAL_NETWORKS_CREDS " +
            "WHERE REGISTRATION_DATE > @start_date and REGISTRATION_DATE < @end_date";

        command.CommandText = sqlString.ToString();

        var startDateParam = command.Parameters.Add("@start_date", SqlDbType.DateTime);
        var endDateParam = command.Parameters.Add("@end_date", SqlDbType.DateTime);
        startDateParam.Value = startDate;
        endDateParam.Value = endDate;

        SqlContext.Pipe.ExecuteAndSend(command);
        command.Connection.Close();
    }
}
