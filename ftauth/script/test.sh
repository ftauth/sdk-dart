#!/usr/bin/env bash

pub get
dart --no-sound-null-safety test --coverage coverage
# dart --no-sound-null-safety test -p "chrome,vm"
# pub publish --dry-run