import 'dart:convert';

import 'package:app_config_test/aws_app_config_information.dart';
import 'package:app_config_test/secrets.dart';
import 'package:aws_appconfig_api/appconfig-2019-10-09.dart';
import 'package:flutter/material.dart';

class TestWithPackage extends StatefulWidget {
  const TestWithPackage({Key? key}) : super(key: key);

  @override
  State<TestWithPackage> createState() => _PackageTestState();
}

class _PackageTestState extends State<TestWithPackage> {
  late String time;

  Future<Map<String, dynamic>> getConfigurations() async {
    final start = DateTime.now();

    final appConfig = AppConfig(
      region: Secrets.awsRegion,
      credentials: AwsClientCredentials(
        accessKey: Secrets.awsAccessKey,
        secretKey: Secrets.awsSecretKey,
      ),
    );

    final configuration = await appConfig.getConfiguration(
      clientId: Secrets.awsClientId,
      application: Secrets.appConfigApplicationId,
      environment: Secrets.appConfigEnvironmnetId,
      configuration: Secrets.appConfigConfigurationId,
    );

    if (configuration.content != null) {
      final json = jsonDecode(String.fromCharCodes(configuration.content!));
      final end = DateTime.now();

      time = end.difference(start).inMilliseconds.toString();

      return json;
    } else {
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text('AWS App Config'),
        centerTitle: true,
      ),
      body: Center(
        child: FutureBuilder(
          future: getConfigurations(),
          builder: ((context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.connectionState == ConnectionState.done) {
              final Map<String, dynamic> basesJson = snapshot.data as Map<String, dynamic>;
              List<String> bases = [];
              basesJson.forEach((key, value) {
                bases.add('$key - $value');
              });

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Tempo Gasto: ',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          time,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        const Text(
                          ' milisegundos',
                          style: TextStyle(fontSize: 16),
                        )
                      ],
                    ),
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    itemCount: bases.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            bases[index],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            }
            return const Text('erro');
          }),
        ),
      ),
    );
  }
}
