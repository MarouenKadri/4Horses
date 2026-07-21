import '../models/mission.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 📊 Inkern - Données de Démonstration
/// ═══════════════════════════════════════════════════════════════════════════

class MissionDemoData {
  static final DateTime _now = DateTime.now();

  // ─── Missions disponibles (vue Freelancer) ────────────────────────────────

  static List<Mission> getAvailableMissions() => [
    Mission(
      id: 'M-2854',
      title: 'Ménage appartement 3 pièces',
      description:
          'Nettoyage complet cuisine, salon et chambre. Produits fournis. Appartement de 65m² au 3ème étage avec ascenseur.',
      categoryId: 'menage',
      date: _now.add(const Duration(days: 3)),
      timeSlot: '14h00 - 17h00',
      address: const MissionAddress(
        fullAddress: '15 rue de la Paix, 75011 Paris',
        shortAddress: 'Paris 11e',
        distance: '2.3 km',
      ),
      budget: const BudgetInfo(type: BudgetType.fixed, amount: 45),
      status: MissionStatus.candidateReceived,
      images: [
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800',
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800',
      ],
      createdAt: _now.subtract(const Duration(hours: 2)),
      client: const ClientInfo(
        id: 'C-001',
        name: 'Marie L.',
        avatarUrl: 'https://i.pravatar.cc/150?img=1',
        rating: 4.8,
        missionsCount: 12,
        isVerified: true,
      ),
      candidatesCount: 5,
    ),
    Mission(
      id: 'M-2855',
      title: 'Réparation fuite robinet cuisine',
      description:
          'Fuite sous l\'évier, joint à changer probablement. Accès facile sous l\'évier.',
      categoryId: 'plomberie',
      date: _now,
      timeSlot: '10h00 - 11h00',
      address: const MissionAddress(
        fullAddress: '8 avenue Victor Hugo, 75016 Paris',
        shortAddress: 'Paris 16e',
        distance: '4.1 km',
      ),
      budget: const BudgetInfo(type: BudgetType.fixed, amount: 50),
      status: MissionStatus.confirmed,
      createdAt: _now.subtract(const Duration(hours: 1)),
      client: const ClientInfo(
        id: 'C-002',
        name: 'Jean P.',
        avatarUrl: 'https://i.pravatar.cc/150?img=3',
        rating: 4.5,
        missionsCount: 5,
      ),
      candidatesCount: 3,
      assignedPresta: const PrestaInfo(
        id: 'P-001',
        name: 'Marc Dupont',
        avatarUrl: 'https://i.pravatar.cc/150?img=12',
        rating: 4.8,
        reviewsCount: 47,
        completedMissions: 156,
        isVerified: true,
      ),
    ),
    Mission(
      id: 'M-2856',
      title: 'Taille de haies et tonte pelouse',
      description:
          'Jardin de 50m², haies à tailler sur 10m. Évacuation des déchets verts comprise.',
      categoryId: 'jardinage',
      date: _now.add(const Duration(days: 4)),
      timeSlot: '09h00 - 12h00',
      address: const MissionAddress(
        fullAddress: '22 rue des Jardins, 75015 Paris',
        shortAddress: 'Paris 15e',
        distance: '3.5 km',
      ),
      budget: const BudgetInfo(type: BudgetType.fixed, amount: 80),
      status: MissionStatus.waitingCandidates,
      images: [
        'https://images.unsplash.com/photo-1558904541-efa843a96f01?w=800',
      ],
      createdAt: _now.subtract(const Duration(minutes: 30)),
      client: const ClientInfo(
        id: 'C-003',
        name: 'Pierre D.',
        avatarUrl: 'https://i.pravatar.cc/150?img=8',
        rating: 4.5,
        missionsCount: 5,
        isVerified: true,
      ),
      candidatesCount: 2,
    ),
    Mission(
      id: 'M-2857',
      title: 'Montage meubles IKEA (3 meubles)',
      description:
          'Montage d\'une armoire PAX, une commode MALM et un lit HEMNES. Meubles déjà livrés.',
      categoryId: 'bricolage',
      date: _now.add(const Duration(days: 2)),
      timeSlot: '14h00 - 18h00',
      address: const MissionAddress(
        fullAddress: '45 boulevard Saint-Michel, 75005 Paris',
        shortAddress: 'Paris 5e',
        distance: '1.8 km',
      ),
      budget: const BudgetInfo(type: BudgetType.fixed, amount: 100),
      status: MissionStatus.candidateReceived,
      images: [
        'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800',
      ],
      createdAt: _now.subtract(const Duration(hours: 3)),
      client: const ClientInfo(
        id: 'C-004',
        name: 'Sophie M.',
        avatarUrl: 'https://i.pravatar.cc/150?img=25',
        rating: 4.9,
        missionsCount: 3,
      ),
      candidatesCount: 6,
    ),
    Mission(
      id: 'M-2858',
      title: 'Garde chat pendant vacances',
      description:
          'Garde d\'un chat adulte calme pendant 1 semaine. Passages matin et soir.',
      categoryId: 'petsitting',
      date: _now.add(const Duration(days: 9)),
      timeSlot: 'Matin et soir',
      address: const MissionAddress(
        fullAddress: '3 rue de Provence, 75009 Paris',
        shortAddress: 'Paris 9e',
        distance: '2.1 km',
      ),
      budget: const BudgetInfo(type: BudgetType.fixed, amount: 120),
      status: MissionStatus.waitingCandidates,
      images: [
        'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=800',
      ],
      createdAt: _now.subtract(const Duration(hours: 5)),
      client: const ClientInfo(
        id: 'C-005',
        name: 'Emma B.',
        avatarUrl: 'https://i.pravatar.cc/150?img=32',
        rating: 4.9,
        missionsCount: 8,
        isVerified: true,
      ),
      candidatesCount: 4,
    ),
  ];

