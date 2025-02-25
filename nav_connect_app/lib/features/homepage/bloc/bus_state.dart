// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'bus_bloc.dart';

@immutable
sealed class BusState {}

final class BusInitial extends BusState {}

class BusDetailsState extends BusState {
  final List<Bus> buses;
  BusDetailsState({
    required this.buses,
  });
}
