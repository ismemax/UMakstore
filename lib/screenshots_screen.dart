import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScreenshotsScreen extends StatelessWidget {
  final String appName;
  final List<String>? screenshots;
  final List<Color>? placeholderColors;

  const ScreenshotsScreen({
    super.key,
    this.appName = 'App',
    this.screenshots,
    this.placeholderColors,
  });

  @override
  Widget build(BuildContext context) {
    // Default placeholder colors if no screenshots or colors are provided
    final List<Color> colors =
        placeholderColors ??
        [
          const Color(0xfffef3c7), // Yellow
          const Color(0xfffee2e2), // Orange/Peach
          const Color(0xfff8fafc), // Grey/White
          const Color(0xfffee2e2), // Orange/Peach
          const Color(0xfffef3c7), // Yellow
          const Color(0xfffee2e2), // Orange/Peach
        ];

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: AppBar(
              backgroundColor: Colors.white.withValues(alpha: 0.95),
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(
                  Icons.chevron_left_rounded,
                  color: Color(0xff0f172a),
                  size: 28,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Screenshots',
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff0f172a),
                ),
              ),
              shape: const Border(
                bottom: BorderSide(color: Color(0xfff1f5f9), width: 1),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 80 + 24, 16, 40),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 32,
                childAspectRatio: 9 / 19,
              ),
              itemCount: screenshots?.length ?? colors.length,
              itemBuilder: (context, index) {
                return _buildScreenshotCard(
                  context,
                  screenshots != null ? null : colors[index],
                  screenshots != null ? screenshots![index] : null,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Text(
              'Showing all ${screenshots?.length ?? colors.length} screenshots',
              style: GoogleFonts.lexend(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xff0f172a).withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenshotCard(
    BuildContext context,
    Color? bgColor,
    String? imageUrl,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor ?? const Color(0xfff8fafc),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffe2e8f0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (imageUrl != null)
            Positioned.fill(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(
                    Icons.broken_image_rounded,
                    color: Color(0xff94a3b8),
                  ),
                ),
              ),
            )
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(1),
                child: _buildMockupContent(bgColor),
              ),
            ),
          // Subtle highlight/shadow overlay to simulate screen depth
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockupContent(Color? bgColor) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 80,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 8,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
