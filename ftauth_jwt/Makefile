.PHONY: test
test:
	dart pub global activate coverage
	dart script/generate_data.dart
	dart test --platform=vm,chrome --coverage="coverage"
	dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage.lcov --packages=.packages --report-on=lib