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
 * 健康检查接口测试：真实 HTTP 请求，随机端口。
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class HealthControllerTest {

    @Autowired
    private Environment environment;

    private final HttpClient client = HttpClient.newHttpClient();

    private HttpResponse<String> get(String path) throws Exception {
        String base = "http://localhost:" + environment.getProperty("local.server.port");
        HttpRequest request = HttpRequest.newBuilder(URI.create(base + path)).GET().build();
        return client.send(request, HttpResponse.BodyHandlers.ofString());
    }

    @Test
    void healthReturnsUnifiedResponse() throws Exception {
        HttpResponse<String> response = get("/api/health");
        assertEquals(200, response.statusCode());
        String body = response.body();
        assertTrue(body.contains("\"code\":0"), "统一响应 code 应为 0: " + body);
        assertTrue(body.contains("\"message\":\"ok\""), "统一响应 message 应为 ok: " + body);
        assertTrue(body.contains("\"status\":\"UP\""), "data 应包含 status=UP: " + body);
    }
}
