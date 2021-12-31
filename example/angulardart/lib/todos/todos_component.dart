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
  );

  @override
  final Router router;

  @override
  final FTAuth ftauth;

  final GraphQLClient gqlClient;

  final ChangeDetectorRef ref;

  List<Todo> todos = [];

  @ViewChild('name')
  InputElement? nameInput;

  @override
  void ngOnInit() {
    super.ngOnInit();
    fetchTodos();
  }

  Future<void> createTodo() async {
    try {
      final name = nameInput?.value ?? '';
      if (name.isEmpty) return;
      final resp = await gqlClient.send(
        GraphQLRequest<Todo>(
          '''
          mutation CompleteTodo {
            createTodo(input: {
              name: "$name"
              completed: false
            }) {
              id
              name
              completed
              owner
            }
          }
        ''',
          fromJson: Todo.fromJson,
        ),
      );
      print('Got todo: ${resp.data}');
      print('Got errors: ${resp.errors}');
      if (resp.errors.isNotEmpty) {
        return;
      }
      final todo = resp.data!['createTodo'] as Map;
      todos.add(Todo.fromJson(todo.cast()));
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
          }
        ''',
          fromJson: Todo.fromJson,
        ),
      );
      print('Got resp for $checked: ${resp.data}');
      print('Got errors: ${resp.errors}');
      if (resp.errors.isNotEmpty) {
        return;
      }
    } finally {
      ref.markForCheck();
    }
  }

  Future<void> fetchTodos() async {
    try {
      final resp = await gqlClient.send(
        GraphQLRequest<Todo>(
          r'''
          query {
            listTodos {
              items {
                id
                name
                completed
                owner
              }
            }
          }
        ''',
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
          todos.cast<Map>().map((m) => Todo.fromJson(m.cast())).toList();
    } finally {
      ref.markForCheck();
    }
  }

  Future<void> logout() => ftauth.logout();
}
