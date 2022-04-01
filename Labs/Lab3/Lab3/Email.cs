using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using System.IO;
using System.Net.Mail;
using System.Text;
using Microsoft.SqlServer.Server;

[Serializable]
[Microsoft.SqlServer.Server.SqlUserDefinedType(Format.UserDefined, MaxByteSize = 50, Name = "email")]
public struct Email: INullable, IBinarySerialize
{
    private bool _null;

    public string EmailValue { get; set; }

    public bool IsNull
    {
        get
        {
            return _null;
        }
    }

    public static Email Null
    {
        get
        {
            Email email = new Email();
            email._null = true;
            return email;
        }
    }

    public override string ToString()
    {
        if (IsNull)
        {
            return "NULL";
        }

        return EmailValue;
    }

    [SqlMethod(OnNullCall = false)]
    public static Email Parse(SqlString emailData)
    {
        if (emailData.IsNull)
        {
            return Null;
        }

        var addr = new MailAddress(emailData.Value);

        if (addr.Address != emailData.Value)
        {
            throw new ArgumentException("The value is not a valid mail address.");
        }

        Email email = new Email();
        email.EmailValue = emailData.Value;

        return email;
    }

    public void Read(BinaryReader r)
    {
        int maxStringSize = 16;
        char[] chars;
        int stringEnd;
        string stringValue;

        chars = r.ReadChars(maxStringSize);

        stringEnd = Array.IndexOf(chars, '\0');

        if (stringEnd == 0)
        {
            stringValue = null;
            return;
        }

        stringValue = new String(chars, 0, stringEnd);
        this.EmailValue = stringValue;
    }

    public void Write(BinaryWriter w)
    {
        int maxStringSize = 50;
        string stringValue = this.EmailValue;
        string paddedString;

        Encoding ascii = Encoding.ASCII;

        // Pad the string from the right with null characters.
        paddedString = stringValue.PadRight(maxStringSize, '\0');

        byte[] b = ascii.GetBytes(paddedString);
        w.Write(b);
    }
}