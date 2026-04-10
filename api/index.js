const express = require('express');
const nodemailer = require('nodemailer');
const cors = require('cors');
const admin = require('firebase-admin');
const rateLimit = require('express-rate-limit');
const helmet = require('helmet');
const hpp = require('hpp');
require('dotenv').config();

const app = express();

// Security middleware
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"],
    },
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true
  }
}));

// Rate limiting for general requests
const generalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  message: { error: 'Too many requests from this IP, please try again later.' },
  standardHeaders: true,
  legacyHeaders: false,
});

// Strict rate limiting for sensitive endpoints
const strictLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // Limit each IP to 5 OTP requests per windowMs
  message: { error: 'Too many OTP requests from this IP, please try again later.' },
  standardHeaders: true,
  legacyHeaders: false,
});

// Request size limiting
app.use(express.json({ limit: '10kb' }));
app.use(express.urlencoded({ extended: true, limit: '10kb' }));

// HTTP Parameter Pollution protection
app.use(hpp());

// CORS configuration
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS ? process.env.ALLOWED_ORIGINS.split(',') : ['http://localhost:3000'],
  credentials: true
}));

// Apply general rate limiting
app.use(generalLimiter);

// IP blocking for suspicious requests
const blockedIPs = new Set();
const requestCounts = new Map();

// Track requests and block suspicious IPs
app.use((req, res, next) => {
  const clientIP = req.ip || req.connection.remoteAddress || req.socket.remoteAddress;
  
  // Block known malicious IPs
  if (blockedIPs.has(clientIP)) {
    return res.status(403).json({ error: 'IP address blocked' });
  }
  
  // Track request frequency
  const currentCount = requestCounts.get(clientIP) || 0;
  requestCounts.set(clientIP, currentCount + 1);
  
  // Auto-block IPs with excessive requests
  if (currentCount > 200) { // More than 200 requests in tracking window
    blockedIPs.add(clientIP);
    requestCounts.delete(clientIP);
    console.log(`IP blocked due to excessive requests: ${clientIP}`);
    return res.status(403).json({ error: 'IP address blocked due to suspicious activity' });
  }
  
  // Clean up old entries periodically
  if (Math.random() < 0.01) { // 1% chance to clean up
    requestCounts.clear();
  }
  
  next();
});

// Initialize Firebase Admin (Only if creds provided)
if (process.env.FIREBASE_PROJECT_ID && process.env.FIREBASE_CLIENT_EMAIL && process.env.FIREBASE_PRIVATE_KEY) {
  try {
    admin.initializeApp({
      credential: admin.credential.cert({
        projectId: process.env.FIREBASE_PROJECT_ID,
        clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
        // Robust key cleaning: handles quotes, escaped \n, and actual newlines
        privateKey: process.env.FIREBASE_PRIVATE_KEY
          .replace(/^"|"$/g, '')        // Remove accidental leading/trailing quotes
          .replace(/\\n/g, '\n'),       // Convert literal \n to actual newlines
      }),
    });
    console.log("Firebase Admin Initialized successfully.");
  } catch (error) {
    console.error("Firebase Admin Initialization Error:", error);
  }
} else {
  console.warn("Skipping Firebase Admin initialization - Credentials missing in .env");
}

// Configure Nodemailer
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

const otpCache = {};
const verifiedEmails = {}; // email -> timestamp

