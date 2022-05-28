using System;
using System.Collections.Generic;

namespace Lab2.Database
{
    public partial class Post
    {
        public int Id { get; set; }
        public string Content { get; set; } = null!;
        public int OwnerId { get; set; }

        public User? Owner { get; set; }
    }
}
