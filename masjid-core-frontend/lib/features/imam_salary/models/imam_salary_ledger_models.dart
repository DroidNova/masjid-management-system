double _money(dynamic value) => value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
int _integer(dynamic value) => value is num ? value.toInt() : int.tryParse('$value') ?? 0;
String? _text(dynamic value) => value == null || '$value'.trim().isEmpty ? null : '$value';

class ImamSalaryMonthModel {
  const ImamSalaryMonthModel({required this.id, required this.month, required this.year, required this.amountPerHead, required this.totalExpected, required this.totalCollected, required this.totalDue, required this.paidCount, required this.partialCount, required this.unpaidCount, required this.status, this.note, this.createdAt, this.updatedAt});
  final String id; final int month, year, paidCount, partialCount, unpaidCount; final double amountPerHead, totalExpected, totalCollected, totalDue; final String status; final String? note, createdAt, updatedAt;
  factory ImamSalaryMonthModel.fromJson(Map<String,dynamic> j) => ImamSalaryMonthModel(id: '${j['id'] ?? ''}', month: _integer(j['month']), year: _integer(j['year']), amountPerHead: _money(j['amountPerHead']), totalExpected: _money(j['totalExpected']), totalCollected: _money(j['totalCollected']), totalDue: _money(j['totalDue']), paidCount: _integer(j['paidCount']), partialCount: _integer(j['partialCount']), unpaidCount: _integer(j['unpaidCount']), status: '${j['status'] ?? 'UNPAID'}', note: _text(j['note']), createdAt: _text(j['createdAt']), updatedAt: _text(j['updatedAt']));
}
class ImamSalaryAssignmentModel {
  const ImamSalaryAssignmentModel({required this.id, required this.memberId, required this.memberName, required this.memberPhone, required this.expectedAmount, required this.paidAmount, required this.dueAmount, required this.status});
  final String id, memberId, memberName, memberPhone, status; final double expectedAmount, paidAmount, dueAmount;
  factory ImamSalaryAssignmentModel.fromJson(Map<String,dynamic> j) => ImamSalaryAssignmentModel(id: '${j['id'] ?? ''}', memberId: '${j['memberId'] ?? ''}', memberName: '${j['memberName'] ?? ''}', memberPhone: '${j['memberPhone'] ?? ''}', expectedAmount: _money(j['expectedAmount']), paidAmount: _money(j['paidAmount']), dueAmount: _money(j['dueAmount']), status: '${j['status'] ?? 'UNPAID'}');
}
class ImamSalaryPaymentModel {
  const ImamSalaryPaymentModel({required this.id, required this.memberId, required this.memberName, required this.memberPhone, required this.amount, required this.paymentMode, required this.paidAt, required this.collectedByName, this.note, required this.paymentForMonth, required this.paymentForYear});
  final String id, memberId, memberName, memberPhone, paymentMode, paidAt, collectedByName; final String? note; final double amount; final int paymentForMonth, paymentForYear;
  factory ImamSalaryPaymentModel.fromJson(Map<String,dynamic> j) => ImamSalaryPaymentModel(id: '${j['id'] ?? ''}', memberId: '${j['memberId'] ?? ''}', memberName: '${j['memberName'] ?? ''}', memberPhone: '${j['memberPhone'] ?? ''}', amount: _money(j['amount']), paymentMode: '${j['paymentMode'] ?? ''}', paidAt: '${j['paidAt'] ?? ''}', collectedByName: '${j['collectedByName'] ?? ''}', note: _text(j['note']), paymentForMonth: _integer(j['paymentForMonth']), paymentForYear: _integer(j['paymentForYear']));
}
class MyImamSalaryHistoryModel {
  const MyImamSalaryHistoryModel({required this.month, required this.year, required this.expectedAmount, required this.paidAmount, required this.dueAmount, required this.status, required this.payments});
  final int month, year; final double expectedAmount, paidAmount, dueAmount; final String status; final List<ImamSalaryPaymentModel> payments;
  factory MyImamSalaryHistoryModel.fromJson(Map<String,dynamic> j) => MyImamSalaryHistoryModel(month: _integer(j['month']), year: _integer(j['year']), expectedAmount: _money(j['expectedAmount']), paidAmount: _money(j['paidAmount']), dueAmount: _money(j['dueAmount']), status: '${j['status'] ?? 'UNPAID'}', payments: (j['payments'] as List<dynamic>? ?? const []).whereType<Map<String,dynamic>>().map((p) => ImamSalaryPaymentModel.fromJson({...p, 'memberId':'', 'memberName':'', 'memberPhone':'', 'collectedByName':'', 'paymentForMonth':j['month'], 'paymentForYear':j['year']})).toList());
}
class CreateImamSalaryMonthRequest { const CreateImamSalaryMonthRequest(this.month,this.year,this.amountPerHead,this.note); final int month,year; final double amountPerHead; final String? note; Map<String,dynamic> toJson()=>{'month':month,'year':year,'amountPerHead':amountPerHead,if(note?.trim().isNotEmpty==true)'note':note!.trim()}; }
class UpdateImamSalaryAmountRequest { const UpdateImamSalaryAmountRequest(this.amountPerHead,this.reason); final double amountPerHead; final String? reason; Map<String,dynamic> toJson()=>{'amountPerHead':amountPerHead,if(reason?.trim().isNotEmpty==true)'reason':reason!.trim()}; }
class CreateImamSalaryPaymentRequest { const CreateImamSalaryPaymentRequest(this.assignmentId,this.amount,this.paymentMode,this.paidAt,this.note); final String assignmentId,paymentMode,paidAt; final double amount; final String? note; Map<String,dynamic> toJson()=>{'assignmentId':assignmentId,'amount':amount,'paymentMode':paymentMode,'paidAt':paidAt,if(note?.trim().isNotEmpty==true)'note':note!.trim()}; }
