// lib/screens/main_layout.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chatbot_provider.dart';
import '../widgets/navigation/side_nav_rail.dart';
import '../widgets/chatbot/chatbot_button.dart';
import '../widgets/chatbot/chatbot_ui.dart';

class MainLayout extends ConsumerStatefulWidget {
  final Widget child;

  const MainLayout({Key? key, required this.child}) : super(key: key);

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  int _selectedIndex = 0;
  OverlayEntry? _chatbotOverlayEntry;

  @override
void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSelectedIndex();
  }

  // No initState needed for ref.listen with this pattern
  // @override
  // void initState() {
  //   super.initState();
  //   ref.listen<bool>(chatbotProvider.select((state) => state.isOpen), (previous, next) {
  //     if (next) {
  //       _showChatbotOverlay();
  //     } else {
  //       _hideChatbotOverlay();
  //     }
  //   });
  // }

  void _updateSelectedIndex() {
    final String location = GoRouterState.of(context).matchedLocation;
    int newIndex = _selectedIndex;

    if (location.startsWith('/market_rates')) {
      newIndex = 1;
    } else if (location.startsWith('/vin-lookup')) {
      newIndex = 2;
    } else if (location.startsWith('/contract_analysis')) {
      newIndex = 3;
    } else {
      newIndex = 0;
    }

    if (newIndex != _selectedIndex) {
      setState(() {
        _selectedIndex = newIndex;
      });
    }
  }

  void _showChatbotOverlay() {
    if (_chatbotOverlayEntry == null) {
      _chatbotOverlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          bottom: 80,
          right: 20,
          child: Material(
            color: Colors.transparent,
            child: ChatbotUI(),
          ),
        ),
      );
      Overlay.of(context).insert(_chatbotOverlayEntry!);
    }
  }

  void _hideChatbotOverlay() {
    _chatbotOverlayEntry?.remove();
    _chatbotOverlayEntry = null;
  }

  @override
  void dispose() {
    _hideChatbotOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the chatbot state to conditionally show/hide the overlay
    final bool isChatbotOpen = ref.watch(chatbotProvider.select((state) => state.isOpen));

    // Use WidgetsBinding.instance.addPostFrameCallback to safely modify Overlay
    // outside of the build phase, reacting to changes in isChatbotOpen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isChatbotOpen) {
        _showChatbotOverlay();
      } else {
        _hideChatbotOverlay();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Autofinance Guardian'),
      ),
      body: Row(
        children: [
          SideNavRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              if (index == 0) {
                context.go('/');
              } else if (index == 1) {
                context.go('/market_rates');
              } else if (index == 2) {
                context.go('/vin-lookup');
              } else if (index == 3) { // New index for Contract Analysis
                context.go('/contract_analysis');
              }
            },
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: widget.child),
        ],
      ),
      floatingActionButton: const ChatbotButton(),
    );
  }
}