app.post('/api/send-otp', strictLimiter, async (req, res) => {
  const { email } = req.body;
  if (!email) return res.status(400).json({ error: 'Email is required' });

  const otp = Math.floor(100000 + Math.random() * 900000).toString();
  otpCache[email] = otp;

  try {
    const mailOptions = {
      from: `"UMak App Store" <${process.env.EMAIL_USER}>`,
      to: email,
      subject: 'Your 6-Digit Verification Code',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: auto;">
          <h2 style="color: #0056d2;">Verifying Details</h2>
          <p>Hello,</p>
          <p>Your 6-digit verification code is:</p>
          <div style="font-size: 32px; font-weight: bold; background: #f1f5f9; padding: 20px; text-align: center; border-radius: 8px; letter-spacing: 5px;">
            ${otp}
          </div>
          <p>Please enter this code in the UMak App Store to complete your action.</p>
          <p>If you didn't request this, you can ignore this email.</p>
        </div>
      `,
    };

    await transporter.sendMail(mailOptions);
    res.status(200).json({ message: 'Code sent successfully' });
  } catch (error) {
    console.error('Mail Error:', error);
    res.status(500).json({ error: 'Failed to send email' });
  }
});

app.post('/api/verify-otp', (req, res) => {
  const { email, otp } = req.body;
  if (otpCache[email] && otpCache[email] === otp) {
    delete otpCache[email];
    // Mark as verified for 10 minutes
    verifiedEmails[email] = Date.now() + (10 * 60 * 1000);
    res.status(200).json({ success: true });
  } else {
    res.status(400).json({ error: 'Invalid verification code' });
  }
});

// NEW: Endpoint to update password using custom OTP verification
app.post('/api/update-password', async (req, res) => {
  const { email, newPassword } = req.body;

  // 1. Check if email was verified recently
  const expiry = verifiedEmails[email];
  if (!expiry || Date.now() > expiry) {
    return res.status(401).json({ error: 'Session expired or email not verified. Please verify again.' });
  }

  try {
    if (!admin.apps.length) {
      throw new Error('Firebase Admin not initialized. Please check your .env credentials.');
    }

    const userRecord = await admin.auth().getUserByEmail(email);
    await admin.auth().updateUser(userRecord.uid, {
      password: newPassword
    });

    // Clear verification after success
    delete verifiedEmails[email];

    res.status(200).json({ message: 'Password updated successfully' });
  } catch (error) {
    console.error('Update Password Error:', error);
    res.status(500).json({
      error: 'Update failed',
      details: error.message
    });
  }
});

// Register device
app.post('/api/register-device', async (req, res) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const decodedToken = await admin.auth().verifyIdToken(token);
    const { deviceId, deviceInfo } = req.body;

    if (!deviceId) {
      return res.status(400).json({ error: 'Device ID is required' });
    }

    const userRef = admin.firestore().collection('users').doc(decodedToken.uid);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      return res.status(404).json({ error: 'User not found' });
    }

    const userData = userDoc.data();
    const currentDeviceId = userData.activeDeviceId;
    const currentDevice = userData.devices ? userData.devices[deviceId] : null;

    // Check if device is already active on another account
    if (currentDeviceId && currentDeviceId !== deviceId) {
      return res.status(403).json({ 
        error: 'Account is already active on another device',
        requiresReauth: true 
      });
    }

    // Register/update device
    const deviceData = {
      ...deviceInfo,
      deviceId,
      lastActive: new Date().toISOString(),
      registeredAt: currentDevice ? currentDevice.registeredAt : new Date().toISOString(),
      isActive: true
    };

    await userRef.update({
      activeDeviceId: deviceId,
      [`devices.${deviceId}`]: deviceData,
      lastDeviceChange: new Date().toISOString()
    });

    return res.status(200).json({ 
      message: 'Device registered successfully',
      deviceId,
      isActive: true
    });

  } catch (error) {
    console.error('Error registering device:', error);
    return res.status(500).json({ error: 'Failed to register device' });
  }
});

// Validate device
app.post('/api/validate-device', async (req, res) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const decodedToken = await admin.auth().verifyIdToken(token);
    const { deviceId } = req.body;

    if (!deviceId) {
      return res.status(400).json({ error: 'Device ID is required' });
    }

    const userDoc = await admin.firestore()
      .collection('users')
      .doc(decodedToken.uid)
      .get();

    if (!userDoc.exists) {
      return res.status(404).json({ error: 'User not found' });
    }

    const userData = userDoc.data();
    const activeDeviceId = userData.activeDeviceId;

    if (activeDeviceId !== deviceId) {
      // Deactivate current device if different
      await admin.firestore()
        .collection('users')
        .doc(decodedToken.uid)
        .update({
          [`devices.${deviceId}.isActive`]: false,
          lastDeviceDeactivation: new Date().toISOString()
        });

      return res.status(403).json({ 
        error: 'Device not authorized. Account is active on another device.',
        requiresReauth: true 
      });
    }

    // Update last active time
    await admin.firestore()
      .collection('users')
      .doc(decodedToken.uid)
      .update({
        [`devices.${deviceId}.lastActive`]: new Date().toISOString()
      });

    return res.status(200).json({ 
      message: 'Device validated successfully',
      isActive: true 
    });

  } catch (error) {
    console.error('Error validating device:', error);
    return res.status(500).json({ error: 'Failed to validate device' });
  }
});

// Revoke all devices
app.post('/api/revoke-all-devices', async (req, res) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const decodedToken = await admin.auth().verifyIdToken(token);
    const userRef = admin.firestore().collection('users').doc(decodedToken.uid);

    await userRef.update({
      activeDeviceId: null,
      devices: admin.firestore.FieldValue.delete(),
      lastDeviceRevoke: new Date().toISOString()
    });

    return res.status(200).json({ 
      message: 'All devices revoked successfully' 
    });

  } catch (error) {
    console.error('Error revoking devices:', error);
    return res.status(500).json({ error: 'Failed to revoke devices' });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log('Security features enabled:');
  console.log('- Rate limiting: Active');
  console.log('- Helmet security headers: Active');
  console.log('- Request size limiting: 10kb');
  console.log('- IP blocking: Active');
  
  // Simple update message for documentation
  console.log('\n=== API Documentation Update ===');
  console.log('Security configuration:');
  console.log('- Rate limiting: enabled');
  console.log('- Helmet: enabled');
  console.log('- HPP: enabled');
  console.log('- Payload limit: 10kb');
  console.log('- Timestamp: ' + new Date().toISOString());
  console.log('================================\n');
});
