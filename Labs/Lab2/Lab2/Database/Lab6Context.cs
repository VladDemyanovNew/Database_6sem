using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;

namespace Lab2.Database
{
    public partial class Lab6Context : DbContext
    {
        public Lab6Context()
        {
        }

        public Lab6Context(DbContextOptions<Lab6Context> options)
            : base(options)
        {
        }

        public DbSet<Post> Posts => this.Set<Post>();
        public DbSet<User> Users => this.Set<User>();

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Post>(entity =>
            {
                entity.ToTable("POSTS");

                entity.Property(e => e.Id)
                    .HasPrecision(10)
                    .HasColumnName("ID");

                entity.Property(e => e.Content)
                    .HasMaxLength(300)
                    .HasColumnName("CONTENT");

                entity.Property(e => e.OwnerId)
                    .HasPrecision(10)
                    .HasColumnName("OWNER_ID");

                entity.HasOne(d => d.Owner)
                    .WithMany(p => p.Posts)
                    .HasForeignKey(d => d.OwnerId)
                    .HasConstraintName("FK_POSTS_TO_USERS");
            });

            modelBuilder.Entity<User>(entity =>
            {
                entity.ToTable("USERS");

                entity.HasIndex(e => e.Nickname, "UQ__USERS__AFFD7B7F4FF1E6D3")
                    .IsUnique();

                entity.Property(e => e.Id)
                    .HasPrecision(10)
                    .HasColumnName("ID");

                entity.Property(e => e.Nickname)
                    .HasMaxLength(30)
                    .HasColumnName("NICKNAME");
            });

            OnModelCreatingPartial(modelBuilder);
        }

        partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
    }
}
