import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:flutter/material.dart' as material show Text;
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import 'device_identity_service.dart';
import 'firebase_options.dart';
import 'startup/connection_probe.dart';
import 'startup/connection_probe_factory.dart';
import 'ticket_image_cropper.dart';
import 'ticket_image_picker_service.dart';
import 'theme/tm_tokens.dart';

part 'app/app_core.dart';
part 'app/auth_flow.dart';
part 'app/editable_text.dart';
part 'app/for_you_mail.dart';
part 'app/home_shell.dart';
part 'app/local_persistence.dart';
part 'app/tickets_flow.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _TicketmasterCloudStore.instance.initialize();
  runApp(const TicketmasterApp());
}
