using Lab2.Abstractions;
using Lab2.Database;
using Lab2.Models;

namespace Lab2.Services;

public class AuditService : IAuditService
{
    private readonly Lab11Context _dbContext;

    public AuditService(Lab11Context dbContext)
    {
        this._dbContext = dbContext;
    }

    public IEnumerable<History> GetAll() =>
        this._dbContext.Histories;
}
