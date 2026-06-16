import '../../domain/repositories/home_repository.dart';
import '../dummy_data.dart';
import '../models/expense_model.dart';
import '../models/group_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl();

  @override
  Map<String, List<ExpenseModel>> getExpenses() => HomeDummyData.expenses;

  @override
  double getTotalBalance() => HomeDummyData.totalBalance;

  @override
  List<GroupModel> getGroups() => HomeDummyData.groups;
}
