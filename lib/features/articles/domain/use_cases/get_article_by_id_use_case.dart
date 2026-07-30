import '../entities/article_entity.dart';
import '../repositories/article_repository.dart';

class GetArticleByIdUseCase {
  final ArticleRepository _repository;

  const GetArticleByIdUseCase(this._repository);

  Future<ArticleEntity> call({required int id}) {
    if (id <= 0) {
      throw const FormatException('Invalid article ID.');
    }

    return _repository.getArticleById(id: id);
  }
}
