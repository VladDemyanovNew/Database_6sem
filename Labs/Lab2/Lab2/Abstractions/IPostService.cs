using Lab2.Database;

namespace Lab2.Abstractions;

public interface IPostService
{
    Task<Post> CreateAsync(Post postCreateData);

    IEnumerable<Post> GetAll();

    Task DeleteAsync(int postId);

    Task UpdateAsync(int postId, Post postUdpateData);

    Task<Post> GetAsync(int postId);
}