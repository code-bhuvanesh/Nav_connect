part of 'bus_bloc.dart';

@immutable
sealed class BusEvent {}


class GetBusesEvent extends BusEvent {}

