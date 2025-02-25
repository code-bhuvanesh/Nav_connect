part of 'main_bloc.dart';

@immutable
sealed class MainState {}

final class MainInitial extends MainState {}

class LocationPermissionSucess extends MainState {}

class LocationPermissionFailure extends MainState {}

class CurrentLocationState extends MainState {
  final LatLng location;
  CurrentLocationState({required this.location});
}
