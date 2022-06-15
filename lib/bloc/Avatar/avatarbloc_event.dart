part of 'avatarbloc_bloc.dart';

abstract class AvatarblocEvent extends Equatable {
  const AvatarblocEvent();

  @override
  List<Object> get props => [];
}

class AvatarIndexChangeRequest extends AvatarblocEvent {
  final int index;
  const AvatarIndexChangeRequest(this.index);
}
class AvatarNameChangeRequest extends AvatarblocEvent {
  final String name;
  const AvatarNameChangeRequest ({required this.name});
}
