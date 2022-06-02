namespace Lab2.Controllers;

using Lab2.Abstractions;
using Lab2.Models;
using Microsoft.AspNetCore.Mvc;

[Route("api/[controller]")]
[ApiController]
public class AuditsController : ControllerBase
{
    private readonly IAuditService auditService;

    public AuditsController(IAuditService auditService)
    {
        this.auditService = auditService;
    }

    [HttpGet]
    public IEnumerable<History> GetAll() =>
        this.auditService.GetAll();
}
