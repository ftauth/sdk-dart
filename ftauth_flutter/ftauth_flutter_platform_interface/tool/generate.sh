#!/bin/bash

flutter pub run pigeon \
--input pigeons/ftauth_flutter.dart \
--dart_out lib/src/ftauth_flutter.pigeon.dart \
--dart_test_out test/ftauth_flutter.pigeon.dart \
--java_out ../ftauth_flutter_android/android/src/main/kotlin/io/ftauth/ftauth_flutter_android/GeneratedBindings.java \
--java_package io.ftauth.ftauth_flutter_android \
--objc_header_out ../ftauth_flutter_ios/ios/Classes/GeneratedBindings.h \
--objc_source_out ../ftauth_flutter_ios/ios/Classes/GeneratedBindings.m \
--objc_prefix FTAuth

flutter format .