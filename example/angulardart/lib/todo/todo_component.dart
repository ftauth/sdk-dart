import 'dart:async';
import 'dart:html';

import 'package:angular/angular.dart';
import 'package:angulardart/models/todo.dart';

@Component(
  selector: 'todo',
  templateUrl: 'todo_component.html',
  styleUrls: [
    'todo_component.css',
  ],
)
class TodoComponent implements AfterContentInit {
  @Input()
  late Todo todo;

  final StreamController<bool> _completedController = StreamController();

  @Output()
  Stream<bool> get checked => _completedController.stream;

  @ViewChild('checkbox')
  InputElement? checkbox;

  @override
  void ngAfterContentInit() {
    checkbox!.checked = todo.completed;
    checkbox!.onChange.listen((event) {
      final value = checkbox!.checked ?? false;
      _completedController.add(value);
    });
  }
}
