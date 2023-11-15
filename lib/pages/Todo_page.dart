import 'dart:convert';
import 'package:curd_api/pages/Add_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http ;

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {

  bool isLoading = true;
  List items = [];

  @override
  void initState() {
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Todo List")),
      ),
      body: Visibility(
          visible: isLoading,
        child:const Center(child: CircularProgressIndicator()),
        replacement :RefreshIndicator(
          onRefresh: fetchTodo,
          child: Visibility(
            visible: items.isNotEmpty,
            replacement: const Center(child: Text("No items"),),

            child: ListView.builder(
              itemCount:items.length,
                itemBuilder: (context,index){
                final item = items[index] as Map;
                final id =item["_id"] as String;
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text("${index +1}")),
                  title: Text(item["title"]),
                 subtitle: Text(item["description"] ),
                  trailing: PopupMenuButton(
                    onSelected: (value) {
                      if (value == "edit") {
                        navigateToEditPage(item);
                      } else if (value == "delete") {
                        showDeleteConfirmationDialog(id);
                      }
                    },
                    itemBuilder: (context) {
                      return [
                        const PopupMenuItem(
                          child: Text("Delete"),
                          value: "delete",
                        ),
                        const PopupMenuItem(
                          child: Text("Edit"),
                          value: "edit",
                        ),
                      ];
                    },
                  ),

                ),
              );
            },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: navigateToAddPage,
          label: const Text("Add")),
    );
  }

  Future <void> navigateToEditPage(Map item) async {
    final route = MaterialPageRoute(
        builder: (context) => AddTodoPage(todo :item),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading =true;
    });
    fetchTodo();
  }

  Future <void> navigateToAddPage() async {
    final route = MaterialPageRoute(
        builder: (context) => const AddTodoPage()
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading =true;
    });
    fetchTodo();
  }

  Future <void> deleteById(String id)  async {

    final url ="https://api.nstack.in/v1/todos/$id";
    final uri = Uri.parse(url);
    final response = await http.delete(uri);

    if(response.statusCode ==200){

      final filtered =items.where((element) => element["_id"] != id).toList();
      setState(() {
        items = filtered;
      });
    } else {

    }
  }

  Future<void> fetchTodo () async {
    final url = "https://api.nstack.in/v1/todos?page=1&limit=20";
    final uri =Uri.parse(url);
    final response = await http.get(uri);

    if(response.statusCode== 200){
      final json = jsonDecode(response.body) as Map;
      final result = json["items"] as List;

      setState(() {
        items =result;
      });

    } else{
      showErrorMessage("Unable to fetch");
    }

    setState(() {
      isLoading = false;
    });
  }

  void showErrorMessage ( String message) {
    final snackBar = SnackBar(content: Text(message),
      backgroundColor: Colors.red,);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> showDeleteConfirmationDialog(String id) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                deleteById(id);
              },
            ),
          ],
        );
      },
    );
  }
}
