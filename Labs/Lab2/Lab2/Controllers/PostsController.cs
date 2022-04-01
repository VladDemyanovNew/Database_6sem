using Lab2.Abstractions;
using Lab2.Exceptions;
using Lab2.Models;
using Microsoft.AspNetCore.Http;
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
        public async Task<Post> Get(int postId)
        {
            var post = await this.postService.GetAsync(postId);

            if (post == null)
            {
                throw new EntityNotFoundException($"Post with id={postId} has not found");
            }

            return post;
        }

        [HttpGet]
        public async Task<ICollection<Post>> GetAll() => 
            await postService.GetAllAsync();

        [HttpPost]
        public async Task<ActionResult<Post>> Post([FromBody] Post postCreateData)
        {
            var post = await this.postService.CreateAsync(postCreateData);
            return CreatedAtAction(nameof(Get), new { postId = post.Id }, post);
        }

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
