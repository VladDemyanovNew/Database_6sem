using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using System.IO;
using System.Text;
using Microsoft.SqlServer.Server;


[Serializable]
[Microsoft.SqlServer.Server.SqlUserDefinedType(Format.UserDefined, MaxByteSize = 6000, Name = "other_creds")]
public struct OtherCreds: INullable, IBinarySerialize
{
    private const int MAX_STRING_SIZE = 6000;

    private bool _null;

    public string SocialNetwork { get; set; }

    public string Login { get; set; }

    public string Password { get; set; }

    public bool IsNull
    {
        get
        {
            return _null;
        }
    }

    public static OtherCreds Null
    {
        get
        {
            OtherCreds otherCreds = new OtherCreds();
            otherCreds._null = true;
            return otherCreds;
        }
    }

    public override string ToString()
    {
        if (IsNull)
        {
            return "NULL";
        }

        return $"SocialNetwork: {this.SocialNetwork}, Login: {this.Login}, Password: {this.Password}";
    }

    [SqlMethod(OnNullCall = false)]
    public static OtherCreds Parse(SqlString otherCredsData)
    {
        if (otherCredsData.IsNull)
        {
            return Null;
        }

        validateValue(otherCredsData.Value);

        var properties = otherCredsData.Value.Trim()
            .Split((char[])null, StringSplitOptions.RemoveEmptyEntries);
        var otherCreds = new OtherCreds()
        {
            SocialNetwork = properties[0],
            Login = properties[1],
            Password = properties[2],
        };

        return otherCreds;
    }

    public void Read(BinaryReader r)
    {
        string stringValue;

        var chars = r.ReadChars(MAX_STRING_SIZE);
        var stringEnd = Array.IndexOf(chars, '\0');

        if (stringEnd == 0)
        {
            stringValue = null;
            return;
        }

        stringValue = new String(chars, 0, stringEnd);
        var properties = stringValue.Trim()
            .Split((char[])null, StringSplitOptions.RemoveEmptyEntries);

        this.SocialNetwork = properties[0];
        this.Login = properties[1];
        this.Password = properties[2];
    }

    public void Write(BinaryWriter writer)
    {
        var stringValue = String.Concat(this.SocialNetwork, ' ', this.Login, ' ', this.Password);
        var ascii = Encoding.ASCII;

        // Pad the string from the right with null characters.
        var paddedString = stringValue.PadRight(MAX_STRING_SIZE, '\0');

        var b = ascii.GetBytes(paddedString);
        writer.Write(b);
    }

    private static void validateValue(string otherCredsData)
    {
        var properties = otherCredsData.Trim()
            .Split((char[])null, StringSplitOptions.RemoveEmptyEntries);

        if (properties.Length == 0)
        {
            throw new ArgumentException("The property socialNetwork is required");
        }

        if (properties.Length == 1)
        {
            throw new ArgumentException("The property login is required");
        }

        if (properties.Length == 2)
        {
            throw new ArgumentException("The property password is required");
        }
    }
}