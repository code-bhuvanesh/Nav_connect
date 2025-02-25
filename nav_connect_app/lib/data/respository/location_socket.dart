
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import '../../utils/constants.dart';

class LocationSocket {
  // var wsUrl = "ws://192.168.29.180:8000/ws/buslocation/";
  // var wsUrl =
  //     "ws://congenial-adventure-v7ww59w77r4fpvwg-8000.app.github.dev/ws/buslocation/";
  // String? wsUrl;
  // int? busid;
  String? wsUrl = "$socketurl/ws/buslocation/";
  int? busid = 2;

  late WebSocketChannel ws;

  LocationSocket() {
    // start();
  }

  Future<void> start() async {
    var client = http.Client();
    // if (wsUrl == null || busid == null) {
    //   try {
    //     var result = await client.get(
    //         Uri.parse("https://api.jsonbin.io/v3/b/6624a9ecad19ca34f85d9496"),
    //         headers: {
    //           "X-Master-Key":
    //               r"$2a$10$lP.Bl674yhOr.IWCNOoc6etqFJblV9c8Neu7qsKc8D88VmpmkrmZW"
    //         });

    //     ///for testing only remove it in production
    //     var msg = jsonDecode(result.body);
    //     print("json api body : ${msg}");
    //     wsUrl = msg["record"]["socketUrl"];
    //     busid = msg["record"]["busid"];
    //   } on Exception {
    //     wsUrl =
    //         "wss://probable-chainsaw-94wwxrw4xqr2p46v-8000.app.github.dev/ws/buslocation/";
    //     busid = 2;
    //   }
    // }

    var sharedPrefernces = await SharedPreferences.getInstance();
    wsUrl = sharedPrefernces.getString("webUrl") ?? socketurl;
    wsUrl = "${wsUrl!}/ws/buslocation/";
    print("wsurl from config file : $wsUrl");
    ws = WebSocketChannel.connect(Uri.parse("$wsUrl$busid"));
  }

  void sendMsg(String msg) {
    ws.sink.add(msg);
  }

  void dispose() {
    ws.sink.close();
  }
}
