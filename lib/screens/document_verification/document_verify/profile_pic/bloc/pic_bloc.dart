import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';

part 'pic_event.dart';
part 'pic_state.dart';

class PicBloc extends Bloc<PicEvent, PicState> {
  PicBloc() : super(const PicState()) {
    on<PicImageChanged>(_onPicImageChanged);
    on<PicSubmitted>(_onSubmitted);
  }

  void _onPicImageChanged(
    PicImageChanged event,
    Emitter<PicState> emit,
  ) {
    final picImage = PicImage.dirty(event.imagePath);
    emit(
      state.copyWith(
        picImage: picImage,
        isValid: Formz.validate([
          picImage,
        ]),
      ),
    );
  }

  void _onSubmitted(
    PicSubmitted event,
    Emitter<PicState> emit,
  ) async {
    if (state.isValid) {
      emit(state.copyWith(status: PicStatus.loading));
      try {
        // TODO: Implement profile photo submission to API
        await Future<void>.delayed(const Duration(seconds: 2)); // Simulate API call
        emit(state.copyWith(status: PicStatus.success));
      } catch (error) {
        emit(
          state.copyWith(
            status: PicStatus.failure,
            errorMessage: error.toString(),
          ),
        );
      }
    }
  }
}
