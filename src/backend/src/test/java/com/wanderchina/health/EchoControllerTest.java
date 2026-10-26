package com.wanderchina.health;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.core.env.Environment;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * 回显接口测试：正常回显 + 缺少参数返回统一错误。
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class EchoControllerTest {

    @Autowired
    private Environment environment;

    private final HttpClient client = HttpClient.newHttpClient();

    private HttpResponse<String> get(String path) throws Exception {
        String base = "http://localhost:" + environment.getProperty("local.server.port");
        HttpRequest request = HttpRequest.newBuilder(URI.create(base + path)).GET().build();
        return client.send(request, HttpResponse.BodyHandlers.ofString());
    }

    @Test
    void echoReturnsMessage() throws Exception {
        HttpResponse<String> response = get("/api/echo?message=hi");
        assertEquals(200, response.statusCode());
        String body = response.body();
        assertTrue(body.contains("\"message\":\"hi\""), "data 应回显 message=hi: " + body);
    }

    @Test
    void echoWithoutMessageReturns400UnifiedError() throws Exception {
        HttpResponse<String> response = get("/api/echo");
        assertEquals(400, response.statusCode());
        assertTrue(response.body().contains("\"code\":400"), "统一错误结构 code 应为 400: " + response.body());
    }
}
