import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../widgets/freelancer_preview_card.dart';
import '../../../../data/models/freelancer.dart';
import '../../../../../mission/data/models/service_category.dart';
import '../../../../../profile/profile_provider.dart';
import '../../../../../client/presentation/pages/freelancer_profile_view.dart';

class FreelancersRow extends StatefulWidget {
  const FreelancersRow({super.key});

  @override
  State<FreelancersRow> createState() => _FreelancersRowState();
}

class _FreelancersRowState extends State<FreelancersRow> {
  static const _fallbackFreelancers = <_HomeFreelancerItem>[
    _HomeFreelancerItem(
      freelancer: Freelancer(
        name: 'Fatima',
        job: 'Ménage · Repassage',
        rating: 4.9,
        subtitle: 'Ménage · Repassage',
        imageUrl:
            'https://images.pexels.com/photos/1181686/pexels-photo-1181686.jpeg',
      ),
      missionsCount: 45,
      reviewsCount: 18,
    ),
    _HomeFreelancerItem(
      freelancer: Freelancer(
        name: 'Lucas',
        job: 'Bricolage · Montage',
        rating: 4.8,
        subtitle: 'Bricolage · Montage',
        imageUrl:
            'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg',
      ),
      missionsCount: 32,
      reviewsCount: 12,
    ),
    _HomeFreelancerItem(
      freelancer: Freelancer(
        name: 'Emma',
        job: 'Jardinage · Entretien',
        rating: 4.9,
        subtitle: 'Jardinage · Entretien',
        imageUrl:
            'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg',
      ),
      missionsCount: 30,
      reviewsCount: 14,
    ),
    _HomeFreelancerItem(
      freelancer: Freelancer(
        name: 'Karim',
        job: 'Plomberie · Électricité',
        rating: 4.7,
        subtitle: 'Plomberie · Électricité',
        imageUrl:
            'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg',
      ),
      missionsCount: 27,
      reviewsCount: 9,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProfileProvider>().loadFreelancers();
    });
  }

  Freelancer _fromRow(Map<String, dynamic> row) {
    final firstName = (row['first_name'] ?? '') as String;
    final lastName = (row['last_name'] ?? '') as String;
    final fullName = '$firstName $lastName'.trim();
    final hourlyRateRaw = row['hourly_rate'];
    final hourlyRate = hourlyRateRaw is num
        ? hourlyRateRaw.toInt()
        : int.tryParse('$hourlyRateRaw') ?? 0;
    final ratingRaw = row['rating'];
    final rating = ratingRaw is num ? ratingRaw.toDouble() : 0.0;
    final categoryNames = ServiceCategory.resolveNames(
      row['service_categories'],
    );
    return Freelancer(
      name: fullName.isEmpty ? 'Prestataire' : fullName,
      job: hourlyRate > 0 ? '$hourlyRate€/h' : 'Prestataire',
      rating: rating > 0 ? rating : 4.8,
      subtitle: categoryNames.isNotEmpty ? categoryNames.join(' · ') : '',
      imageUrl: (row['avatar_url'] ?? '') as String,
      isVerified: (row['is_verified'] ?? false) as bool,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final loaded = provider.freelancers
        .map(
          (row) => _HomeFreelancerItem(
            freelancer: _fromRow(row),
            freelancerId: row['id'] as String?,
            missionsCount: row['completed_missions'] is num
                ? (row['completed_missions'] as num).toInt()
                : int.tryParse('${row['completed_missions']}') ?? 0,
            reviewsCount: row['reviews_count'] is num
                ? (row['reviews_count'] as num).toInt()
                : int.tryParse('${row['reviews_count']}') ?? 0,
          ),
        )
        .toList(growable: false);
    final fallback = _fallbackFreelancers;
    final items = loaded.isEmpty ? fallback : loaded;
    final itemCount = items.length > 8 ? 8 : items.length;

    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          final f = item.freelancer;
          return FreelancerPreviewCard(
            freelancer: f,
            missionsCount: item.missionsCount,
            reviewsCount: item.reviewsCount,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FreelancerProfileView(
                  freelancerId: item.freelancerId,
                  freelancerName: f.name,
                  freelancerAvatar: f.imageUrl,
                  rating: f.rating,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HomeFreelancerItem {
  final Freelancer freelancer;
  final String? freelancerId;
  final int missionsCount;
  final int reviewsCount;

  const _HomeFreelancerItem({
    required this.freelancer,
    this.freelancerId,
    this.missionsCount = 0,
    this.reviewsCount = 0,
  });
}
