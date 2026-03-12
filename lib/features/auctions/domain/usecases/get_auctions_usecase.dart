import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auction_entity.dart';
import '../repositories/auction_repository.dart';

class GetAuctionsUseCase implements UseCase<List<AuctionEntity>, GetAuctionsParams> {
  final AuctionRepository repository;
  GetAuctionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<AuctionEntity>>> call(GetAuctionsParams params) =>
      repository.getAuctions(category: params.category, searchQuery: params.query, page: params.page);
}

class GetAuctionsParams extends Equatable {
  final AuctionCategory? category;
  final String? query;
  final int page;
  const GetAuctionsParams({this.category, this.query, this.page = 1});
  @override
  List<Object?> get props => [category, query, page];
}
