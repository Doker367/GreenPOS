import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/employee.dart';

/// Provider de empleados (mock data)
final employeesProvider = StateNotifierProvider<EmployeesNotifier, List<Employee>>(
  (ref) => EmployeesNotifier(),
);

class EmployeesNotifier extends StateNotifier<List<Employee>> {
  EmployeesNotifier() : super(_initialEmployees);

  static final List<Employee> _initialEmployees = [
    Employee(
      id: '1',
      name: 'Juan Pérez',
      email: 'juan.perez@restaurant.com',
      phone: '+52 55 1234 5678',
      role: 'Mesero',
      status: EmployeeStatus.active,
      hourlyRate: 80.0,
      hireDate: DateTime(2024, 1, 15),
      address: 'Calle Principal 123, CDMX',
      emergencyContact: '+52 55 9876 5432',
      createdAt: DateTime(2024, 1, 15),
    ),
    Employee(
      id: '2',
      name: 'María González',
      email: 'maria.gonzalez@restaurant.com',
      phone: '+52 55 2345 6789',
      role: 'Chef',
      status: EmployeeStatus.active,
      hourlyRate: 150.0,
      hireDate: DateTime(2023, 6, 1),
      address: 'Av. Reforma 456, CDMX',
      emergencyContact: '+52 55 8765 4321',
      createdAt: DateTime(2023, 6, 1),
    ),
    Employee(
      id: '3',
      name: 'Carlos Rodríguez',
      email: 'carlos.rodriguez@restaurant.com',
      phone: '+52 55 3456 7890',
      role: 'Cajero',
      status: EmployeeStatus.active,
      hourlyRate: 90.0,
      hireDate: DateTime(2024, 3, 10),
      address: 'Colonia del Valle 789, CDMX',
      emergencyContact: '+52 55 7654 3210',
      createdAt: DateTime(2024, 3, 10),
    ),
    Employee(
      id: '4',
      name: 'Ana Martínez',
      email: 'ana.martinez@restaurant.com',
      phone: '+52 55 4567 8901',
      role: 'Mesera',
      status: EmployeeStatus.active,
      hourlyRate: 80.0,
      hireDate: DateTime(2024, 2, 20),
      address: 'Polanco 321, CDMX',
      emergencyContact: '+52 55 6543 2109',
      createdAt: DateTime(2024, 2, 20),
    ),
    Employee(
      id: '5',
      name: 'Luis Hernández',
      email: 'luis.hernandez@restaurant.com',
      phone: '+52 55 5678 9012',
      role: 'Gerente',
      status: EmployeeStatus.active,
      hourlyRate: 200.0,
      hireDate: DateTime(2023, 1, 5),
      address: 'Santa Fe 654, CDMX',
      emergencyContact: '+52 55 5432 1098',
      createdAt: DateTime(2023, 1, 5),
    ),
    Employee(
      id: '6',
      name: 'Laura Sánchez',
      email: 'laura.sanchez@restaurant.com',
      phone: '+52 55 6789 0123',
      role: 'Chef Ayudante',
      status: EmployeeStatus.vacation,
      hourlyRate: 100.0,
      hireDate: DateTime(2024, 4, 1),
      address: 'Condesa 987, CDMX',
      emergencyContact: '+52 55 4321 0987',
      createdAt: DateTime(2024, 4, 1),
    ),
  ];

  void addEmployee({
    required String name,
    required String email,
    required String phone,
    required String role,
    required double hourlyRate,
  }) {
    final newEmployee = Employee(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      phone: phone,
      role: role,
      status: EmployeeStatus.active,
      hourlyRate: hourlyRate,
      hireDate: DateTime.now(),
      createdAt: DateTime.now(),
    );
    state = [...state, newEmployee];
  }

  void updateEmployee(
    String id, {
    required String name,
    required String email,
    required String phone,
    required String role,
    required double hourlyRate,
  }) {
    state = [
      for (final emp in state)
        if (emp.id == id)
          emp.copyWith(
            name: name,
            email: email,
            phone: phone,
            role: role,
            hourlyRate: hourlyRate,
            updatedAt: DateTime.now(),
          )
        else
          emp,
    ];
  }

