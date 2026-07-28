class ArticleImages {
  ArticleImages._();

  static const List<String> _images = [
    'https://images.unsplash.com/photo-1499750310107-5fef28a66643'
        '?auto=format&fit=crop&w=900&q=80',
    'https://images.unsplash.com/photo-1455390582262-044cdead277a'
        '?auto=format&fit=crop&w=900&q=80',
    'https://images.unsplash.com/photo-1481627834876-b7833e8f5570'
        '?auto=format&fit=crop&w=900&q=80',
    'https://images.unsplash.com/photo-1504711434969-e33886168f5c'
        '?auto=format&fit=crop&w=900&q=80',
    'https://images.unsplash.com/photo-1516321318423-f06f85e504b3'
        '?auto=format&fit=crop&w=900&q=80',
    'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f'
        '?auto=format&fit=crop&w=900&q=80',
    'https://images.unsplash.com/photo-1495446815901-a7297e633e8d'
        '?auto=format&fit=crop&w=900&q=80',
    'https://images.unsplash.com/photo-1471107340929-a87cd0f5b5f3'
        '?auto=format&fit=crop&w=900&q=80',
    'https://images.unsplash.com/photo-1434030216411-0b793f4b4173'
        '?auto=format&fit=crop&w=900&q=80',
    'https://images.unsplash.com/photo-1491841550275-ad7854e35ca6'
        '?auto=format&fit=crop&w=900&q=80',
  ];

  static String getForArticle(int articleId) {
    if (_images.isEmpty) {
      return '';
    }

    final index = articleId.abs() % _images.length;

    return _images[index];
  }
}