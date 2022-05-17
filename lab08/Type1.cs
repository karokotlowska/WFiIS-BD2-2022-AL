using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;

[Serializable]
[Microsoft.SqlServer.Server.SqlUserDefinedType(Format.Native)]
public struct Type1: INullable
{
    public override string ToString(){
        if (zeroInFrontCount != 0)
        {
            string ret="";
            for (int i=0;i<zeroInFrontCount;i++){
                ret+="0";
            }
            return ret + pesel.ToString();
        }
        return pesel.ToString();
    }

    public bool IsNull{
        get{
            bNull = pesel == 0 ? true : false;
            return bNull;
        }
    }

    public static Type1 Null
    {
        get{
            Type1 h = new Type1();
            h.bNull = true;

            return h;
        }
    }

    public static Type1 Parse(SqlString s)
    {
        if (s.IsNull)
            return Null;
        Type1 u = new Type1();

        try{
            u.pesel = Int64.Parse(s.Value);
            u.zeroInFrontCount = 11-u.pesel.ToString().Length;
        }
        catch (Exception e){
            throw e;
        }
        if (s.ToString().Length != 11){
            throw new Exception("Niepoprawna dlugosc peselu");
        }

        return u;
    }


    private Int64 pesel;
    private Int64 zeroInFrontCount;
    private bool bNull;
}


