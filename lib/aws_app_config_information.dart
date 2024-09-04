import 'package:app_config_test/secrets.dart';

class AwsAppConfigInformation {
  static String baseUrl = 'appconfig.${Secrets.awsRegion}.amazonaws.com';

  static String get path =>
      '/applications/${Secrets.appConfigApplicationId}/environments/${Secrets.appConfigEnvironmnetId}/configurations/${Secrets.appConfigConfigurationId}';
  static String get endpoint => 'https://$baseUrl$path';
}
