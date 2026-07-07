class AdminDashboardSummary {
  const AdminDashboardSummary({this.totalUsers=0,this.activeUsers=0,this.inactiveUsers=0,this.suspendedUsers=0,this.totalMasjids=0,this.pendingRequests=0,this.approvedRequests=0,this.rejectedRequests=0});
  final int totalUsers, activeUsers, inactiveUsers, suspendedUsers, totalMasjids, pendingRequests, approvedRequests, rejectedRequests;
}
