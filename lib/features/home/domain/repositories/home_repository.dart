import '../../data/models/expense_model.dart';
import '../../data/models/group_model.dart';

abstract interface class HomeRepository {
  Map<String, List<ExpenseModel>> getExpenses();
  double getTotalBalance();
  List<GroupModel> getGroups();
}
