namespace Lab2.Exceptions;

public class OperationFailedException : Exception
{
    public OperationFailedException(string message)
        : base(message)
    {
    }
}
