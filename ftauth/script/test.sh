#!/usr/bin/env bash

pub get
dart --no-sound-null-safety test
# pub publish --dry-run