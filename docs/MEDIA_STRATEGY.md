# Media Strategy: Cloudinary Integration

UMAS (UMak App Store) migrates away from standard Firebase Storage for image assets to **Cloudinary**, an industry-leading media management platform. This switch provides superior image optimization, faster delivery via CDN, and dynamic transformations.

## Configuration

The application interacts with Cloudinary via its REST API (specifically the unsigned upload preset flow).

- **Cloud Name**: `dkgrsvydx`
- **Upload Preset**: `makstore`

## Media Types

Cloudinary handles the following assets for the store:
1. **App Icons**: Standardized square icons for app listings.
2. **Screenshots**: High-resolution previews for the app details section.
3. **User Content**: Any images uploaded by developers during the submission process.

## Optimization & Transformations

To ensure high performance on mobile devices and reduce data consumption, UMAS implements dynamic transformations using Cloudinary's URL-based API.

### Implementation Example:
In `DeveloperService.getOptimizedUrl()`, we automatically append transformations:

```dart
// Auto format (f_auto) and Auto quality (q_auto) 
String transform = 'f_auto,q_auto';
if (width != null) transform += ',w_$width';
if (height != null) transform += ',h_$height,c_fill';

return url.replaceFirst('/upload/', '/upload/$transform/');
```

### Key Optimizations:
- **`f_auto`**: Delivers the best image format for the current browser/device (e.g., WebP on Android).
- **`q_auto`**: Intelligently compresses images to the lowest possible file size without visible quality loss.
- **`c_fill`**: Resizes and crops images to specific dimensions (like 500x500 thumbnails) to prevent UI layout shifts.

## 📤 Upload Process

Before uploading, images are compressed locally using `flutter_image_compress` to save user bandwidth:
1. **Local Compression**: Shrink to max 1080px and 70% quality.
2. **API Request**: POST multipart request to `api.cloudinary.com/v1_1/`.
3. **Secure Storage**: Cloudinary returns a `secure_url` which is then saved in the Firestore `submitted_apps` collection.

---
*Last Updated: April 2026*
