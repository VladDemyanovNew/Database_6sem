using System;
using System.Collections.Generic;

namespace Lab2.Database
{
    public partial class User
    {
        public User()
        {
        }

        public int Id { get; set; }
        public string Nickname { get; set; } = null!;

        public ICollection<Post> Posts { get; } = new HashSet<Post>();
    }
}
