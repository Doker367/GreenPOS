# Configuración de Firestore
Esta es la configuración de seguridad para Firestore.

## Instrucciones

1. Ve a Firebase Console → Firestore Database → Rules
2. Copia y pega el siguiente contenido:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Función helper para verificar si el usuario está autenticado
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Función helper para verificar si el usuario es admin
    function isAdmin() {
      return isAuthenticated() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Función helper para verificar si el usuario es staff
    function isStaff() {
      return isAuthenticated() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['admin', 'waiter', 'chef'];
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && request.auth.uid == userId;
      allow update: if isAuthenticated() && (request.auth.uid == userId || isAdmin());
      allow delete: if isAdmin();
    }
    
    // Categories collection
    match /categories/{categoryId} {
      allow read: if true; // Público
      allow write: if isAdmin();
    }
    
    // Products collection
    match /products/{productId} {
      allow read: if true; // Público
      allow write: if isAdmin();
    }
    
    // Orders collection
    match /orders/{orderId} {
      allow read: if isAuthenticated() && 
                    (resource.data.user_id == request.auth.uid || isStaff());
      allow create: if isAuthenticated();
      allow update: if isAuthenticated() && 
                      (resource.data.user_id == request.auth.uid || isStaff());
      allow delete: if isAdmin();
    }
    
    // Tables collection
    match /tables/{tableId} {
      allow read: if isAuthenticated();
      allow write: if isStaff();
    }
    
    // Reservations collection
    match /reservations/{reservationId} {
      allow read: if isAuthenticated() && 
                    (resource.data.user_id == request.auth.uid || isStaff());
      allow create: if isAuthenticated();
      allow update: if isAuthenticated() && 
                      (resource.data.user_id == request.auth.uid || isStaff());
      allow delete: if isAdmin();
    }
  }
}
```

## Índices recomendados

Ve a Firebase Console → Firestore Database → Indexes y crea estos índices compuestos:

1. **Orders**:
   - Collection: `orders`
   - Fields: `user_id` (Ascending), `created_at` (Descending)

2. **Orders por estado**:
   - Collection: `orders`
   - Fields: `status` (Ascending), `created_at` (Descending)

3. **Products por categoría**:
   - Collection: `products`
   - Fields: `category_id` (Ascending), `is_available` (Ascending)

4. **Reservations por fecha**:
   - Collection: `reservations`
   - Fields: `reservation_date` (Ascending), `is_confirmed` (Ascending)
