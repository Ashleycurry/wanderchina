package com.wanderchina.common;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.core.env.Environment;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * 全局异常处理测试：未捕获异常应返回 500 统一错误结构。
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Import(ExceptionHandlerTest.FailingController.class)
class ExceptionHandlerTest {

    @Autowired
    private Environment environment;

    private final HttpClient client = HttpClient.newHttpClient();

    /** 仅用于测试的控制器：抛出未捕获异常。 */
    @RestController
    static class FailingController {

        @GetMapping("/api/test/fail")
        String fail() {
            throw new IllegalStateException("boom");
        }
    }

    private HttpResponse<String> get(String path) throws Exception {
        String base = "http://localhost:" + environment.getProperty("local.server.port");
        HttpRequest request = HttpRequest.newBuilder(URI.create(base + path)).GET().build();
        return client.send(request, HttpResponse.BodyHandlers.ofString());
    }

    @Test
    void unknownExceptionReturns500UnifiedError() throws Exception {
        HttpResponse<String> response = get("/api/test/fail");
        assertEquals(500, response.statusCode());
        assertTrue(response.body().contains("\"code\":500"), "统一错误结构 code 应为 500: " + response.body());
    }
}
