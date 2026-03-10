import '../../domain/repositories/calendar_repository.dart';
import '../datasources/calendar_remote_datasource.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  final CalendarRemoteDatasource remoteDatasource;

  CalendarRepositoryImpl({required this.remoteDatasource});

  @override
  Future<CalendarMonthData> getCalendarMonth(String yearMonth) async {
    return await remoteDatasource.getCalendarMonth(yearMonth);
  }
}
