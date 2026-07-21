String formatReviewDate(DateTime dt) {
  const months = [
    'jan.',
    'fev.',
    'mars',
    'avr.',
    'mai',
    'juin',
    'juil.',
    'aout',
    'sept.',
    'oct.',
    'nov.',
    'dec.',
  ];
  return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
}
