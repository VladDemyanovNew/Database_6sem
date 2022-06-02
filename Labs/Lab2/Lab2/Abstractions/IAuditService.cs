using Lab2.Models;

namespace Lab2.Abstractions;

public interface IAuditService
{
    IEnumerable<History> GetAll();
}
