import 'dart:convert';

import 'package:app_config_test/aws_app_config_information.dart';
import 'package:app_config_test/secrets.dart';
import 'package:app_config_test/utils/date_time_helper.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class TestWithManualImplementation extends StatefulWidget {
  const TestWithManualImplementation({Key? key}) : super(key: key);

  @override
  State<TestWithManualImplementation> createState() => _HomePageState();
}

class _HomePageState extends State<TestWithManualImplementation> {
  Future<Map<String, dynamic>> getConfigurations() async {
    final Map<String, String> headers = {
      'Date': DateTimeHelper.convertCurrentDateToServerTime,
      'Host': AwsAppConfigInformation.baseUrl,
    };

    final canonicalHeaders = headers.keys.map((key) => '${key.toLowerCase()}:${headers[key]!.trim()}').toList()..sort();

    final headerKeys = headers.keys.map((key) => key.toLowerCase()).toList()..sort();

    final canonical = [
      'GET',
      AwsAppConfigInformation.path,
      'client_id=${Secrets.awsClientId}',
      ...canonicalHeaders,
      '',
      headerKeys.join(';'),
      sha256.convert([]).toString(), // body request
    ].join('\n');

    final canonicalHash = sha256.convert(utf8.encode(canonical)).toString();

    const aws4HmacSha256 = 'AWS4-HMAC-SHA256';

    final toSign = [
      aws4HmacSha256,
      DateTimeHelper.convertCurrentDateToServerTime, // "20220721T025741Z"
      '${DateTimeHelper.serverTimeFormatted}/${Secrets.awsRegion}/appconfig/aws4_request',
      canonicalHash,
    ].join('\n');

    final credentialList = [
      DateTimeHelper.serverTimeFormatted,
      Secrets.awsRegion,
      'appconfig',
      'aws4_request',
    ];

    List<int> signingKey = utf8.encode('AWS4${Secrets.awsSecretKey}');

    for (String credential in credentialList) {
      final hmac = Hmac(sha256, signingKey);
      signingKey = hmac.convert(utf8.encode(credential)).bytes;
    }

    final signature = Hmac(sha256, signingKey).convert(utf8.encode(toSign)).toString();

    final auth = '$aws4HmacSha256 '
        'Credential=${Secrets.awsAccessKey}/${credentialList.join('/')}, '
        'SignedHeaders=${headerKeys.join(';')}, '
        'Signature=$signature';

    headers.addAll({'Authorization': auth});

    final dio = Dio();

    final response = await dio.get(
      AwsAppConfigInformation.endpoint,
      queryParameters: {'client_id': Secrets.awsClientId},
      options: Options(headers: headers, validateStatus: (status) => true),
    );

    return response.data;
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
