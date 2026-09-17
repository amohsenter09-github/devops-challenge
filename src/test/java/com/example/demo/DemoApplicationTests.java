package com.example.demo;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.test.context.TestPropertySource;
import org.springframework.web.client.RestClient;

import static org.junit.jupiter.api.Assertions.assertTrue;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@TestPropertySource(properties = {
		"HELLO_COLOR=blue",
		"HELLO_EMOJI=🛠️"
})
class DemoApplicationTests {

	@LocalServerPort
	private int port;

	@Test
	void helloReturnsColoredHelloWorld() {
		String body = RestClient.create()
				.get()
				.uri("http://127.0.0.1:" + port + "/")
				.retrieve()
				.body(String.class);

		assertTrue(body != null && body.contains("Hello World"));
		assertTrue(body.contains("color: blue"));
		assertTrue(body.contains("🛠️"));
	}
}
