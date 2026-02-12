import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/employee.dart';
import '../providers/employees_provider.dart';
import '../../../../core/providers/role_provider.dart';
import '../../../../core/utils/permissions.dart';

class EmployeesScreen extends ConsumerStatefulWidget {
  const EmployeesScreen({super.key});

  @override
  ConsumerState<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends ConsumerState<EmployeesScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final role = ref.watch(roleProvider);

    // Sólo administradores pueden gestionar empleados localmente
    if (!canManageEmployees(role) && !canManageAll(role)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Empleados')),
        body: const Center(child: Text('No autorizado para ver esta sección')),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Empleados'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showAddEmployeeDialog(),
            tooltip: 'Agregar',
          ),
        ],
      ),
      body: isMobile
          ? Column(
              children: [
                Expanded(child: _buildSelectedView()),
              ],
            )
          : Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() => _selectedIndex = index);
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.people),
                      label: Text('Empleados'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.schedule),
                      label: Text('Turnos'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.check_circle),
                      label: Text('Asistencia'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: _buildSelectedView(),
                ),
              ],
            ),
      bottomNavigationBar: isMobile
          ? NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.people),
                  label: 'Empleados',
                ),
                NavigationDestination(
                  icon: Icon(Icons.schedule),
                  label: 'Turnos',
                ),
                NavigationDestination(
                  icon: Icon(Icons.check_circle),
                  label: 'Asistencia',
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildSelectedView() {
    switch (_selectedIndex) {
      case 0:
        return _buildEmployeesView();
      case 1:
        return _buildShiftsView();
      case 2:
        return _buildAttendanceView();
      default:
        return _buildEmployeesView();
    }
  }

  Widget _buildEmployeesView() {
    final employees = ref.watch(employeesProvider);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(isMobile ? 8 : 16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar...',
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        Expanded(
          child: employees.isEmpty
              ? const Center(
                  child: Text('No hay empleados registrados'),
                )
              : ListView.builder(
                  itemCount: employees.length,
                  padding: EdgeInsets.all(isMobile ? 8 : 16),
                  itemBuilder: (context, index) {
                    final employee = employees[index];
                    return _EmployeeCard(
                      employee: employee,
                      isMobile: isMobile,
                      onEdit: () => _showEditEmployeeDialog(employee),
                      onDelete: () => _confirmDeleteEmployee(employee),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildShiftsView() {
    final shifts = ref.watch(shiftsProvider);
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.schedule, size: 32),
              const SizedBox(width: 16),
              Text(
                'Turnos Activos',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        ),
        Expanded(
          child: shifts.isEmpty
              ? const Center(
                  child: Text('No hay turnos activos'),
                )
              : ListView.builder(
                  itemCount: shifts.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final shift = shifts[index];
                    final employees = ref.watch(employeesProvider);
                    final employee = employees.firstWhere(
                      (e) => e.id == shift.employeeId,
                      orElse: () => Employee(
                        id: '',
                        name: 'Desconocido',
                        email: '',
                        phone: '',
                        role: 'Desconocido',
                        status: EmployeeStatus.inactive,
                        hourlyRate: 0,
                        hireDate: DateTime.now(),
                        createdAt: DateTime.now(),
                      ),
                    );

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(employee.name[0]),
                        ),
                        title: Text(employee.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('${employee.role} - ${shift.type.displayName}'),
                            Text(
                              'Inicio: ${DateFormat('HH:mm').format(shift.startTime)}',
                            ),
                            if (shift.hoursWorked != null && shift.hoursWorked! > 0)
                              Text(
                                'Horas: ${shift.hoursWorked!.toStringAsFixed(1)}h - ${currencyFormat.format(shift.hoursWorked! * employee.hourlyRate)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                          ],
                        ),
                        trailing: shift.endTime == null
                            ? FilledButton.icon(
                                onPressed: () => _endShift(shift.id),
                                icon: const Icon(Icons.logout),
                                label: const Text('Finalizar'),
                              )
                            : Chip(
                                label: Text(
                                  'Finalizado ${DateFormat('HH:mm').format(shift.endTime!)}',
                                ),
                                backgroundColor: Colors.green.shade100,
                              ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAttendanceView() {
    final attendance = ref.watch(attendanceProvider);
    final employees = ref.watch(employeesProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.check_circle, size: 32),
              const SizedBox(width: 16),
              Text(
                'Registro de Asistencia',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _showCheckInDialog(),
                icon: const Icon(Icons.login),
                label: const Text('Registrar Entrada'),
              ),
            ],
          ),
        ),
        Expanded(
          child: attendance.isEmpty
              ? const Center(
                  child: Text('No hay registros de asistencia'),
                )
              : ListView.builder(
                  itemCount: attendance.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final record = attendance[index];
                    final employee = employees.firstWhere(
                      (e) => e.id == record.employeeId,
                      orElse: () => Employee(
                        id: '',
                        name: 'Desconocido',
                        email: '',
                        phone: '',
                        role: 'Desconocido',
                        status: EmployeeStatus.inactive,
                        hourlyRate: 0,
                        hireDate: DateTime.now(),
                        createdAt: DateTime.now(),
                      ),
                    );

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: record.isLate ? Colors.orange : Colors.green,
                          child: Icon(
                            record.isLate ? Icons.warning : Icons.check,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(employee.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Entrada: ${DateFormat('HH:mm').format(record.checkIn)}'),
                            if (record.checkOut != null)
                              Text(
                                'Salida: ${DateFormat('HH:mm').format(record.checkOut!)}',
                              ),
                            if (record.hoursWorked != null && record.hoursWorked! > 0)
                              Text(
                                'Total: ${record.hoursWorked!.toStringAsFixed(1)} horas',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            if (record.isLate)
                              const Text(
                                '⚠️ Llegada tarde',
                                style: TextStyle(color: Colors.orange),
                              ),
                          ],
                        ),
                        trailing: record.checkOut == null
                            ? FilledButton.icon(
                                onPressed: () => _checkOut(record.id),
                                icon: const Icon(Icons.logout),
                                label: const Text('Salida'),
                              )
                            : null,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showAddEmployeeDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final roleController = TextEditingController();
    final hourlyRateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Empleado'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre Completo',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: roleController,
                decoration: const InputDecoration(
                  labelText: 'Puesto',
                  prefixIcon: Icon(Icons.work),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: hourlyRateController,
                decoration: const InputDecoration(
                  labelText: 'Tarifa por Hora (\$)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  emailController.text.isNotEmpty &&
                  roleController.text.isNotEmpty &&
                  hourlyRateController.text.isNotEmpty) {
                ref.read(employeesProvider.notifier).addEmployee(
                      name: nameController.text,
                      email: emailController.text,
                      phone: phoneController.text,
                      role: roleController.text,
                      hourlyRate: double.parse(hourlyRateController.text),
                    );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Empleado agregado exitosamente'),
                  ),
                );
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _showEditEmployeeDialog(Employee employee) {
    final nameController = TextEditingController(text: employee.name);
    final emailController = TextEditingController(text: employee.email);
    final phoneController = TextEditingController(text: employee.phone);
    final roleController = TextEditingController(text: employee.role);
    final hourlyRateController =
        TextEditingController(text: employee.hourlyRate.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Empleado'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre Completo',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: roleController,
                decoration: const InputDecoration(
                  labelText: 'Puesto',
                  prefixIcon: Icon(Icons.work),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: hourlyRateController,
                decoration: const InputDecoration(
                  labelText: 'Tarifa por Hora (\$)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  emailController.text.isNotEmpty &&
                  roleController.text.isNotEmpty &&
                  hourlyRateController.text.isNotEmpty) {
                ref.read(employeesProvider.notifier).updateEmployee(
                      employee.id,
                      name: nameController.text,
                      email: emailController.text,
                      phone: phoneController.text,
                      role: roleController.text,
                      hourlyRate: double.parse(hourlyRateController.text),
                    );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Empleado actualizado exitosamente'),
                  ),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteEmployee(Employee employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro de eliminar a ${employee.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(employeesProvider.notifier).deleteEmployee(employee.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Empleado eliminado'),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _endShift(String shiftId) {
    ref.read(shiftsProvider.notifier).endShift(shiftId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Turno finalizado'),
      ),
    );
  }

  void _showCheckInDialog() {
    final employees = ref.read(employeesProvider);
    final activeEmployees =
        employees.where((e) => e.status == EmployeeStatus.active).toList();

    if (activeEmployees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay empleados activos'),
        ),
      );
      return;
    }

    String? selectedEmployeeId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Registrar Entrada'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedEmployeeId,
                decoration: const InputDecoration(
                  labelText: 'Seleccionar Empleado',
                  prefixIcon: Icon(Icons.person),
                ),
                items: activeEmployees.map((employee) {
                  return DropdownMenuItem(
                    value: employee.id,
                    child: Text('${employee.name} - ${employee.role}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedEmployeeId = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: selectedEmployeeId != null
                  ? () {
                      final employee = activeEmployees.firstWhere(
                        (e) => e.id == selectedEmployeeId,
                      );
                      ref
                          .read(attendanceProvider.notifier)
                          .checkIn(employee);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Entrada registrada'),
                        ),
                      );
                    }
                  : null,
              child: const Text('Registrar'),
            ),
          ],
        ),
      ),
    );
  }

  void _checkOut(String attendanceId) {
    ref.read(attendanceProvider.notifier).checkOut(attendanceId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Salida registrada'),
      ),
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  final Employee employee;
  final bool isMobile;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EmployeeCard({
    required this.employee,
    required this.isMobile,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      child: ListTile(
        contentPadding: EdgeInsets.all(isMobile ? 8 : 12),
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(employee.status),
          child: Text(
            employee.name[0].toUpperCase(),
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        title: Text(
          employee.name,
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${employee.role} - ${employee.status.displayName}',
              style: TextStyle(fontSize: isMobile ? 12 : 14),
            ),
            Text(
              '${currencyFormat.format(employee.hourlyRate)}/hora',
              style: TextStyle(fontSize: isMobile ? 12 : 14),
            ),
            if (!isMobile) ...[
              Text('📧 ${employee.email}'),
              if (employee.phone.isNotEmpty) Text('📱 ${employee.phone}'),
            ],
          ],
        ),
        trailing: isMobile
            ? PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 18),
                        SizedBox(width: 8),
                        Text('Eliminar', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
                ],
              ),
        isThreeLine: true,
      ),
    );
  }

  Color _getStatusColor(EmployeeStatus status) {
    switch (status) {
      case EmployeeStatus.active:
        return Colors.green;
      case EmployeeStatus.inactive:
        return Colors.grey;
      case EmployeeStatus.vacation:
        return Colors.blue;
      case EmployeeStatus.suspended:
        return Colors.red;
    }
  }
}
