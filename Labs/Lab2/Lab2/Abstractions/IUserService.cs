namespace Lab2.Abstractions;

using Lab2.Models;

public interface IUserService
{
    Task<ICollection<User>> GetSubscribersAsync(int userId);

    Task<User> CreateAsync(User userCreateData);

    Task<ICollection<User>> GetAllAsync();

    Task DeleteAsync(int userId);

    Task UpdateAsync(int userId, User userUdpateData);

    Task<User?> GetAsync(int userId);

    Task SubscribeAsync(int ownerId, int subscriberId);

    Task UnsubscribeAsync(int ownerId, int subscriberId);
}
