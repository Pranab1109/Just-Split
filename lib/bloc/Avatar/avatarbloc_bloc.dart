import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:just_split/Services/AvatarRepo.dart';

part 'avatarbloc_event.dart';
part 'avatarbloc_state.dart';

class AvatarBloc extends Bloc<AvatarblocEvent, AvatarState> {
  final AvatarRepo avatarRepo;
  AvatarBloc(this.avatarRepo) : super(AvatarblocInitial(state: 0)) {
    on<AvatarIndexChangeRequest>((event, emit) {
      emit(AvatarblocLoading());
      avatarRepo.selectIndex(event.index);
      emit(AvatarblocChanged(
          ind: avatarRepo.selectedAvatar, name: avatarRepo.userName));
    });
    on<AvatarNameChangeRequest>((event, emit) {
      emit(AvatarblocLoading());
      avatarRepo.selectUserName(event.name);
      emit(AvatarblocChanged(
          ind: avatarRepo.selectedAvatar, name: avatarRepo.userName));
    });
  }
}
