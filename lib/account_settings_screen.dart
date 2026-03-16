import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'change_password_screen.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xff1a3b5d)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Account Settings',
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xff1a3b5d),
            letterSpacing: -0.45,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xfff3f4f6),
            height: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 128,
                          height: 128,
                          decoration: BoxDecoration(
                            color: const Color(0xfffad9c1), // Matches the Figma screenshot
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1A000000),
                                blurRadius: 15,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.person, size: 80, color: Colors.white),
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xff2094f3),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x1A000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Change Profile Photo',
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff2094f3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              // PERSONAL INFORMATION Section
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 16.0),
                child: Text(
                  'PERSONAL INFORMATION',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff1a3b5d).withValues(alpha: 0.7),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              _buildTextField('First Name', 'Juan'),
              const SizedBox(height: 16),
              _buildTextField('Middle Initial', 'D.'),
              const SizedBox(height: 16),
              _buildTextField('Last Name', 'Cruz'),
              
              const SizedBox(height: 40),
              
              // SECURITY Section
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 16.0),
                child: Text(
                  'SECURITY',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff1a3b5d).withValues(alpha: 0.7),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xfff8fafc),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xffe5e7eb)),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0D000000),
                                  blurRadius: 2,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.restore_rounded, color: Color(0xff1a3b5d), size: 20),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Change Password',
                              style: GoogleFonts.lexend(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xff102a43),
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: Color(0xff94a3b8), size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Action Buttons
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xff2094f3),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x332094f3),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Text(
                    'Save Changes',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xffe5e7eb)), // Using border color since it matches design cleanly
                  ),
                  child: Text(
                    'Cancel',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff1a3b5d),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
      decoration: BoxDecoration(
        color: const Color(0xfff8fafc),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffe5e7eb)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xff1a3b5d),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.lexend(
              fontSize: 16,
              color: const Color(0xff102a43),
            ),
          ),
        ],
      ),
    );
  }
}
