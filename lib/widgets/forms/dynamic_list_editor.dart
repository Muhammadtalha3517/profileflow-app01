import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class DynamicListEditor extends StatefulWidget {
  final String label;
  final String hintText;
  final List<String> initialItems;
  final ValueChanged<List<String>> onItemsChanged;

  const DynamicListEditor({
    Key? key,
    required this.label,
    required this.hintText,
    required this.initialItems,
    required this.onItemsChanged,
  }) : super(key: key);

  @override
  State<DynamicListEditor> createState() => _DynamicListEditorState();
}

class _DynamicListEditorState extends State<DynamicListEditor> {
  late List<String> _items;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.initialItems);
  }

  void _addItem() {
    final text = _textController.text.trim();
    if (text.isNotEmpty && !_items.contains(text)) {
      setState(() {
        _items.add(text);
        _textController.clear();
      });
      widget.onItemsChanged(_items);
    }
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
    widget.onItemsChanged(_items);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  onSubmitted: (_) => _addItem(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addItem,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  padding: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Icon(Icons.add, size: 20),
              ),
            ],
          ),
          if (_items.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_items.length, (index) {
                return Chip(
                  label: Text(_items[index]),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => _removeItem(index),
                  backgroundColor: AppColors.primaryLight.withOpacity(0.3),
                  side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryDark,
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }
}
