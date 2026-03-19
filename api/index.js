const express = require('express');
const nodemailer = require('nodemailer');
const cors = require('cors');
const admin = require('firebase-admin');
require('dotenv').config();

const app = express();
app.use(express.json());
app.use(cors());

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

app.post('/api/send-otp', async (req, res) => {
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

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
