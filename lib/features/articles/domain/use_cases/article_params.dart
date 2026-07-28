import 'package:equatable/equatable.dart';

class PaginationParams extends Equatable {
  final int limit;
  final int skip;

  const PaginationParams({required this.limit, required this.skip});

  @override
  List<Object?> get props => [limit, skip];
}

class SearchArticlesParams extends PaginationParams {
  final String query;

  const SearchArticlesParams({
    required this.query,
    required super.limit,
    required super.skip,
  });

  @override
  List<Object?> get props => [...super.props, query];
}
