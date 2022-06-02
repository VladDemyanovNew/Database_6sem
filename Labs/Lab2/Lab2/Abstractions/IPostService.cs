namespace Lab2.Abstractions;

using Lab2.Models;

public interface IPostService
{
    Task<Post> CreateAsync(Post postCreateData);

    IEnumerable<Post> GetAll();

    Task DeleteAsync(int postId);

    Task UpdateAsync(int postId, Post postUdpateData);

    Task<Post> GetAsync(int postId);

    Task<IEnumerable<Post>> ExampleOfTransaction(IEnumerable<Post> posts);
}