  // ─── Missions du client ───────────────────────────────────────────────────

  static List<Mission> getClientMissions() => [
    Mission(
      id: 'M-C-001',
      title: 'Nettoyage fin de chantier',
      description:
          'Appartement neuf de 80m² à nettoyer après travaux. Poussière, traces de peinture, vitres.',
      categoryId: 'menage',
      date: _now.add(const Duration(days: 2)),
      timeSlot: '09h00 - 14h00',
      address: const MissionAddress(
        fullAddress: '25 rue des Lilas, 75011 Paris',
        shortAddress: 'Paris 11e',
      ),
      budget: const BudgetInfo(type: BudgetType.fixed, amount: 120),
      status: MissionStatus.candidateReceived,
      images: [
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800',
      ],
      createdAt: _now.subtract(const Duration(hours: 6)),
      candidatesCount: 7,
    ),
    Mission(
      id: 'M-C-002',
      title: 'Déménagement petit volume',
      description: 'Studio de 25m² à déménager dans le même arrondissement.',
      categoryId: 'demenagement',
      date: _now.add(const Duration(days: 5)),
      timeSlot: '08h00 - 12h00',
      address: const MissionAddress(
        fullAddress: '8 allée des Roses, 75015 Paris',
        shortAddress: 'Paris 15e',
      ),
      budget: const BudgetInfo(type: BudgetType.fixed, amount: 150),
      status: MissionStatus.waitingCandidates,
      createdAt: _now.subtract(const Duration(hours: 2)),
      candidatesCount: 0,
    ),
    Mission(
      id: 'M-C-003',
      title: 'Installation climatisation',
      description: 'Pose d\'un climatiseur split dans le salon.',
      categoryId: 'electricite',
      date: _now.add(const Duration(days: 7)),
      timeSlot: '14h00 - 18h00',
      address: const MissionAddress(
        fullAddress: '25 rue des Lilas, 75011 Paris',
        shortAddress: 'Paris 11e',
      ),
      budget: const BudgetInfo(type: BudgetType.fixed, amount: 250),
      status: MissionStatus.confirmed,
      createdAt: _now.subtract(const Duration(days: 2)),
      candidatesCount: 4,
      assignedPresta: const PrestaInfo(
        id: 'P-001',
        name: 'Marc Dupont',
        avatarUrl: 'https://i.pravatar.cc/150?img=12',
        rating: 4.8,
        reviewsCount: 47,
        isVerified: true,
        acceptedPrice: '300 €',
      ),
    ),
  ];

  // ─── Missions terminées ───────────────────────────────────────────────────

