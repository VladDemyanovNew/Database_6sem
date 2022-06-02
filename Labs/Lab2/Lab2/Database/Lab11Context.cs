using Lab2.Models;
using Microsoft.EntityFrameworkCore;

namespace Lab2.Database;

public class Lab11Context : DbContext
{
    public Lab11Context()
    {
    }

    public Lab11Context(DbContextOptions<Lab11Context> options)
        : base(options)
    {
    }

    public DbSet<Post> Posts => this.Set<Post>();

    public DbSet<User> Users => this.Set<User>();

    public DbSet<History> Histories => this.Set<History>();
}
