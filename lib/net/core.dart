class WrapperModel {
  final int code;
  final dynamic data;
  final String message;

  WrapperModel({
    required this.code,
    required this.data,
    required this.message,
  });

  WrapperModel.formJson(Map<String, dynamic> json)
      : code = json['code'],
        data = json['data'],
        message = json['message'];
}

abstract class BaseModel {
  BaseModel fromJson(dynamic data);
}
