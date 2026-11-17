import 'package:flutter/material.dart';

class BannerSlider extends StatefulWidget {
  final List<Widget> banners;
  final double height;

  const BannerSlider({
    super.key,
    required this.banners,
    this.height = 160,
  });

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });
            },
            children: widget.banners,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.banners.length,
            (index) {
              final isActive = currentPage == index;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 20 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF1976D2)
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