  void deleteEmployee(String id) {
    state = state.where((emp) => emp.id != id).toList();
  }

  void updateEmployeeStatus(String id, EmployeeStatus status) {
    state = [
      for (final emp in state)
        if (emp.id == id)
          emp.copyWith(status: status, updatedAt: DateTime.now())
        else
          emp,
    ];
  }
}

/// Provider de turnos (mock data)
final shiftsProvider = StateNotifierProvider<ShiftsNotifier, List<Shift>>(
  (ref) => ShiftsNotifier(),
);

class ShiftsNotifier extends StateNotifier<List<Shift>> {
  ShiftsNotifier() : super(_initialShifts);

  static final List<Shift> _initialShifts = [
    Shift(
      id: '1',
      employeeId: '1',
      employeeName: 'Juan Pérez',
      type: ShiftType.morning,
      date: DateTime.now(),
      startTime: DateTime.now().subtract(const Duration(hours: 3)),
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    Shift(
      id: '2',
      employeeId: '2',
      employeeName: 'María González',
      type: ShiftType.morning,
      date: DateTime.now(),
      startTime: DateTime.now().subtract(const Duration(hours: 4)),
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    Shift(
      id: '3',
      employeeId: '3',
      employeeName: 'Carlos Rodríguez',
      type: ShiftType.afternoon,
      date: DateTime.now(),
      startTime: DateTime.now().subtract(const Duration(hours: 2)),
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  void startShift(Employee employee, ShiftType type) {
    final now = DateTime.now();
    final shift = Shift(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      employeeId: employee.id,
      employeeName: employee.name,
      type: type,
      date: now,
      startTime: now,
      createdAt: now,
    );
    state = [...state, shift];
  }

  void endShift(String shiftId) {
    state = [
      for (final shift in state)
        if (shift.id == shiftId)
          shift.copyWith(
            endTime: DateTime.now(),
            hoursWorked: DateTime.now().difference(shift.startTime).inMinutes / 60,
          )
        else
          shift,
    ];
  }

  void deleteShift(String id) {
    state = state.where((shift) => shift.id != id).toList();
  }

  List<Shift> getEmployeeShifts(String employeeId) {
    return state.where((shift) => shift.employeeId == employeeId).toList();
  }

  List<Shift> getActiveShifts() {
    return state.where((shift) => shift.isActive).toList();
  }

  List<Shift> getShiftsByDate(DateTime date) {
    return state.where((shift) {
      return shift.date.year == date.year &&
          shift.date.month == date.month &&
          shift.date.day == date.day;
    }).toList();
  }
}

/// Provider de asistencias (mock data)
final attendanceProvider = StateNotifierProvider<AttendanceNotifier, List<Attendance>>(
  (ref) => AttendanceNotifier(),
);

class AttendanceNotifier extends StateNotifier<List<Attendance>> {
  AttendanceNotifier() : super(_initialAttendance);

  static final List<Attendance> _initialAttendance = [
    Attendance(
      id: '1',
      employeeId: '1',
      employeeName: 'Juan Pérez',
      date: DateTime.now(),
      checkIn: DateTime.now().subtract(const Duration(hours: 3)),
      isLate: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    Attendance(
      id: '2',
      employeeId: '2',
      employeeName: 'María González',
      date: DateTime.now(),
      checkIn: DateTime.now().subtract(const Duration(hours: 4)),
      isLate: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
  ];

  void checkIn(Employee employee, {bool isLate = false}) {
    final now = DateTime.now();
    final attendance = Attendance(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      employeeId: employee.id,
      employeeName: employee.name,
      date: now,
      checkIn: now,
      isLate: isLate,
      createdAt: now,
    );
    state = [...state, attendance];
  }

  void checkOut(String attendanceId) {
    state = [
      for (final att in state)
        if (att.id == attendanceId)
          att.copyWith(checkOut: DateTime.now())
        else
          att,
    ];
  }

  List<Attendance> getEmployeeAttendance(String employeeId) {
    return state.where((att) => att.employeeId == employeeId).toList();
  }

  List<Attendance> getAttendanceByDate(DateTime date) {
    return state.where((att) {
      return att.date.year == date.year &&
          att.date.month == date.month &&
          att.date.day == date.day;
    }).toList();
  }
}
