using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;

public partial class UserDefinedFunctions
{
    [Microsoft.SqlServer.Server.SqlFunction(DataAccess = DataAccessKind.Read)]
    public static SqlInt32 Fun1(SqlInt32 ID)
    {
        var res = new SqlInt32();
        using (SqlConnection mConnection = new SqlConnection("context connection=true"))
        {
            var Command = new SqlCommand("SELECT BirthDate FROM HumanResources.Employee WHERE BusinessEntityId = @ID", mConnection);
            Command.Parameters.Add("@ID", SqlDbType.Int).Value = ID;
            mConnection.Open();

            try
            {
                var rdr = Command.ExecuteReader();
                if (rdr.HasRows)
                {
                    while (rdr.Read())
                    {
                        var time = (DateTime.Now).Subtract((DateTime)rdr["BirthDate"]);
                        res = ((time.Days) / 365);
                    }
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