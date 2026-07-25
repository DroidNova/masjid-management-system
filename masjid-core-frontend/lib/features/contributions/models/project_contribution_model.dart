class ProjectContributionModel {
  const ProjectContributionModel({required this.id, required this.projectId, required this.contributorName, this.contributorPhone, required this.amount, required this.paymentMode, this.paidAt, required this.collectedByName, this.note, this.projectTitle});
  factory ProjectContributionModel.fromJson(Map<String,dynamic> json) => ProjectContributionModel(id:'${json['id']??''}',projectId:'${json['projectId']??''}',contributorName:'${json['contributorName']??''}',contributorPhone:json['contributorPhone']?.toString(),amount:_money(json['amount']),paymentMode:'${json['paymentMode']??''}',paidAt:DateTime.tryParse('${json['paidAt']??''}'),collectedByName:'${json['collectedByName']??''}',note:_text(json['note']),projectTitle:json['project'] is Map<String,dynamic> ? (json['project'] as Map<String,dynamic>)['title']?.toString() : null);
  final String id,projectId,contributorName,paymentMode,collectedByName; final String? contributorPhone,note,projectTitle; final double amount; final DateTime? paidAt;
}
class CreateProjectContributionRequest {
  const CreateProjectContributionRequest({this.memberId,required this.contributorName,this.contributorPhone,required this.amount,required this.paymentMode,required this.paidAt,this.note});
  final String? memberId,contributorPhone,note; final String contributorName,paymentMode; final double amount; final DateTime paidAt;
  Map<String,dynamic> toJson()=>{if(memberId?.isNotEmpty==true)'memberId':memberId,'contributorName':contributorName.trim(),if(contributorPhone?.trim().isNotEmpty==true)'contributorPhone':contributorPhone!.trim(),'amount':amount,'paymentMode':paymentMode,'paidAt':paidAt.toIso8601String(),if(note?.trim().isNotEmpty==true)'note':note!.trim()};
}
double _money(dynamic value)=>value is num?value.toDouble():double.tryParse('$value')??0;
String? _text(dynamic value){final text=value?.toString().trim();return text==null||text.isEmpty?null:text;}
