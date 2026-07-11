class AdminDashboardSummary {
  const AdminDashboardSummary({
    this.totalUsers = 0,
    this.activeUsers = 0,
    this.inactiveUsers = 0,
    this.suspendedUsers = 0,
    this.totalMasjids = 0,
    this.pendingRequests = 0,
    this.approvedRequests = 0,
    this.rejectedRequests = 0,
  });

  factory AdminDashboardSummary.fromJson(Map<String, dynamic> json) {
    int readInt(String key) => int.tryParse('${json[key] ?? 0}') ?? 0;
    return AdminDashboardSummary(
      totalUsers: readInt('totalUsers'),
      activeUsers: readInt('activeUsers'),
      inactiveUsers: readInt('inactiveUsers'),
      suspendedUsers: readInt('suspendedUsers'),
      totalMasjids: readInt('totalMasjids'),
      pendingRequests: readInt('pendingRequests'),
      approvedRequests: readInt('approvedRequests'),
      rejectedRequests: readInt('rejectedRequests'),
    );
  }

  final int totalUsers;
  final int activeUsers;
  final int inactiveUsers;
  final int suspendedUsers;
  final int totalMasjids;
  final int pendingRequests;
  final int approvedRequests;
  final int rejectedRequests;
}
