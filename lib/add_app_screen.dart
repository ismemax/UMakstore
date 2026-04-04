import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/developer_service.dart';

class AddAppScreen extends StatefulWidget {
  const AddAppScreen({super.key});

  @override
  State<AddAppScreen> createState() => _AddAppScreenState();
}

class _AddAppScreenState extends State<AddAppScreen> {
  int _currentStep = 0;
  bool _isSaving = false;
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _titleController = TextEditingController();
  final _publisherController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _packageNameController = TextEditingController();
  final _versionController = TextEditingController();
  final _apkUrlController = TextEditingController();
  final _iconUrlController = TextEditingController();
  String _selectedCategory = 'Academic';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = colorScheme.surface;
    final accentColor = colorScheme.primary;
    final textColor = colorScheme.onSurface;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Deploy New App',
          style: GoogleFonts.lexend(
            fontWeight: FontWeight.bold,
            color: textColor,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildStepIndicator(accentColor, colorScheme),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: _buildStepContent(colorScheme),
              ),
            ),
          ),
          _buildBottomNavigation(accentColor, colorScheme),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(Color accent, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      child: Row(
        children: List.generate(3, (index) {
          bool isActive = index <= _currentStep;
          bool isCurrent = index == _currentStep;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isActive ? accent : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                    boxShadow: isCurrent ? [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ] : [],
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: GoogleFonts.lexend(
                        color: isActive ? Colors.white : colorScheme.onSurface.withValues(alpha: 0.3),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (index < 2)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: index < _currentStep ? accent : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent(ColorScheme colorScheme) {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfo(colorScheme);
      case 1:
        return _buildTechnicalDetails(colorScheme);
      case 2:
        return _buildAssets(colorScheme);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBasicInfo(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('App Basics', colorScheme),
        const SizedBox(height: 8),
        _buildInputField('APP TITLE', 'e.g. MakMessenger', _titleController, colorScheme),
        const SizedBox(height: 24),
        _buildInputField('PUBLISHER', 'e.g. Student Council', _publisherController, colorScheme),
        const SizedBox(height: 24),
        _buildInputField(
          'DESCRIPTION', 
          'Tell us what your app does...', 
          _descriptionController,
          colorScheme,
          maxLines: 5,
        ),
        const SizedBox(height: 24),
        _buildCategoryDropdown(colorScheme),
      ],
    );
  }

  Widget _buildTechnicalDetails(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Technical Specifications', colorScheme),
        const SizedBox(height: 8),
        _buildInputField('PACKAGE NAME', 'e.g. com.umak.messenger', _packageNameController, colorScheme),
        const SizedBox(height: 24),
        _buildInputField('VERSION', 'e.g. 1.0.0', _versionController, colorScheme),
        const SizedBox(height: 24),
        _buildInputField('APK DOWNLOAD URL', 'Direct link to your .apk file', _apkUrlController, colorScheme),
        const SizedBox(height: 24),
        _buildInfoBox('Make sure your APK link is publicly accessible for our review team.'),
      ],
    );
  }

  Widget _buildAssets(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('App Assets', colorScheme),
        const SizedBox(height: 8),
        _buildInputField('ICON URL', 'Link to your app icon (PNG/SVG)', _iconUrlController, colorScheme),
        const SizedBox(height: 32),
        Text(
          'SCREENSHOTS',
          style: GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface.withValues(alpha: 0.3),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildAddScreenshotCard(colorScheme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, ColorScheme colorScheme) {
    return Text(
      title,
      style: GoogleFonts.lexend(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
    );
  }

  Widget _buildInputField(String label, String hint, TextEditingController controller, ColorScheme colorScheme, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface.withValues(alpha: 0.4),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.lexend(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.2)),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(20),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CATEGORY',
          style: GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface.withValues(alpha: 0.4),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              dropdownColor: isDark ? colorScheme.surfaceContainer : colorScheme.surface,
              value: _selectedCategory,
              style: GoogleFonts.lexend(color: colorScheme.onSurface),
              items: ['Academic', 'Social', 'Utility', 'Gaming'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBox(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Colors.blueAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.lexend(
                fontSize: 13,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddScreenshotCard(ColorScheme colorScheme) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant, style: BorderStyle.solid),
      ),
      child: Center(
        child: Icon(Icons.add_photo_alternate_outlined, color: colorScheme.onSurface.withValues(alpha: 0.2), size: 32),
      ),
    );
  }

  Widget _buildBottomNavigation(Color accent, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5))),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: TextButton(
                onPressed: () => setState(() => _currentStep--),
                child: Text(
                  'Previous',
                  style: GoogleFonts.lexend(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: _isSaving ? null : () async {
                if (_currentStep < 2) {
                  setState(() => _currentStep++);
                } else {
                  // Final submission logic
                  setState(() => _isSaving = true);
                  try {
                    await DeveloperService().submitApp(
                      title: _titleController.text,
                      publisher: _publisherController.text,
                      description: _descriptionController.text,
                      category: _selectedCategory,
                      apkUrl: _apkUrlController.text,
                      packageName: _packageNameController.text,
                      version: _versionController.text,
                      iconUrl: _iconUrlController.text,
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('App submitted successfully!')),
                      );
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  } finally {
                    if (mounted) setState(() => _isSaving = false);
                  }
                }
              },
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: _isSaving 
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        _currentStep == 2 ? 'Submit Application' : 'Continue',
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
