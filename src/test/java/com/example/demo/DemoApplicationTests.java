package com.example.demo;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.web.client.RestClient;

import static org.junit.jupiter.api.Assertions.assertEquals;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class DemoApplicationTests {

	@LocalServerPort
	private int port;

	@Test
	void helloReturnsHelloWorld() {
		String body = RestClient.create()
				.get()
				.uri("http://127.0.0.1:" + port + "/")
				.retrieve()
				.body(String.class);
		assertEquals("Hello World", body);
	}
}
