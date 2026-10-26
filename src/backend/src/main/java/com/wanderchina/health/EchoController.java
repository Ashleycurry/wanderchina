package com.wanderchina.health;

import com.wanderchina.common.ApiResponse;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * 回显接口：用于验证前后端联通与参数校验。
 */
@RestController
@RequestMapping("/api")
public class EchoController {

    /** 回显客户端传入的消息；缺少 message 参数时由全局异常处理器返回 400。 */
    @GetMapping("/echo")
    public ApiResponse<Map<String, String>> echo(@RequestParam String message) {
        return ApiResponse.ok(Map.of("message", message));
    }
}
