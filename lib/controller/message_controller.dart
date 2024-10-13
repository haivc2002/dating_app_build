import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../argument_model/arguments_detail_model.dart';
import '../bloc/bloc_message/detail_message_bloc.dart';
import '../bloc/bloc_message/message_bloc.dart';
import '../common/global.dart';
import '../common/textstyles.dart';
import '../model/model_info_user.dart' as user_info;
import '../model/model_outside_view_message.dart';
import '../model/model_request_send.dart';
import '../model/model_response_message.dart';
import '../model/model_send_message_success.dart';
import '../service/exception.dart';
import '../service/service_message.dart';
import '../service/url/api.dart';
import '../theme/theme_color.dart';
import '../theme/theme_config.dart';
import '../theme/theme_notifier.dart';
import '../ui/detail/detail_screen.dart';
import '../ui/message/view_chat_screen.dart';

class MessageController {
  BuildContext context;
  MessageController(this.context);

  ServiceMessage serviceMessage = ServiceMessage();
  List<String> menuAction = ['Chat', 'Information', 'Delete'];
  WebSocketChannel? channel;
  Timer? timer;
  Timer? realTimeMessage;
  int retryCount = 0;
  final int maxRetries = 3;
  String urlConnect = Api.notification;
  ModelResponseMessage response = ModelResponseMessage();
  TextEditingController content = TextEditingController();

  void refreshWithTime() {
    realTimeMessage?.cancel();
    realTimeMessage = Timer.periodic(const Duration(seconds: 5), (_) async {
      getData();
    });
  }

  void getData() async {
    int idUser = Global.getInt(ThemeConfig.idUser);
    if(context.mounted) {
      var response = await serviceMessage.getOutsideView(idUser);
      if(response is Success<ModelOutsideViewMessage, Exception>) {
        if(response.value.result == 'Success') {
          List<Conversations> listData = response.value.conversations ?? [];
          onSuccess(listData);
        } else {
          onError();
        }
      } else if (response is Failure<ModelOutsideViewMessage, Exception>) {
        print(response.exception);
        onError();
      }
    }
  }

  void onLoad()=> context.read<MessageBloc>().add(LoadMessageEvent());

  void onSuccess(List<Conversations> response) {
    if(context.mounted) context.read<MessageBloc>().add(SuccessMessageEvent(response));
  }

  void onError() {}

  List<Function()> onPressedList(SuccessMessageState state, int index) {
    return [
      ()=> gotoViewChat(state, index),
      ()=> gotoDetail(state, index),
      ()=> print('object'),
    ];
  }

