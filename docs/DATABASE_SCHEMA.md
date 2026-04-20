# Database Schema: UMAS Firestore

UMAS uses Google Cloud Firestore (NoSQL) for all persistence. The data is organized into three primary collections.

## 📁 Collection: `users`
Stores student and staff profile information.

| Field | Type | Description |
| :--- | :--- | :--- |
| `email` | `String` | UMak student/staff email (e.g., `*.@umak.edu.ph`). |
| `studentId` | `String` | UMak Student ID (extracted from email or manual). |
| `firstName` | `String` | User's first name. |
| `lastName` | `String` | User's last name. |
| `middleName` | `String` | User's middle name (optional). |
| `college` | `String` | The college the student belongs to. |
| `course` | `String` | Current course/degree. |
| `role` | `String` | User role (`student`, `developer`, or `admin`). |
| `photoBase64` | `String` | Base64 encoded profile string (for small icons). |
| `createdAt` | `Timestamp` | Account creation server timestamp. |

## 📁 Collection: `submitted_apps`
Stores metadata for all applications submitted to the store.

| Field | Type | Description |
| :--- | :--- | :--- |
| `title` | `String` | Name of the application. |
| `publisher` | `String` | Developer or organization name. |
| `description` | `String` | App summary and description. |
| `category` | `String` | Category (e.g., Utility, Education). |
| `college` | `String` | Target college. |
| `downloadUrl` | `String` | URL to the APK file (External/Storage). |
| `iconUrl` | `String` | **Cloudinary URL** for the app icon. |
| `screenshots` | `List<String>` | **List of Cloudinary URLs** for app preview. |
| `packageName` | `String` | Unique Android package identifier (e.g. `com.umak.app`). |
| `version` | `String` | App version string (e.g., `1.0.0`). |
| `size` | `String` | Human-readable file size (e.g., `15.5 MB`). |
| `status` | `String` | App status (`Pending`, `Live`, `Rejected`). |
| `rating` | `String` | Average star rating (0.0 to 5.0). |
| `reviews` | `String` | Total number of reviews. |
| `developerId` | `String` | UID of the submitting user. |
| `createdAt` | `Timestamp` | Submission timestamp. |

### 📂 Sub-collection: `submitted_apps/{appId}/reviews`
Stores individual user reviews for a specific app.

| Field | Type | Description |
| :--- | :--- | :--- |
| `userId` | `String` | UID of the reviewer. |
| `userName` | `String` | Display name (or "UMak User" if anonymous). |
| `rating` | `Number` | Star rating (1-5). |
| `comment` | `String` | Text content of the review. |
| `isAnonymous` | `Boolean` | Visibility flag for the user's name. |
| `createdAt` | `Timestamp` | Review submission timestamp. |

---
*Last Updated: April 2026*
