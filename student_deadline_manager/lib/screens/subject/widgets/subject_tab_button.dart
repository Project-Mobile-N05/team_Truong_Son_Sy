import 'package:flutter/material.dart';

const _primary = Color(0xFF5147BD);

class SubjectTabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const SubjectTabButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: onTap,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: selected ? _primary : Colors.white,
            borderRadius: BorderRadius.circular(11),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : const Color(0xFF5A5C72),
            ),
          ),
        ),
      ),
    );
  }
}
