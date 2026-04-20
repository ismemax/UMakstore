# Security & Permissions: UMAS Roles

UMAS implements a Role-Based Access Control (RBAC) system to ensure that only authorized users can perform sensitive actions like approving apps or accessing administrative dashboards.

## 👥 User Roles

| Role | Permissions | Access Level |
| :--- | :--- | :--- |
| **Student** | Browse apps, download/install APKs, submit reviews, and manage personal profile. | Basic |
| **Developer** | All Student permissions + Submit new apps, update existing submissions, and view developer analytics. | Elevated |
| **Admin** | All Developer permissions + Approve/Reject app submissions, manage user roles, and access global analytics. | Full |

## 🔐 Authorization Logic

Authorization is handled at two levels:

### 1. Client-Side (Flutter)
The UI conditionally renders elements based on the `role` field in the user's Firestore document.
- **AuthGate**: Directs users to the appropriate starting point.
- **Dashboard Filtering**: The 'Admin' and 'Developer' tiles only appear in the Profile/Settings if the user's role matches.

### 2. Server-Side (Firestore Rules & API)
- **Firestore Rules**: Restrict write access to the `submitted_apps` collection. Only users with `role == 'developer'` can create documents, and only `role == 'admin'` can update the `status` field.
- **Role Assignment API**: To prevent unauthorized escalation, roles cannot be changed directly via Firestore. Role changes are processed through a secure Vercel-hosted API (`/assign-role`) that validates the requester's authority and uses a master key for bypasses.

## 🛡️ Role Escalation

By default, all new users (registered with `@umak.edu.ph`) are assigned the **Student** role.
- **To become a Developer**: Users must be promoted by an Admin or through the official developer application process.
- **Admin Assignment**: Admin roles are managed via the **Role Management Screen**, where existing admins can promote others by providing a justified reason.

## 🚀 Security Features

- **Domain Restriction**: Only emails ending in `@umak.edu.ph` are permitted to register.
- **App Check**: Firebase App Check is enabled to ensure that only the official UMAS app can interact with Firebase services, preventing unauthorized API usage.
- **Device Locking**: The app includes logic to validate and register specific devices to prevent account sharing or unauthorized multi-device access (see `AuthService.registerDevice`).

---
*Last Updated: April 2026*
