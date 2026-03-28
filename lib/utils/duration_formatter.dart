String formatDuration(Duration duration) {
  String hours = duration.inHours > 0 ? '${duration.inHours}h ' : '';
  String minutes = '${duration.inMinutes.remainder(60)}m';
  return hours + minutes;
}
