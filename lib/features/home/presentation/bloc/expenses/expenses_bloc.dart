import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/expense_model.dart';
import '../../../domain/entities/expense_filter.dart';
import '../../../domain/repositories/home_repository.dart';
import '../../../domain/usecases/filter_expenses_usecase.dart';

part 'expenses_event.dart';
part 'expenses_state.dart';

class ExpensesBloc extends Bloc<ExpensesEvent, ExpensesState> {
  ExpensesBloc(this._repository, this._filterExpenses)
    : super(ExpensesInitial()) {
    on<ExpensesStarted>((event, emit) {
      emit(
        ExpensesSuccess(
          expenses: _repository.getExpenses(),
          totalBalance: _repository.getTotalBalance(),
        ),
      );
    });

    on<ExpensesFilterApplied>((event, emit) {
      emit(
        ExpensesSuccess(
          expenses: _filterExpenses(_repository.getExpenses(), event.filter),
          totalBalance: _repository.getTotalBalance(),
          activeFilter: event.filter,
        ),
      );
    });
  }

  final HomeRepository _repository;
  final FilterExpensesUseCase _filterExpenses;
}
