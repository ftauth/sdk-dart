# TODO: Follow guidelines here: https://dart.dev/null-safety/migration-guide#package-version
# e.g. setting SDK constraint with local dart version
.PHONY: ftauth
ftauth: ftauth-test
	cd ftauth; \
	dart pub publish;

# TODO: Upload coverage: https://pub.dev/packages/test#collecting-code-coverage
# "The files can then be formatted using the package:coverage format_coverage executable."
.PHONY: ftauth-test
ftauth-test:
	cd ftauth; \
	dart pub upgrade; \
	dart test; \
	dart pub publish --dry-run;

.PHONY: ftauth_flutter
ftauth_flutter: ftauth_flutter-test
	cd ftauth_flutter; \
	flutter pub publish;

.PHONY: ftauth_flutter-test
ftauth_flutter-test:
	cd ftauth_flutter; \
	flutter pub upgrade; \
	flutter test; \
	flutter pub publish --dry-run;

.PHONY: examples-test
examples-test:
	cd example/flutter_nav1.0; \
	flutter build web;

	cd example/flutter_nav2.0; \
	flutter build web;

# TODO: Upload to hosting
.PHONY: examples
examples: examples-test
	cd example/flutter_nav1.0; \
	flutter build web;

	cd example/flutter_nav2.0; \
	flutter build web;

.PHONY: clean
clean:
	rm -rf example/flutter_nav1.0/build/ example/flutter_nav2.0/build/