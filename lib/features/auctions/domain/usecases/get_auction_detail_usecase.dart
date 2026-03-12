import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auction_entity.dart';
import '../repositories/auction_repository.dart';

/// FIX: Missing GetAuctionDetailUseCase — created so injection_container
/// and the detail bloc can reference it without an "Undefined class" error.
class GetAuctionDetailUseCase
    implements UseCase<AuctionEntity, GetAuctionDetailParams> {
  final AuctionRepository repository;
  GetAuctionDetailUseCase(this.repository);

  @override
  Future<Either<Failure, AuctionEntity>> call(
          GetAuctionDetailParams params) =>
      repository.getAuctionById(params.id);
}

class GetAuctionDetailParams extends Equatable {
  final String id;
  const GetAuctionDetailParams({required this.id});

  @override
  List<Object> get props => [id];
}
