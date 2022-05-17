using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using System.Transactions;


public partial class StoredProcedures
{
    [Microsoft.SqlServer.Server.SqlProcedure]
    public static void _zad2()
    {
        //tworzymy obiekt klasy TransactionScope
        TransactionScope oTran = new TransactionScope();
        using (SqlConnection oConn =
        new SqlConnection("context connection=true;"))
        {
            try
            {
                //otwieramy connection
                oConn.Open();
                //pierwszy krok transakcji
                SqlCommand oCmd =
                new SqlCommand(@"INSERT INTO [dbo].[Konta] (Name, Value) VALUES ('Robert', 0)", oConn);
                oCmd.ExecuteNonQuery();
                //drugi krok transakcji
                oCmd.CommandText = @"INSERT INTO [dbo].[Konta] (Name, Value) VALUES ('Robert', 1000)";
                oCmd.ExecuteNonQuery();
                //trzeci krok transakcji
                oCmd.CommandText = @"INSERT INTO [dbo].[Konta] (Name, Value) VALUES ('Alan', 80)";
                oCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                SqlContext.Pipe.Send(ex.Message.ToString());
            }
            finally
            {
                //commit lub rollback
                oTran.Complete();
                oConn.Close();
            }
        }
        //Uwaga: usuwamy obiekt transakcji
        oTran.Dispose();
    }
};