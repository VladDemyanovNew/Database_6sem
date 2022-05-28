using Lab2;
using Lab2.Abstractions;
using Lab2.Database;
using Lab2.Exceptions;
using Lab2.Models;
using Lab2.Services;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.EntityFrameworkCore;
using System.Text.Json.Serialization;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers().AddJsonOptions(options =>
{
    options.JsonSerializerOptions.ReferenceHandler = ReferenceHandler.Preserve;
});

builder.Services
    .AddScoped<IUserService, UserService>()
    .AddScoped<IPostService, PostService>();

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<Lab6Context>(options => 
    options.UseOracle(connectionString));

var app = builder.Build();

app.UseExceptionHandler(app => app.Run(async context =>
{
    var exception = context.Features.Get<IExceptionHandlerFeature>()?.Error;

    switch (exception)
    {
        case EntityNotFoundException:
            context.Response.StatusCode = 404;
            break;
        case OperationFailedException:
            context.Response.StatusCode = 400;
            break;
        default:
            context.Response.StatusCode = 500;
            break;
    }

    await context.Response.WriteAsJsonAsync(new ErrorResponse
    {
        StatusCode = context.Response.StatusCode,
        ErrorMessage = exception.Message,
    });
}));

app.MapControllers();

app.Run();
