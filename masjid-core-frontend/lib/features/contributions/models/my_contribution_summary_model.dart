class MyContributionUserModel {
  const MyContributionUserModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.isFamilyHead,
  });

  factory MyContributionUserModel.fromJson(Map<String, dynamic> json) {
    return MyContributionUserModel(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      phone: json['phone']?.toString(),
      isFamilyHead: json['isFamilyHead'] == true,
    );
  }

  final String id;
  final String fullName;
  final String? phone;
  final bool isFamilyHead;
}

class ImamSalaryContributionSummaryModel {
  const ImamSalaryContributionSummaryModel({
    required this.monthsShown,
    required this.totalExpected,
    required this.totalPaid,
    required this.totalDue,
    required this.paidMonths,
    required this.partialMonths,
    required this.unpaidMonths,
  });

  factory ImamSalaryContributionSummaryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ImamSalaryContributionSummaryModel(
      monthsShown: _readInt(json['monthsShown']),
      totalExpected: _readDouble(json['totalExpected']),
      totalPaid: _readDouble(json['totalPaid']),
      totalDue: _readDouble(json['totalDue']),
      paidMonths: _readInt(json['paidMonths']),
      partialMonths: _readInt(json['partialMonths']),
      unpaidMonths: _readInt(json['unpaidMonths']),
    );
  }

  final int monthsShown;
  final double totalExpected;
  final double totalPaid;
  final double totalDue;
  final int paidMonths;
  final int partialMonths;
  final int unpaidMonths;
}

class MyContributionSummaryModel {
  const MyContributionSummaryModel({
    required this.user,
    required this.imamSalary,
    required this.projectContributionTotal,
    required this.collectionContributionTotal,
    required this.totalContributionAmount,
  });

  factory MyContributionSummaryModel.fromJson(Map<String, dynamic> json) {
    return MyContributionSummaryModel(
      user: MyContributionUserModel.fromJson(
        json['user'] is Map<String, dynamic>
            ? json['user'] as Map<String, dynamic>
            : const <String, dynamic>{},
      ),
      projectContributionTotal: _readDouble(json['projectContributionTotal']),
      collectionContributionTotal: _readDouble(json['collectionContributionTotal']),
      totalContributionAmount: _readDouble(json['totalContributionAmount']),
      imamSalary: ImamSalaryContributionSummaryModel.fromJson(
        json['imamSalary'] is Map<String, dynamic>
            ? json['imamSalary'] as Map<String, dynamic>
            : const <String, dynamic>{},
      ),
    );
  }

  final MyContributionUserModel user;
  final ImamSalaryContributionSummaryModel imamSalary;
  final double projectContributionTotal;
  final double collectionContributionTotal;
  final double totalContributionAmount;
}

double _readDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? 0;
}

int _readInt(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}
