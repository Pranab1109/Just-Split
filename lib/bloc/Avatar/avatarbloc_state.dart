part of 'avatarbloc_bloc.dart';

abstract class AvatarState extends Equatable {
  @override
  List<Object> get props => [];
}

class AvatarblocInitial extends AvatarState {
  AvatarblocInitial({required int state}) : super();
}

class AvatarblocLoading extends AvatarState {}

class AvatarblocChanged extends AvatarState {
  final int ind;
  final String name;
  AvatarblocChanged({required this.ind, required this.name}) : super();
}
