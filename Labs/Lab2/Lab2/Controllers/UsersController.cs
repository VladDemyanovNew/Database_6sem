namespace Lab2.Controllers;

using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

using Lab2.Abstractions;
using Lab2.Models;
using Lab2.Exceptions;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Types;

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
    public async Task<ICollection<User>> GetAll() =>
        await this.userService.GetAllAsync();

    [HttpGet("{userId}")]
    public async Task<User> Get(int userId)
    {
        var user = await this.userService.GetAsync(userId);

        if (user == null)
        {
            throw new EntityNotFoundException($"User with id={userId} has not found");
        }

        return user;
    }

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

    [HttpGet("{userId}/subscribers")]
    public async Task<ICollection<User>> GetUserSubscribers(int userId) =>
        await this.userService.GetSubscribersAsync(userId);

    [HttpPost("{ownerId}/subscribers/{subscriberId}")]
    public async Task<IActionResult> Subscribe(int ownerId, int subscriberId)
    {
        await this.userService.SubscribeAsync(ownerId, subscriberId);
        return NoContent();
    }

    [HttpDelete("{ownerId}/subscribers/{subscriberId}")]
    public async Task<IActionResult> Unsubscribe(int ownerId, int subscriberId)
    {
        await this.userService.UnsubscribeAsync(ownerId, subscriberId);
        return NoContent();
    }

    [HttpGet("{userId}/nearest")]
    public async Task<ActionResult<User?>> FindNearestNeighbor(int userId) =>
        await this.userService.FindNearestNeighborAsync(userId);

    [HttpGet("shortestWay")]
    public async Task<IEnumerable<string>> DisplayShortestWay() =>
        await this.userService.DisplayShortestWay();
}
