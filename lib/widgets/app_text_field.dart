part of '../main.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.controller,
    required this.label,
    this.icon,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.showPrefixIcon = false,
    this.suffix,
    this.validator,
    super.key,
  });

  final TextEditingController controller;
  final IconData? icon;
  final String label;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool showPrefixIcon;
  final Widget? suffix;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1E1E1E),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 7),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            validator: validator,
            style: const TextStyle(
              color: Color(0xFF252525),
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              prefixIcon: showPrefixIcon && icon != null
                  ? Icon(icon, color: const Color(0xFF9C9C9C))
                  : null,
              suffixIcon: suffix,
              hintText: hintText,
              hintStyle: const TextStyle(
                color: Color(0xFF969696),
                fontWeight: FontWeight.w500,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 17,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(
                  color: Color(0xFFDCDCDC),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(
                  color: Color(0xFF6693E7),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: Colors.redAccent),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: Colors.redAccent, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
