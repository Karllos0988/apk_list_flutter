import 'package:apk_list_flutter/repositories/todo_repository.dart';
import 'package:flutter/material.dart';

import '../models/todo.dart';
import '../widgets/todo_list_itens.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({Key? key}) : super(key: key);

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {

  final TextEditingController todoController = TextEditingController();
  final TodoRepository todoRepository = TodoRepository();

  List<Todo> todos = [];
  Todo? deleTodo;
  int? deleTodoPos;

  String? errorText;

  @override
  void initState() {
    super.initState();
    
    todoRepository.getTodoList().then((value){
      setState(() {
        todos = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(

      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(children: [

                  Expanded(
                    child: TextField(
                      controller: todoController,
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Digite uma tarefa',
                          hintText: 'Ex.. Estudar Flutter',
                          errorText: errorText,
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide (
                              color: Color(0xff00d7f3),
                              width: 3,
                            )
                          ),
                          labelStyle: const TextStyle(
                            color: Color(0xff00d7f3)
                          )
                          ),
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  ElevatedButton(

                    onPressed: () {
                      String text = todoController.text;

                      if(text.isEmpty){
                        setState(() {
                          errorText = 'O texto não pode está vazio';
                        });
                        return;
                      }

                      setState(() {
                        Todo newTodo =
                        Todo(title: text, dateTime: DateTime.now());
                        todos.add(newTodo);
                        errorText = null;

                      });

                      todoController.clear();
                      todoRepository.saveTodoList(todos);
                    },
                    style: ElevatedButton.styleFrom (
                      backgroundColor: Color(0xff00d7f3),
                      padding: EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(),
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 30,
                    ),
                  ),
                ]),

                const SizedBox(
                  height: 16,
                ),

                Flexible(
                  child: ListView(shrinkWrap: true, children: [
                    for (Todo todo in todos)
                      TodoListItens(todo: todo, onDelete: onDelete),
                  ]),
                ),

                const SizedBox(
                  height: 16,
                ),

                Row(
                  children: [
                    Expanded(
                        child: Text(
                            'Você possui ${todos.length} tarefas pendentes')),

                    ElevatedButton(
                        onPressed: showDeleteTodosConfirmatedDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff00d7f3),
                          padding: EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(),
                        ),
                        child: Text('Limpar tudo'))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onDelete(Todo todo) {
    deleTodo = todo;
    deleTodoPos = todos.indexOf(todo);

    setState(() {
      todos.remove(todo);      
    });
    todoRepository.saveTodoList(todos);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        'Tarefa ${todo.title} foi removida com sucesso!',
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.white,

      action: SnackBarAction(
        label: 'Desfazer',
        textColor: Color(0xff00d7f3),
        onPressed: () {
          setState(() {
            todos.insert(deleTodoPos!, deleTodo!);
          });
        todoRepository.saveTodoList(todos);
        },
      ),

      duration: const Duration(seconds: 4),

    ));
  }

  void showDeleteTodosConfirmatedDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Limpar tudo?'),
              content: Text('Você realmente deseja limpar todas as tarefas?'),
              actions: [

                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancelar'),
                  style: TextButton.styleFrom(
                    foregroundColor: Color(0xff00d7f3),
                  ),
                ),

                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    deleteAllTodos();
                  },
                  child: Text('Limpar tudo'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ));
  }

  void deleteAllTodos(){
    setState(() {
      todos.clear();
    });
    todoRepository.saveTodoList(todos);
  }

}
