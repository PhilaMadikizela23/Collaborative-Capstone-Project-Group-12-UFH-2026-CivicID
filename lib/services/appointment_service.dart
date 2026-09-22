import 'mock_data.dart';
import '../models/appointment.dart';

class AppointmentService {
  final MockData _mockData = MockData();

  Future<List<Appointment>> getAppointments() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockData.appointments;
  }

  Future<void> bookAppointment(String serviceName, DateTime dateTime, String location) async {
    await Future.delayed(const Duration(seconds: 1));
    _mockData.appointments.add(Appointment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      serviceName: serviceName,
      dateTime: dateTime,
      location: location,
    ));
  }
}
