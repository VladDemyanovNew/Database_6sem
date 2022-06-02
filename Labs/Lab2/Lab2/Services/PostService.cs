namespace Lab2.Services;

using Lab2.Abstractions;
using Lab2.Database;
using Lab2.Exceptions;
using Lab2.Models;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;

public class PostService : IPostService
{
    private readonly Lab11Context _dbContext;

    public PostService(Lab11Context dbContext)
    {
        this._dbContext = dbContext;
    }

    public async Task<Post> GetAsync(int postId)
    {
        var post = await this._dbContext.Posts.FirstOrDefaultAsync(post => post.Id == postId);
        if (post == null)
        {
            throw new EntityNotFoundException($"Post with id={postId} has not found");
        }

        return post;
    }

    public async Task UpdateAsync(int postId, Post postUdpateData)
    {
        var post = await this._dbContext.Posts.FirstOrDefaultAsync(post => post.Id == postId);
        if (post == null)
        {
            throw new EntityNotFoundException($"Can't update post, " +
                   $"because post with id={postId} has not found");
        }

        var user = await this._dbContext.Users.FirstOrDefaultAsync(user => user.Id == postUdpateData.OwnerId);
        if (user == null)
        {
            throw new EntityNotFoundException($"Can't update post, " +
                $"because user with id={postUdpateData.OwnerId} has not found");
        }

        post.OwnerId = postUdpateData.OwnerId;
        post.Content = postUdpateData.Content;
        await this._dbContext.SaveChangesAsync();
    }

    public async Task<Post> CreateAsync(Post postCreateData)
    {
        var user = await this._dbContext.Users.FirstOrDefaultAsync(user => user.Id == postCreateData.OwnerId);
        if (user == null)
        {
            throw new EntityNotFoundException($"Can't create post, " +
                $"because user with id={postCreateData.OwnerId} has not found");
        }

        _ = await this._dbContext.Posts.AddAsync(postCreateData);
        _ = await this._dbContext.SaveChangesAsync();
        return postCreateData;
    }

    public async Task DeleteAsync(int postId)
    {
        var post = await this._dbContext.Posts.FirstOrDefaultAsync(post => post.Id == postId);
        if (post == null)
        {
            throw new EntityNotFoundException($"Post with id={postId} has not found");
        }

        this._dbContext.Posts.Remove(post);
        _ = await this._dbContext.SaveChangesAsync();
    }

    public IEnumerable<Post> GetAll() => this._dbContext.Posts;

    public async Task<IEnumerable<Post>> ExampleOfTransaction(IEnumerable<Post> posts)
    {
        using var transaction = this._dbContext.Database.BeginTransaction();

        try
        {
            foreach (var post in posts)
            {
                _ = await this._dbContext.Posts.AddAsync(post);
            }

            _ = await this._dbContext.SaveChangesAsync();
            transaction.Commit();
        }
        catch (Exception)
        {
            transaction.Rollback();
            throw new OperationFailedException($"Transaction failed");
        }

        return posts;
    }
}
