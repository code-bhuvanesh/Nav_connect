import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:sist_nav_connect/data/respository/backend_api.dart';

import '../../../data/model/bus.dart';

part 'bus_event.dart';
part 'bus_state.dart';

class BusBloc extends Bloc<BusEvent, BusState> {
  BusBloc() : super(BusInitial()) {
    on<GetBusesEvent>(onGetBusesEvent);
  }
  BackendApi backendApi = BackendApi();
  FutureOr<void> onGetBusesEvent(
    GetBusesEvent event,
    Emitter<BusState> emit,
  ) async {
    var busData = await backendApi.getBuses();
    // print(busData);
    // print(busData.runtimeType);
    var buses = busData.map((e) => Bus.fromMap(e)).toList();
    print(buses);
    emit(BusDetailsState(buses: buses));
  }
}
