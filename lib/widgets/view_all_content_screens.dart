import 'package:flutter/material.dart';
import 'package:thenew/widgets/dynamic_video_player.dart';

// ── 1. VIEW ALL VIDEOS SCREEN ────────────────────────────────────────────────
class ViewAllVideosScreen extends StatelessWidget {
  final List<dynamic> videos;
  final Color themeColor;

  const ViewAllVideosScreen({
    super.key,
    required this.videos,
    this.themeColor = const Color(0xff0EA5E9),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        title: const Text("All Training Videos", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: themeColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: videos.isEmpty
          ? const Center(child: Text("No training videos available.", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final v = videos[index];
                final title = v['title'] ?? "Video ${index + 1}";
                final desc = v['description'] ?? "";
                final videoUrl = v['video_url'] ?? "";

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3)),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    leading: Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.play_circle_filled_rounded, color: themeColor, size: 28),
                    ),
                    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xff1E293B))),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        desc.isNotEmpty ? desc : "Tap to watch video stream",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade400),
                    onTap: () {
                      DynamicVideoPlayerModal.show(
                        context,
                        title: title,
                        description: desc,
                        videoUrl: videoUrl,
                        themeColor: themeColor,
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

// ── 2. VIEW ALL TESTIMONIALS SCREEN ──────────────────────────────────────────
class ViewAllTestimonialsScreen extends StatelessWidget {
  final List<dynamic> testimonials;
  final Color themeColor;

  const ViewAllTestimonialsScreen({
    super.key,
    required this.testimonials,
    this.themeColor = const Color(0xff0EA5E9),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        title: const Text("All Testimonials", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: themeColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: testimonials.isEmpty
          ? const Center(child: Text("No testimonials available.", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: testimonials.length,
              itemBuilder: (context, index) {
                final t = testimonials[index];
                final name = t['name'] ?? "Anonymous";
                final role = t['role'] ?? "";
                final message = t['message'] ?? "";
                final rating = int.tryParse(t['rating']?.toString() ?? '5') ?? 5;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: themeColor.withOpacity(0.12),
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : "?",
                              style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xff1E293B))),
                                if (role.isNotEmpty)
                                  Text(role, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                              ],
                            ),
                          ),
                          Row(
                            children: List.generate(
                              5,
                              (i) => Icon(
                                i < rating ? Icons.star_rounded : Icons.star_border_rounded,
                                color: const Color(0xffF59E0B),
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        message,
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 14, height: 1.4),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

// ── 3. VIEW ALL FAQS SCREEN ──────────────────────────────────────────────────
class ViewAllFaqsScreen extends StatelessWidget {
  final List<dynamic> faqs;
  final Color themeColor;

  const ViewAllFaqsScreen({
    super.key,
    required this.faqs,
    this.themeColor = const Color(0xff0EA5E9),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        title: const Text("All FAQs", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: themeColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: faqs.isEmpty
          ? const Center(child: Text("No FAQs available.", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: faqs.length,
              itemBuilder: (context, index) {
                final f = faqs[index];
                final question = f['question'] ?? "";
                final answer = f['answer'] ?? "";

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
                    ],
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      leading: Icon(Icons.help_outline_rounded, color: themeColor, size: 22),
                      title: Text(
                        question,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xff1E293B)),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              answer,
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.45),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ── 4. VIEW ALL GALLERY SCREEN ────────────────────────────────────────────────
class ViewAllGalleryScreen extends StatelessWidget {
  final List<dynamic> photos;
  final Color themeColor;

  const ViewAllGalleryScreen({
    super.key,
    required this.photos,
    this.themeColor = const Color(0xff0EA5E9),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        title: const Text("Photo Gallery", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: themeColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: photos.isEmpty
          ? const Center(child: Text("No gallery photos available.", style: TextStyle(color: Colors.grey)))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.95,
              ),
              itemCount: photos.length,
              itemBuilder: (context, index) {
                final p = photos[index];
                final title = p['title'] ?? "";
                final imageUrl = p['image_url'] ?? "";

                return GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 200,
                                  color: Colors.grey.shade200,
                                  child: const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 40)),
                                ),
                              ),
                            ),
                            if (title.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.network(
                              imageUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: themeColor.withOpacity(0.08),
                                child: Center(child: Icon(Icons.image_outlined, color: themeColor, size: 36)),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            title.isNotEmpty ? title : "Gallery Photo",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ── 5. VIEW ALL PROGRAMS SCREEN (WITH DEMO & FULL DEMO VIDEO BUTTONS) ─────────
class ViewAllProgramsScreen extends StatelessWidget {
  final List<dynamic> programs;
  final Color themeColor;

  const ViewAllProgramsScreen({
    super.key,
    required this.programs,
    this.themeColor = const Color(0xff0EA5E9),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        title: const Text("Our Programs & Demos", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: themeColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: programs.isEmpty
          ? const Center(child: Text("No programs available.", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: programs.length,
              itemBuilder: (context, index) {
                final p = programs[index];
                final title = p['title'] ?? "Program ${index + 1}";
                final desc = p['description'] ?? "";
                final demoUrl = p['demo_video_url'] ?? "";
                final fullDemoUrl = p['full_demo_video_url'] ?? "";

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: themeColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(Icons.school_rounded, color: themeColor, size: 26),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xff1E293B)),
                            ),
                          ),
                        ],
                      ),
                      if (desc.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(desc, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4)),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          if (demoUrl.isNotEmpty)
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: themeColor),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                                onPressed: () {
                                  DynamicVideoPlayerModal.show(
                                    context,
                                    title: "$title - Demo Video",
                                    description: desc,
                                    videoUrl: demoUrl,
                                    themeColor: themeColor,
                                  );
                                },
                                icon: Icon(Icons.play_arrow_rounded, color: themeColor, size: 18),
                                label: Text("Watch Demo", style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ),
                          if (demoUrl.isNotEmpty && fullDemoUrl.isNotEmpty)
                            const SizedBox(width: 10),
                          if (fullDemoUrl.isNotEmpty)
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: themeColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  DynamicVideoPlayerModal.show(
                                    context,
                                    title: "$title - Full Demo Video",
                                    description: desc,
                                    videoUrl: fullDemoUrl,
                                    themeColor: themeColor,
                                  );
                                },
                                icon: const Icon(Icons.play_circle_filled_rounded, color: Colors.white, size: 18),
                                label: const Text("Full Demo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

// ── 6. ANNOUNCEMENT / CIRCULAR DETAILS DIALOG ─────────────────────────────────
void showCircularDetailsDialog(BuildContext context, Map<String, dynamic> circular) {
  final title = circular['title'] ?? "Announcement";
  final message = circular['message'] ?? "";
  final createdAt = circular['created_at'] != null ? circular['created_at'].toString().split(' ')[0] : "";
  final target = circular['target_roles'] ?? "All";

  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xffFF1493).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.campaign_rounded, color: Color(0xffFF1493), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xff1E293B))),
                      if (createdAt.isNotEmpty)
                        Text(createdAt, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              message,
              style: TextStyle(color: Colors.grey.shade800, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text("Target: $target", style: TextStyle(color: Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2563EB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Close", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
