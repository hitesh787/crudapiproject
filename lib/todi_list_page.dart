import 'dart:convert';

import 'package:crudapiproject/add_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TodoListPage extends StatefulWidget {
  const TodoListPage({Key? key}) : super(key: key);

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List items = [];
  bool isLoading = true;

  @override
  void initState() {
    fetchTodo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To Do List'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: fetchTodo,
        child: Visibility(
          visible: items.isNotEmpty,
          replacement: const Center(
            child: Text('No Todo List',style: TextStyle(fontSize: 25),),
          ),
          child: ListView.builder(
            padding: const EdgeInsets.all(18),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index] as Map;
                final id = item['_id'] as String;
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: CircleAvatar(child: Text("${index + 1}")),
                    title: Text(item['title']),
                    subtitle: Text(item['description']),
                    trailing: PopupMenuButton(
                      icon: const Icon(Icons.more_horiz_rounded),
                      onSelected: (value) {
                        if(value == 'edit'){
                          navigatorToEditPage(item);
                        }else if(value == 'delete'){
                          deleteById(id);
                        }
                      },
                      itemBuilder: (context) {
                        return [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ];
                      },
                    ),
                  ),
                );
              }),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigatorToAddPage,
        label: const Text('Add Todo'),
      ),
    );
  }

  Future<void> deleteById(id) async {
    final url = "http://api.nstack.in/v1/todos/$id";
    final uri = Uri.parse(url);
    final response = await http.delete(uri);

    if(response.statusCode == 200){
      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {items = filtered;});
    }
  }

  Future<void> fetchTodo() async {
    const url = "https://api.nstack.in/v1/todos?page=1&limit=20";
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      setState(() {items = result;});
    }
    setState(() {isLoading = false;});
  }

  Future<void> navigatorToAddPage() async {
    final route = MaterialPageRoute(builder: (context) => const AddPages());
    await Navigator.push(context, route);
    setState(() {isLoading = true;});
    fetchTodo();
  }

  Future<void>  navigatorToEditPage(Map item) async {
    final route = MaterialPageRoute(builder: (context) => AddPages(todo: item,));
    await Navigator.push(context, route);
    setState(() {isLoading = true;});
    fetchTodo();
  }

}
