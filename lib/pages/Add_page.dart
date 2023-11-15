import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddTodoPage extends StatefulWidget {

  final Map? todo;
  const AddTodoPage({super.key, this.todo});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {

  TextEditingController titlecontroller = TextEditingController();
  TextEditingController discriptioncontroller = TextEditingController();
  bool isEdit = false;

  @override
  void initState() {
    super.initState();
    final todo = widget.todo;
      if(todo != null){
        isEdit= true;

        final  title = todo["title"];
        final  description = todo["description"];
        titlecontroller.text =title;
        discriptioncontroller.text=description;
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            isEdit ? "Edit Todo" : "Add Todo"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            TextField(
              controller: titlecontroller,
              decoration: InputDecoration(
                hintText: "Title"
              ),
            ),
            SizedBox(height: 10,),
            TextField(
              controller: discriptioncontroller,
              decoration: InputDecoration(
                  hintText: "Discription",
              ),
              keyboardType: TextInputType.multiline,
              minLines: 5,
              maxLines: 8,
            ),
            SizedBox(height: 20,),
            ElevatedButton(onPressed:isEdit ? updateData :  submitData,
                child: Text(
                    isEdit? "Update" : "Submit"),
            ),
          ],
        ),
      ),
    );
  }

  Future <void> updateData () async {


    final todo = widget.todo;
    if(todo == null){
      print("you can't updated without todo data");
      return;
    }

    final id = todo ["_id"];
    final title = titlecontroller.text;
    final description = discriptioncontroller.text;

    final body = {
      "title": title,
      "description": description,
      "is_completed": false
    };

    final url = "https://api.nstack.in/v1/todos/$id";
    final uri =Uri.parse(url);
    final response = await http.put(uri , body: jsonEncode(body),
      headers: { "Content-Type": "application/json"},
    );

    if(response.statusCode == 200) {
      showSucessMessage("Updation Sucess");
    }else {
      print("Creation failed");
      showErrorMessage("Updation Filed");
    }
  }

  Future <void> submitData () async {

    final title = titlecontroller.text;
    final description = discriptioncontroller.text;

    final body = {
        "title": title,
        "description": description,
        "is_completed": false
    };
    final url = "https://api.nstack.in/v1/todos";
    final uri =Uri.parse(url);
    final response = await http.post(uri , body: jsonEncode(body),
    headers: { "Content-Type": "application/json"},
    );

    if(response.statusCode == 201) {
      titlecontroller.text="";
      discriptioncontroller.text="";
      print("Success");
      showSucessMessage("creation Success");
    }else {
      print("Creation failed");
      showErrorMessage("creation Filed");
    }
  }
  void showSucessMessage ( String message) {
    final snackBar = SnackBar(content: Text(message),);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showErrorMessage ( String message) {
    final snackBar = SnackBar(content: Text(message),
    backgroundColor: Colors.red,);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
