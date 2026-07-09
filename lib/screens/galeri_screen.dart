import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/app_drawer.dart';
import '../widgets/modern_app_bar.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';

class GaleriScreen extends StatefulWidget {
  const GaleriScreen({super.key});

  @override
  State<GaleriScreen> createState() => _GaleriScreenState();
}

class _GaleriScreenState extends State<GaleriScreen> {
  final FirestoreService _db = FirestoreService();

  void _showDetail(GaleriModel item) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                image: item.gambarUrl.isNotEmpty
                    ? DecorationImage(image: NetworkImage(item.gambarUrl), fit: BoxFit.cover)
                    : null,
              ),
              child: item.gambarUrl.isEmpty
                  ? const Center(child: Icon(Icons.photo_library_rounded, size: 60, color: AppColors.accentGreen))
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.judul, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(item.deskripsi, style: const TextStyle(fontSize: 13, color: AppColors.textGrey, height: 1.5)),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(color: AppColors.primaryGreen, borderRadius: BorderRadius.circular(10)),
                      child: const Center(child: Text('Tutup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGreen,
      appBar: ModernAppBar(title: 'Galeri Kegiatan'),
      drawer: const AppDrawer(currentRoute: '/galeri'),
      body: StreamBuilder<List<GaleriModel>>(
        stream: _db.streamGaleri(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
          }
          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(
              child: Text('Belum ada foto galeri', style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.82,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items[i];
                return GestureDetector(
                  onTap: () => _showDetail(item),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.lightGreen,
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
                              image: item.gambarUrl.isNotEmpty
                                  ? DecorationImage(image: NetworkImage(item.gambarUrl), fit: BoxFit.cover)
                                  : null,
                            ),
                            child: item.gambarUrl.isEmpty
                                ? Center(child: Icon(Icons.photo_library_rounded, size: 44, color: AppColors.accentGreen.withOpacity(0.8)))
                                : null,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.judul,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                item.deskripsi,
                                style: const TextStyle(fontSize: 10.5, color: AppColors.textGrey, height: 1.4),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
