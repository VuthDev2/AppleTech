import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconly/iconly.dart';

import '../../main.dart';
import 'admin_widgets.dart';

class ProductsView extends StatelessWidget {
  const ProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          AdminSliverHeader(
            title: 'Products',
            subtitle: 'Manage catalog & inventory.',
            trailingActions: [
              _AddProductButton(context: context),
            ],
          ),
          _buildProductList(context),
          const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
        ],
      ),
    );
  }

  Widget _buildProductList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .orderBy('name')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SliverFillRemaining(
            child: _EmptyProducts(),
          );
        }

        final docs = snapshot.data!.docs;
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return SliverPadding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl, vertical: AppSpacing.md),
          sliver: SliverList.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              return _ProductRow(
                doc: doc,
                data: data,
                isDark: isDark,
                theme: theme,
              );
            },
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add Product FAB-style button in the header trailing slot
// ─────────────────────────────────────────────────────────────────────────────

class _AddProductButton extends StatelessWidget {
  final BuildContext context;
  const _AddProductButton({required this.context});

  @override
  Widget build(BuildContext _) {
    return GestureDetector(
      onTap: () => _showAddProductSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, Color(0xFF0055CC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.full),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: Colors.white, size: 16),
            SizedBox(width: 4),
            Text(
              'Add',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Product Row Card
// ─────────────────────────────────────────────────────────────────────────────

class _ProductRow extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  final Map<String, dynamic> data;
  final bool isDark;
  final ThemeData theme;

  const _ProductRow({
    required this.doc,
    required this.data,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final name = (data['name'] as String?) ?? 'Unnamed';
    final price = data['price'];
    final imageUrl = data['imageUrl'] as String?;
    final category = (data['category'] as String?) ?? '';
    final inStock = (data['inStock'] as bool?) ?? true;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor.withOpacity(0.85) : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.06),
        ),
        boxShadow: isDark ? [] : appShadowSm,
      ),
      child: Row(
        children: [
          // Product image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppRadius.xl),
              bottomLeft: Radius.circular(AppRadius.xl),
            ),
            child: Container(
              width: 76,
              height: 80,
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : AppColors.lightGray,
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        IconlyLight.image,
                        color: AppColors.mediumGray,
                      ),
                    )
                  : const Icon(
                      IconlyLight.image,
                      color: AppColors.mediumGray,
                    ),
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      // In-stock badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: inStock
                              ? AppColors.success.withOpacity(0.12)
                              : AppColors.error.withOpacity(0.12),
                          borderRadius:
                              BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          inStock ? 'In Stock' : 'Out',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: inStock
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  if (category.isNotEmpty)
                    Text(
                      category,
                      style: theme.textTheme.bodySmall,
                    ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        price != null ? '\$$price' : '—',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const Spacer(),
                      // Edit button
                      _ActionButton(
                        icon: IconlyLight.edit,
                        color: AppColors.primary,
                        onTap: () => _showEditProductSheet(context, doc, data),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      // Delete button
                      _ActionButton(
                        icon: IconlyLight.delete,
                        color: AppColors.error,
                        onTap: () => _confirmDelete(context, doc),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small icon action button
// ─────────────────────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 17, color: color),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyProducts extends StatelessWidget {
  const _EmptyProducts();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.04),
              shape: BoxShape.circle,
            ),
            child: Icon(
              IconlyLight.bag,
              size: 40,
              color: isDark ? Colors.white38 : Colors.black26,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'No products yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Tap the Add button to add a product.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add Product bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

void _showAddProductSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ProductFormSheet(existingData: null, docId: null),
  );
}

void _showEditProductSheet(
    BuildContext context, QueryDocumentSnapshot doc, Map<String, dynamic> data) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) =>
        _ProductFormSheet(existingData: data, docId: doc.id),
  );
}

Future<void> _confirmDelete(
    BuildContext context, QueryDocumentSnapshot doc) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete Product'),
      content: const Text(
          'Are you sure you want to delete this product? This cannot be undone.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: FilledButton.styleFrom(
              backgroundColor: AppColors.error),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (confirmed == true) {
    await doc.reference.delete();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Product form (Add / Edit)
// ─────────────────────────────────────────────────────────────────────────────

class _ProductFormSheet extends StatefulWidget {
  final Map<String, dynamic>? existingData;
  final String? docId;

  const _ProductFormSheet({
    required this.existingData,
    required this.docId,
  });

  @override
  State<_ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<_ProductFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _imageCtrl;
  late final TextEditingController _descCtrl;
  bool _inStock = true;
  bool _saving = false;

  bool get isEditing => widget.existingData != null;

  @override
  void initState() {
    super.initState();
    final d = widget.existingData;
    _nameCtrl =
        TextEditingController(text: d != null ? (d['name'] ?? '') : '');
    _priceCtrl =
        TextEditingController(text: d != null ? '${d['price'] ?? ''}' : '');
    _categoryCtrl =
        TextEditingController(text: d != null ? (d['category'] ?? '') : '');
    _imageCtrl =
        TextEditingController(text: d != null ? (d['imageUrl'] ?? '') : '');
    _descCtrl =
        TextEditingController(text: d != null ? (d['description'] ?? '') : '');
    _inStock = d != null ? (d['inStock'] ?? true) as bool : true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _categoryCtrl.dispose();
    _imageCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final payload = {
      'name': _nameCtrl.text.trim(),
      'price': int.tryParse(_priceCtrl.text.trim()) ?? 0,
      'category': _categoryCtrl.text.trim(),
      'imageUrl': _imageCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'inStock': _inStock,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      if (isEditing) {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.docId)
            .update(payload);
      } else {
        payload['createdAt'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance
            .collection('products')
            .add(payload);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomPad = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      margin: const EdgeInsets.only(top: 60),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface1 : Colors.white,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xxl)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              AppSpacing.xxl, 0, AppSpacing.xxl, bottomPad + 20),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 20),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.2)
                          : Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                ),
                // Title
                Text(
                  isEditing ? 'Edit Product' : 'Add Product',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                // Fields
                _FormField(
                  label: 'Product Name',
                  controller: _nameCtrl,
                  hint: 'e.g. iPhone 16 Pro',
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: _FormField(
                        label: 'Price (USD)',
                        controller: _priceCtrl,
                        hint: '999',
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Required';
                          }
                          if (int.tryParse(v.trim()) == null) {
                            return 'Enter a valid number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: _FormField(
                        label: 'Category',
                        controller: _categoryCtrl,
                        hint: 'iPhone',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _FormField(
                  label: 'Image URL',
                  controller: _imageCtrl,
                  hint: 'https://...',
                ),
                const SizedBox(height: AppSpacing.lg),
                _FormField(
                  label: 'Description',
                  controller: _descCtrl,
                  hint: 'Short product description...',
                  maxLines: 3,
                ),
                const SizedBox(height: AppSpacing.lg),
                // In Stock toggle
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurface2
                        : AppColors.lightGray,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'In Stock',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Switch.adaptive(
                        value: _inStock,
                        onChanged: (v) => setState(() => _inStock = v),
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                // Save button
                SizedBox(
                  height: 54,
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.xl),
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white),
                          )
                        : Text(
                            isEditing ? 'Save Changes' : 'Add Product',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Form field helper
// ─────────────────────────────────────────────────────────────────────────────

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _FormField({
    required this.label,
    required this.controller,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}