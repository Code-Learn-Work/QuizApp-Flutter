import "package:flutter/material.dart";
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:quiz_app_flutter/quiz.dart';

void main() => runApp(MyApp()); 

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new HomePage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Quiz quiz;
  List<Results> results;

  Future<void> fetchQuestions()async{
    var res = await http.get("https://opentdb.com/api.php?amount=20");
    var decRes = jsonDecode(res.body);
    print(decRes);
    quiz = Quiz.fromJson(decRes);
    results = quiz.results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Quiz App"),
        elevation: 0.0,
      ),
      body: RefreshIndicator(
        onRefresh: fetchQuestions,
              child: new FutureBuilder(
          future: fetchQuestions(),
          builder: (BuildContext context, AsyncSnapshot snapshot){
            switch(snapshot.connectionState){
              case ConnectionState.none:
                return Text("Press Button to Start !");
              case ConnectionState.active:
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              case ConnectionState.done:
                if(snapshot.hasError) return errorData(
                  snapshot
                );
              return questionsList();
            }
            return null;
          },
        ),
      ),
    );
  }

  Padding errorData(AsyncSnapshot snapshot){
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Text("Error :${snapshot.error}"),
          SizedBox(
            height: 20.0,
          ),
          RaisedButton(
            onPressed: (){
              fetchQuestions();
              setState(() {
                              
                            });
            },
            child: new Text("Try Again"),
          )
        ],
      ),
    );
  }

  ListView questionsList(){
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context,i)=>Card(
        color: Colors.white,
        elevation: 0.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ExpansionTile(
            title: new Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text(results[i].question,style: new TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold),),
                FittedBox(
                                child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      FilterChip(
                        backgroundColor: Colors.grey[100],
                        label: Text(results[i].category),
                        onSelected: (b){},
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      FilterChip(
                        backgroundColor: Colors.grey[100],
                        label: Text(results[i].difficulty),
                        onSelected: (b){},
                      )
                    ],
                  ),
                )
              ],
            ),
            leading: new CircleAvatar(
              backgroundColor: Colors.grey[100],
              child: new Text(
                results[i].type.startsWith("m")?"M":"B"
              ),
            ),
            children: results[i].incorrectAnswers.map((m){
              return AnswerWidget(results, i, m);
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class AnswerWidget extends StatefulWidget {

  final List<Results> results;
  final int index;
  final String m;

  AnswerWidget(this.results,this.index,this.m);


  @override
  _AnswerWidgetState createState() => _AnswerWidgetState();
}

class _AnswerWidgetState extends State<AnswerWidget> {

  Color c = Colors.black;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: (){
        setState(() {
                  if(widget.m == widget.results[widget.index].correctAnswer){
          c = Colors.green;
        }
        else{
          c = Colors.red;
        }
                });
      },
      title: new Text(
        widget.m,
        textAlign: TextAlign.center,
        style: new TextStyle(
          color: c,
          fontWeight: FontWeight.bold,
        )
      ),
    );
  }
}