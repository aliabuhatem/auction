// lib/features/recent/data/recent_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/errors/failures.dart';
import '../../auctions/domain/entities/auction_entity.dart';
import '../domain/recent_repository.dart';
import 'recent_remote_datasource.dart';

class RecentRepositoryImpl implements RecentRepository {
  final RecentRemoteDatasource remote;
  final FirebaseAuth auth;

  RecentRepositoryImpl({required this.remote, required this.auth});

  String? get _uid => auth.currentUser?.uid;

  @override
  Future<void> recordView(AuctionEntity auction) async {
    final uid = _uid;
    if (uid == null) return;
    // Best-effort side effect — never surface errors to the detail view.
    try {
      await remote.recordView(uid, auction);
    } catch (_) {/* ignore */}
  }

  @override
  Future<Either<Failure, List<AuctionEntity>>> getRecent() async {
    final uid = _uid;
    if (uid == null) return const Right([]);
    try {
      final result = await remote.getRecent(uid);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> clear() async {
    final uid = _uid;
    if (uid == null) return const Right(true);
    try {
      await remote.clear(uid);
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
