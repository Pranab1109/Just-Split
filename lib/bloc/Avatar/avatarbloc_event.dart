part of 'avatarbloc_bloc.dart';

abstract class AvatarblocEvent extends Equatable {
  const AvatarblocEvent();

  @override
  List<Object> get props => [];
}

class AvatarChangeRequest extends AvatarblocEvent {
  final int index;
  const AvatarChangeRequest(this.index);
}
