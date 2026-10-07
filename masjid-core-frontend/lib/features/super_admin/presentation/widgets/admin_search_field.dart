import 'dart:async';

import 'package:flutter/material.dart';

/// Search box that reports the trimmed text after typing pauses.
class AdminSearchField extends StatefulWidget {
  const AdminSearchField({
    super.key,
    required this.label,
    required this.onSearch,
    this.initialValue = '',
    this.hint,
  });

  final String label;
  final String? hint;
  final String initialValue;
  final ValueChanged<String> onSearch;

  @override
  State<AdminSearchField> createState() => _AdminSearchFieldState();
}

class _AdminSearchFieldState extends State<AdminSearchField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => widget.onSearch(value.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
        ),
        onChanged: _onChanged,
      ),
    );
  }
}
