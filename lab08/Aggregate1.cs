using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using System.IO;
using System.Text;


[Serializable]
[Microsoft.SqlServer.Server.SqlUserDefinedAggregate(
    Format.UserDefined,
    IsInvariantToNulls = true, 
    IsInvariantToDuplicates = false, 
    IsInvariantToOrder = false, 
    MaxByteSize = 8000)
    ]
public class Aggregate1 : IBinarySerialize
{
    private StringBuilder stringB;

    public void Init(){
        this.stringB = new StringBuilder();
    }

    public void Accumulate(SqlString value){
        if (value.IsNull){
            return;
        }

        this.stringB.Append(value.Value).Append(' ');
    }

    public void Merge(Aggregate1 Group){
        this.stringB.Append(Group.stringB);
    }

    public SqlString Terminate(){
        string output = string.Empty;
        if (this.stringB != null && this.stringB.Length > 0){
            output = this.stringB.ToString(0, this.stringB.Length - 1);
        }

        return new SqlString(output);
    }

    public void Read(BinaryReader r){
        stringB = new StringBuilder(r.ReadString());
    }

    public void Write(BinaryWriter w){
        w.Write(this.stringB.ToString());
    }
}