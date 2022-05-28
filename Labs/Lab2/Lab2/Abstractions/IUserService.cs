using Lab2.Database;

namespace Lab2.Abstractions;

public interface IUserService
{
    Task<User> CreateAsync(User userCreateData);

    IEnumerable<User> GetAll();

    Task DeleteAsync(int userId);

    Task UpdateAsync(int userId, User userUdpateData);

    Task<User> GetAsync(int userId);
}
