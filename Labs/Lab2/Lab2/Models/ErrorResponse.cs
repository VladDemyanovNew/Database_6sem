﻿namespace Lab2.Models;

public class ErrorResponse
{
    public int StatusCode { get; set; }

    public string ErrorMessage { get; set; } = default!;
}

