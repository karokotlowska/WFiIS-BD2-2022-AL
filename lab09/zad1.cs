using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using System.Security.Principal;


public partial class StoredProcedures
{
    [Microsoft.SqlServer.Server.SqlProcedure]
    public static void _zad1()
    {
        WindowsIdentity newIdentity = null;
        WindowsImpersonationContext newContext = null;
        try
        {
            // zmiana tozsamosci uzytkownika
            newIdentity = SqlContext.WindowsIdentity;
            newContext = newIdentity.Impersonate();
            if (newContext != null)
            {
                using (SqlConnection oConn = new SqlConnection(@"Data Source=MSSQLSERVER114;Initial Catalog=AdventureWorks2008;User Id=labuser;Password=Passw0rd"))
                {
                    SqlCommand oCmd = new SqlCommand("SELECT * FROM [dbo].[Konta]", oConn);
                    oConn.Open();
                    SqlDataReader oRead = oCmd.ExecuteReader(CommandBehavior.CloseConnection);
                    // przywracamy kontekst tozsamosci
                    newContext.Undo();
                    // wyniki metoda Send
                    SqlContext.Pipe.Send(oRead);
                }
            }
            else
            {
                throw new Exception("zmiana tozsamosci ");
            }
        }
        catch (SqlException ex)
        {
            SqlContext.Pipe.Send(ex.Message.ToString());
        }
        finally
        {
            if (newContext != null)
            {
                newContext.Undo();
            }
        }
    }

};