  static List<Mission> getCompletedMissions() => [
    Mission(
      id: 'M-C-010',
      title: 'Réparation plomberie salle de bain',
      description: 'Fuite au niveau du siphon de la douche.',
      categoryId: 'plomberie',
      date: _now.subtract(const Duration(days: 5)),
      timeSlot: '10h00 - 12h00',
      address: const MissionAddress(
        fullAddress: '25 rue des Lilas, 75011 Paris',
        shortAddress: 'Paris 11e',
      ),
      budget: const BudgetInfo(type: BudgetType.fixed, amount: 80),
      status: MissionStatus.closed,
      createdAt: _now.subtract(const Duration(days: 8)),
      candidatesCount: 3,
      assignedPresta: const PrestaInfo(
        id: 'P-002',
        name: 'Sophie Laurent',
        avatarUrl: 'https://i.pravatar.cc/150?img=5',
        rating: 4.9,
        reviewsCount: 112,
        isVerified: true,
        acceptedPrice: '80 €',
      ),
      rating: 5,
    ),
  ];

  // ─── Brouillons ───────────────────────────────────────────────────────────

  static List<Mission> getDraftMissions() => [
    Mission(
      id: 'M-DRAFT-1',
      title: 'Cours de piano à domicile',
      description:
          'Débutant adulte souhaitant apprendre les bases. 1h par semaine.',
      categoryId: 'cours',
      date: _now.add(const Duration(days: 7)),
      timeSlot: '',
      address: const MissionAddress(
        fullAddress: '25 rue des Lilas, 75011 Paris',
        shortAddress: 'Paris 11e',
      ),
      budget: const BudgetInfo(
        type: BudgetType.hourly,
        amount: 30,
        estimatedHours: 1,
      ),
      status: MissionStatus.draft,
      createdAt: _now.subtract(const Duration(days: 3)),
      candidatesCount: 0,
    ),
  ];

  // ─── Missions du freelancer connecté ──────────────────────────────────────

