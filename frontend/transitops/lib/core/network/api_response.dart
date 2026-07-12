class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final ApiMeta? meta;
  final ApiError? error;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.meta,
    this.error,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    final success = json['success'] ?? false;
    return ApiResponse(
      success: success,
      data: json['data'] != null && success ? fromJsonT(json['data']) : null,
      message: json['message'] as String?,
      meta: json['meta'] != null ? ApiMeta.fromJson(json['meta'] as Map<String, dynamic>) : null,
      error: json['error'] != null ? ApiError.fromJson(json['error'] as Map<String, dynamic>) : null,
    );
  }
}

class ApiMeta {
  final int page;
  final int limit;
  final int totalCount;

  ApiMeta({
    required this.page,
    required this.limit,
    required this.totalCount,
  });

  factory ApiMeta.fromJson(Map<String, dynamic> json) {
    return ApiMeta(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalCount: json['totalCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'totalCount': totalCount,
    };
  }
}

class ApiError {
  final String code;
  final String message;
  final List<ApiErrorDetail>? details;

  ApiError({
    required this.code,
    required this.message,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] ?? '',
      message: json['message'] ?? '',
      details: json['details'] != null
          ? (json['details'] as List<dynamic>)
              .map((e) => ApiErrorDetail.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'details': details?.map((e) => e.toJson()).toList(),
    };
  }
}

class ApiErrorDetail {
  final String field;
  final String issue;

  ApiErrorDetail({
    required this.field,
    required this.issue,
  });

  factory ApiErrorDetail.fromJson(Map<String, dynamic> json) {
    return ApiErrorDetail(
      field: json['field'] ?? '',
      issue: json['issue'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'field': field,
      'issue': issue,
    };
  }
}
