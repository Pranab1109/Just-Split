part of 'avatarbloc_bloc.dart';

abstract class AvatarState extends Equatable {
  const AvatarState({required this.selected});
  final int selected;
  @override
  List<Object> get props => [selected];
}

class AvatarblocInitial extends AvatarState {
  const AvatarblocInitial({required int state}) : super(selected: state);
}

class AvatarblocChanged extends AvatarState {
  const AvatarblocChanged({required int state}) : super(selected: state);
}
