import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'set_location_event.dart';
part 'set_location_state.dart';

class SetLocationBloc extends Bloc<SetLocationEvent, SetLocationState> {
  SetLocationBloc() : super(SetLocationInitial()) {
    on<SetLocationEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
