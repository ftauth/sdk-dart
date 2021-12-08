#!/bin/sh

if [ -z $CI ]; then
    exit 0
fi

# Format coverage to lcov format
dart pub global activate coverage
dart run coverage:format_coverage -l -i coverage/ -o coverage/lcov.info --packages=.packages --report-on=lib

# Download and integrity check Codecov
curl https://keybase.io/codecovsecurity/pgp_keys.asc | gpg --no-default-keyring --keyring trustedkeys.gpg --import # One-time step
curl -Os https://uploader.codecov.io/latest/linux/codecov
curl -Os https://uploader.codecov.io/latest/linux/codecov.SHA256SUM
curl -Os https://uploader.codecov.io/latest/linux/codecov.SHA256SUM.sig

gpgv codecov.SHA256SUM.sig codecov.SHA256SUM
shasum -a 256 -c codecov.SHA256SUM
chmod +x codecov

# Upload coverage
./codecov --file coverage/lcov.info