# FTAuth Todos

An example of using FTAuth as an OIDC provider in AWS AppSync. Built with AngularDart.

## Setup

To create the backend:

```sh
cd amplify
amplify init
amplify push
```

To run the app:

```sh
dart pub get
dart pub global activate webdev
webdev serve # or `dart pub global run webdev serve`
```