using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using System.Transactions;


public partial class StoredProcedures
{
    [Microsoft.SqlServer.Server.SqlProcedure]
    public static void _zad4()
    {
        System.Transactions.CommittableTransaction oTran = new CommittableTransaction();
        using (SqlConnection oConn = new SqlConnection("context connection=true"))
        {
            try
            {
                SqlCommand oCmd = new SqlCommand();
                oConn.Open();
                //przekazujemy obiekt CommittableTransaction
                oConn.EnlistTransaction(oTran);
                oCmd.Connection = oConn;
                // insert nr 1
                oCmd.CommandText = "INSERT INTO [dbo].[Konta] (name, value) VALUES ('name3', 500)";
                SqlContext.Pipe.ExecuteAndSend(oCmd);
                // insert nr 2
                oCmd.CommandText = "INSERT INTO [dbo].[Konta] (name, value) VALUES ('name4', 300)";
                SqlContext.Pipe.ExecuteAndSend(oCmd);
                // insert nr 3
                oCmd.CommandText = "INSERT INTO [dbo].[Konta] (name, value) VALUES ('name5', 200)";
                SqlContext.Pipe.ExecuteAndSend(oCmd);

                SqlContext.Pipe.Send("COMMITING TRANSACTION");

                oTran.Commit();


            }
            catch (SqlException ex)
            {
                //wysylamy komunikat z przechwyconego wyjatku
                SqlContext.Pipe.Send(@"ROLLING BACK TRANSACTION DUE TO THE FOLLOWING ERROR " + ex.Message.ToString());
                //rollback xact
                oTran.Rollback();
            }
            finally
            {
                oConn.Close();
                oTran = null;
            }

        }
    }
};