package com.wanderchina.health;

import com.wanderchina.common.ApiResponse;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * 健康检查接口。
 */
@RestController
@RequestMapping("/api")
public class HealthController {

    /** 返回应用名与运行状态。 */
    @GetMapping("/health")
    public ApiResponse<Map<String, Object>> health() {
        return ApiResponse.ok(Map.of(
                "app", "wanderchina-backend",
                "status", "UP"
        ));
    }
}