  static List<Mission> getFreelancerMissions() => [
    // ── Postulées ─────────────────────────────────────────────────────────
    Mission(
      id: 'M-2854',
      title: 'Ménage appartement 3 pièces',
      description:
          'Nettoyage complet cuisine, salon et chambre. Produits fournis.',
      categoryId: 'menage',
      date: _now.add(const Duration(days: 3)),
      timeSlot: '14h00 - 17h00',
      address: const MissionAddress(
        fullAddress: '15 rue de la Paix, 75011 Paris',
        shortAddress: 'Paris 11e',
        distance: '2.3 km',
      ),
      budget: const BudgetInfo(type: BudgetType.fixed, amount: 45),
      status: MissionStatus.candidateReceived,
      images: [
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800',
      ],
      createdAt: _now.subtract(const Duration(hours: 4)),
      client: const ClientInfo(
        id: 'C-001',
        name: 'Marie L.',
        avatarUrl: 'https://i.pravatar.cc/150?img=1',
        rating: 4.8,
        missionsCount: 12,
        isVerified: true,
      ),
      candidatesCount: 5,
    ),
    Mission(
      id: 'M-2857',
      title: 'Montage meubles IKEA (3 meubles)',
      description:
          'Montage d\'une armoire PAX, une commode MALM et un lit HEMNES.',
      categoryId: 'bricolage',
      date: _now.add(const Duration(days: 2)),
      timeSlot: '14h00 - 18h00',
      address: const MissionAddress(
        fullAddress: '45 boulevard Saint-Michel, 75005 Paris',
        shortAddress: 'Paris 5e',
        distance: '1.8 km',
      ),
      budget: const BudgetInfo(type: BudgetType.fixed, amount: 100),
      status: MissionStatus.candidateReceived,
      images: [
        'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800',
      ],
      createdAt: _now.subtract(const Duration(hours: 6)),
      client: const ClientInfo(
        id: 'C-004',
        name: 'Sophie M.',
        avatarUrl: 'https://i.pravatar.cc/150?img=25',
        rating: 4.9,
        missionsCount: 3,
      ),
      candidatesCount: 6,
    ),
    // ── En cours ──────────────────────────────────────────────────────────
    Mission(
      id: 'M-C-003',
      title: 'Installation climatisation',
      description: 'Pose d\'un climatiseur split dans le salon.',
      categoryId: 'electricite',
      date: _now.add(const Duration(days: 7)),
      timeSlot: '14h00 - 18h00',
      address: const MissionAddress(
        fullAddress: '25 rue des Lilas, 75011 Paris',
        shortAddress: 'Paris 11e',
        distance: '1.2 km',
      ),
      budget: const BudgetInfo(type: BudgetType.fixed, amount: 250),
      status: MissionStatus.confirmed,
      createdAt: _now.subtract(const Duration(days: 2)),
      client: const ClientInfo(
        id: 'C-CLIENT',
        name: 'Thomas R.',
        avatarUrl: 'https://i.pravatar.cc/150?img=11',
        rating: 4.7,
        missionsCount: 7,
        isVerified: true,
      ),
      candidatesCount: 4,
      assignedPresta: const PrestaInfo(
        id: 'ME',
        name: 'Moi',
        avatarUrl: '',
        rating: 4.8,
        reviewsCount: 32,
        isVerified: true,
        acceptedPrice: '300 €',
      ),
    ),
    Mission(
      id: 'M-F-EC02',
      title: 'Réparation fuite robinet cuisine',
      description: 'Fuite sous l\'évier, joint à remplacer.',
      categoryId: 'plomberie',
      date: _now,
      timeSlot: '10h00 - 11h00',
      address: const MissionAddress(
        fullAddress: '8 avenue Victor Hugo, 75016 Paris',
        shortAddress: 'Paris 16e',
        distance: '4.1 km',
      ),
      budget: const BudgetInfo(type: BudgetType.fixed, amount: 65),
      status: MissionStatus.confirmed,
      createdAt: _now.subtract(const Duration(days: 1)),
      client: const ClientInfo(
        id: 'C-002',
        name: 'Jean P.',
        avatarUrl: 'https://i.pravatar.cc/150?img=3',
        rating: 4.5,
        missionsCount: 5,
      ),
      candidatesCount: 3,
      assignedPresta: const PrestaInfo(
        id: 'ME',
        name: 'Moi',
        avatarUrl: '',
        rating: 4.8,
        reviewsCount: 32,
        isVerified: true,
        acceptedPrice: '65 €',
      ),
    ),
    // ── Archivées ─────────────────────────────────────────────────────────
    Mission(
      id: 'M-F-A01',
      title: 'Nettoyage fin de chantier',
      description: 'Appartement neuf de 80m² nettoyé après travaux.',
      categoryId: 'menage',
      date: _now.subtract(const Duration(days: 5)),
      timeSlot: '09h00 - 14h00',
      address: const MissionAddress(
        fullAddress: '25 rue des Lilas, 75011 Paris',
        shortAddress: 'Paris 11e',
      ),
      budget: const BudgetInfo(type: BudgetType.fixed, amount: 135),
      status: MissionStatus.closed,
      images: [
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800',
      ],
      createdAt: _now.subtract(const Duration(days: 8)),
      client: const ClientInfo(
        id: 'C-007',
        name: 'Claire B.',
        avatarUrl: 'https://i.pravatar.cc/150?img=20',
        rating: 5.0,
        missionsCount: 4,
        isVerified: true,
      ),
      candidatesCount: 4,
      assignedPresta: const PrestaInfo(
        id: 'ME',
        name: 'Moi',
        avatarUrl: '',
        rating: 4.8,
        reviewsCount: 32,
        isVerified: true,
        acceptedPrice: '135 €',
      ),
      rating: 5,
    ),
    Mission(
      id: 'M-F-A02',
      title: 'Garde chat pendant vacances',
      description: 'Garde d\'un chat adulte calme pendant 1 semaine.',
      categoryId: 'petsitting',
      date: _now.subtract(const Duration(days: 12)),
      timeSlot: 'Matin et soir',
      address: const MissionAddress(
        fullAddress: '3 rue de Provence, 75009 Paris',
        shortAddress: 'Paris 9e',
      ),
      budget: const BudgetInfo(type: BudgetType.fixed, amount: 140),
      status: MissionStatus.closed,
      images: [
        'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=800',
      ],
      createdAt: _now.subtract(const Duration(days: 15)),
      client: const ClientInfo(
        id: 'C-005',
        name: 'Emma B.',
        avatarUrl: 'https://i.pravatar.cc/150?img=32',
        rating: 4.9,
        missionsCount: 8,
        isVerified: true,
      ),
      candidatesCount: 4,
      assignedPresta: const PrestaInfo(
        id: 'ME',
        name: 'Moi',
        avatarUrl: '',
        rating: 4.8,
        reviewsCount: 32,
        isVerified: true,
        acceptedPrice: '140 €',
      ),
      rating: 4,
    ),
  ];
}
