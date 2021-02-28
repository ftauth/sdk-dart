#!/bin/sh

pub get
dart test -p "chrome,firefox,vm"
pub publish --dry-run