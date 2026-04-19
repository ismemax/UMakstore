import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/developer_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddAppScreen extends StatefulWidget {
  final Map<String, dynamic>? appData;
  const AddAppScreen({super.key, this.appData});

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
  final _iconUrlController = TextEditingController(); // Stores the Cloudinary URL
  bool _isUploadingIcon = false;
  bool _isUploadingScreenshot = false;
  String _selectedCategory = 'Academic';
  String _selectedCollege = 'University-wide';
  List<String> _screenshotUrls = [];
  final _permissionsController = TextEditingController();

  final List<String> _colleges = [
    'University-wide',
    'CBFS - College of Business and Financial Sciences',
    'CITE - College of Innovative Teacher Education',
    'CTHM - College of Tourism and Hospitality Management',
    'SOL - School of Law',
    'CCIS - College of Computer and Information Science',
    'CCAPS - College of Continuing, Advanced and Professional Studies',
    'CET - College of Engineering and Technology',
    'IAD - Institute of Accountancy',
    'IOA - Institute of Architecture',
    'CHK - College of Human Kinetics',
    'IDEM - Institute of Design and Engineering Management',
    'ISW - Institute of Social Work',
    'IOP - Institute of Pharmacy',
    'ITEST - Institute of Technology and Entrepreneurship Studies',
    'IOPsy - Institute of Psychology',
    'IIHS - Institute of Integrated Health Sciences',
    'CGPP - College of Governance and Public Policy',
    'CCSE - College of Computing and Software Engineering',
    'ION - Institute of Nursing',
  ];

  bool get _isEditing => widget.appData != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final data = widget.appData!;
      _titleController.text = data['title'] ?? '';
      _publisherController.text = data['publisher'] ?? '';
      _descriptionController.text = data['description'] ?? '';
      _packageNameController.text = data['packageName'] ?? '';
      _versionController.text = data['version'] ?? '';
      _apkUrlController.text = data['downloadUrl'] ?? '';
      _iconUrlController.text = data['iconUrl'] ?? '';
      _screenshotUrls = List<String>.from(data['screenshots'] ?? []);
      if (['Academic', 'Social', 'Utility', 'Gaming'].contains(data['category'])) {
        _selectedCategory = data['category'];
      }
      if (data['college'] != null && _colleges.contains(data['college'])) {
        _selectedCollege = data['college'];
      }
      _permissionsController.text = (data['permissions'] as List?)?.join(', ') ?? '';
    }
  }

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
          _isEditing ? 'Edit Application' : 'Deploy New App',
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
        const SizedBox(height: 24),
        _buildCollegeDropdown(colorScheme),
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
        _buildInputField('REQUESTED PERMISSIONS', 'e.g. Camera, Location, Storage (Optional, Comma separated)', _permissionsController, colorScheme),
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
        _buildIconUploadField(colorScheme),
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
              ..._screenshotUrls.map((url) => _buildScreenshotItem(url, colorScheme)),
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
        _buildDropdownLabel('CATEGORY', colorScheme),
        const SizedBox(height: 12),
        _buildDropdown(
          value: _selectedCategory,
          items: ['Academic', 'Social', 'Utility', 'Gaming'],
          onChanged: (val) {
            if (val != null) setState(() => _selectedCategory = val);
          },
          colorScheme: colorScheme,
        ),
      ],
    );
  }

  Widget _buildCollegeDropdown(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdownLabel('TARGET COLLEGE', colorScheme),
        const SizedBox(height: 12),
        _buildDropdown(
          value: _selectedCollege,
          items: _colleges,
          onChanged: (val) {
            if (val != null) setState(() => _selectedCollege = val);
          },
          colorScheme: colorScheme,
        ),
      ],
    );
  }

  Widget _buildDropdownLabel(String label, ColorScheme colorScheme) {
    return Text(
      label,
      style: GoogleFonts.lexend(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface.withValues(alpha: 0.4),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required ColorScheme colorScheme,
  }) {
    final isDark = colorScheme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          dropdownColor: isDark ? colorScheme.surfaceContainer : colorScheme.surface,
          value: value,
          style: GoogleFonts.lexend(color: colorScheme.onSurface),
          items: items.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(val, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
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

  Widget _buildScreenshotItem(String url, ColorScheme colorScheme) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: CachedNetworkImageProvider(DeveloperService.getOptimizedUrl(url, width: 400)),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 8,
            top: 8,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _screenshotUrls.remove(url);
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddScreenshotCard(ColorScheme colorScheme) {
    return GestureDetector(
      onTap: _isUploadingScreenshot ? null : () => _pickAndUploadScreenshot(colorScheme),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: colorScheme.onSurface.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant, style: BorderStyle.solid),
        ),
        child: Center(
          child: _isUploadingScreenshot 
            ? CircularProgressIndicator(color: colorScheme.primary, strokeWidth: 2)
            : Icon(Icons.add_photo_alternate_outlined, color: colorScheme.onSurface.withValues(alpha: 0.2), size: 32),
        ),
      ),
    );
  }

  Widget _buildIconUploadField(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'APP ICON',
          style: GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface.withValues(alpha: 0.4),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _isUploadingIcon ? null : _pickAndUploadIcon,
          child: Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            clipBehavior: Clip.antiAlias,
            child: _isUploadingIcon
                ? Center(child: CircularProgressIndicator(color: colorScheme.primary, strokeWidth: 2))
                : _iconUrlController.text.startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: DeveloperService.getOptimizedUrl(_iconUrlController.text, width: 200, height: 200),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: colorScheme.surface),
                        errorWidget: (context, url, error) => Icon(Icons.broken_image, color: colorScheme.outline),
                      )
                    : Center(
                        child: Icon(
                          Icons.add_a_photo_outlined,
                          color: colorScheme.onSurface.withValues(alpha: 0.2),
                          size: 32,
                        ),
                      ),
          ),
        ),
        if (_iconUrlController.text.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Keep it simple and recognizable.',
            style: GoogleFonts.lexend(fontSize: 12, color: colorScheme.onSurface.withValues(alpha: 0.3)),
          ),
        ],
      ],
    );
  }

  Future<void> _pickAndUploadIcon() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() => _isUploadingIcon = true);
      try {
        final url = await DeveloperService().uploadToCloudinary(File(image.path));
        setState(() {
          _iconUrlController.text = url;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
        }
      } finally {
        if (mounted) setState(() => _isUploadingIcon = false);
      }
    }
  }

  Future<void> _pickAndUploadScreenshot(ColorScheme colorScheme) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() => _isUploadingScreenshot = true);
      try {
        final url = await DeveloperService().uploadToCloudinary(File(image.path));
        setState(() {
          _screenshotUrls.add(url);
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
        }
      } finally {
        if (mounted) setState(() => _isUploadingScreenshot = false);
      }
    }
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
                    final permissionsList = _permissionsController.text.split(',')
                        .map((p) => p.trim())
                        .where((p) => p.isNotEmpty)
                        .toList();

                    // MAK Guard: Check for duplicate package name
                    final isTaken = await DeveloperService().isPackageNameTaken(
                      _packageNameController.text,
                      excludeAppId: _isEditing ? widget.appData!['id'] : null,
                    );

                    if (isTaken) {
                      throw 'Package Name "${_packageNameController.text}" is already registered to another app. Please use a unique ID.';
                    }

                    if (_isEditing) {
                      await DeveloperService().updateApp(
                        appId: widget.appData!['id'],
                        title: _titleController.text,
                        publisher: _publisherController.text,
                        description: _descriptionController.text,
                        category: _selectedCategory,
                        college: _selectedCollege,
                        apkUrl: _apkUrlController.text,
                        packageName: _packageNameController.text,
                        version: _versionController.text,
                        iconUrl: _iconUrlController.text,
                        screenshotUrls: _screenshotUrls,
                        permissions: permissionsList,
                      );
                    } else {
                      await DeveloperService().submitApp(
                        title: _titleController.text,
                        publisher: _publisherController.text,
                        description: _descriptionController.text,
                        category: _selectedCategory,
                        college: _selectedCollege,
                        apkUrl: _apkUrlController.text,
                        packageName: _packageNameController.text,
                        version: _versionController.text,
                        iconUrl: _iconUrlController.text,
                        screenshotUrls: _screenshotUrls,
                        permissions: permissionsList,
                      );
                    }
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(_isEditing ? 'App updated successfully!' : 'App submitted successfully!')),
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
                        _currentStep == 2 
                          ? (_isEditing ? 'Update Application' : 'Submit Application') 
                          : 'Continue',
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
