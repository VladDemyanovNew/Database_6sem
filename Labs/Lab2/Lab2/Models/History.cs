namespace Lab2.Models;

public class History : BaseEntity
{
    public string Action { get; set; } = string.Empty;

    public string Info { get; set; } = string.Empty;

    public string TableName { get; set; } = string.Empty;

    public string Timestamp { get; set; } = string.Empty;
}
