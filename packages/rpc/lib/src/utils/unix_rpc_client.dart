import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:clightning_rpc/src/utils/logger_manager.dart';
import 'package:jsonrpc2/jsonrpc2.dart';

class UnixRPCClient extends ServerProxyBase {
  UnixRPCClient(String path) : super(path);

  @override
  Future<String> transmit(String package) async {
    var address = InternetAddress(resource, type: InternetAddressType.unix);
    // https://api.dart.dev/stable/2.13.4/dart-io/Socket/port.html
    // 0 is used to indicate that it is a unix socket.
    var completer = Completer<String>();
    var socket = await Socket.connect(address, 0);
    socket.add(utf8.encode(package));

    socket.listen((event) {
      LogManager.getInstance.debug('Event received is ${utf8.decode(event)}');
      completer.complete(utf8.decode(event));
      return null;
    }, onDone: () => LogManager.getInstance.info('End JSON RPC Stream'));
    return completer.future;
  }
}
