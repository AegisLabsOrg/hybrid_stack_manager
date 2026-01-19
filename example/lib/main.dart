// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:aegis_hybrid_stack_manager/aegis_hybrid_stack_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _lastAction = 'None';

  @override
  void initState() {
    super.initState();
    // 注册回调，监听来自 Native 的跳转请求
    HybridStackManager.instance.setDelegate(
      onPush: (routeName, args) {
        setState(() {
          _lastAction = 'Native pushed: $routeName\nArgs: $args';
        });
        debugPrint("Dart received push request to: $routeName with $args");
        // 在真实项目中，这里会调用 Navigator.pushNamed(context, routeName, arguments: args);
      },
      onPop: () {
        setState(() {
          _lastAction = 'Native requested pop';
        });
        debugPrint("Dart received pop request");
        // Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Hybrid Stack Example')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Running on: ${Theme.of(context).platform}'),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[200],
                child: Text('Last Action: $_lastAction'),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // 请求打开 Native 页面
                  HybridStackManager.instance.pushNative(
                    "native_settings_page",
                    arguments: {"userId": 12345, "from": "flutter_home"},
                  );
                },
                child: const Text('Push Native Page'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // 请求关闭当前页面
                  HybridStackManager.instance.popNative();
                },
                child: const Text('Pop This Page (Finish)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
