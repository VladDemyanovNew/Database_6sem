using Lab2.Abstractions;
using Lab2.Exceptions;
using Lab2.Models;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Lab2.Services;

public class UserService : IUserService
{
    private readonly string connectionString;

    public UserService(IConfiguration configuration) 
    {
        this.connectionString = configuration.GetConnectionString("DefaultConnection");
    }

    public async Task<User?> GetAsync(int userId)
    {
        using (SqlConnection connection = new SqlConnection(this.connectionString))
        {
            await connection.OpenAsync();

            SqlCommand command = new SqlCommand("PGET_USER", connection);
            command.CommandType = CommandType.StoredProcedure;

            SqlParameter userIdParam = new SqlParameter
            {
                ParameterName = "@user_id",
                Value = userId
            };
            command.Parameters.Add(userIdParam);

            using (SqlDataReader reader = await command.ExecuteReaderAsync())
            {
                if (!reader.HasRows)
                {
                    return null;
                }

                await reader.ReadAsync();

                var user = new User
                {
                    Id = reader.GetInt32(0),
                    Nickname = reader.GetString(1)
                };

                return user;
            }
        }
    }

    public async Task<ICollection<User>> GetSubscribersAsync(int userId)
    {
        var subscribers = new List<User>();

        using (SqlConnection connection = new SqlConnection(this.connectionString))
        {
            await connection.OpenAsync();

            SqlCommand command = new SqlCommand("PGET_USER_SUBSCRIBERS", connection);
            command.CommandType = CommandType.StoredProcedure;

            SqlParameter userIdParam = new SqlParameter
            {
                ParameterName = "@user_id",
                Value = userId
            };
            command.Parameters.Add(userIdParam);

            using (SqlDataReader reader = await command.ExecuteReaderAsync())
            {
                if (reader.HasRows)
                {
                    while (await reader.ReadAsync())
                    {
                        subscribers.Add(new User
                        {
                            Id = reader.GetInt32(0),
                            Nickname = reader.GetString(1)
                        });
                    }
                }
            }
        }

        return subscribers;
    }

    public async Task<ICollection<User>> GetAllAsync()
    {
        var users = new List<User>();

        using (SqlConnection connection = new SqlConnection(this.connectionString))
        {
            await connection.OpenAsync();

            SqlCommand command = new SqlCommand("PGET_ALL_USERS", connection);
            command.CommandType = CommandType.StoredProcedure;

            using (SqlDataReader reader = await command.ExecuteReaderAsync())
            {
                if (reader.HasRows)
                {
                    while (await reader.ReadAsync())
                    {
                        users.Add(new User
                        {
                            Id = reader.GetInt32(0),
                            Nickname = reader.GetString(1)
                        });
                    }
                }
            }
        }

        return users;
    }

    public async Task<User> CreateAsync(User userCreateData)
    {
        using (SqlConnection connection = new SqlConnection(this.connectionString))
        {
            await connection.OpenAsync();

            SqlCommand command = new SqlCommand("PCREATE_USER", connection);
            command.CommandType = CommandType.StoredProcedure;

            SqlParameter nicknameParam = new SqlParameter
            {
                ParameterName = "@nickname",
                Value = userCreateData.Nickname
            };
            command.Parameters.Add(nicknameParam);

            var result = await command.ExecuteScalarAsync();
            if (result != null && Int32.TryParse(result.ToString(), out int createdPostId))
            {
                userCreateData.Id = createdPostId;
            }
        }
        return userCreateData;
    }

    public async Task DeleteAsync(int userId)
    {
        var user = await this.GetAsync(userId);

        if (user == null)
        {
            throw new EntityNotFoundException($"User with id={userId} has not found");
        }

        using (SqlConnection connection = new SqlConnection(this.connectionString))
        {
            await connection.OpenAsync();

            SqlCommand command = new SqlCommand("PDELETE_USER", connection);
            command.CommandType = CommandType.StoredProcedure;

            SqlParameter userIdParam = new SqlParameter
            {
                ParameterName = "@user_id",
                Value = userId
            };
            command.Parameters.Add(userIdParam);

            _ = await command.ExecuteNonQueryAsync();
        }
    }

    public async Task UpdateAsync(int userId, User userUdpateData)
    {
        var user = await this.GetAsync(userId);

        if (user == null)
        {
            throw new EntityNotFoundException($"User with id={userId} has not found");
        }

        using (SqlConnection connection = new SqlConnection(this.connectionString))
        {
            await connection.OpenAsync();

            SqlCommand command = new SqlCommand("PUPDATE_USER", connection);
            command.CommandType = CommandType.StoredProcedure;

            SqlParameter userIdParam = new SqlParameter
            {
                ParameterName = "@user_id",
                Value = userId
            };

            SqlParameter nicknameParam = new SqlParameter
            {
                ParameterName = "@nickname",
                Value = userUdpateData.Nickname
            };

            command.Parameters.Add(userIdParam);
            command.Parameters.Add(nicknameParam);

            _ = await command.ExecuteScalarAsync();
        }
    }

    public async Task SubscribeAsync(int ownerId, int subscriberId)
    {
        var user = await this.GetAsync(ownerId);

        if (user == null)
        {
            throw new EntityNotFoundException($"Can't subscribe on owner with id={ownerId}, " +
                "because it doesn't exist.");
        }

        var canUserSubscribe = !await this.HasUserAlreadySubscribed(ownerId, subscriberId);

        if (!canUserSubscribe)
        {
            throw new OperationFailedException($"Can't subscribe on owner with id={ownerId}, " +
                "because user has already subscribed on it");
        }


        using (SqlConnection connection = new SqlConnection(this.connectionString))
        {
            await connection.OpenAsync();

            SqlCommand command = new SqlCommand("PSUBSCRIBE", connection);
            command.CommandType = CommandType.StoredProcedure;

            SqlParameter ownerIdParam = new SqlParameter
            {
                ParameterName = "@ownerId",
                Value = ownerId
            };
            SqlParameter subscriberIdParam = new SqlParameter
            {
                ParameterName = "@subscriberId",
                Value = subscriberId
            };

            command.Parameters.Add(ownerIdParam);
            command.Parameters.Add(subscriberIdParam);

            _ = await command.ExecuteScalarAsync();
        }
    }

    public async Task UnsubscribeAsync(int ownerId, int subscriberId)
    {
        var canUserUnsubscribe = await this.HasUserAlreadySubscribed(ownerId, subscriberId);

        if (!canUserUnsubscribe)
        {
            throw new OperationFailedException($"Can't unsubscribe by owner with id={ownerId}, " +
                "because user has not subscribed on it yet");
        }


        using (SqlConnection connection = new SqlConnection(this.connectionString))
        {
            await connection.OpenAsync();

            SqlCommand command = new SqlCommand("PUNSUBSCRIBE", connection);
            command.CommandType = CommandType.StoredProcedure;

            SqlParameter ownerIdParam = new SqlParameter
            {
                ParameterName = "@ownerId",
                Value = ownerId
            };
            SqlParameter subscriberIdParam = new SqlParameter
            {
                ParameterName = "@subscriberId",
                Value = subscriberId
            };

            command.Parameters.Add(ownerIdParam);
            command.Parameters.Add(subscriberIdParam);

            _ = await command.ExecuteScalarAsync();
        }
    }

    private async Task<bool> HasUserAlreadySubscribed(int ownerId, int subscriberId)
    {
        var subscribers = await this.GetSubscribersAsync(ownerId);
        return subscribers.Any(user => user.Id == subscriberId);
    }
}
