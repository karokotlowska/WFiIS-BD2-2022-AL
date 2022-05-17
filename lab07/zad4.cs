using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;


public partial class StoredProcedures
{
    [Microsoft.SqlServer.Server.SqlProcedure]
    public static void Fun4(SqlInt32 ID)
    {
        using (var mConnection = new SqlConnection("context connection=true"))
        {
            SqlCommand oCmd = new SqlCommand(
                "SELECT LastName + ';' + MiddleName + ';' + FirstName + ';' + AddressLine1 FROM HumanResources.Employee e " +
                "JOIN Person.Person p ON p.BusinessEntityID = e.BusinessEntityID " +
                "JOIN Person.BusinessEntity pbe ON pbe.BusinessEntityID = p.BusinessEntityID " +
                "JOIN Person.BusinessEntityAddress pbea ON pbea.BusinessEntityID = pbe.BusinessEntityID " +
                "JOIN Person.Address pa ON pa.AddressID = pbea.AddressID " +
                "WHERE e.BusinessEntityID = @ID",
                mConnection
            );

            oCmd.Parameters.Add("@ID", SqlDbType.Int).Value = ID;

            mConnection.Open();
            SqlContext.Pipe.ExecuteAndSend(oCmd);
            mConnection.Close();

        }
    }
};