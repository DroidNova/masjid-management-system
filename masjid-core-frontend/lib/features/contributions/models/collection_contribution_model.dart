class CollectionContributionModel {
  const CollectionContributionModel({required this.id,required this.collectionType,required this.contributorName,this.contributorPhone,required this.amount,required this.paymentMode,this.paidAt,required this.collectedByName,this.note});
  factory CollectionContributionModel.fromJson(Map<String,dynamic> json)=>CollectionContributionModel(id:'${json['id']??''}',collectionType:'${json['collectionType']??''}',contributorName:'${json['contributorName']??''}',contributorPhone:json['contributorPhone']?.toString(),amount:_money(json['amount']),paymentMode:'${json['paymentMode']??''}',paidAt:DateTime.tryParse('${json['paidAt']??''}'),collectedByName:'${json['collectedByName']??''}',note:_text(json['note']));
  final String id,collectionType,contributorName,paymentMode,collectedByName;final String? contributorPhone,note;final double amount;final DateTime? paidAt;
}
class CreateCollectionContributionRequest {
  const CreateCollectionContributionRequest({this.memberId,required this.contributorName,this.contributorPhone,required this.collectionType,required this.amount,required this.paymentMode,required this.paidAt,this.note});
  final String? memberId,contributorPhone,note;final String contributorName,collectionType,paymentMode;final double amount;final DateTime paidAt;
  Map<String,dynamic> toJson()=>{if(memberId?.isNotEmpty==true)'memberId':memberId,'contributorName':contributorName.trim(),if(contributorPhone?.trim().isNotEmpty==true)'contributorPhone':contributorPhone!.trim(),'collectionType':collectionType,'amount':amount,'paymentMode':paymentMode,'paidAt':paidAt.toIso8601String(),if(note?.trim().isNotEmpty==true)'note':note!.trim()};
}
double _money(dynamic value)=>value is num?value.toDouble():double.tryParse('$value')??0;
String? _text(dynamic value){final text=value?.toString().trim();return text==null||text.isEmpty?null:text;}
