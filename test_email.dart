import 'lib/core/email_validation.dart';

void main() {
  print('Result for abcd1234:');
  print(EmailAddress.validate('abcd1234'));
  print('Is valid: ${EmailAddress.isValid('abcd1234')}');
}
