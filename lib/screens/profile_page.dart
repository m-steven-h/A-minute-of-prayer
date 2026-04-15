import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/theme_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = 'مستخدم دقيقة صلاة';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'مستخدم دقيقة صلاة';
    });
  }

  Future<void> _saveUserData(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, provider, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: provider.backgroundColor,
            body: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 20),

                      // بطاقة الملف الشخصي
                      _buildProfileCard(provider),

                      const SizedBox(height: 20),

                      // زر تعديل الملف الشخصي
                      _buildEditButton(provider),

                      const SizedBox(height: 40),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileCard(ThemeProvider provider) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF4ADE80), Color(0xFF22C55E)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4ADE80).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Text(
              _userName,
              style: GoogleFonts.cairo(
                fontSize: 28 * provider.fontScale,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'عضو في دقيقة صلاة',
                style: GoogleFonts.cairo(
                  fontSize: 14 * provider.fontScale,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditButton(ThemeProvider provider) {
    return GestureDetector(
      onTap: () => _showEditDialog(context, provider),
      child: Container(
        decoration: BoxDecoration(
          color: provider.cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF4ADE80).withOpacity(0.15),
                      const Color(0xFF4ADE80).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  color: Color(0xFF4ADE80),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'تعديل اسم المستخدم',
                  style: GoogleFonts.cairo(
                    fontSize: 18 * provider.fontScale,
                    fontWeight: FontWeight.w600,
                    color: provider.textColor,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: const Color(0xFF4ADE80),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, ThemeProvider provider) {
    final TextEditingController controller =
        TextEditingController(text: _userName);

    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: provider.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Text(
              'تعديل الاسم',
              style: GoogleFonts.cairo(
                color: provider.textColor,
                fontWeight: FontWeight.bold,
                fontSize: 20 * provider.fontScale,
              ),
            ),
            content: TextField(
              controller: controller,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.cairo(
                fontSize: 16 * provider.fontScale,
                color: provider.textColor,
              ),
              decoration: InputDecoration(
                hintText: 'أدخل اسمك',
                hintStyle: GoogleFonts.cairo(
                  fontSize: 14 * provider.fontScale,
                  color: provider.secondaryTextColor,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: const Color(0xFF4ADE80).withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: const Color(0xFF4ADE80).withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFF4ADE80),
                    width: 2,
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'إلغاء',
                  style: GoogleFonts.cairo(
                    fontSize: 16 * provider.fontScale,
                    color: Colors.grey,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    _saveUserData(controller.text.trim());
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'تم تحديث الاسم بنجاح',
                          style: GoogleFonts.cairo(
                            fontSize: 14 * provider.fontScale,
                          ),
                        ),
                        backgroundColor: const Color(0xFF4ADE80),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4ADE80),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'حفظ',
                  style: GoogleFonts.cairo(
                    fontSize: 16 * provider.fontScale,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
