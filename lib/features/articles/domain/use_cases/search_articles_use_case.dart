import '../entities/article_page_entity.dart';
import '../repositories/article_repository.dart';
import 'article_params.dart';

class SearchArticlesUseCase {
  final ArticleRepository _repository;

  const SearchArticlesUseCase(this._repository);

  Future<ArticlePageEntity> call(SearchArticlesParams params) {
    return _repository.searchArticles(
      query: params.query,
      limit: params.limit,
      skip: params.skip,
    );
  }
}
