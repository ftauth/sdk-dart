#!/bin/bash

flutter pub run pigeon \
--input pigeons/ftauth_storage.dart \
--dart_out lib/src/ftauth_storage.pigeon.dart \
--dart_test_out test/ftauth_storage.pigeon.dart \
--java_out ../ftauth_storage_android/android/src/main/kotlin/io/ftauth/ftauth_storage_android/GeneratedBindings.java \
--java_package io.ftauth.ftauth_storage_android \
--objc_header_out ../ftauth_storage_ios/ios/Classes/GeneratedBindings.h \
--objc_source_out ../ftauth_storage_ios/ios/Classes/GeneratedBindings.m \
--objc_prefix FTAuth