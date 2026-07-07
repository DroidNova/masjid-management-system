import 'package:flutter/material.dart';
Future<String?> showUpdateMasjidStatusDialog(BuildContext c)=>showDialog<String>(context:c,builder:(x)=>SimpleDialog(title:const Text('Change status'),children:[for(final s in ['PENDING','APPROVED','REJECTED','SUSPENDED'])SimpleDialogOption(onPressed:()=>Navigator.pop(x,s),child:Text(s))]));
