namespace Lab2.Controllers;

using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

using Lab2.Abstractions;
using Lab2.Models;
using Lab2.Exceptions;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Types;
using Lab2.Database;

[Route("api/[controller]")]
[ApiController]
public class UsersController : ControllerBase
{
    private readonly IUserService userService;

    public UsersController(IUserService userService)
    {
        this.userService = userService;
    }

    [HttpGet]
    public IEnumerable<User> GetAll() => this.userService.GetAll();

    [HttpGet("{userId}")]
    public async Task<User> Get(int userId) => 
        await this.userService.GetAsync(userId);

    [HttpPost]
    public async Task<ActionResult<User>> Post([FromBody] User userCreateData)
    {
        var user = await this.userService.CreateAsync(userCreateData);
        return CreatedAtAction(nameof(Get), new { userId = user.Id }, user);
    }

    [HttpPut("{userId}")]
    public async Task<IActionResult> Put(int userId, [FromBody] User userUpdateData)
    {
        await this.userService.UpdateAsync(userId, userUpdateData);
        return NoContent();
    }

    [HttpDelete("{userId}")]
    public async Task<IActionResult> Delete(int userId)
    {
        await this.userService.DeleteAsync(userId);
        return NoContent();
    }
}
