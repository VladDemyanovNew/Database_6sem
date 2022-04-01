namespace Lab2.Services;

using Lab2.Abstractions;
using Lab2.Exceptions;
using Lab2.Models;
using Microsoft.Data.SqlClient;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;

public class PostService : IPostService
{
    private readonly string connectionString;

    public PostService(IConfiguration configuration)
    {
        this.connectionString = configuration.GetConnectionString("DefaultConnection");
    }

    public async Task<Post?> GetAsync(int postId)
    {
        using (SqlConnection connection = new SqlConnection(this.connectionString))
        {
            await connection.OpenAsync();

            SqlCommand command = new SqlCommand("PGET_POST", connection);
            command.CommandType = CommandType.StoredProcedure;

            SqlParameter postIdParam = new SqlParameter
            {
                ParameterName = "@post_id",
                Value = postId
            };
            command.Parameters.Add(postIdParam);

            using (SqlDataReader reader = await command.ExecuteReaderAsync())
            {
                if (!reader.HasRows)
                {
                    return null;
                }

                await reader.ReadAsync();

                var post = new Post
                {
                    Id = reader.GetInt32(0),
                    Content = reader.GetString(1),
                    OwnerId = reader.GetInt32(2),
                };

                return post;
            }
        }
    }

    public async Task UpdateAsync(int postId, Post postUdpateData)
    {
        var post = await this.GetAsync(postId);

        if (post == null)
        {
            throw new EntityNotFoundException($"Post with id={postId} has not found");
        }

        using (SqlConnection connection = new SqlConnection(this.connectionString))
        {
            await connection.OpenAsync();

            SqlCommand command = new SqlCommand("PUPDATE_POST", connection);
            command.CommandType = CommandType.StoredProcedure;

            SqlParameter postIdParam = new SqlParameter
            {
                ParameterName = "@post_id",
                Value = postId
            };
            SqlParameter contentParam = new SqlParameter
            {
                ParameterName = "@content",
                Value = postUdpateData.Content
            };
            SqlParameter ownerIdParam = new SqlParameter
            {
                ParameterName = "@owner_id",
                Value = postUdpateData.OwnerId
            };

            command.Parameters.Add(postIdParam);
            command.Parameters.Add(contentParam);
            command.Parameters.Add(ownerIdParam);

            _ = await command.ExecuteScalarAsync();
        }
    }

    public async Task<Post> CreateAsync(Post postCreateData)
    {
        using (SqlConnection connection = new SqlConnection(this.connectionString))
        {
            await connection.OpenAsync();

            SqlCommand command = new SqlCommand("PCREATE_POST", connection);
            command.CommandType = CommandType.StoredProcedure;

            SqlParameter contentParam = new SqlParameter
            {
                ParameterName = "@content",
                Value = postCreateData.Content
            };
            SqlParameter ownerIdParam = new SqlParameter
            {
                ParameterName = "@owner_id",
                Value = postCreateData.OwnerId
            };

            command.Parameters.Add(contentParam);
            command.Parameters.Add(ownerIdParam);

            var result = await command.ExecuteScalarAsync();
            if (result != null && Int32.TryParse(result.ToString(), out int createdPostId))
            {
                postCreateData.Id = createdPostId;
            }
        }
        return postCreateData;
    }

    public async Task DeleteAsync(int postId)
    {
        var post = await this.GetAsync(postId);

        if (post == null)
        {
            throw new EntityNotFoundException($"Post with id={postId} has not found");
        }

        using (SqlConnection connection = new SqlConnection(this.connectionString))
        {
            await connection.OpenAsync();

            SqlCommand command = new SqlCommand("PDELETE_POST", connection);
            command.CommandType = CommandType.StoredProcedure;

            SqlParameter postIdParam = new SqlParameter
            {
                ParameterName = "@post_id",
                Value = postId
            };
            command.Parameters.Add(postIdParam);

            _ = await command.ExecuteNonQueryAsync();
        }
    }

    public async Task<ICollection<Post>> GetAllAsync()
    {
        var posts = new List<Post>();

        using (SqlConnection connection = new SqlConnection(this.connectionString))
        {
            await connection.OpenAsync();

            SqlCommand command = new SqlCommand("PGET_ALL_POSTS", connection);
            command.CommandType = CommandType.StoredProcedure;

            using (SqlDataReader reader = await command.ExecuteReaderAsync())
            {
                if (!reader.HasRows)
                {
                    return posts;
                }

                while (await reader.ReadAsync())
                {
                    posts.Add(new Post
                    {
                        Id = reader.GetInt32(0),
                        Content = reader.GetString(1),
                        OwnerId = reader.GetInt32(2),
                    });
                }
            }
        }

        return posts;
    }
}
