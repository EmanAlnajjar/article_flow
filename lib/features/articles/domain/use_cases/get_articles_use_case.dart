import '../entities/article_page_entity.dart';
import '../repositories/article_repository.dart';
import 'article_params.dart';

class GetArticlesUseCase {
  final ArticleRepository _repository;

  const GetArticlesUseCase(this._repository);

  Future<ArticlePageEntity> call(PaginationParams params) {
    return _repository.getArticles(limit: params.limit, skip: params.skip);
  }
}
