import '../../domain/entities/dashboard_data.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDatasource remoteDatasource;

  DashboardRepositoryImpl({required this.remoteDatasource});

  @override
  Future<DashboardData> getDashboard() async {
    return await remoteDatasource.getDashboard();
  }
}
