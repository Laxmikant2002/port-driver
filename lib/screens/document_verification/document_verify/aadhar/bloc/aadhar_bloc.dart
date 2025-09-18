import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';

part 'aadhar_event.dart';
part 'aadhar_state.dart';

class AadharBloc extends Bloc<AadharEvent, AadharState> {
  AadharBloc() : super(const AadharState()) {
    on<AadharNumberChanged>(_onAadharNumberChanged);
    on<AadharImageChanged>(_onAadharImageChanged);
    on<AadharSubmitted>(_onSubmitted);
  }

  void _onAadharNumberChanged(
    AadharNumberChanged event,
    Emitter<AadharState> emit,
  ) {
    final aadharNumber = AadharNumber.dirty(event.aadharNumber);
    emit(
      state.copyWith(
        aadharNumber: aadharNumber,
        isValid: Formz.validate([
          aadharNumber,
          state.aadharImage,
        ]),
      ),
    );
  }

  void _onAadharImageChanged(
    AadharImageChanged event,
    Emitter<AadharState> emit,
  ) {
    final aadharImage = AadharImage.dirty(event.aadharImage);
    emit(
      state.copyWith(
        aadharImage: aadharImage,
        isValid: Formz.validate([
          state.aadharNumber,
          aadharImage,
        ]),
      ),
    );
  }

  void _onSubmitted(
    AadharSubmitted event,
    Emitter<AadharState> emit,
  ) async {
    if (state.isValid) {
      emit(state.copyWith(status: AadharStatus.loading));
      try {
        // TODO: Implement Aadhaar submission to API
        await Future<void>.delayed(const Duration(seconds: 2)); // Simulate API call
        emit(state.copyWith(status: AadharStatus.success));
      } catch (error) {
        emit(
          state.copyWith(
            status: AadharStatus.failure,
            errorMessage: error.toString(),
          ),
        );
      }
    }
  }
}
