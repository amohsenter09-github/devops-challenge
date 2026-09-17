package com.example.demo;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

	// Set at runtime by Docker/Terraform (HELLO_COLOR / HELLO_EMOJI).
	@Value("${HELLO_COLOR:black}")
	private String color;

	@Value("${HELLO_EMOJI:}")
	private String emoji;

	@GetMapping(value = "/", produces = MediaType.TEXT_HTML_VALUE)
	public String hello() {
		String safeColor = color.replaceAll("[^a-zA-Z0-9#]", "");
		String label = emoji.isBlank() ? "Hello World" : emoji + " Hello World";
		return """
			<!DOCTYPE html>
			<html lang="en">
			<head><meta charset="UTF-8"><title>Hello World</title></head>
			<body style="font-family: system-ui, sans-serif; display: grid; place-items: center; min-height: 100vh; margin: 0;">
			  <h1 style="color: %s; font-size: 3rem;">%s</h1>
			</body>
			</html>
			""".formatted(safeColor, label);
	}
}
