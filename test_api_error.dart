import 'lib/core/api_error_text.dart';

void main() {
  final input = "ErrorDetail(string='Enter a valid email address.', code='invalid')";
  print('Result:');
  print(ApiErrorText.readable(input));
  
  final input2 = "{'identifier': [ErrorDetail(string='Enter a valid email address.', code='invalid')]}";
  print('Result 2:');
  print(ApiErrorText.readable(input2));
}
