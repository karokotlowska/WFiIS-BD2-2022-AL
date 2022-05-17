using System;
using System.Collections;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;

public partial class UserDefinedFunctions
{
    private class FakturaRes
    {
        public SqlInt32 symbol;
        public SqlMoney wartosc;
        public SqlDateTime data;

        public FakturaRes(SqlInt32 symbol, SqlMoney wartosc, SqlDateTime data)
        {
            this.symbol = symbol;
            this.wartosc = wartosc;
            this.data = data;
        }
    }

    public static void FakturaFillRow(object result, out SqlInt32 symbol, out SqlMoney wartosc, out SqlDateTime data)
    {
        FakturaRes faktura = (FakturaRes)result;
        symbol = faktura.symbol;
        wartosc = faktura.wartosc;
        data = faktura.data;
    }

    [SqlFunction(DataAccess = DataAccessKind.Read,
                  FillRowMethodName = "FakturaFillRow",
                  TableDefinition = "SYMBOL int, WARTOSC money, DATA datetime")]

    public static IEnumerable Function6()
    {
        ArrayList resultCollection = new ArrayList();

        using (SqlConnection connection = new SqlConnection("context connection=true"))
        {
            connection.Open();

            using (SqlCommand selectFaktura =
                new SqlCommand("SELECT" +
                "[SalesOrderID], SUM([UnitPrice]), [ModifiedDate] FROM Sales.SalesOrderDetail GROUP BY [SalesOrderID], [UnitPrice], [ModifiedDate]",
                connection))
            {
                using (SqlDataReader aReader = selectFaktura.ExecuteReader())
                {
                    while (aReader.Read())
                    {
                        resultCollection.Add(new FakturaRes(aReader.GetSqlInt32(0), aReader.GetSqlMoney(1), aReader.GetSqlDateTime(2)));
                    }
                }
            }
        }
        return resultCollection;
    }

};

