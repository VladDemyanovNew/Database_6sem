using Lab2.Abstractions;
using Lab2.Database;
using Lab2.Exceptions;
using Lab2.Models;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.SqlServer.Types;
using Oracle.ManagedDataAccess.Client;
using System.Data;
using System.Data.SqlTypes;

namespace Lab2.Services;

public class UserService : IUserService
{
    private readonly Lab6Context _dbContext;

    public UserService(Lab6Context dbContext) 
    {
        this._dbContext = dbContext;
    }

    public async Task<User> GetAsync(int userId)
    {
        var user = await this._dbContext.Users.FirstOrDefaultAsync(user => user.Id == userId);
        if (user == null)
        {
            throw new EntityNotFoundException($"User with id={userId} has not found");
        }

        return user;
    }

    public IEnumerable<User> GetAll() => this._dbContext.Users;

    public async Task<User> CreateAsync(User userCreateData)
    {
        _ = await this._dbContext.Users.AddAsync(userCreateData);
        _ = await this._dbContext.SaveChangesAsync();
        return userCreateData;
    }

    public async Task DeleteAsync(int userId)
    {
        var user = await this._dbContext.Users.FirstOrDefaultAsync(user => user.Id == userId);
        if (user == null)
        {
            throw new EntityNotFoundException($"User with id={userId} has not found");
        }

        this._dbContext.Users.Remove(user);
        _ = await this._dbContext.SaveChangesAsync();
    }

    public async Task UpdateAsync(int userId, User userUdpateData)
    {
        var user = await this._dbContext.Users.FirstOrDefaultAsync(user => user.Id == userId);
        if (user == null)
        {
            throw new EntityNotFoundException($"User with id={userId} has not found");
        }

        user.Nickname = userUdpateData.Nickname;
        _ = this._dbContext.SaveChangesAsync();
    }
}
