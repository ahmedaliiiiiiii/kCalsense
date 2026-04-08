import 'api_exception.dart';

String userFriendlyMessage(Object error) {
  if (error is! ApiException) {
    return "Something went wrong. Please try again.";
  }

  if (error.message == "NO_INTERNET") {
    return "No internet connection. Please check your connection and try again.";
  }

  if (error.message == "TIMEOUT") {
    return "Request timed out. Please try again.";
  }

  if (error.message == "CANCELLED") {
    return "Request cancelled. Please try again.";
  }

  final raw = error.message.trim();
  final lower = raw.toLowerCase();
  final status = error.statusCode;

  if (status == 401) {
    return "Email or password is incorrect.";
  }

  if (status == 403) {
    return "You don’t have permission to do this.";
  }

  if (status == 404) {
    return "you don’t have acount.";
  }

  if (status != null && status >= 500) {
    return "Service is currently unavailable. Please try again later.";
  }

  if (lower.contains("username") && lower.contains("taken")) {
    return "Username already taken.";
  }

  if (lower.contains("email") &&
      (lower.contains("taken") ||
          lower.contains("exists") ||
          lower.contains("already"))) {
    return "Email already registered.";
  }

  if (lower.contains("password") &&
      (lower.contains("uppercase") ||
          lower.contains("lowercase") ||
          lower.contains("number"))) {
    return "Password must include uppercase, lowercase, and number.";
  }

  if (lower.contains("validation") || lower.contains("required")) {
    return "Please check your inputs.";
  }

  if (raw.isNotEmpty && raw.length <= 120) {
    return raw;
  }

  return "Something went wrong. Please try again.";
}