  Widget returnContentMessage(SuccessMessageState state, int index, ThemeNotifier color) {
    bool newMessage = state.response[index].latestMessage?.newState == 1;
    bool senderIsMe = state.response[index].latestMessage?.idUser == Global.getInt(ThemeConfig.idUser);
    if(newMessage && !senderIsMe) {
      if(senderIsMe) {
        return Text(
          'you: ${state.response[index].latestMessage?.content}',
          style: TextStyles.defaultStyle.setColor(color.systemText.withOpacity(0.6)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      } else {
        return Text(
          '${state.response[index].latestMessage?.content}',
          style: TextStyles.defaultStyle.setColor(color.systemText).bold,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      }
    } else {
      return Text(
        '${state.response[index].latestMessage?.content}',
        style: TextStyles.defaultStyle.setColor(color.systemText.withOpacity(0.6)),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
  }

  Widget iconState(SuccessMessageState state, int index) {
    final newState = state.response[index].latestMessage?.newState;
    if(newState == 0) {
      return const SizedBox();
    } else {
      if(state.response[index].latestMessage?.idUser != Global.getInt(ThemeConfig.idUser)) {
        return Icon(Icons.circle, color: ThemeColor.pinkColor, size: 14.sp);
      } else {
        return const SizedBox();
      }
    }
  }

  void gotoDetail(SuccessMessageState state, int index) {
    final dataInfo = state.response[index].info;
    final list = state.response[index].listImage;
    final dataInfoMore = state.response[index].infoMore;
    user_info.Info info = user_info.Info(
      lon: dataInfo?.lon,
      lat: dataInfo?.lat,
      name: dataInfo?.name,
      word: dataInfo?.word,
      describeYourself: dataInfo?.describeYourself,
      birthday: dataInfo?.birthday,
      academicLevel: dataInfo?.academicLevel,
      desiredState: dataInfo?.desiredState,
    );

    List<user_info.ListImage> listImage = [];
    for(int i=0; i< list!.length; i++) {
      listImage.add(user_info.ListImage(
        image: list[i].image,
      ));
    }

    user_info.InfoMore infoMore = user_info.InfoMore(
        hometown: dataInfoMore?.hometown,
        height: dataInfoMore?.height,
        zodiac: dataInfoMore?.zodiac,
        smoking: dataInfoMore?.smoking,
        wine: dataInfoMore?.wine,
        religion: dataInfoMore?.religion
    );

    Navigator.pushNamed(
        context,
        DetailScreen.routeName,
        arguments: ArgumentsDetailModel(
            keyHero: 0,
            idUser: state.response[index].idUser,
            info: info,
            listImage: listImage,
            infoMore: infoMore,
            notFeedback: false
        )
    );
  }

  void gotoViewChat(SuccessMessageState state, int index) async {
    final dataInfo = state.response[index].info;
    final list = state.response[index].listImage;
    final dataInfoMore = state.response[index].infoMore;
    user_info.Info info = user_info.Info(
      lon: dataInfo?.lon,
      lat: dataInfo?.lat,
      name: dataInfo?.name,
      word: dataInfo?.word,
      describeYourself: dataInfo?.describeYourself,
      birthday: dataInfo?.birthday,
      academicLevel: dataInfo?.academicLevel,
      desiredState: dataInfo?.desiredState,
    );

    List<user_info.ListImage> listImage = [];
    for(int i=0; i< list!.length; i++) {
      listImage.add(user_info.ListImage(
        image: list[i].image,
      ));
    }

    user_info.InfoMore infoMore = user_info.InfoMore(
        hometown: dataInfoMore?.hometown,
        height: dataInfoMore?.height,
        zodiac: dataInfoMore?.zodiac,
        smoking: dataInfoMore?.smoking,
        wine: dataInfoMore?.wine,
        religion: dataInfoMore?.religion
    );
    if(context.mounted) context.read<DetailMessageBloc>().add(DetailMessageEvent(response: []));
    Navigator.pushNamed(context, ViewChatScreen.routeName, arguments: ArgumentsDetailModel(
        keyHero: 0,
        idUser: state.response[index].idUser,
        info: info,
        listImage: listImage,
        infoMore: infoMore,
        notFeedback: false
    ));
  }

  void sendMessage(int idUser, int receiver) async {
    ModelRequestSend request = ModelRequestSend(
      idUser: idUser,
      receiver: receiver,
      content: content.text
    );
    if(content.text != '') {
      var send = await serviceMessage.send(request);
      if(send is Success<ModelSendMessageSuccess, Exception>) {
        if(send.value.result == 'Success') {
          content.text = '';
        }
      }
    }
  }

  void continuous(String idUser, int receiver) {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (context.mounted) connect(idUser, receiver);
    });
  }

  void connect(String idUser, int receiver) {
    if (!context.mounted) return;
    channel?.sink.close();
    channel = IOWebSocketChannel.connect(Uri.parse(urlConnect));
    response = ModelResponseMessage(messages: List.from(context.read<DetailMessageBloc>().state.response ?? []));
    channel?.stream.listen(
          (message) {
        if (context.mounted) {
          final data = jsonDecode(message);
          if (data['result'] == 'Success') {
            response = ModelResponseMessage.fromJson(data);
            context.read<DetailMessageBloc>().add(DetailMessageEvent(response: response.messages));
            retryCount = 0;
          }
        }
      },
      onError: (error) {if (context.mounted) handleConnectionError(idUser, receiver);},
      onDone: () {if (context.mounted) handleConnectionError(idUser, receiver);},
    );
    channel?.sink.add(jsonEncode({
      'idUser': idUser,
      'type': 'getMessages',
      'receiver': receiver,
    }));
  }

  void handleConnectionError(String idUser, int receiver) {
    retryCount++;
    if (retryCount <= maxRetries) {
      reconnect(idUser, receiver);
    } else {
      stopReconnecting();
    }
  }

  void reconnect(String idUser, int receiver) {
    channel?.sink.close();
    Future.delayed(const Duration(seconds: 5), () {
      connect(idUser, receiver);
    });
  }

  void stopReconnecting() {
    channel?.sink.close();
    timer?.cancel();
  }

  void checkMessage(int idUser, DetailMessageState state) async {
    var response = await serviceMessage.checkMessage(idUser, state.response![0].id!);
    if(response is Failure<void, Exception>) {
      final error = response.exception;
      if (kDebugMode) print(error);
    }
  }
}