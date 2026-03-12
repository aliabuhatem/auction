// Place bid use case

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auction_repository.dart';

class PlaceBidUseCase implements UseCase<bool, PlaceBidParams> {
  final AuctionRepository repository;
  PlaceBidUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(PlaceBidParams params) async {
    return await repository.placeBid(
      auctionId: params.auctionId,
      bidAmount: params.bidAmount,
    );
  }
}

class PlaceBidParams extends Equatable {
  final String auctionId;
  final double bidAmount;
  const PlaceBidParams({required this.auctionId, required this.bidAmount});

  @override
  List<Object> get props => [auctionId, bidAmount];
}