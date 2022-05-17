using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;


public partial class StoredProcedures
{
    [Microsoft.SqlServer.Server.SqlProcedure]
    public static void Fun2(SqlDateTime dateTime, SqlInt32 Age)
    {
        var returnRecord = new SqlDataRecord(
            new SqlMetaData("LastName", SqlDbType.NVarChar, 50),
            new SqlMetaData("FirstName", SqlDbType.NVarChar, 50),
            new SqlMetaData("EmailAddress", SqlDbType.NVarChar, 50),
            new SqlMetaData("Age", SqlDbType.Int)
        );
        using (var mConnection = new SqlConnection("context connection=true"))
        {
            var Command = new SqlCommand(
                "SELECT LastName, FirstName, EmailAddress, DATEDIFF(year, BirthDate, @DATE) Age FROM HumanResources.Employee e " +
                "JOIN Person.Person p ON p.BusinessEntityId = e.BusinessEntityId " +
                "JOIN Person.EmailAddress ea ON ea.BusinessEntityId = p.BusinessEntityId " +
                "WHERE DATEDIFF(year, BirthDate, @DATE) >= @AGE",
                mConnection
            );

            Command.Parameters.Add("@DATE", SqlDbType.DateTime).Value = dateTime;
            Command.Parameters.Add("@AGE", SqlDbType.Int).Value = Age;

            try
            {
                mConnection.Open();
                var rdr = Command.ExecuteReader();

                if (rdr.HasRows)
                {
                    SqlContext.Pipe.SendResultsStart(returnRecord);
                    while (rdr.Read())
                    {
                        returnRecord.SetString(0, (string)rdr["LastName"]);
                        returnRecord.SetString(1, (string)rdr["FirstName"]);
                        returnRecord.SetString(2, (string)rdr["EmailAddress"]);
                        returnRecord.SetInt32(3, (int)rdr["Age"]);
                        SqlContext.Pipe.SendResultsRow(returnRecord);
                    }
                }
                SqlContext.Pipe.SendResultsEnd();
            }
            catch (SqlException e)
            {
                SqlContext.Pipe.Send(e.Message.ToString());
            }
            finally
            {
                mConnection.Close();
            }
        }
    }
};