using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using System.Transactions;


public partial class StoredProcedures
{
    [Microsoft.SqlServer.Server.SqlProcedure]
    public static void _zad3()
    {
        int returnValue;
        using (TransactionScope oTran = new TransactionScope())
        {
            using (SqlConnection oConn = new SqlConnection("context connection=true;"))
            {
                oConn.Open();
                SqlCommand update = new SqlCommand("UPDATE [dbo].[Konta] SET value = value + 55.55 WHERE name = 'name1'", oConn);
                returnValue = update.ExecuteNonQuery();
                using (SqlConnection remConn = new SqlConnection("Data Source=MSSQLSERVER114;Initial Catalog=AdventureWorks2008;User Id=labuser;Password=Passw0rd;"))
                {
                    returnValue = 0;
                    remConn.Open();
                    SqlCommand updateRemote = new SqlCommand("UPDATE [dbo].[Konta] SET value = value - 55.5 WHERE name = 'name1'", remConn);
                    returnValue = updateRemote.ExecuteNonQuery();
                    oTran.Complete();
                }
            }
        }
    }
};