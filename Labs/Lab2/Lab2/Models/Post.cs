﻿namespace Lab2.Models;

public class Post : BaseEntity
{
    public string? Content { get; set; }

    public string? Title { get; set; }

    public int OwnerId { get; set; }
}