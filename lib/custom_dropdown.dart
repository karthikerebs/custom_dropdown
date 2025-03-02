import 'package:flutter/material.dart';

/// A highly customizable dropdown component with modern styling
/// that adapts to the app's theme while allowing complete customization.
class CustomDropdown<T> extends StatefulWidget {
  /// The currently selected value
  final T? value;

  /// List of items to display in dropdown
  final List<T> items;

  /// Callback when value changes
  final void Function(T?)? onChanged;

  /// How to display each item
  final String Function(T) displayStringFor;

  /// Hint text when no item is selected
  final String hintText;

  /// Label text above the dropdown
  final String labelText;

  /// Width of the dropdown
  final double width;

  /// Custom icon for the dropdown button
  final Widget? icon;

  /// Custom suffix icon to display after the dropdown arrow
  final Widget? suffixIcon;

  /// Custom prefix icon to display at the start of the dropdown field
  final Widget? prefixIcon;

  /// Padding around the prefix icon
  final EdgeInsetsGeometry prefixIconPadding;

  /// Whether to show the dropdown arrow icon
  final bool showDropdownIcon;

  /// Spacing between dropdown arrow and suffix icon (if both are present)
  final double iconSpacing;

  /// Vertical margin around the dropdown
  final double verticalMargin;

  /// Horizontal margin around the dropdown
  final double horizontalMargin;

  /// Whether the dropdown is enabled
  final bool isEnabled;

  /// Validation function
  final String? Function(T?)? validator;

  /// Custom decoration theme
  final InputDecoration? decoration;

  /// Text style for dropdown items
  final TextStyle? itemStyle;

  /// Background color for dropdown menu
  final Color? dropdownColor;

  /// Color for the dropdown icon when enabled
  final Color? iconEnabledColor;

  /// Color for the dropdown icon when disabled
  final Color? iconDisabledColor;

  /// Style for the dropdown button

  /// Elevation for dropdown menu
  final int? elevation;

  /// Menu maximum height
  final double? menuMaxHeight;

  /// Whether to automatically focus this dropdown
  final bool autofocus;

  /// Focus node for controlling focus
  final FocusNode? focusNode;

  /// Alignment of the dropdown menu
  final AlignmentGeometry alignment;

  /// Border radius of dropdown menu items
  final BorderRadius? borderRadius;

  /// Whether to show a subtle hover effect on items
  final bool enableHover;

  /// Custom styling for the selected item
  final TextStyle? selectedItemStyle;

  /// Custom text style for the dropdown button text
  final TextStyle? buttonTextStyle;

  /// Custom shadow for the dropdown menu
  final List<BoxShadow>? dropdownShadow;

  /// Padding for dropdown menu items
  final EdgeInsetsGeometry? itemPadding;

  const CustomDropdown({
    super.key,
    required this.items,
    required this.displayStringFor,
    this.value,
    this.onChanged,
    this.hintText = 'Select an option',
    this.labelText = '',
    this.width = double.infinity,
    this.icon,
    this.suffixIcon,
    this.prefixIcon,
    this.prefixIconPadding = const EdgeInsets.only(left: 12, right: 8),
    this.showDropdownIcon = true,
    this.iconSpacing = 8,
    this.verticalMargin = 16,
    this.horizontalMargin = 0,
    this.isEnabled = true,
    this.validator,
    this.decoration,
    this.itemStyle,
    this.selectedItemStyle,
    this.buttonTextStyle,
    this.dropdownColor,
    this.iconEnabledColor,
    this.iconDisabledColor,
    this.elevation,
    this.menuMaxHeight,
    this.autofocus = false,
    this.focusNode,
    this.alignment = AlignmentDirectional.centerStart,
    this.borderRadius,
    this.enableHover = true,
    this.dropdownShadow,
    this.itemPadding,
  });

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Use provided styles or fallback to current theme
    final TextStyle effectiveItemStyle =
        widget.itemStyle ??
        theme.textTheme.bodyMedium ??
        const TextStyle(fontSize: 14);

