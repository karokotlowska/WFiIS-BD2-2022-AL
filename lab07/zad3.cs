using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;

public partial class UserDefinedFunctions
{
    [Microsoft.SqlServer.Server.SqlFunction(DataAccess = DataAccessKind.Read)]
    public static SqlString Fun3(SqlInt32 ID)
    {
        var res = new SqlString("---");

        using (var mConnection = new SqlConnection("context connection=true"))
        {
            SqlCommand command = new SqlCommand(
                "SELECT LastName + ';' + FirstName + ';' + CONVERT(VARCHAR, DATEDIFF(year, BirthDate, GETDATE())) Result FROM HumanResources.Employee e " +
                "JOIN Person.Person p ON p.BusinessEntityID = e.BusinessEntityID " +
                "WHERE e.BusinessEntityID = @ID;",
                mConnection
            );

            command.Parameters.Add("@ID", SqlDbType.Int).Value = ID;

            mConnection.Open();

            try
            {
                var rdr = command.ExecuteReader();

                if (rdr.HasRows)
                {
                   rdr.Read();
                   res = (string)rdr["Result"];
                }
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

        return res;
    }
};