import 'package:flutter/material.dart';
Future<String?> showUpdateUserStatusDialog(BuildContext c)=>showDialog<String>(context:c,builder:(x)=>SimpleDialog(title:const Text('Change status'),children:[for(final s in ['ACTIVE','INACTIVE','SUSPENDED'])SimpleDialogOption(onPressed:()=>Navigator.pop(x,s),child:Text(s))]));