    final TextStyle effectiveSelectedItemStyle =
        widget.selectedItemStyle ??
        effectiveItemStyle.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w500,
        );

    final TextStyle effectiveButtonTextStyle =
        widget.buttonTextStyle ?? effectiveItemStyle;

    final Color effectiveDropdownColor =
        widget.dropdownColor ?? theme.colorScheme.surface;

    final Color effectiveIconEnabledColor =
        widget.iconEnabledColor ?? theme.colorScheme.primary;

    final Color effectiveIconDisabledColor =
        widget.iconDisabledColor ?? theme.disabledColor;

    // Get default border radius from theme or use fallback
    final BorderRadius defaultBorderRadius = BorderRadius.circular(
      _getBorderRadiusFromTheme(theme) ?? 8.0,
    );

    // Create dropdown icon if needed
    final Widget? dropdownIcon =
        widget.showDropdownIcon
            ? (widget.icon ??
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color:
                      widget.isEnabled
                          ? effectiveIconEnabledColor
                          : effectiveIconDisabledColor,
                  size: 24,
                ))
            : null;

    // Custom decoration to combine prefix, suffix, and dropdown icons
    InputDecoration buildDecoration() {
      // Start with base decoration (either provided or default)
      InputDecoration baseDecoration =
          widget.decoration ??
          InputDecoration(
            hintText: widget.hintText,
            labelText: widget.labelText,
            contentPadding: EdgeInsets.symmetric(
              horizontal: widget.prefixIcon != null ? 0 : 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(borderRadius: defaultBorderRadius),
            isDense: true,
          );

      // Handle prefix icon
      if (widget.prefixIcon != null) {
        baseDecoration = baseDecoration.copyWith(
          prefixIcon: Padding(
            padding: widget.prefixIconPadding,
            child: widget.prefixIcon,
          ),
          // Adjust contentPadding when prefix icon is present
          contentPadding:
              baseDecoration.contentPadding is EdgeInsets
                  ? (baseDecoration.contentPadding as EdgeInsets).copyWith(
                    left: 0, // Let the prefix icon handle left padding
                  )
                  : EdgeInsets.only(right: 16, top: 14, bottom: 14),
        );
      }

      // Handle suffix and dropdown icons
      if (widget.suffixIcon != null && !widget.showDropdownIcon) {
        return baseDecoration.copyWith(suffixIcon: widget.suffixIcon);
      } else if (widget.suffixIcon != null && widget.showDropdownIcon) {
        return baseDecoration.copyWith(suffixIcon: _buildCombinedIcons());
      }

      // Return the updated decoration
      return baseDecoration;
    }

    final InputDecoration effectiveDecoration = buildDecoration();

    return Container(
      width: widget.width,
      margin: EdgeInsets.symmetric(
        vertical: widget.verticalMargin,
        horizontal: widget.horizontalMargin,
      ),
      child: DropdownButtonFormField<T>(
        value: widget.value,
        items:
            widget.items.map((T item) {
              final bool isSelected = widget.value == item;
              return DropdownMenuItem<T>(
                value: item,
                alignment: widget.alignment,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    widget.displayStringFor(item),
                    style:
                        isSelected
                            ? effectiveSelectedItemStyle
                            : effectiveItemStyle,
                  ),
                ),
              );
            }).toList(),
        onChanged: widget.isEnabled ? widget.onChanged : null,
        validator: widget.validator,
        decoration: effectiveDecoration,
        // Only show the dropdown icon if there's no suffix icon, otherwise we handle it in the decoration
        icon: widget.suffixIcon != null ? null : dropdownIcon,
        style: effectiveButtonTextStyle,
        isExpanded: true,
        dropdownColor: effectiveDropdownColor,
        iconEnabledColor: effectiveIconEnabledColor,
        iconDisabledColor: effectiveIconDisabledColor,
        elevation: widget.elevation ?? 4,
        menuMaxHeight: widget.menuMaxHeight,
        autofocus: widget.autofocus,
        focusNode: widget.focusNode,
        borderRadius: widget.borderRadius ?? defaultBorderRadius,
        // Add hint alignment to match text alignment
        hint:
            widget.hintText.isNotEmpty
                ? Align(
                  alignment: widget.alignment,
                  child: Text(
                    widget.hintText,
                    style: theme.inputDecorationTheme.hintStyle,
                  ),
                )
                : null,
      ),
    );
  }

  /// Builds a row containing both the dropdown icon and the suffix icon
  Widget _buildCombinedIcons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Suffix icon
        if (widget.suffixIcon != null) widget.suffixIcon!,
        // Spacing between icons
        if (widget.suffixIcon != null && widget.showDropdownIcon)
          SizedBox(width: widget.iconSpacing),
        // Dropdown arrow icon
        if (widget.showDropdownIcon)
          widget.icon ??
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color:
                    widget.isEnabled
                        ? widget.iconEnabledColor ??
                            Theme.of(context).colorScheme.primary
                        : widget.iconDisabledColor ??
                            Theme.of(context).disabledColor,
                size: 24,
              ),
        // Extra padding to ensure icon doesn't get cut off
        SizedBox(width: 4),
      ],
    );
  }

  /// Helper method to safely extract border radius from the theme
  double? _getBorderRadiusFromTheme(ThemeData theme) {
    // First check if InputDecorationTheme has OutlineInputBorder
    if (theme.inputDecorationTheme.border is OutlineInputBorder) {
      final border = theme.inputDecorationTheme.border as OutlineInputBorder;
      return border.borderRadius.topLeft.x;
    }

    // Check for the Material 3 shape properties
    return theme.materialTapTargetSize == MaterialTapTargetSize.padded
        ? 8.0 // Modern default border radius
        : null;
  }
}
