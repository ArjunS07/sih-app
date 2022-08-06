class ZoomMeeting {
  final String startUrl;
  final String joinUrl;
  final String meetingId;
  final String meetingPassword;

  const ZoomMeeting({
    required this.startUrl,
    required this.joinUrl,
    required this.meetingId,
    required this.meetingPassword,
  });

  factory ZoomMeeting.fromJson(Map<String, dynamic> json) {
    return ZoomMeeting(
      startUrl: json['start_url'],
      joinUrl: json['join_url'],
      meetingId: json['meeting_id'],
      meetingPassword: json['meeting_password'],
    );
  }
}