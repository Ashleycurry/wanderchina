package com.wanderchina.common;

/**
 * 统一响应结构：code=0 表示成功，非 0 表示失败。
 *
 * @param code    业务状态码（成功为 0，失败与 HTTP 状态一致）
 * @param message 提示信息
 * @param data    业务数据
 */
public record ApiResponse<T>(int code, String message, T data) {

    /** 成功响应。 */
    public static <T> ApiResponse<T> ok(T data) {
        return new ApiResponse<>(0, "ok", data);
    }

    /** 失败响应。 */
    public static <T> ApiResponse<T> error(int code, String message) {
        return new ApiResponse<>(code, message, null);
    }
}
