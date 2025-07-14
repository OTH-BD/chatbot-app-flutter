import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart ' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatbotPage extends StatefulWidget {
  ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  var messages = [
    {"role": "user", "content": "Bonjour"},
    {"role": "assistant", "content": "Que puis-je faire pour vous !"},
  ];

  TextEditingController userController = TextEditingController();
  ScrollController scrollController = ScrollController();

  void scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent + 100,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F2F6),
      appBar: AppBar(
        title: Text("🤖 Chatbot", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF2F3542),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, "/");
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                bool isUser = messages[index]['role'] == 'user';
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment:
                    isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      if (!isUser)
                        CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Icon(Icons.smart_toy, color: Colors.white),
                        ),
                      SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isUser
                                ? Color.fromARGB(40, 0, 255, 0)
                                : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                              bottomLeft: Radius.circular(isUser ? 16 : 0),
                              bottomRight: Radius.circular(isUser ? 0 : 16),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 4,
                                offset: Offset(2, 2),
                              )
                            ],
                          ),
                          child: Text(
                            "${messages[index]['content']}",
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      if (isUser)
                        CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Zone de saisie utilisateur
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: userController,
                    decoration: InputDecoration(
                      hintText: "Let's Talk",
                      suffixIcon: Icon(Icons.chat_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          width: 1,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    String question = userController.text;

                    //Uri uri = Uri.https("api.openai.com","/v1/chat/completions");
                    //Uri uri = Uri.parse("https://Add ip address :11434/v1/chat/completions");
                    // URL pour utiliser lamma3 comme LLM
                    // n'oublier pas avant de démarrer ollama de autoriser toutes les adresses ip y accéder
                    // en utilisant OLLAMA_HOST "0.0.0.0" et OLLAMA_ORIGINS=*

                    Uri uri = Uri.parse(
                      "https://api.openai.com/v1/chat/completions",
                    );

                    var headers = {
                      "Content-Type": "application/json",
                      "Authorization": "Bearer ${dotenv.env['OPENAI_API_KEY']}",
                      // pour lamma t'es pas besoin de envoyer Authorization et pas besoin d'une clé api just ollama run lamma3.2
                    };

                    messages.add(
                      {"role": "user", "content": question},
                    ); // pour envoyer la question précédente pour que AI s’en rappelle

                    var body = {
                      "model": "gpt-4.1", // utilise lamma3.2 ici au lieu de gpt-4
                      "messages": messages,
                    };

                    http
                        .post(uri, headers: headers, body: json.encode(body))
                        .then((resp) {
                      var aiResponse = json.decode(resp.body);
                      String answer =
                      aiResponse['choices'][0]['message']['content'];

                      setState(() {
                        messages.add({
                          "role": "assistant",
                          "content": answer,
                        });
                        scrollToBottom(); // scroll automatique
                      });
                      userController.text = "";
                    }).catchError((err) {
                      print(err);
                    });
                  },
                  icon: Icon(Icons.send),
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
