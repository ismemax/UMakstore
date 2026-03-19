import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePhotoBottomSheet extends StatelessWidget {
  const ProfilePhotoBottomSheet({super.key});

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (pickedFile != null && context.mounted) {
        Navigator.of(context).pop(File(pickedFile.path));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 50,
            offset: Offset(0, -25),
          ),
        ],
      ),
      padding: const EdgeInsets.only(top: 12, left: 24, right: 24, bottom: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xffd1d5db),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Header title & close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Change Profile Photo',
                style: GoogleFonts.lexend(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff001f3f),
                  letterSpacing: -0.5,
                ),
              ),
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(24),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.close_rounded, color: Color(0xff94a3b8), size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Action Squares
          Row(
            children: [
              Expanded(
                child: _buildActionSquare(
                  icon: Icons.camera_alt_outlined,
                  label: 'Take Photo',
                  onTap: () => _pickImage(context, ImageSource.camera),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionSquare(
                  icon: Icons.photo_library_outlined,
                  label: 'From Gallery',
                  onTap: () => _pickImage(context, ImageSource.gallery),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Divider
          Container(
            height: 1,
            color: const Color(0xfff3f4f6),
          ),
          const SizedBox(height: 8),

          // Remove Action
          InkWell(
            onTap: () {
              Navigator.pop(context, 'REMOVE');
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.delete_outline_rounded, color: Color(0xffdc2626), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Remove Current Photo',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xffdc2626),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSquare({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 144,
        decoration: BoxDecoration(
          color: const Color(0xfff9fafb),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xfff3f4f6)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xffe8eaf6),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  )
                ],
              ),
              child: Center(
                child: Icon(icon, color: const Color(0xff001f3f), size: 24),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xff001f3f),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
