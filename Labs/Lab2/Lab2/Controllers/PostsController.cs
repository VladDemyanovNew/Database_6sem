using Lab2.Abstractions;
using Lab2.Database;
using Lab2.Exceptions;
using Microsoft.AspNetCore.Mvc;

namespace Lab2.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PostsController : ControllerBase
    {
        private readonly IPostService postService;

        public PostsController(IPostService postService)
        {
            this.postService = postService;
        }

        [HttpGet("{postId}")]
        public async Task<Post> Get(int postId) =>
            await this.postService.GetAsync(postId);

        [HttpGet]
        public IEnumerable<Post> GetAll() => 
            this.postService.GetAll();

        [HttpPost]
        public async Task<Post> Post([FromBody] Post postCreateData) => 
            await this.postService.CreateAsync(postCreateData);

        [HttpPut("{postId}")]
        public async Task<IActionResult> Put(int postId, [FromBody] Post postUpdateData)
        {
            await this.postService.UpdateAsync(postId, postUpdateData);
            return NoContent();
        }

        [HttpDelete("{postId}")]
        public async Task<ActionResult> Delete(int postId)
        {
            await postService.DeleteAsync(postId);
            return NoContent();
        }
    }
}
