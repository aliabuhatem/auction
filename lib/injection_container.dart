// lib/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/auctions/data/datasources/auction_local_datasource.dart';
import 'features/auctions/data/datasources/auction_remote_datasource.dart';
import 'features/auctions/data/repositories/auction_repository_impl.dart';
import 'features/auctions/domain/repositories/auction_repository.dart';
import 'features/auctions/domain/usecases/get_auction_detail_usecase.dart';
import 'features/auctions/domain/usecases/get_auctions_usecase.dart';
import 'features/auctions/domain/usecases/place_bid_usecase.dart';
import 'features/auctions/domain/usecases/watch_auction_usecase.dart';
import 'features/auctions/domain/usecases/watch_auctions_usecase.dart';
import 'features/auctions/presentation/bloc/auction_list_bloc.dart';
import 'features/auctions/presentation/bloc/bidding_bloc.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/my_auctions/data/my_auctions_remote_datasource.dart';
import 'features/my_auctions/data/my_auctions_repository_impl.dart';
import 'features/my_auctions/domain/my_auctions_repository.dart';
import 'features/my_auctions/presentation/bloc/my_auctions_bloc.dart';
import 'features/notifications/notification_service.dart';
import 'features/profile/presentation/bloc/locale_bloc.dart';
import 'features/tickets/data/tickets_remote_datasource.dart';
import 'features/tickets/data/tickets_repository_impl.dart';
import 'features/tickets/domain/tickets_repository.dart';
import 'features/scratch_card/data/scratch_card_remote_datasource.dart';
import 'features/scratch_card/data/scratch_card_repository_impl.dart';
import 'features/scratch_card/domain/scratch_card_repository.dart';
import 'features/payment/data/payment_remote_datasource.dart';
import 'features/payment/data/payment_repository_impl.dart';
import 'features/payment/domain/payment_repository.dart';
import 'features/profile/data/profile_remote_datasource.dart';
import 'features/profile/data/profile_repository_impl.dart';
import 'features/profile/domain/profile_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ── External ─────────────────────────────────────────────────────────────────
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseAuth.instance);

  // ── Core ─────────────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => NotificationService());

  // ── Auth ─────────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(auth: sl(), firestore: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(datasource: sl()),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  // AuthBloc is a singleton so both app_router (GoRouterRefreshStream) and
  // the widget tree share the exact same instance and stream.
  sl.registerLazySingleton(() => AuthBloc(
        loginUseCase:    sl(),
        registerUseCase: sl(),
        logoutUseCase:   sl(),
        repository:      sl(),
      ));

  // ── Auctions ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuctionRemoteDatasource>(
    () => AuctionRemoteDatasourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<AuctionLocalDatasource>(
    () => AuctionLocalDatasourceImpl(prefs: sl()),
  );
  sl.registerLazySingleton<AuctionRepository>(
    () => AuctionRepositoryImpl(remote: sl(), local: sl()),
  );
  sl.registerLazySingleton(() => GetAuctionsUseCase(sl()));
  sl.registerLazySingleton(() => GetAuctionDetailUseCase(sl()));
  sl.registerLazySingleton(() => PlaceBidUseCase(sl()));
  sl.registerLazySingleton(() => WatchAuctionUseCase(sl()));
  sl.registerLazySingleton(() => WatchAuctionsUseCase(sl()));

  // ── My Auctions ───────────────────────────────────────────────────────────────
  sl.registerLazySingleton<MyAuctionsRemoteDatasource>(
    () => MyAuctionsRemoteDatasourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<MyAuctionsRepository>(
    () => MyAuctionsRepositoryImpl(remote: sl()),
  );

  // ── Tickets / Vouchers ───────────────────────────────────────────────────────
  sl.registerLazySingleton<TicketsRemoteDatasource>(
    () => TicketsRemoteDatasourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<TicketsRepository>(
    () => TicketsRepositoryImpl(datasource: sl()),
  );

  // ── Scratch Card ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<ScratchCardRemoteDatasource>(
    () => ScratchCardRemoteDatasourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<ScratchCardRepository>(
    () => ScratchCardRepositoryImpl(datasource: sl()),
  );

  // ── Payment ───────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<PaymentRemoteDatasource>(
    () => PaymentRemoteDatasourceImpl(),
  );
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(datasource: sl()),
  );

  // ── Profile ───────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<ProfileRemoteDatasource>(
    () => ProfileRemoteDatasourceImpl(firestore: sl(), auth: sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(datasource: sl()),
  );

  // ── BLoCs (factories — fresh instance per page) ───────────────────────────────
  sl.registerFactory(() => LocaleBloc(sl<SharedPreferences>()));

  sl.registerFactory(() => AuctionListBloc(
        getAuctions:   sl(),
        watchAuctions: sl(),
      ));

  sl.registerFactory(() => BiddingBloc(
        getAuctionDetail: sl(),
        placeBid:         sl(),
        watchAuction:     sl(),
        repository:       sl(),
      ));

  sl.registerFactory(() => MyAuctionsBloc(
        repository:        sl(),
        auctionRepository: sl(),
      ));
}
