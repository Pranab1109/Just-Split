import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:just_split/Services/AvatarRepo.dart';

part 'avatarbloc_event.dart';
part 'avatarbloc_state.dart';

class AvatarBloc extends Bloc<AvatarblocEvent, AvatarState> {
  final AvatarRepo avatarRepo;
  AvatarBloc(this.avatarRepo) : super(const AvatarblocInitial(state: 0)) {
    on<AvatarChangeRequest>((event, emit) {
      avatarRepo.selectIndex(event.index);
      emit(AvatarblocChanged(state: avatarRepo.selectedAvatar));
    });
  }
}
