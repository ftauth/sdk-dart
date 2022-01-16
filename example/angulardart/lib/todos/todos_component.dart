import 'dart:html';

import 'package:amplify_appsync/amplify_appsync.dart';
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angulardart/auth_redirector.dart';
import 'package:angulardart/models/todo.dart';
import 'package:angulardart/todo/todo_component.dart';
import 'package:ftauth/ftauth.dart';

@Component(
  selector: 'todos',
  templateUrl: 'todos_component.html',
  styleUrls: [
    'todos_component.css',
  ],
  directives: [
    coreDirectives,
    TodoComponent,
  ],
  changeDetection: ChangeDetectionStrategy.OnPush,
)
class TodosComponent with AuthRedirector {
  TodosComponent(
    this.ftauth,
    this.router,
    this.gqlClient,
    this.ref,
    this.wsConn,
  );

  @override
  final Router router;

  @override
  final FTAuth ftauth;

  final GraphQLClient gqlClient;
  final WebSocketConnection wsConn;

  final ChangeDetectorRef ref;

  Set<Todo> todos = {};

  @ViewChild('name')
  InputElement? nameInput;

  @override
  void ngOnInit() {
    super.ngOnInit();
    ftauth.authStates.firstWhere((state) => state is AuthSignedIn).then((_) {
      print('Fetching todos');
      fetchTodos();
      todosStream.listen((todo) {
        todos.add(todo);
        ref.markForCheck();
      }, onError: (err) {
        window.console.error('Error listening for todos: $err');
      });
    });
  }

  Stream<Todo> get todosStream async* {
    await wsConn.init();
    final currentUser = ftauth.currentUser!;
    final stream = wsConn.subscribe(GraphQLRequest(
      '''
subscription {
  onCreateTodo(owner: "${currentUser.id}") {
    id
    name
    completed
    owner
  }
}''',
    ));
    await for (final payload in stream) {
      final json = payload.data?['onCreateTodo'] as Map?;
      print('Got payload: $json');
      if (json == null) {
        throw Exception('Null payload');
      }
      yield Todo.fromJson(json.cast());
    }
  }

  Future<void> createTodo() async {
    try {
      final name = nameInput?.value ?? '';
      if (name.isEmpty) return;
      final resp = await gqlClient.send(
        GraphQLRequest<Todo>(
          '''
mutation {
  createTodo(input: {
    name: "$name"
    completed: false
  }) {
    id
    name
    completed
    owner
  }
}''',
          fromJson: Todo.fromJson,
        ),
      );
      print('Got todo: ${resp.data}');
      print('Got errors: ${resp.errors}');
      nameInput?.value = '';
    } finally {
      ref.markForCheck();
    }
  }

  Future<void> updateTodo(Todo todo, bool checked) async {
    try {
      final resp = await gqlClient.send(
        GraphQLRequest<Todo>(
          '''
mutation {
  updateTodo(input: {
    id: "${todo.id}"
    completed: $checked
  }) {
    completed
  }
}''',
          fromJson: Todo.fromJson,
        ),
      );
      print('Got resp for $checked: ${resp.data}');
      print('Got errors: ${resp.errors}');
    } finally {
      ref.markForCheck();
    }
  }

  Future<void> fetchTodos() async {
    try {
      final resp = await gqlClient.send(
        GraphQLRequest<Todo>(
          '''
query {
  listTodos {
    items {
      id
      name
      completed
      owner
    }
  }
}''',
          fromJson: Todo.fromJson,
        ),
      );
      print('Got todos: ${resp.data}');
      print('Got errors: ${resp.errors}');

      if (resp.errors.isNotEmpty) {
        return;
      }
      final todos = resp.data!['listTodos']['items'] as List;
      this.todos =
          todos.cast<Map>().map((m) => Todo.fromJson(m.cast())).toSet();
    } finally {
      ref.markForCheck();
    }
  }

  Future<void> logout() => ftauth.logout();
}
