part of 'main_bloc.dart';

@immutable
sealed class MainEvent {}


class GetLocationPermission extends MainEvent {}

class GetCurrentLocation extends MainEvent {}

class SendCurrentLocation extends MainEvent {}