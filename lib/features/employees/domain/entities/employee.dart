import 'package:equatable/equatable.dart';

/// Estados de empleado
enum EmployeeStatus {
  active,
  inactive,
  vacation,
  suspended;

  String get displayName {
    switch (this) {
      case EmployeeStatus.active:
        return 'Activo';
      case EmployeeStatus.inactive:
        return 'Inactivo';
      case EmployeeStatus.vacation:
        return 'De vacaciones';
      case EmployeeStatus.suspended:
        return 'Suspendido';
    }
  }
}

/// Tipos de turno
enum ShiftType {
  morning,
  afternoon,
  night,
  full;

  String get displayName {
    switch (this) {
      case ShiftType.morning:
        return 'Mañana';
      case ShiftType.afternoon:
        return 'Tarde';
      case ShiftType.night:
        return 'Noche';
      case ShiftType.full:
        return 'Completo';
    }
  }
}

/// Entidad de Empleado
class Employee extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // mesero, chef, cajero, gerente
  final EmployeeStatus status;
  final double hourlyRate;
  final DateTime hireDate;
  final String? photoUrl;
  final String? address;
  final String? emergencyContact;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    required this.hourlyRate,
    required this.hireDate,
    this.photoUrl,
    this.address,
    this.emergencyContact,
    required this.createdAt,
    this.updatedAt,
  });

  Employee copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    EmployeeStatus? status,
    double? hourlyRate,
    DateTime? hireDate,
    String? photoUrl,
    String? address,
    String? emergencyContact,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      hireDate: hireDate ?? this.hireDate,
      photoUrl: photoUrl ?? this.photoUrl,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        role,
        status,
        hourlyRate,
        hireDate,
        photoUrl,
        address,
        emergencyContact,
        createdAt,
        updatedAt,
      ];
}

/// Entidad de Turno
class Shift extends Equatable {
  final String id;
  final String employeeId;
  final String employeeName;
  final ShiftType type;
  final DateTime date;
  final DateTime startTime;
  final DateTime? endTime;
  final double? hoursWorked;
  final String? notes;
  final DateTime createdAt;

  const Shift({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.type,
    required this.date,
    required this.startTime,
    this.endTime,
    this.hoursWorked,
    this.notes,
    required this.createdAt,
  });

  bool get isActive => endTime == null;

  Shift copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    ShiftType? type,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    double? hoursWorked,
    String? notes,
    DateTime? createdAt,
  }) {
    return Shift(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      type: type ?? this.type,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      hoursWorked: hoursWorked ?? this.hoursWorked,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        employeeId,
        employeeName,
        type,
        date,
        startTime,
        endTime,
        hoursWorked,
        notes,
        createdAt,
      ];
}

/// Entidad de Asistencia
class Attendance extends Equatable {
  final String id;
  final String employeeId;
  final String employeeName;
  final DateTime date;
  final DateTime checkIn;
  final DateTime? checkOut;
  final bool isLate;
  final String? notes;
  final DateTime createdAt;

  const Attendance({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.date,
    required this.checkIn,
    this.checkOut,
    required this.isLate,
    this.notes,
    required this.createdAt,
  });

  double? get hoursWorked {
    if (checkOut == null) return null;
    return checkOut!.difference(checkIn).inMinutes / 60;
  }

  Attendance copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    DateTime? date,
    DateTime? checkIn,
    DateTime? checkOut,
    bool? isLate,
    String? notes,
    DateTime? createdAt,
  }) {
    return Attendance(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      date: date ?? this.date,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      isLate: isLate ?? this.isLate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        employeeId,
        employeeName,
        date,
        checkIn,
        checkOut,
        isLate,
        notes,
        createdAt,
      ];
}
