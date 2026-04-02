import '../enums/user_role.dart';

bool canManageAll(UserRole role) => role == UserRole.admin;

bool canCharge(UserRole role) => role == UserRole.admin || role == UserRole.cashier;

bool canOrder(UserRole role) => role == UserRole.admin || role == UserRole.waiter;

bool canSeeKitchen(UserRole role) => role == UserRole.admin || role == UserRole.chef;

bool canManageInventory(UserRole role) => role == UserRole.admin || role == UserRole.cashier;

bool canManageEmployees(UserRole role) => role == UserRole.admin;
