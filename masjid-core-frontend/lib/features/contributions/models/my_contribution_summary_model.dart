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
  });

  factory MyContributionSummaryModel.fromJson(Map<String, dynamic> json) {
    return MyContributionSummaryModel(
      user: MyContributionUserModel.fromJson(
        json['user'] is Map<String, dynamic>
            ? json['user'] as Map<String, dynamic>
            : const <String, dynamic>{},
      ),
      imamSalary: ImamSalaryContributionSummaryModel.fromJson(
        json['imamSalary'] is Map<String, dynamic>
            ? json['imamSalary'] as Map<String, dynamic>
            : const <String, dynamic>{},
      ),
    );
  }

  final MyContributionUserModel user;
  final ImamSalaryContributionSummaryModel imamSalary;
}

double _readDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? 0;
}

int _readInt(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}
